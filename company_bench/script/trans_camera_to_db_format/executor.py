import re
import json
from typing import List, Dict

import jsonschema
from loguru import logger

from company_bench.util.caller import Executor, ParseError


SYSTEM_PROMPT = """You are a camera specifications expert. Your task is to convert raw camera data into a structured JSON format following a strict schema.

Given a camera's raw specification data, output a JSON object with the following fields. Use ONLY the allowed enum values where specified. If a field cannot be extracted from the input, use your expert knowledge of the camera to fill it in — the value MUST be factually correct and consistent with common sense.

Schema:
- id (string, max 64): camera identifier
- brand (string, enum): one of ["Canon", "Fujifilm", "Hasselblad", "Leica", "Nikon", "OM System / Olympus", "Panasonic", "Pentax", "Pixii", "Sigma", "Sony"]
- model_name (string, max 128): camera model name
- manufacturer_suggested_retail_price (number): MSRP in USD at launch, body only 
- announced_at (string, date format YYYY-MM-DD): announcement date
- body_type (string, enum): one of ["Compact SLR", "Large SLR", "Mid-size SLR", "Rangefinder-style mirrorless", "SLR-style mirrorless"]
- max_resolution_width_px (number): max image width in pixels
- max_resolution_height_px (number): max image height in pixels
- effective_pixels_megapixel (number): effective megapixels (e.g. 24, 45.0)
- sensor_size_category (string, enum): one of ["Full frame", "APS-C", "Four Thirds", "Medium Format"]
- sensor_width_mm (number): sensor width in mm
- sensor_height_mm (number): sensor height in mm
- sensor_type (string, enum): one of ["CMOS", "BSI-CMOS", "Stacked CMOS"]
- iso_auto (string, enum): "Yes" or "No"
- iso_min (number): minimum native ISO
- iso_max (number): maximum native ISO
- iso_expanded_min (number): minimum expanded ISO (if available)
- iso_expanded_max (number): maximum expanded ISO (if available)
- lens_mount (string, enum): one of ["Canon EF", "Canon EF-M", "Canon EF/EF-S", "Canon RF", "Canon RF-S", "Fujifilm G", "Fujifilm X", "Hasselblad X", "Leica L", "Leica M", "Micro Four Thirds", "Nikon F", "Nikon Z", "Pentax KAF2", "Sony E"]
- focal_length_multiplier (number): crop factor
- articulated_lcd (string, enum): one of ["Fixed", "Fully articulated", "Tilting", "No"]
- screen_size_inch (number): screen size in inches
- screen_dots (number): screen resolution in dots (e.g. 1040000, 2100000)
- max_shutter_speed_reciprocal (number): denominator of max shutter speed (e.g. 8000 for 1/8000)
- video_formats (array of strings, enum): subset of ["MPEG-4", "AVCHD", "XAVC S", "XAVC HS", "XAVC S-I", "H.264", "H.265", "ProRes", "ProResRAW", "Canon Cinema Raw", "Canon Cinema Raw Light", "Nikon N-Raw", "XF-AVC"]
- storage_types (array of strings, enum): subset of ["CFexpress Type A", "CFexpress Type B", "XQD", "SD", "SDHC", "SDXC", "UHS-I SD", "UHS-II SD", "Micro SD"]
- usb (string, enum): one of ["USB 2.0 (480 Mbit/sec)", "USB 3.0 (5 GBit/sec)", "USB 3.2 Gen 1 (5 GBit/sec)", "USB 3.2 Gen 2 (10 GBit/sec)"]
- weight_g (number): weight in grams (including batteries)
- dimension_length_mm (number): body length in mm
- dimension_width_mm (number): body width in mm
- dimension_height_mm (number): body height in mm
- gps (string, enum): one of ["Built-in", "Optional", "None"]

Important rules:
1. For storage_types, normalize to the closest matching enum values. E.g. "SD/SDHC/SDXC (UHS-I)" -> ["SD", "SDHC", "SDXC", "UHS-I SD"]. "Dual CFexpress type B" -> ["CFexpress Type B"]. "UHS-II SD card" -> ["UHS-II SD"].
2. For ISO, parse "Auto, 100-102400 (expands to 50-819200)" as: iso_auto="Yes", iso_min=100, iso_max=102400, iso_expanded_min=50, iso_expanded_max=819200. If ISO string starts with a number (no "Auto"), check context — if the camera supports auto ISO (most modern cameras do), set iso_auto="Yes".
3. For video_formats, parse comma-separated format names and map to enums.
4. For dimensions "158 x 168 x 83 mm", parse as dimension_length_mm=158, dimension_width_mm=168, dimension_height_mm=83.
5. For weight "1440 g (...)", extract the number before "g".
6. For screen_dots, remove commas and parse as integer (e.g. "2,100,000" -> 2100000).
7. For max_shutter_speed, parse "1/8000 sec" as 8000.
8. For announced_at "Announced\\nJan 7, 2020", parse to announced_at="2020-01-07"
9. For sensor size "Full frame (36 x 24 mm)", parse sensor_size_category="Full frame", sensor_width_mm=36, sensor_height_mm=24.
10. For effective_pixels, parse "20 megapixels" as 20.
11. For max_resolution "5472 x 3648", parse as max_resolution_width_px=5472, max_resolution_height_px=3648.
12. If a field is missing from the input, fill it in from your knowledge.
13. manufacturer_suggested_retail_price should be the body-only MSRP in USD at launch time.

DO NOT omit any field.

Output the result as a JSON code block in the following format:
```json
{ ... }
```"""

CAMERA_SCHEMA = {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "Camera",
    "type": "object",
    "required": ["id", "brand", "model_name"],
    "properties": {
        "id": {"type": "string", "maxLength": 64},
        "brand": {
            "type": "string",
            "enum": ["Canon", "Fujifilm", "Hasselblad", "Leica", "Nikon",
                     "OM System / Olympus", "Panasonic", "Pentax", "Pixii",
                     "Sigma", "Sony"]
        },
        "model_name": {"type": "string", "maxLength": 128},
        "manufacturer_suggested_retail_price": {"type": "number"},
        "announced_at": {"type": "string", "format": "date"},
        "body_type": {
            "type": "string",
            "enum": ["Compact SLR", "Large SLR", "Mid-size SLR",
                     "Rangefinder-style mirrorless", "SLR-style mirrorless"]
        },
        "max_resolution_width_px": {"type": "number"},
        "max_resolution_height_px": {"type": "number"},
        "effective_pixels_megapixel": {"type": "number"},
        "sensor_size_category": {
            "type": "string",
            "enum": ["Full frame", "APS-C", "Four Thirds", "Medium Format"]
        },
        "sensor_width_mm": {"type": "number"},
        "sensor_height_mm": {"type": "number"},
        "sensor_type": {
            "type": "string",
            "enum": ["CMOS", "BSI-CMOS", "Stacked CMOS"]
        },
        "iso_auto": {"type": "string", "enum": ["Yes", "No"]},
        "iso_min": {"type": "number"},
        "iso_max": {"type": "number"},
        "iso_expanded_min": {"type": "number"},
        "iso_expanded_max": {"type": "number"},
        "lens_mount": {
            "type": "string",
            "enum": ["Canon EF", "Canon EF-M", "Canon EF/EF-S", "Canon RF",
                     "Canon RF-S", "Fujifilm G", "Fujifilm X", "Hasselblad X",
                     "Leica L", "Leica M", "Micro Four Thirds", "Nikon F",
                     "Nikon Z", "Pentax KAF2", "Sony E"]
        },
        "focal_length_multiplier": {"type": "number"},
        "articulated_lcd": {
            "type": "string",
            "enum": ["Fixed", "Fully articulated", "Tilting", "No"]
        },
        "screen_size_inch": {"type": "number"},
        "screen_dots": {"type": "number"},
        "max_shutter_speed_reciprocal": {"type": "number"},
        "video_formats": {
            "type": "array",
            "items": {
                "type": "string",
                "enum": ["MPEG-4", "AVCHD", "XAVC S", "XAVC HS", "XAVC S-I",
                         "H.264", "H.265", "ProRes", "ProResRAW",
                         "Canon Cinema Raw", "Canon Cinema Raw Light",
                         "Nikon N-Raw", "XF-AVC"]
            }
        },
        "storage_types": {
            "type": "array",
            "items": {
                "type": "string",
                "enum": ["CFexpress Type A", "CFexpress Type B", "XQD",
                         "SD", "SDHC", "SDXC",
                         "UHS-I SD", "UHS-II SD", "Micro SD"]
            }
        },
        "usb": {
            "type": "string",
            "enum": ["USB 2.0 (480 Mbit/sec)",
                     "USB 3.0 (5 GBit/sec)",
                     "USB 3.2 Gen 1 (5 GBit/sec)",
                     "USB 3.2 Gen 2 (10 GBit/sec)"]
        },
        "weight_g": {"type": "number"},
        "dimension_length_mm": {"type": "number"},
        "dimension_width_mm": {"type": "number"},
        "dimension_height_mm": {"type": "number"},
        "gps": {"type": "string", "enum": ["Built-in", "Optional", "None"]}
    }
}

INPUT_TEMPLATE = """Convert the following camera data to the formal schema format:

{INPUT}"""


class CameraFormatExecutor(Executor):

    def _validate_schema(self, data: dict) -> List[str]:
        """Validate parsed JSON against CAMERA_SCHEMA. Returns list of error messages."""
        validator = jsonschema.Draft7Validator(CAMERA_SCHEMA)
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
