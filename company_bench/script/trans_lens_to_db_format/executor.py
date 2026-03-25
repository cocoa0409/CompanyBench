import re
import json
from typing import List, Dict

import jsonschema
from loguru import logger

from company_bench.util.caller import Executor, ParseError


SYSTEM_PROMPT = """You are a camera lens specifications expert. Your task is to convert raw lens data into a structured JSON format following a strict schema.

Given a lens's raw specification data, output a JSON object with the following fields. Use ONLY the allowed enum values where specified. If a field cannot be extracted from the input, use your expert knowledge of the lens to fill it in — the value MUST be factually correct and consistent with common sense.

Schema:
- id (string, max 128): lens identifier
- brand (string, enum): one of ["7Artisans", "All Lenses", "Canon", "Fujifilm", "Hasselblad", "Irix", "Laowa/Venus Optics", "Leica", "Nikon", "OM System / Olympus", "Panasonic", "Pentax", "Samyang/Rokinon", "Sigma", "Sony", "Tamron", "Tokina", "Viltrox", "Voigtlander", "Zeiss"]
- model_name (string, max 256): lens model name
- manufacturer_suggested_retail_price (number): MSRP in USD at launch, lens only 
- announced_at (string, date format YYYY-MM-DD): announcement date
- lens_type (string, enum): one of ["Prime lens", "Zoom lens"]
- image_stab (string, enum): one of ["Yes", "No"]
- focal_length_wide_mm (number): focal length at wide end in mm. For prime lenses, same as tele.
- focal_length_tele_mm (number): focal length at tele end in mm. For prime lenses, same as wide.
- max_aperture_f (number): maximum aperture F-number (smallest F value, i.e. widest aperture). For zoom lenses with variable aperture like "F4.5–6.3", use the wide-end value (4.5).
- min_aperture_f (number): minimum aperture F-number (largest F value, i.e. narrowest aperture). For zoom lenses with variable min aperture like "F32–45", use the tele-end value (45).
- min_focus_m (number): minimum focus distance in meters
- max_magnification_multiplier (number): maximum magnification ratio (e.g. 0.11 for "0.11×")
- weight_g (number): weight in grams
- length_mm (number): lens length in mm
- lens_mounts (array of strings, enum): subset of ["Canon EF", "Canon EF-M", "Canon EF-S", "Canon RF", "Canon RF-S", "Fujifilm G", "Fujifilm X", "Hasselblad X", "L-Mount", "Leica M", "Leica TL", "Micro Four Thirds", "Nikon F (FX)", "Nikon Z", "Pentax KAF", "Pentax KAF2", "Pentax KAF4", "Sony E", "Sony FE"]

Important rules:
1. For announced_at, parse "Announced\\nOct 25, 2022" to "2022-10-25".
2. For focal_length, parse "100–300 mm" as focal_length_wide_mm=100, focal_length_tele_mm=300. Parse "50 mm" as both =50.
3. For max_aperture_f, parse "F2.8" as 2.8. Parse "F4.5–6.3" as 4.5 (use widest/smallest F-number). Parse "F1.8–16" as 1.8.
4. For min_aperture_f, parse "F22" as 22. Parse "F32–45" as 45 (use narrowest/largest F-number). If missing, use your knowledge.
5. For image_stab, normalize any "Yes (...)" variants to "Yes". If missing, use your knowledge.
6. For min_focus_m, parse "0.09 m (3.35″)" as 0.09.
7. For max_magnification_multiplier, parse "0.11×" as 0.11. If missing, use your knowledge.
8. For weight_g, parse "201 g (0.44 lb)" as 201.
9. For length_mm, parse "54 mm (2.13″)" as 54.
10. For lens_mounts, split "Fujifilm X, Micro Four Thirds, Sony E" into ["Fujifilm X", "Micro Four Thirds", "Sony E"].
11. If a field is missing from the input, fill it in from your knowledge.
12. manufacturer_suggested_retail_price should be the lens-only MSRP in USD at launch time.

DO NOT omit any field.

Output the result as a JSON code block in the following format:
```json
{ ... }
```"""

LENS_SCHEMA = {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "Lens",
    "type": "object",
    "required": ["id", "brand", "model_name"],
    "properties": {
        "id": {"type": "string", "maxLength": 128},
        "brand": {
            "type": "string",
            "enum": ["7Artisans", "All Lenses", "Canon", "Fujifilm", "Hasselblad",
                     "Irix", "Laowa/Venus Optics", "Leica", "Nikon",
                     "OM System / Olympus", "Panasonic", "Pentax",
                     "Samyang/Rokinon", "Sigma", "Sony", "Tamron", "Tokina",
                     "Viltrox", "Voigtlander", "Zeiss"]
        },
        "model_name": {"type": "string", "maxLength": 256},
        "manufacturer_suggested_retail_price": {"type": "number"},
        "announced_at": {"type": "string", "format": "date"},
        "lens_type": {
            "type": "string",
            "enum": ["Prime lens", "Zoom lens"]
        },
        "image_stab": {
            "type": "string",
            "enum": ["Yes", "No"]
        },
        "focal_length_wide_mm": {"type": "number"},
        "focal_length_tele_mm": {"type": "number"},
        "max_aperture_f": {"type": "number"},
        "min_aperture_f": {"type": "number"},
        "min_focus_m": {"type": "number"},
        "max_magnification_multiplier": {"type": "number"},
        "weight_g": {"type": "number"},
        "length_mm": {"type": "number"},
        "lens_mounts": {
            "type": "array",
            "items": {
                "type": "string",
                "enum": ["Canon EF", "Canon EF-M", "Canon EF-S",
                         "Canon RF", "Canon RF-S",
                         "Fujifilm G", "Fujifilm X", "Hasselblad X",
                         "L-Mount", "Leica M", "Leica TL",
                         "Micro Four Thirds",
                         "Nikon F (FX)", "Nikon Z",
                         "Pentax KAF", "Pentax KAF2", "Pentax KAF4",
                         "Sony E", "Sony FE"]
            }
        }
    }
}

INPUT_TEMPLATE = """Convert the following lens data to the formal schema format:

{INPUT}"""


class LensFormatExecutor(Executor):

    def _validate_schema(self, data: dict) -> List[str]:
        """Validate parsed JSON against LENS_SCHEMA. Returns list of error messages."""
        validator = jsonschema.Draft7Validator(LENS_SCHEMA)
        return [e.message for e in validator.iter_errors(data)]

    def _extract_json(self, content: str) -> dict:
        """Extract JSON from ```json ... ``` code block, with fallback to raw { ... }."""
        m = re.search(r"```json\s*(.*?)\s*```", content, re.DOTALL)
        if m:
            return json.loads(m.group(1).strip())

        m = re.search(r"\{.*\}", content, re.DOTALL)
        if m:
            return json.loads(m.group(0).strip())

        return None

    def _parse_choice(self, id: str, choice: dict) -> dict:
        """解析单个 choice，返回 {"ok": bool, "result": ..., "error": ...}。"""
        finish_reason = choice.get('finish_reason')
        if finish_reason != 'stop':
            return {"ok": False, "error": f"finish_reason={finish_reason}", "result": None}

        content = choice['message']['content']

        try:
            parsed = self._extract_json(content)
        except json.JSONDecodeError as e:
            logger.warning(f'{id} JSON decode error: {e}')
            return {"ok": False, "error": f"json_decode_error: {e}", "result": None}

        if parsed is None:
            logger.warning(f'{id} no JSON found in response')
            return {"ok": False, "error": "no_json_found", "result": None}

        errors = self._validate_schema(parsed)
        if errors:
            logger.warning(f'{id} schema validation failed: {errors}')
            return {"ok": False, "error": f"schema_validation: {errors}", "result": parsed}

        return {"ok": True, "error": None, "result": parsed}

    async def run(self, id: str, data: dict) -> None:
        call_id = self._generate_call_id(id=id)

        messages = [
            {'role': 'system', 'content': SYSTEM_PROMPT},
            {'role': 'user', 'content': INPUT_TEMPLATE.format(INPUT=json.dumps(data, ensure_ascii=False))},
        ]

        response = await self.caller._call(
            id=call_id,
            messages=messages,
            temperature=self.temperature,
            max_tokens=self.max_tokens,
            n=self.n,
        )

        parsed_choices = [self._parse_choice(call_id, c) for c in response['choices']]
        pred = next((p["result"] for p in parsed_choices if p["ok"]), None)

        self._update_tag(
            data,
            messages=messages,
            response=response,
            parsed_choices=parsed_choices,
            formal_format=pred,
        )

        if pred is None:
            errors = [p["error"] for p in parsed_choices]
            raise ParseError(f'{call_id} all choices failed: {errors}')

        logger.info(f'{call_id} done.')
