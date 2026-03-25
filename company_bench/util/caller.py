import asyncio
import os

import litellm
import tenacity
from dataclasses import dataclass
from loguru import logger

litellm.suppress_debug_info = True

######################################## CallerConfig
@dataclass
class CallerConfig:
    model_id: str
    max_concurrency: int
    api_base: str = "https://openai.app.msh.team/v1"
    api_key: str | None = None
    timeout: int | None = None
    max_retries: int | None = None

######################################## ModelChoiceConfig
@dataclass
class ModelChoiceConfig:
    temperature: float
    max_tokens: int
    n: int

def _get_real_call_model_id(
    model_id: str
) -> str:
    if '|' in model_id:
        return model_id.split('|')[0]
    else:
        return model_id

class OpenAICaller(object):
    def __init__(
        self,
        caller_config: CallerConfig
    ) -> None:
        self.model_id = caller_config.model_id
        self.max_concurrency = caller_config.max_concurrency
        self.timeout = caller_config.timeout
        self.max_retries = caller_config.max_retries
        self.api_base = caller_config.api_base
        self.api_key = caller_config.api_key or os.environ.get("OPENAI_API_KEY")

        self.semaphore = asyncio.Semaphore(
            value=self.max_concurrency
        )
        logger.info(f'Initialize OpenAICaller (litellm): model={self.model_id}, concurrency={self.max_concurrency}, api_base={self.api_base}')

    async def _call(
        self,
        id: str,
        messages: list[dict],
        *,
        temperature: float | None = None,
        max_tokens: int | None = None,
        n: int | None = None,
    ) -> dict:
        """调用 LLM，返回完整响应 dict，包含 choices、usage、model 等。

        失败时按 max_retries 重试，使用指数退避（1s, 2s, 4s, ...）。

        返回格式:
            {
                "choices": [{"finish_reason": "stop", "message": {"role": "assistant", "content": "..."}}],
                "usage": {"prompt_tokens": ..., "completion_tokens": ..., "total_tokens": ...},
                "model": "...",
            }
        """
        _log_prefix = f'>> {self.model_id}, {id}, n={n}, temp={temperature}, max_tokens={max_tokens}'

        retrier = tenacity.AsyncRetrying(
            stop=tenacity.stop_never if self.max_retries is None else tenacity.stop_after_attempt(max(1, self.max_retries)),
            wait=tenacity.wait_fixed(1),
            before_sleep=lambda rs: logger.warning(
                f'Retry {rs.attempt_number} {_log_prefix}: {rs.outcome.exception()}'
            ),
            reraise=True,
        )

        async with self.semaphore:
            async for attempt in retrier:
                with attempt:
                    logger.info(f'Call {_log_prefix} (attempt {attempt.retry_state.attempt_number})')

                    real_model_id = _get_real_call_model_id(self.model_id)
                    response = await litellm.acompletion(
                        model=f"openai/{real_model_id}",
                        messages=messages,
                        api_base=self.api_base,
                        api_key=self.api_key,
                        temperature=temperature,
                        max_tokens=max_tokens,
                        n=n,
                        timeout=self.timeout,
                    )

                    result = response.model_dump()
                    usage = result.get('usage', {})
                    cached = (usage.get('prompt_tokens_details') or {}).get('cached_tokens', 0)
                    logger.info(
                        f'Success {_log_prefix} (attempt {attempt.retry_state.attempt_number}) '
                        f'prompt={usage.get("prompt_tokens")}, cached={cached}, comp={usage.get("completion_tokens")}'
                    )
                    return result


class ParseError(Exception):
    """LLM 返回结果解析失败，可触发 executor 级别重试。"""


class Executor(object):

    def __init__(
        self,
        caller: OpenAICaller,
        model_choice: ModelChoiceConfig,
        max_parse_retries: int = 1,
    ) -> None:
        self.caller = caller
        self.temperature = model_choice.temperature
        self.max_tokens = model_choice.max_tokens
        self.n = model_choice.n
        self.max_parse_retries = max_parse_retries
        logger.info(f'Initialize executor: {self.name()}, {self.caller.__dict__}, temperature: {self.temperature}, max_tokens: {self.max_tokens}, n: {self.n}, max_parse_retries: {self.max_parse_retries}')

    async def run_with_retry(self, id: str, data: dict) -> None:
        """带解析重试的 run 入口。解析失败时重新调用 LLM。"""
        retrier = tenacity.AsyncRetrying(
            stop=tenacity.stop_after_attempt(self.max_parse_retries),
            wait=tenacity.wait_fixed(1),
            retry=tenacity.retry_if_exception_type(ParseError),
            before_sleep=lambda rs: logger.warning(
                f'Parse retry {rs.attempt_number}/{self.max_parse_retries} '
                f'{self._generate_call_id(id)}: {rs.outcome.exception()}'
            ),
            reraise=True,
        )
        async for attempt in retrier:
            with attempt:
                await self.run(id, data)

    async def run(self, id: str, data: dict) -> None:
        """子类实现。解析失败时应抛出 ParseError。"""
        raise NotImplementedError

    @classmethod
    def name(cls):
        return cls.__name__

    def _generate_call_id(
        self,
        id: str
    ) -> str:
        return f'{self.name()}|{id}'

    def _get_tag(self, data: dict) -> dict:
        """获取或创建 data 中当前 executor 的 tag dict。"""
        key = f'tag/{self.name()}'
        if key not in data or data[key] is None:
            data[key] = {}
        return data[key]

    def _update_tag(self, data: dict, **kwargs) -> None:
        """更新 tag，None 值会被跳过。"""
        tag = self._get_tag(data)
        tag.update({k: v for k, v in kwargs.items() if v is not None})
