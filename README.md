# CompanyBench

LLM-based benchmark for evaluating enterprise scenario task completion, covering customer service, HR, and order management domains.

## Prerequisites

- Python >= 3.12
- [uv](https://docs.astral.sh/uv/) (recommended package manager)

## Setup

```bash
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Clone and enter project
git clone <repo-url> && cd CompanyBench

# Install dependencies (uv auto-creates venv and resolves Python version)
uv sync

# Install dev dependencies (pytest, etc.)
uv sync --extra dev
```

## Project Structure

```
company_bench/          # Core package
  script/
    crawl/              # Web scraping & parsing (camera/lens specs)
    trans_camera_to_db_format/   # Camera data → DB format
    trans_lens_to_db_format/     # Lens data → DB format
  util/                 # Shared utilities (LLM caller, I/O, path helpers)
data/
  crawl/                # Raw crawled HTML & parsed JSONL
  doc/                  # Policy documents (zh/en)
  schema/               # Database schema
  task/                 # Benchmark task definitions
tests/                  # Unit tests
```

## Running Tests

```bash
uv run pytest
```

## Usage

```bash
uv run python main.py
```
