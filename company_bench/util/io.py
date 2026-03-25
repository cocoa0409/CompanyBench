import aiofiles
import os
import traceback
from tqdm import tqdm
from loguru import logger
import json


async def append_to_file(
    id: str,
    path: str, 
    content: str,
    verbose: bool = True
) -> None:
    if os.path.exists(path) is False:
        file = open(path, 'w')
        file.close()
    fname = path.split('/')[-1]
    try:
        async with aiofiles.open(path, 'a') as file:
            await file.write(content + '\n')
            if verbose:
                logger.info(f'Append to file: {fname}, {id}')
    except:
        logger.error(traceback.format_exc())
        logger.error(f'Fail to append to file: {fname}. {id}')

def load_json(input_str):
    input_str = input_str.strip()
    if input_str.startswith('```json'):
        input_str = input_str[len('```json'):].strip()
    if input_str.startswith('```'):
        input_str = input_str[len('```'):].strip()
    if input_str.endswith('```'):
        input_str = input_str[:-len('```')].strip()
    return json.loads(input_str)

def load_prompt(path):
    prompt = ''
    for line in open(path, 'r'):
        prompt += line
    logger.info(f'Load prompt from: {path}')
    return prompt

def load_jsonl(path, n=-1):
    clct = []
    for line in tqdm(open(path, 'r'), desc=f'load {path}...'):
        clct.append(json.loads(line))
        if len(clct) == n:
            break
    logger.info(f'Load [{len(clct)}] items from: {path}')
    return clct
