#!/usr/bin/env python3
"""解析 lens HTML 的 quickSpecs table，输出 lens.jsonl"""

import json
from lxml import html
from loguru import logger

from company_bench.util.root import PROJECT_ROOT

HTML_DIR = PROJECT_ROOT / "data/crawl/html/lens"
OUT_PATH = PROJECT_ROOT / "data/crawl/lens.jsonl"


def parse_quick_specs(file_path):
    tree = html.parse(str(file_path))

    # brand
    brand_nodes = tree.xpath('.//div[@class="breadcrumbs"]/a[@class="item"][2]')
    brand = brand_nodes[0].text_content().strip() if brand_nodes else ""

    # model_name
    h1_nodes = tree.xpath('.//h1')
    model_name = h1_nodes[0].text_content().replace("Overview", "").strip() if h1_nodes else ""

    # announced_at
    date_nodes = tree.xpath('.//div[@class="productOverviewPage"]/div[@class="section"][2]/div[2]')
    announced_at = date_nodes[0].text_content().strip() if date_nodes else ""

    tables = tree.xpath('//div[contains(@class,"quickSpecs")]//table')
    if not tables:
        return None
    kv = {"brand": brand, "model_name": model_name, "announced_at": announced_at}
    for row in tables[0].xpath('.//tr'):
        ths = row.xpath('.//th')
        tds = row.xpath('.//td')
        if ths and tds:
            key = ths[0].text_content().strip()
            val = tds[0].text_content().strip()
            if key:
                kv[key] = val
    return kv


def main():
    files = sorted(HTML_DIR.glob("*.html"))
    logger.info(f"Found {len(files)} HTML files in {HTML_DIR}")

    ok = fail = 0
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        for fp in files:
            slug = fp.stem
            specs = parse_quick_specs(fp)
            if specs is None:
                logger.warning(f"No quickSpecs table: {fp.name}")
                fail += 1
                continue
            record = {"id": slug, **specs}
            f.write(json.dumps(record, ensure_ascii=False) + "\n")
            ok += 1

    logger.info(f"Done: ok={ok} fail={fail} -> {OUT_PATH}")


if __name__ == "__main__":
    main()
