import sys
import traceback
import json
import os
from tqdm.asyncio import tqdm_asyncio
import asyncio
import random
random.seed(21)

from company_bench.util.io import *
from company_bench.util.caller import *
from company_bench.util.root import PROJECT_ROOT

from company_bench.script.trans_lens_to_db_format.executor import LensFormatExecutor

########################################################
# Configuration
INPUT_PATH = str(PROJECT_ROOT / "data/crawl/lens.jsonl")
OUTPUT_PATH = str(PROJECT_ROOT / "data/crawl/lens.formal_format.jsonl")

DATA_CONCURRENCY = 64

CALLER = OpenAICaller(caller_config=CallerConfig(
    model_id='gemini-3.1-pro-preview-construct',
    max_concurrency=DATA_CONCURRENCY * 2,
    timeout=None,
    max_retries=None
))

MODEL_CHOICE_CONFIG = ModelChoiceConfig(
    temperature=1.0,
    max_tokens=64 * 1024,
    n=1
)

DATA_SEMAPHORE = asyncio.Semaphore(DATA_CONCURRENCY)

EXECUTOR = LensFormatExecutor(
    caller=CALLER,
    model_choice=MODEL_CHOICE_CONFIG
)
########################################################


async def run(data):
    """Run executor for a single data point"""
    id = data['id']
    async with DATA_SEMAPHORE:
        try:
            await EXECUTOR.run_with_retry(id=id, data=data)
        except Exception:
            logger.error(f'{id}: execution failed')
            logger.error(traceback.format_exc())
            return

        tag = data.get(f'tag/{EXECUTOR.name()}', {})
        formal_format = tag.get('formal_format')

        if formal_format is not None:
            await append_to_file(
                id=id,
                path=OUTPUT_PATH,
                content=json.dumps(formal_format, ensure_ascii=False)
            )
        else:
            logger.warning(f'{id}: no formal_format produced, skipping output')


async def main(input_clct):
    task_list = []
    for data in input_clct:
        task_list.append(asyncio.create_task(
            run(data=data)
        ))
    await tqdm_asyncio.gather(*task_list)


if __name__ == '__main__':
    if not os.path.exists(INPUT_PATH):
        logger.error(f'Input file not found: {INPUT_PATH}')
        sys.exit(1)

    output_dir = os.path.dirname(OUTPUT_PATH)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    if os.path.exists(OUTPUT_PATH):
        os.remove(OUTPUT_PATH)
        logger.info(f'Removed existing output file: {OUTPUT_PATH}')

    input_clct = []
    for data in load_jsonl(INPUT_PATH):
        input_clct.append(data)

    # input_clct = input_clct[:1]

    logger.info(f'Input file: {INPUT_PATH}')
    logger.info(f'Output file: {OUTPUT_PATH}')
    logger.info(f'Loaded {len(input_clct)} records')

    asyncio.run(main(input_clct))

    logger.success(f'Processing complete!')
    logger.success(f'Output: {OUTPUT_PATH}')
