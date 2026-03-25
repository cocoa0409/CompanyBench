#!/usr/bin/env python3
"""抓取 dpreview 相机和镜头页面，保存原始 HTML（Playwright 版）。"""

import time
import random

from playwright.sync_api import sync_playwright
from loguru import logger

PROXY = "http://agent-proxy-all-us.msh.team:3128"
MAX_RETRIES = 3

from company_bench.util.root import PROJECT_ROOT

DATA_DIR = PROJECT_ROOT / "data/crawl/html"
URL_DIR = PROJECT_ROOT / "data/crawl/url"


def load_urls(file_path):
    with open(file_path) as f:
        return [line.strip() for line in f if line.strip()]


def url_to_filename(url):
    return url.rstrip("/").split("/")[-1] + ".html"


def fetch_page(browser, url):
    """使用 Playwright 抓取单个页面，对应 scrape_kaggle.py 的 method4"""
    context = browser.new_context(
        user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    )
    page = context.new_page()
    try:
        page.goto(url, timeout=180000, wait_until='domcontentloaded')
        page.wait_for_timeout(3000)
        return page.content()
    finally:
        page.close()
        context.close()


def fetch_and_save(browser, url, out_dir):
    out_path = out_dir / url_to_filename(url)
    if out_path.exists():
        logger.info(f"SKIP (exists): {url}")
        return url, "skip"

    for attempt in range(MAX_RETRIES):
        try:
            html = fetch_page(browser, url)
            out_path.write_text(html, encoding="utf-8")
            logger.info(f"OK: {url}")
            time.sleep(random.uniform(0.5, 2.0))
            return url, "ok"
        except Exception as e:
            logger.warning(f"Attempt {attempt + 1} failed for {url}: {e}")
            if attempt < MAX_RETRIES - 1:
                time.sleep(random.uniform(3, 6))
            else:
                return url, f"fail: {e}"


def scrape(name, url_file, out_dir):
    urls = load_urls(url_file)
    # urls = urls[:1]
    out_dir.mkdir(parents=True, exist_ok=True)
    logger.info(f"[{name}] {len(urls)} urls -> {out_dir}")

    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=True,
            proxy={'server': PROXY},
        )
        logger.info(f"Using proxy: {PROXY}")

        ok = skip = fail = 0
        try:
            for i, url in enumerate(urls, 1):
                url, status = fetch_and_save(browser, url, out_dir)
                if status == "ok":
                    ok += 1
                elif status == "skip":
                    skip += 1
                else:
                    fail += 1
                    logger.error(f"  FAIL {url}: {status}")
                if i % 20 == 0 or i == len(urls):
                    logger.info(f"  [{i}/{len(urls)}] ok={ok} skip={skip} fail={fail}")
        finally:
            browser.close()

    logger.info(f"[{name}] done: ok={ok} skip={skip} fail={fail}")


def main():
    scrape("camera", URL_DIR / "camera_url_list", DATA_DIR / "camera")
    scrape("lens", URL_DIR / "lens_url_list", DATA_DIR / "lens")


if __name__ == "__main__":
    main()
