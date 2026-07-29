#!/usr/bin/env python3
"""Build and review CHAT.COPY.V1.3 with local deterministic image operations.

The authorized V1.3 pipeline performs no network access, ImageGen call, or upload.
It derives A from the accepted Chat V3 parchment and reads only the fixed-SHA first
V1.2 B1 raw as surface material. All B geometry, state differences, alpha masks,
layer order, runtime scaling, and previews are owned by this script.
"""

from __future__ import annotations

import argparse
from collections import deque
import hashlib
import json
from pathlib import Path
from typing import Iterable, Sequence

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
SOURCE_FRAME = ROOT / "assets/source/chat/v3/ChatBookFrame_Master_v3.png"
DONOR_RAW = (
    ROOT
    / "generated/chat/copy/v1_2/b1/"
    "CHAT.COPY.TOGGLE.CLOSED.V1_2.raw.png"
)
BOOK_PREVIEW = (
    ROOT / "generated/chat/v3/runtime-artifacts/ChatBookFrame_440x320_v3.png"
)

OUTPUT_ROOT = ROOT / "generated/chat/copy/v1_3"
A_CANDIDATE = OUTPUT_ROOT / "a/CHAT.COPY.SURFACE.V1_3.candidate.png"
B_CLOSED = OUTPUT_ROOT / "b/CHAT.COPY.TOGGLE.CLOSED.V1_3.candidate.png"
B_OPEN = OUTPUT_ROOT / "b/CHAT.COPY.TOGGLE.OPEN.V1_3.candidate.png"
DIAGNOSTIC_DIR = OUTPUT_ROOT / "diagnostics"
PREVIEW_DIR = OUTPUT_ROOT / "previews"
BUILD_RECORD = OUTPUT_ROOT / "CHAT.COPY.V1_3.build.json"

AUTHORIZATION_COMMIT = "77fb32f804d0b06700fcef4f9562318635866baa"
EXPECTED_SOURCE_SHA256 = (
    "f45cfe614dffd4cbc1e17b1af0f6c66b2100f530c353e3954956476b7cf05057"
)
EXPECTED_DONOR_SHA256 = (
    "682459afa17ac43d3961085d211b340ed446152cf52fd2e7b250422316180e4b"
)
EXPECTED_SOURCE_SIZE = (1608, 978)
EXPECTED_DONOR_SIZE = (1254, 1254)

A_CROP = (270, 130, 1338, 827)
A_SIZE = (1140, 744)
A_SLICE_X = (0, 24, 1116, 1140)
A_SLICE_Y = (0, 24, 720, 744)
A_TEXT_SAFE = (30, 24, 1110, 720)

DONOR_CROP = (360, 242, 915, 994)
CANVAS_SIZE = (1024, 1024)
OUTER_BOX = (336, 304, 688, 720)
OUTER_SIZE = (352, 416)

LOWER_LEAF = ((336, 348), (674, 332), (687, 719), (344, 711))
UPPER_CLOSED = ((370, 328), (650, 340), (638, 672), (358, 690))
UPPER_OPEN = ((370, 328), (650, 340), (678, 684), (350, 704))
TOP_CLAMP = (
    (420, 312),
    (584, 304),
    (606, 338),
    (592, 378),
    (414, 370),
    (402, 340),
)

RUNTIME_BOOK_SIZE = (440, 320)
RUNTIME_SURFACE_SIZE = (380, 248)
RUNTIME_EXPANDED_SURFACE_SIZE = (480, 348)
RUNTIME_TOGGLE_SIZE = (22, 26)
RUNTIME_HIT_SIZE = (28, 32)
RUNTIME_SURFACE_POS = (30, 32)
RUNTIME_TOGGLE_POS = (404, 155)
RUNTIME_HIT_POS = (401, 152)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def save_png(image: Image.Image, path: Path) -> None:
    ensure_parent(path)
    image.save(path, format="PNG", compress_level=9)


def load_verified(
    path: Path,
    expected_size: tuple[int, int],
    expected_mode: str,
    expected_sha256: str,
) -> Image.Image:
    actual_sha = sha256(path)
    if actual_sha != expected_sha256:
        raise RuntimeError(
            f"Unexpected SHA-256 for {path}: {actual_sha} != {expected_sha256}"
        )
    image = Image.open(path)
    image.load()
    if image.size != expected_size or image.mode != expected_mode:
        raise RuntimeError(
            f"Expected {expected_size} {expected_mode}, got "
            f"{image.size} {image.mode}: {path}"
        )
    return image


def require_accepted_frame() -> Image.Image:
    return load_verified(
        SOURCE_FRAME,
        EXPECTED_SOURCE_SIZE,
        "RGBA",
        EXPECTED_SOURCE_SHA256,
    )


def require_donor() -> Image.Image:
    return load_verified(
        DONOR_RAW,
        EXPECTED_DONOR_SIZE,
        "RGB",
        EXPECTED_DONOR_SHA256,
    )


def require_a_candidate() -> Image.Image:
    if not A_CANDIDATE.is_file():
        raise RuntimeError("Build A before constructing B.")
    image = Image.open(A_CANDIDATE)
    image.load()
    if image.size != A_SIZE or image.mode != "RGBA":
        raise RuntimeError(
            f"Expected A {A_SIZE} RGBA, got {image.size} {image.mode}"
        )
    if image.getchannel("A").getextrema() != (255, 255):
        raise RuntimeError("A candidate must remain fully opaque.")
    return image


def cap_partial_green(image: Image.Image) -> Image.Image:
    """Reapply the authorized partial-alpha green cap after interpolation."""

    output = image.convert("RGBA").copy()
    pixels = output.load()
    for y in range(output.height):
        for x in range(output.width):
            red, green, blue, alpha = pixels[x, y]
            if 0 < alpha < 255:
                green = min(green, max(0, max(red, blue) - 1))
                pixels[x, y] = (red, green, blue, alpha)
    return output


def resize_rgba(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    """Lanczos-resize RGBA in premultiplied space and reapply spill cleanup."""

    if image.size == size:
        return cap_partial_green(image)
    premultiplied = image.convert("RGBA").convert("RGBa")
    resized = premultiplied.resize(size, Image.Resampling.LANCZOS)
    return cap_partial_green(resized.convert("RGBA"))


def render_nine_slice(
    source: Image.Image,
    target_size: tuple[int, int],
    destination_border: int = 8,
) -> Image.Image:
    target_width, target_height = target_size
    if target_width <= destination_border * 2:
        raise ValueError("Target width is smaller than the fixed borders.")
    if target_height <= destination_border * 2:
        raise ValueError("Target height is smaller than the fixed borders.")

    destination_x = (
        0,
        destination_border,
        target_width - destination_border,
        target_width,
    )
    destination_y = (
        0,
        destination_border,
        target_height - destination_border,
        target_height,
    )
    output = Image.new("RGBA", target_size, (0, 0, 0, 0))
    for row in range(3):
        for column in range(3):
            source_box = (
                A_SLICE_X[column],
                A_SLICE_Y[row],
                A_SLICE_X[column + 1],
                A_SLICE_Y[row + 1],
            )
            destination_box = (
                destination_x[column],
                destination_y[row],
                destination_x[column + 1],
                destination_y[row + 1],
            )
            tile = resize_rgba(
                source.crop(source_box),
                (
                    destination_box[2] - destination_box[0],
                    destination_box[3] - destination_box[1],
                ),
            )
            output.alpha_composite(tile, destination_box[:2])
    return output


def build_a() -> Image.Image:
    source = require_accepted_frame()
    crop = source.crop(A_CROP)
    if crop.size != (1068, 697):
        raise RuntimeError(f"Unexpected A crop size: {crop.size}")
    candidate = resize_rgba(crop, A_SIZE)
    candidate.putalpha(255)
    if candidate.size != A_SIZE or candidate.mode != "RGBA":
        raise RuntimeError("A candidate failed its size or mode contract.")
    if candidate.getchannel("A").getbbox() != (0, 0, *A_SIZE):
        raise RuntimeError("A candidate is not fully visible.")
    if (
        A_SLICE_X[2] - A_SLICE_X[1],
        A_SLICE_Y[2] - A_SLICE_Y[1],
    ) != (1092, 696):
        raise RuntimeError("A nine-slice center no longer matches the contract.")
    if (
        A_TEXT_SAFE[2] - A_TEXT_SAFE[0],
        A_TEXT_SAFE[3] - A_TEXT_SAFE[1],
    ) != (1080, 696):
        raise RuntimeError("A text-safe center no longer matches the contract.")
    save_png(candidate, A_CANDIDATE)

    real_size = render_nine_slice(candidate, RUNTIME_SURFACE_SIZE)
    expanded_size = render_nine_slice(
        candidate, RUNTIME_EXPANDED_SURFACE_SIZE
    )
    save_png(
        real_size,
        PREVIEW_DIR / "CHAT.COPY.SURFACE.V1_3.nineslice.380x248.png",
    )
    save_png(
        expanded_size,
        PREVIEW_DIR / "CHAT.COPY.SURFACE.V1_3.nineslice.480x348.png",
    )

    safe_area = real_size.copy()
    draw = ImageDraw.Draw(safe_area)
    draw.rectangle((10, 8, 369, 239), outline=(170, 35, 28, 255), width=1)
    save_png(
        safe_area,
        PREVIEW_DIR / "CHAT.COPY.SURFACE.V1_3.text-safe.380x248.png",
    )
    return candidate


def chroma_to_alpha(donor: Image.Image) -> Image.Image:
    if donor.mode != "RGB":
        raise ValueError("The fixed donor must be RGB.")
    output = Image.new("RGBA", donor.size, (0, 0, 0, 0))
    source_pixels = donor.load()
    output_pixels = output.load()
    for y in range(donor.height):
        for x in range(donor.width):
            red, green, blue = source_pixels[x, y]
            difference = green - max(red, blue)
            if difference >= 96:
                alpha = 0
            elif difference <= 16:
                alpha = 255
            else:
                t = (96.0 - difference) / 80.0
                value = 255.0 * t * t * (3.0 - 2.0 * t)
                alpha = int(value + 0.5)
                green = min(green, max(0, max(red, blue) - 1))
            output_pixels[x, y] = (red, green, blue, alpha)
    return output


def polygon_mask(points: Iterable[tuple[int, int]]) -> Image.Image:
    mask = Image.new("L", CANVAS_SIZE, 0)
    ImageDraw.Draw(mask).polygon(tuple(points), fill=255)
    return mask


def union_masks(*masks: Image.Image) -> Image.Image:
    output = Image.new("L", CANVAS_SIZE, 0)
    for mask in masks:
        output = ImageChops.lighter(output, mask)
    return output


def canvas_from_patch(patch: Image.Image) -> Image.Image:
    if patch.size != OUTER_SIZE:
        raise ValueError(f"Expected normalized patch {OUTER_SIZE}, got {patch.size}")
    canvas = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    canvas.alpha_composite(patch, OUTER_BOX[:2])
    return canvas


def masked_layer(material: Image.Image, mask: Image.Image) -> Image.Image:
    if material.size != CANVAS_SIZE or material.mode != "RGBA":
        raise ValueError("Layer material must be a full RGBA working canvas.")
    layer = material.copy()
    layer.putalpha(ImageChops.multiply(layer.getchannel("A"), mask))
    return layer


def solve_linear_system(
    matrix: list[list[float]], vector: list[float]
) -> list[float]:
    """Solve a square system with deterministic Gaussian elimination."""

    size = len(vector)
    augmented = [
        [float(value) for value in matrix[row]] + [float(vector[row])]
        for row in range(size)
    ]
    for column in range(size):
        pivot = max(range(column, size), key=lambda row: abs(augmented[row][column]))
        if abs(augmented[pivot][column]) < 1e-12:
            raise RuntimeError("Perspective correspondence is singular.")
        if pivot != column:
            augmented[column], augmented[pivot] = (
                augmented[pivot],
                augmented[column],
            )
        pivot_value = augmented[column][column]
        for entry in range(column, size + 1):
            augmented[column][entry] /= pivot_value
        for row in range(size):
            if row == column:
                continue
            factor = augmented[row][column]
            if factor == 0.0:
                continue
            for entry in range(column, size + 1):
                augmented[row][entry] -= factor * augmented[column][entry]
    return [augmented[row][size] for row in range(size)]


def perspective_coefficients(
    source: Sequence[tuple[int, int]],
    destination: Sequence[tuple[int, int]],
) -> tuple[float, ...]:
    """Return Pillow coefficients mapping destination pixels to source pixels."""

    if len(source) != 4 or len(destination) != 4:
        raise ValueError("Perspective transform requires four ordered corners.")
    matrix: list[list[float]] = []
    vector: list[float] = []
    for (source_x, source_y), (dest_x, dest_y) in zip(source, destination):
        matrix.append(
            [
                dest_x,
                dest_y,
                1.0,
                0.0,
                0.0,
                0.0,
                -source_x * dest_x,
                -source_x * dest_y,
            ]
        )
        vector.append(float(source_x))
        matrix.append(
            [
                0.0,
                0.0,
                0.0,
                dest_x,
                dest_y,
                1.0,
                -source_y * dest_x,
                -source_y * dest_y,
            ]
        )
        vector.append(float(source_y))
    return tuple(solve_linear_system(matrix, vector))


def warp_upper_open(closed_upper: Image.Image) -> Image.Image:
    coefficients = perspective_coefficients(UPPER_CLOSED, UPPER_OPEN)
    premultiplied = closed_upper.convert("RGBa")
    transformed = premultiplied.transform(
        CANVAS_SIZE,
        Image.Transform.PERSPECTIVE,
        coefficients,
        resample=Image.Resampling.BICUBIC,
        fillcolor=(0, 0, 0, 0),
    ).convert("RGBA")
    transformed = cap_partial_green(transformed)
    open_mask = polygon_mask(UPPER_OPEN)
    transformed.putalpha(
        ImageChops.multiply(transformed.getchannel("A"), open_mask)
    )
    return transformed


def compose_state(
    lower: Image.Image,
    upper: Image.Image,
    clamp: Image.Image,
    total_mask: Image.Image,
) -> Image.Image:
    output = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    output.alpha_composite(lower)
    output.alpha_composite(upper)
    output.alpha_composite(clamp)
    output.putalpha(
        ImageChops.multiply(output.getchannel("A"), total_mask)
    )
    return remove_subpixel_islands(cap_partial_green(output))


def difference_bbox(first: Image.Image, second: Image.Image) -> tuple[int, ...] | None:
    difference = ImageChops.difference(first, second)
    combined = Image.new("L", first.size, 0)
    for channel in difference.split():
        combined = ImageChops.lighter(combined, channel)
    return combined.getbbox()


def assert_no_pixels_outside(
    image: Image.Image, declared_mask: Image.Image, name: str
) -> None:
    leak = ImageChops.multiply(
        image.getchannel("A"), ImageChops.invert(declared_mask)
    )
    if leak.getbbox() is not None:
        raise RuntimeError(f"{name} contains visible pixels outside its masks.")


def remove_subpixel_islands(
    image: Image.Image,
    maximum_area: int = 4,
    maximum_alpha: int = 2,
) -> Image.Image:
    """Remove only disconnected resampling specks too faint to be surface pixels."""

    output = image.copy()
    alpha = output.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        return output
    x0, y0, x1, y1 = bbox
    width, height = alpha.size
    data = alpha.load()
    visited = bytearray(width * height)
    components: list[list[tuple[int, int]]] = []
    for y in range(y0, y1):
        for x in range(x0, x1):
            index = y * width + x
            if visited[index] or data[x, y] == 0:
                continue
            points: list[tuple[int, int]] = []
            queue: deque[tuple[int, int]] = deque([(x, y)])
            visited[index] = 1
            while queue:
                current_x, current_y = queue.popleft()
                points.append((current_x, current_y))
                for neighbor_x, neighbor_y in (
                    (current_x - 1, current_y),
                    (current_x + 1, current_y),
                    (current_x, current_y - 1),
                    (current_x, current_y + 1),
                ):
                    if (
                        neighbor_x < x0
                        or neighbor_x >= x1
                        or neighbor_y < y0
                        or neighbor_y >= y1
                    ):
                        continue
                    neighbor_index = neighbor_y * width + neighbor_x
                    if visited[neighbor_index] or data[neighbor_x, neighbor_y] == 0:
                        continue
                    visited[neighbor_index] = 1
                    queue.append((neighbor_x, neighbor_y))
            components.append(points)

    if len(components) <= 1:
        return output
    largest = max(components, key=len)
    for component in components:
        if component is largest:
            continue
        component_max_alpha = max(data[x, y] for x, y in component)
        if len(component) <= maximum_area and component_max_alpha <= maximum_alpha:
            for x, y in component:
                data[x, y] = 0
    output.putalpha(alpha)
    return output


def connected_components(alpha: Image.Image) -> int:
    bbox = alpha.getbbox()
    if bbox is None:
        return 0
    x0, y0, x1, y1 = bbox
    width, height = alpha.size
    data = alpha.load()
    visited = bytearray(width * height)
    components = 0
    for y in range(y0, y1):
        for x in range(x0, x1):
            index = y * width + x
            if visited[index] or data[x, y] == 0:
                continue
            components += 1
            queue: deque[tuple[int, int]] = deque([(x, y)])
            visited[index] = 1
            while queue:
                current_x, current_y = queue.popleft()
                for neighbor_x, neighbor_y in (
                    (current_x - 1, current_y),
                    (current_x + 1, current_y),
                    (current_x, current_y - 1),
                    (current_x, current_y + 1),
                ):
                    if (
                        neighbor_x < x0
                        or neighbor_x >= x1
                        or neighbor_y < y0
                        or neighbor_y >= y1
                    ):
                        continue
                    neighbor_index = neighbor_y * width + neighbor_x
                    if visited[neighbor_index] or data[neighbor_x, neighbor_y] == 0:
                        continue
                    visited[neighbor_index] = 1
                    queue.append((neighbor_x, neighbor_y))
    return components


def count_visible_green(image: Image.Image) -> int:
    count = 0
    for red, green, blue, alpha in image.getdata():
        if (
            alpha > 0
            and green >= 96
            and green > red + 48
            and green > blue + 48
        ):
            count += 1
    return count


def runtime_difference_metrics(
    closed: Image.Image, opened: Image.Image
) -> dict[str, object]:
    closed_runtime = resize_rgba(closed.crop(OUTER_BOX), RUNTIME_TOGGLE_SIZE)
    open_runtime = resize_rgba(opened.crop(OUTER_BOX), RUNTIME_TOGGLE_SIZE)
    difference = ImageChops.difference(closed_runtime, open_runtime)
    pixels = list(difference.getdata())
    channel_names = ("red", "green", "blue", "alpha")
    maxima: dict[str, int] = {}
    means: dict[str, float] = {}
    rms: dict[str, float] = {}
    for index, name in enumerate(channel_names):
        values = [pixel[index] for pixel in pixels]
        maxima[name] = max(values)
        means[name] = sum(values) / len(values)
        rms[name] = (sum(value * value for value in values) / len(values)) ** 0.5
    return {
        "size": list(RUNTIME_TOGGLE_SIZE),
        "changed_pixels": sum(any(channel > 0 for channel in pixel) for pixel in pixels),
        "total_pixels": len(pixels),
        "channel_maximum": maxima,
        "channel_mean": means,
        "channel_rms": rms,
    }


def assert_b_candidate(
    image: Image.Image,
    declared_mask: Image.Image,
    name: str,
) -> dict[str, object]:
    if image.size != CANVAS_SIZE or image.mode != "RGBA":
        raise RuntimeError(f"{name} failed the 1024x1024 RGBA contract.")
    bbox = image.getchannel("A").getbbox()
    if bbox != OUTER_BOX:
        raise RuntimeError(f"{name} bbox {bbox} != {OUTER_BOX}")
    assert_no_pixels_outside(image, declared_mask, name)
    components = connected_components(image.getchannel("A"))
    if components != 1:
        raise RuntimeError(f"{name} has {components} connected components.")
    visible_green = count_visible_green(image)
    if visible_green != 0:
        raise RuntimeError(f"{name} has {visible_green} visible green pixels.")
    return {
        "size": list(image.size),
        "mode": image.mode,
        "visible_bbox": list(bbox),
        "connected_components": components,
        "visible_green_pixels": visible_green,
    }


def build_b(paper: Image.Image) -> tuple[Image.Image, Image.Image, dict[str, object]]:
    donor = require_donor()
    donor_rgba = chroma_to_alpha(donor)
    donor_crop = donor_rgba.crop(DONOR_CROP)
    if donor_crop.size != (555, 752):
        raise RuntimeError(f"Unexpected donor crop size: {donor_crop.size}")
    normalized_patch = resize_rgba(donor_crop, OUTER_SIZE)
    normalized_donor = canvas_from_patch(normalized_patch)

    lower_patch = resize_rgba(paper.crop((0, 0, 600, 744)), OUTER_SIZE)
    lower_material = canvas_from_patch(lower_patch)

    lower_mask = polygon_mask(LOWER_LEAF)
    upper_closed_mask = polygon_mask(UPPER_CLOSED)
    upper_open_mask = polygon_mask(UPPER_OPEN)
    clamp_mask = polygon_mask(TOP_CLAMP)
    closed_total = union_masks(lower_mask, upper_closed_mask, clamp_mask)
    open_total = union_masks(lower_mask, upper_open_mask, clamp_mask)
    if closed_total.getbbox() != OUTER_BOX or open_total.getbbox() != OUTER_BOX:
        raise RuntimeError("Declared B masks no longer share the exact outer box.")

    lower_layer = masked_layer(lower_material, lower_mask)
    upper_closed_layer = masked_layer(normalized_donor, upper_closed_mask)
    upper_open_layer = warp_upper_open(upper_closed_layer)
    clamp_layer = masked_layer(normalized_donor, clamp_mask)

    closed = compose_state(
        lower_layer,
        upper_closed_layer,
        clamp_layer,
        closed_total,
    )
    opened = compose_state(
        lower_layer,
        upper_open_layer,
        clamp_layer,
        open_total,
    )

    closed_metrics = assert_b_candidate(closed, closed_total, "closed")
    open_metrics = assert_b_candidate(opened, open_total, "open")

    if difference_bbox(closed, opened) is None:
        raise RuntimeError("The open state is pixel-identical to the closed state.")
    upper_change_mask = union_masks(upper_closed_mask, upper_open_mask)
    difference = ImageChops.difference(closed, opened)
    combined_difference = Image.new("L", CANVAS_SIZE, 0)
    for channel in difference.split():
        combined_difference = ImageChops.lighter(combined_difference, channel)
    change_leak = ImageChops.multiply(
        combined_difference, ImageChops.invert(upper_change_mask)
    )
    if change_leak.getbbox() is not None:
        raise RuntimeError("State differences escaped the declared upper polygons.")

    save_png(closed, B_CLOSED)
    save_png(opened, B_OPEN)
    save_png(
        normalized_donor,
        DIAGNOSTIC_DIR / "CHAT.COPY.TOGGLE.DONOR.NORMALIZED.V1_3.png",
    )
    save_png(
        lower_layer,
        DIAGNOSTIC_DIR / "CHAT.COPY.TOGGLE.LOWER.SHARED.V1_3.png",
    )
    save_png(
        upper_closed_layer,
        DIAGNOSTIC_DIR / "CHAT.COPY.TOGGLE.UPPER.CLOSED.V1_3.png",
    )
    save_png(
        upper_open_layer,
        DIAGNOSTIC_DIR / "CHAT.COPY.TOGGLE.UPPER.OPEN.V1_3.png",
    )
    save_png(
        clamp_layer,
        DIAGNOSTIC_DIR / "CHAT.COPY.TOGGLE.CLAMP.SHARED.V1_3.png",
    )
    for state, masks in (
        (
            "CLOSED",
            {
                "LOWER": lower_mask,
                "UPPER": upper_closed_mask,
                "CLAMP": clamp_mask,
                "TOTAL": closed_total,
            },
        ),
        (
            "OPEN",
            {
                "LOWER": lower_mask,
                "UPPER": upper_open_mask,
                "CLAMP": clamp_mask,
                "TOTAL": open_total,
            },
        ),
    ):
        for part, mask in masks.items():
            save_png(
                mask,
                DIAGNOSTIC_DIR
                / f"CHAT.COPY.TOGGLE.{state}.{part}.MASK.V1_3.png",
            )

    metrics: dict[str, object] = {
        "closed": closed_metrics,
        "open": open_metrics,
        "state_difference_bbox": list(difference_bbox(closed, opened) or ()),
        "runtime_difference": runtime_difference_metrics(closed, opened),
        "shared_lower_sha256": sha256(
            DIAGNOSTIC_DIR / "CHAT.COPY.TOGGLE.LOWER.SHARED.V1_3.png"
        ),
        "shared_clamp_sha256": sha256(
            DIAGNOSTIC_DIR / "CHAT.COPY.TOGGLE.CLAMP.SHARED.V1_3.png"
        ),
    }
    return closed, opened, metrics


def checkerboard(
    size: tuple[int, int],
    cell: int = 8,
    light: tuple[int, int, int, int] = (196, 177, 142, 255),
    dark: tuple[int, int, int, int] = (82, 64, 47, 255),
) -> Image.Image:
    output = Image.new("RGBA", size, light)
    draw = ImageDraw.Draw(output)
    for y in range(0, size[1], cell):
        for x in range(0, size[0], cell):
            if (x // cell + y // cell) % 2:
                draw.rectangle(
                    (
                        x,
                        y,
                        min(x + cell - 1, size[0] - 1),
                        min(y + cell - 1, size[1] - 1),
                    ),
                    fill=dark,
                )
    return output


def composite_on_checker(image: Image.Image, cell: int = 8) -> Image.Image:
    background = checkerboard(image.size, cell)
    background.alpha_composite(image)
    return background


def require_book_preview() -> Image.Image:
    image = Image.open(BOOK_PREVIEW)
    image.load()
    if image.size != RUNTIME_BOOK_SIZE or image.mode != "RGBA":
        raise RuntimeError(
            f"Expected book preview {RUNTIME_BOOK_SIZE} RGBA, got "
            f"{image.size} {image.mode}"
        )
    return image


def runtime_toggle(candidate: Image.Image) -> Image.Image:
    return resize_rgba(candidate.crop(OUTER_BOX), RUNTIME_TOGGLE_SIZE)


def build_previews(
    paper: Image.Image,
    closed: Image.Image,
    opened: Image.Image,
) -> None:
    for state, candidate in (("CLOSED", closed), ("OPEN", opened)):
        crop = candidate.crop(OUTER_BOX)
        save_png(
            composite_on_checker(crop, 16),
            PREVIEW_DIR / f"CHAT.COPY.TOGGLE.{state}.CHECKER.V1_3.png",
        )
        runtime = runtime_toggle(candidate)
        save_png(
            runtime,
            PREVIEW_DIR / f"CHAT.COPY.TOGGLE.{state}.22x26.V1_3.png",
        )

        hit_preview = checkerboard(RUNTIME_HIT_SIZE, 4)
        hit_preview.alpha_composite(runtime, (3, 3))
        hit_draw = ImageDraw.Draw(hit_preview)
        hit_draw.rectangle((0, 0, 27, 31), outline=(230, 65, 45, 255), width=1)
        hit_draw.rectangle((3, 3, 24, 28), outline=(245, 210, 100, 255), width=1)
        hit_scaled = hit_preview.resize((168, 192), Image.Resampling.NEAREST)
        save_png(
            hit_scaled,
            PREVIEW_DIR / f"CHAT.COPY.TOGGLE.{state}.HITBOX.6X.V1_3.png",
        )

    closed_runtime = runtime_toggle(closed)
    open_runtime = runtime_toggle(opened)
    runtime_comparison = checkerboard((22 * 2 + 4, 26), 2)
    runtime_comparison.alpha_composite(closed_runtime, (0, 0))
    runtime_comparison.alpha_composite(open_runtime, (26, 0))
    ImageDraw.Draw(runtime_comparison).rectangle(
        (22, 0, 25, 25), fill=(36, 23, 15, 255)
    )
    runtime_comparison = runtime_comparison.resize(
        (480, 260), Image.Resampling.NEAREST
    )
    save_png(
        runtime_comparison,
        PREVIEW_DIR / "CHAT.COPY.TOGGLE.CLOSED-OPEN.10X.V1_3.png",
    )

    book = require_book_preview()
    surface = render_nine_slice(paper, RUNTIME_SURFACE_SIZE)

    off_assembly = book.copy()
    off_assembly.alpha_composite(closed_runtime, RUNTIME_TOGGLE_POS)
    on_assembly = book.copy()
    on_assembly.alpha_composite(surface, RUNTIME_SURFACE_POS)
    on_assembly.alpha_composite(open_runtime, RUNTIME_TOGGLE_POS)
    save_png(
        off_assembly,
        PREVIEW_DIR / "CHAT.COPY.ASSEMBLY.OFF.440x320.V1_3.png",
    )
    save_png(
        on_assembly,
        PREVIEW_DIR / "CHAT.COPY.ASSEMBLY.ON.440x320.V1_3.png",
    )

    debug = on_assembly.copy()
    debug_draw = ImageDraw.Draw(debug)
    debug_draw.rectangle((40, 40, 399, 271), outline=(65, 205, 235, 255), width=1)
    debug_draw.rectangle((401, 152, 428, 183), outline=(230, 65, 45, 255), width=1)
    debug_draw.rectangle((404, 155, 425, 180), outline=(245, 210, 100, 255), width=1)
    save_png(
        debug,
        PREVIEW_DIR / "CHAT.COPY.ASSEMBLY.ON.DEBUG.440x320.V1_3.png",
    )

    gap = 24
    comparison = checkerboard((440 * 2 + gap, 320), 12)
    comparison.alpha_composite(off_assembly, (0, 0))
    comparison.alpha_composite(on_assembly, (440 + gap, 0))
    divider = ImageDraw.Draw(comparison)
    divider.rectangle((440, 0, 440 + gap - 1, 319), fill=(36, 23, 15, 255))
    save_png(
        comparison,
        PREVIEW_DIR / "CHAT.COPY.ASSEMBLY.OFF-ON.V1_3.png",
    )


def write_build_record(
    paper: Image.Image,
    closed: Image.Image,
    opened: Image.Image,
    b_metrics: dict[str, object],
) -> None:
    record = {
        "schema": "aeui.chat-copy-candidate-build.v1",
        "component_version": "CHAT.COPY.V1.3",
        "authorization_commit": AUTHORIZATION_COMMIT,
        "network_access": False,
        "imagegen_called": False,
        "external_uploads": [],
        "inputs": {
            "accepted_frame": {
                "path": SOURCE_FRAME.relative_to(ROOT).as_posix(),
                "sha256": EXPECTED_SOURCE_SHA256,
                "size": list(EXPECTED_SOURCE_SIZE),
                "mode": "RGBA",
                "crop": list(A_CROP),
            },
            "surface_donor": {
                "path": DONOR_RAW.relative_to(ROOT).as_posix(),
                "sha256": EXPECTED_DONOR_SHA256,
                "size": list(EXPECTED_DONOR_SIZE),
                "mode": "RGB",
                "crop": list(DONOR_CROP),
            },
        },
        "outputs": {
            "a": {
                "path": A_CANDIDATE.relative_to(ROOT).as_posix(),
                "sha256": sha256(A_CANDIDATE),
                "size": list(paper.size),
                "mode": paper.mode,
                "visible_bbox": list(paper.getchannel("A").getbbox() or ()),
                "nine_slice_center": [1092, 696],
                "text_safe_center": [1080, 696],
            },
            "closed": {
                "path": B_CLOSED.relative_to(ROOT).as_posix(),
                "sha256": sha256(B_CLOSED),
                **b_metrics["closed"],
            },
            "open": {
                "path": B_OPEN.relative_to(ROOT).as_posix(),
                "sha256": sha256(B_OPEN),
                **b_metrics["open"],
            },
        },
        "geometry": {
            "canvas": list(CANVAS_SIZE),
            "outer_box_half_open": list(OUTER_BOX),
            "lower": [list(point) for point in LOWER_LEAF],
            "upper_closed": [list(point) for point in UPPER_CLOSED],
            "upper_open": [list(point) for point in UPPER_OPEN],
            "clamp": [list(point) for point in TOP_CLAMP],
            "layer_order": ["lower", "upper", "clamp"],
            "state_difference_bbox": b_metrics["state_difference_bbox"],
        },
        "shared_layers": {
            "lower_sha256": b_metrics["shared_lower_sha256"],
            "clamp_sha256": b_metrics["shared_clamp_sha256"],
        },
        "runtime_review": {
            "toggle_difference": b_metrics["runtime_difference"],
            "visual_verdict": "internal-reject: off/on are not legible at 22x26",
        },
    }
    ensure_parent(BUILD_RECORD)
    BUILD_RECORD.write_text(
        json.dumps(record, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def build_all() -> None:
    paper = build_a()
    closed, opened, b_metrics = build_b(paper)
    build_previews(paper, closed, opened)
    write_build_record(paper, closed, opened, b_metrics)
    print(f"A:      {A_CANDIDATE.relative_to(ROOT)} {sha256(A_CANDIDATE)}")
    print(f"closed: {B_CLOSED.relative_to(ROOT)} {sha256(B_CLOSED)}")
    print(f"open:   {B_OPEN.relative_to(ROOT)} {sha256(B_OPEN)}")
    print(f"record: {BUILD_RECORD.relative_to(ROOT)}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "command",
        choices=("build-a", "build-b", "build-previews", "build-all"),
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.command == "build-a":
        build_a()
        return
    if args.command == "build-b":
        paper = require_a_candidate()
        closed, opened, b_metrics = build_b(paper)
        write_build_record(paper, closed, opened, b_metrics)
        return
    if args.command == "build-previews":
        paper = require_a_candidate()
        closed = Image.open(B_CLOSED).convert("RGBA")
        opened = Image.open(B_OPEN).convert("RGBA")
        build_previews(paper, closed, opened)
        return
    build_all()


if __name__ == "__main__":
    main()
