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
import canonicalize_action_fieldkit_candidate_v1 as canonicalize  # noqa: E402


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

    def test_chroma_transport_builds_exact_canonical_per_cell(self) -> None:
        raw = Image.new("RGB", (1254, 1254), (0, 255, 0))
        draw = ImageDraw.Draw(raw)
        half = raw.width // 2
        objects = (
            (150, 145, 480, 490),
            (half + 185, 160, half + 465, 455),
            (135, half + 120, 500, half + 500),
            (half + 205, half + 270, half + 445, half + 355),
        )
        for index, box in enumerate(objects):
            draw.rectangle(box, fill=(74 + index * 6, 47 + index * 4, 29))

        atlas, report = canonicalize.canonicalize(raw)
        metrics, _ = review.cell_metrics(atlas)
        self.assertEqual(atlas.size, (1024, 1024))
        self.assertEqual(atlas.mode, "RGBA")
        self.assertEqual(report["status"], "pass")
        self.assertTrue(all(item["minimum_margin"] >= 80 for item in metrics.values()))
        self.assertEqual(canonicalize.transparent_rgb_nonzero(atlas), 0)
        self.assertTrue(
            all(value == 0 for value in canonicalize.visible_green_metrics(atlas).values())
        )

    def test_edge_connected_key_preserves_isolated_interior_green(self) -> None:
        cell = Image.new("RGB", (512, 512), (0, 255, 0))
        draw = ImageDraw.Draw(cell)
        draw.rectangle((96, 96, 415, 415), fill=(82, 51, 30))
        draw.rectangle((220, 220, 291, 291), fill=(0, 255, 0))
        keyed, report = canonicalize.edge_connected_chroma_key(cell)
        self.assertEqual(keyed.getpixel((0, 0))[3], 0)
        self.assertEqual(keyed.getpixel((250, 250)), (0, 255, 0, 255))
        self.assertGreater(report["edge_connected_pixels"], 0)

    def test_chroma_transport_reports_raw_boundary_contact(self) -> None:
        cell = Image.new("RGB", (512, 512), (0, 255, 0))
        draw = ImageDraw.Draw(cell)
        draw.rectangle((400, 180, 511, 330), fill=(82, 51, 30))
        _, report = canonicalize.edge_connected_chroma_key(cell)
        self.assertTrue(report["touches_cell_boundary"])
        self.assertEqual(report["keyed_margins_ltrb"][2], 0)

    def test_chroma_transport_reports_multiple_significant_objects(self) -> None:
        cell = Image.new("RGB", (512, 512), (0, 255, 0))
        draw = ImageDraw.Draw(cell)
        draw.rectangle((90, 160, 220, 330), fill=(82, 51, 30))
        draw.rectangle((300, 190, 410, 300), fill=(96, 61, 34))
        _, report = canonicalize.edge_connected_chroma_key(cell)
        self.assertEqual(report["components"]["significant_count"], 2)

    def test_canonical_review_requires_matching_provenance(self) -> None:
        raw_path = ROOT / "tests" / "__missing_raw_for_sha__.png"
        canonical_path = ROOT / "tests" / "__missing_canonical_for_sha__.png"
        with self.assertRaises(ValueError):
            review.validate_canonical_provenance(
                {"schema": "wrong"},
                component_name="AB.TRINKET.KIT.V1",
                attempt="attempt-03",
                raw_path=raw_path,
                canonical_path=canonical_path,
            )


if __name__ == "__main__":
    unittest.main()
