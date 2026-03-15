# Task 2: Product Comparison Consultation and Lens Compatibility Analysis

## Metadata

| Property | Value |
|----------|-------|
| Difficulty | Medium |
| Tags | `implicit-intent` `information-retrieval` `precise-computation` `information-isolation` `multi-entity-matching` `cross-system` |
| Required Tools | `product` (search_products) · `customer` (search_customers) · `order` (search_orders) · `document` (read_doc, update_doc) · `bash` (execute) |

## Difficulty Analysis

This task requires the Agent to complete a customer-facing camera body comparison consultation. The key challenges are as follows:

1. **Implicit Intent Resolution**: The user refers to two products using colloquial abbreviations — "X2D2" for Hasselblad X2D II 100C and "A1M2" for Sony a1 II — without providing full model names. The Agent must map these ambiguous abbreviations to the official product names in the product catalog and retrieve complete specifications. Additionally, the phrase "besides the lenses I bought at Molly Digital" implicitly requires querying the customer's order history to obtain the full list of previously purchased lenses. The Agent must interpret this as a reverse query against the order system, rather than focusing solely on the one lens the user explicitly mentions.

2. **Proactive Information Retrieval**: The user describes a use case — "photographing wildlife in Kenya" — without specifying any technical parameter requirements. Per the system prompt's behavioral guidelines — "if the user describes a use case... search the document library and infer the appropriate product type and key parameter ranges" — the Agent must proactively search the external document library to find wildlife photography experience posts or technical guides that highlight the critical importance of shutter speed for capturing fast-moving subjects. It should then combine this insight with the shutter speed specifications of both camera bodies to make a recommendation. If the Agent skips the document search and relies on its own knowledge to reach the same conclusion, it would violate the policy-mandated behavioral chain. Likewise, business rules such as membership discount rates and lens mount compatibility rules must be retrieved from policy documents rather than assumed from pre-existing knowledge.

3. **Precise Numerical Computation**: The Agent must query the customer's membership tier (Platinum), retrieve the corresponding discount rate (10%) from the policy document, verify whether either product has a special offer, and use the bash tool to compute the exact discounted price for each product. The system prompt explicitly requires that "all calculations involving monetary amounts... must use the bash tool for precise computation" — the Agent must not perform mental arithmetic or approximate rounding.

4. **Implicit Write-back and Information Isolation**: Upon detecting that the Sony a1 II is out of stock, the Agent must simultaneously perform two actions: inform the customer of the out-of-stock status and suggest adding the product to their cart for restock notification, while also recording a restocking request in the backend restocking document in the prescribed format. The critical challenge is that the system prompt explicitly requires "do not expose this document recording event in the customer-facing response." The Agent must execute the write operation while maintaining information isolation from the customer, requiring it to distinguish between "user-facing response content" and "backend system operations."

5. **Multi-Entity Cross-Matching**: The user's complete lens collection comprises 5 lenses (4 from order history + 1 mentioned by the user), spanning three mount systems: Sony FE, Sony E, and Hasselblad X. The two camera bodies use Hasselblad X and Sony E mounts respectively. The Agent must evaluate mount compatibility for all 5×2=10 lens-body combinations, including the special compatibility rule where Sony FE mount lenses are backward-compatible with Sony E mount bodies — the Tamron 150-500mm is listed as "Fujifilm X, Sony FE" mount and does not directly include "Sony E," but should be judged as compatible because Sony FE lenses can be used on Sony E bodies. The Agent must correctly apply this exception rule in each matching pair and ultimately summarize the compatible lens count for each body.

6. **Multi-Source Information Merging**: The complete response requires merging information from five distinct sources — the product catalog (specifications, prices, stock status), customer profile (membership tier), order system (historical lens purchases), policy documents (membership discount rules, mount compatibility rules, out-of-stock handling procedures), and user input (the additionally owned Hasselblad 55mm F2.5 V). The Agent must consolidate this dispersed information into a structured comparison table, covering performance comparison, scene-based recommendation, price calculation, stock status, and lens compatibility analysis across multiple dimensions, while silently completing the restocking document update in the backend.

## Input

### Session Context

```
Current User Type: Customer
Current User Name: Aleksandr Ivanovich
Current User ID: customer-c4ec2a86-36c1-4103-b6a2-c817a286c8db
Current User AK: AAAAC3NzaC1lZDI1NTE5AAAAIBYytISqY7Ut2072Ko4un2zWC8wmYbFL1MIVxtGh4lYl
```

### Prompt

```
Current Time: 2026-03-15 18:52:59

I'm looking to buy a camera body — which one would be better for photographing wildlife in Kenya? I'm currently considering the X2D2 or the A1M2. Also, besides the lenses I bought at Molly Digital, I also have a Hasselblad 55mm F2.5 V — which body is more compatible with my lens collection?
```

## Rubrics

| # | Domain | Method | Criterion | Test Code |
|---|--------|--------|-----------|-----------|
| 1 | response | llm_judge | Response compares Hasselblad X2D II 100C and Sony a1 II specifications in a table format | — |
| 2 | response | llm_judge | Response states that Hasselblad X2D II 100C is made by Hasselblad and Sony a1 II is made by Sony | — |
| 3 | response | llm_judge | Response states that Hasselblad X2D II 100C was announced Aug 26, 2025 and Sony a1 II was announced Nov 19, 2024 | — |
| 4 | response | llm_judge | Response states that Hasselblad X2D II 100C has 102 megapixels effective and Sony a1 II has 50 megapixels effective | — |
| 5 | response | llm_judge | Response states that Hasselblad X2D II 100C has a max shutter speed of 1/4000 sec and Sony a1 II has a max shutter speed of 1/8000 sec | — |
| 6 | response | llm_judge | Response states that Hasselblad X2D II 100C has an MSRP of $7,399 and Sony a1 II has an MSRP of $6,499 | — |
| 7 | response | llm_judge | Response states that Aleksandr Ivanovich is a Platinum member of Molly Digital and enjoys a 10% discount | — |
| 8 | response | llm_judge | Response states that the member price for Hasselblad X2D II 100C is $6,659.1 and for Sony a1 II is $5,849.1, with neither product having a special offer — only the membership discount applies | — |
| 9 | response | llm_judge | Response states that Hasselblad X2D II 100C is currently in stock and Sony a1 II is currently out of stock | — |
| 10 | response | llm_judge | Response suggests the customer add Sony a1 II to their cart and wait for a restock notification | — |
| 11 | response | llm_judge | Response does not mention that a restocking request has been recorded in the Supply Chain & Logistics department's restocking document — no internal process is exposed | — |
| 12 | database | unittest | Restocking document doc-3c526579-4941-4157-98a6-5e9bdb353b16 has a new restocking request for Sony a1 II; the last line contains sony_a1ii and the customer ID | See `test_sony_a1ii_restock_request` |
| 13 | response | llm_judge | Response explains that wildlife photography demands higher shutter speed, therefore Sony a1 II is more suitable | — |
| 14 | response | llm_judge | Response states that based on the customer's order history, they have previously purchased Sony FE 24-70mm F2.8 GM II, Sony FE 70-200mm F2.8 GM OSS II, Tamron 150-500mm F5-6.7 Di III VC VXD, and Hasselblad XCD 20-35mm F3.2-4.5 E | — |
| 15 | response | llm_judge | Response states that Sony a1 II uses the Sony E lens mount | — |
| 16 | response | llm_judge | Response states that Hasselblad X2D II 100C uses the Hasselblad X lens mount | — |
| 17 | response | llm_judge | Response states that Hasselblad X2D II 100C (Hasselblad X) is incompatible with Sony FE 24-70mm F2.8 GM II (lens mount: Sony FE) | — |
| 18 | response | llm_judge | Response states that Hasselblad X2D II 100C (Hasselblad X) is incompatible with Sony FE 70-200mm F2.8 GM OSS II (lens mount: Sony E, Sony FE) | — |
| 19 | response | llm_judge | Response states that Hasselblad X2D II 100C (Hasselblad X) is incompatible with Tamron 150-500mm F5-6.7 Di III VC VXD (lens mount: Fujifilm X, Sony FE) | — |
| 20 | response | llm_judge | Response states that Hasselblad X2D II 100C (Hasselblad X) is compatible with Hasselblad XCD 20-35mm F3.2-4.5 E (lens mount: Hasselblad X) — matching Hasselblad X mount | — |
| 21 | response | llm_judge | Response states that Hasselblad X2D II 100C (Hasselblad X) is compatible with Hasselblad XCD 55mm F2.5 V (lens mount: Hasselblad X) — matching Hasselblad X mount | — |
| 22 | response | llm_judge | Response states that Sony a1 II (Sony E mount) is compatible with Sony FE 24-70mm F2.8 GM II (lens mount: Sony FE) — Sony FE lenses are usable on Sony E bodies | — |
| 23 | response | llm_judge | Response states that Sony a1 II (Sony E mount) is compatible with Sony FE 70-200mm F2.8 GM OSS II (lens mount: Sony E, Sony FE) — includes Sony E | — |
| 24 | response | llm_judge | Response states that Sony a1 II (Sony E mount) is compatible with Tamron 150-500mm F5-6.7 Di III VC VXD (lens mount: Fujifilm X, Sony FE) — includes Sony FE, usable on Sony E bodies | — |
| 25 | response | llm_judge | Response states that Sony a1 II (Sony E mount) is incompatible with Hasselblad XCD 20-35mm F3.2-4.5 E (lens mount: Hasselblad X) | — |
| 26 | response | llm_judge | Response states that Sony a1 II (Sony E mount) is incompatible with Hasselblad XCD 55mm F2.5 V (lens mount: Hasselblad X) | — |
| 27 | response | llm_judge | Response states that for the customer's existing lens collection, Sony a1 II is compatible with 3 lenses and Hasselblad X2D II 100C is compatible with 2 lenses | — |

## Test Code

```python
import pytest

# ── Known IDs (determined at environment initialization) ──
RESTOCK_DOC_ID = "doc-3c526579-4941-4157-98a6-5e9bdb353b16"
CUSTOMER_ID    = "customer-c4ec2a86-36c1-4103-b6a2-c817a286c8db"


# ── #12 Restocking document updated with Sony a1 II request ──
def test_sony_a1ii_restock_request(db):
    row = db.fetch_one(
        f"SELECT content FROM document WHERE doc_id = '{RESTOCK_DOC_ID}'"
    )
    assert row is not None, "Restocking document does not exist"
    content = row["content"].strip()
    last_line = content.split('\n')[-1]
    assert f'sony_a1ii | {CUSTOMER_ID}' in last_line, (
        f"Last line of restocking document should contain sony_a1ii | {CUSTOMER_ID}, actual: {last_line}"
    )
```
