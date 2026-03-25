"""测试 OpenAICaller 的基本调用功能。

需要环境变量 OPENAI_API_KEY 已设置。
运行: pytest tests/test_caller.py -v -s
"""

import asyncio
import pytest
from company_bench.util.caller import CallerConfig, OpenAICaller

API_BASE = "https://openai.app.msh.team/v1"
# MODEL_ID = "stupid/gpt-5.1"
MODEL_ID = "o3-mini"

@pytest.fixture
def caller():
    config = CallerConfig(
        model_id=MODEL_ID,
        max_concurrency=2,
        api_base=API_BASE,
        api_key=None,
        timeout=None,
        max_retries=1,
    )
    return OpenAICaller(caller_config=config)


@pytest.mark.asyncio
async def test_basic_call(caller):
    """测试基本调用，验证返回结构完整。"""
    result = await caller._call(
        id="test-basic",
        messages=[{"role": "user", "content": "Tell me who are u in 1 sentence."}],
        temperature=1.0,
        max_tokens=1024,
        n=1,
    )

    # 验证返回结构
    assert "choices" in result
    assert "usage" in result
    assert "model" in result

    # 验证 choices
    choices = result["choices"]
    assert len(choices) == 1
    choice = choices[0]
    assert choice["finish_reason"] == "stop"
    assert "content" in choice["message"]
    assert len(choice["message"]["content"]) > 0

    # 验证 usage
    usage = result["usage"]
    assert usage["prompt_tokens"] > 0
    assert usage["completion_tokens"] > 0
    assert usage["total_tokens"] == usage["prompt_tokens"] + usage["completion_tokens"]

    print(f"\nModel: {result['model']}")
    print(f"Content: {choice['message']['content']}")
    print(f"Usage: {usage}")


@pytest.mark.asyncio
async def test_multi_turn(caller):
    """测试多轮对话。"""
    result = await caller._call(
        id="test-multi-turn",
        messages=[
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "What is 1+1?"},
            {"role": "assistant", "content": "2"},
            {"role": "user", "content": "And plus 3?"},
        ],
        temperature=1.0,
        max_tokens=1024,
        n=1,
    )

    content = result["choices"][0]["message"]["content"]
    assert "5" in content
    print(f"\nContent: {content}")


@pytest.mark.asyncio
async def test_concurrency(caller):
    """测试并发控制（semaphore）是否正常工作。"""
    async def single_call(i):
        return await caller._call(
            id=f"test-concurrent-{i}",
            messages=[{"role": "user", "content": f"Reply with the number {i} only."}],
            temperature=1.0,
            max_tokens=1024,
            n=1,
        )

    results = await asyncio.gather(*[single_call(i) for i in range(4)])

    assert len(results) == 4
    for r in results:
        assert r["choices"][0]["finish_reason"] == "stop"
    print(f"\nAll {len(results)} concurrent calls succeeded.")
