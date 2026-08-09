#!/usr/bin/env python3
"""Deterministic checks for the Field Kit production-candidate reviewer."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

import review_action_fieldkit_candidate_v1 as review  # noqa: E402


class FieldKitCandidateReviewTest(unittest.TestCase):
    def test_exact_rgba_cells_preserve_alpha_and_margin_contract(self) -> None:
        atlas = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
        draw = ImageDraw.Draw(atlas)
        for x, y in ((0, 0), (512, 0), (0, 512), (512, 512)):
            draw.rectangle((x + 80, y + 80, x + 431, y + 431), fill=(90, 55, 31, 255))
        normalized, derivation = review.derive_review_rgba(atlas)
        metrics, sprites = review.cell_metrics(normalized)
        self.assertTrue(derivation["source_has_usable_transparency"])
        self.assertEqual(normalized.size, (1024, 1024))
        self.assertTrue(all(item["minimum_margin"] >= 80 for item in metrics.values()))
        self.assertTrue(all(sprite.size == (352, 352) for sprite in sprites.values()))

    def test_baked_checker_is_review_only_and_normalized(self) -> None:
        raw = Image.new("RGB", (1254, 1254), (244, 244, 244))
        draw = ImageDraw.Draw(raw)
        draw.rectangle((150, 150, 450, 450), fill=(70, 42, 25))
        normalized, derivation = review.derive_review_rgba(raw)
        self.assertEqual(normalized.size, (1024, 1024))
        self.assertFalse(derivation["source_has_usable_transparency"])
        self.assertTrue(derivation["review_only"])
        self.assertIn("LANCZOS", derivation["method"])
        self.assertNotEqual(review.bbox_or_empty(normalized), (0, 0, 0, 0))

    def test_nine_slice_supports_wide_and_tall_targets(self) -> None:
        sprite = Image.new("RGBA", (352, 352), (0, 0, 0, 0))
        draw = ImageDraw.Draw(sprite)
        draw.rectangle((0, 0, 351, 351), outline=(120, 85, 45, 255), width=32)
        self.assertEqual(review.nine_slice(sprite, (985, 42), 4).size, (985, 42))
        self.assertEqual(review.nine_slice(sprite, (42, 768), 4).size, (42, 768))


if __name__ == "__main__":
    unittest.main()
