"""Vanilla WoW compatible containers for accepted runtime pixels."""

from __future__ import annotations

from PIL import Image


VANILLA_MAX_TEXTURE_SIZE = 1024
DEFAULT_RUNTIME_TEXEL_DENSITY = 2


def is_power_of_two(value: int) -> bool:
    return value > 0 and value & (value - 1) == 0


def next_power_of_two(value: int) -> int:
    if value <= 0:
        raise ValueError(f"texture dimension must be positive: {value}")
    return 1 << (value - 1).bit_length()


def power_of_two_size(size: tuple[int, int]) -> tuple[int, int]:
    texture_size = tuple(next_power_of_two(value) for value in size)
    if max(texture_size) > VANILLA_MAX_TEXTURE_SIZE:
        raise ValueError(
            "Turtle WoW 1.12 runtime texture exceeds 1024px: "
            f"logical={size}, texture={texture_size}"
        )
    return texture_size


def sampled_size(
    logical_ui_size: tuple[int, int],
    texels_per_ui_unit: int = DEFAULT_RUNTIME_TEXEL_DENSITY,
) -> tuple[int, int]:
    """Return texture samples independently from the frame's UI geometry."""

    if texels_per_ui_unit < 1:
        raise ValueError(
            f"texels_per_ui_unit must be positive: {texels_per_ui_unit}"
        )
    return tuple(value * texels_per_ui_unit for value in logical_ui_size)


def sampled_content_uv(
    logical_ui_size: tuple[int, int],
    texels_per_ui_unit: int = DEFAULT_RUNTIME_TEXEL_DENSITY,
    texture_size: tuple[int, int] | None = None,
) -> list[float]:
    """Return UVs for a high-density sample displayed at logical UI size."""

    content_size = sampled_size(logical_ui_size, texels_per_ui_unit)
    return content_uv(content_size, texture_size)


def pad_to_power_of_two(image: Image.Image) -> Image.Image:
    """Place exact logical RGBA pixels at the top-left of a transparent POT TGA."""

    logical = image.convert("RGBA")
    texture_size = power_of_two_size(logical.size)
    texture = Image.new("RGBA", texture_size, (0, 0, 0, 0))
    texture.paste(logical, (0, 0))
    return texture


def content_uv(
    logical_size: tuple[int, int],
    texture_size: tuple[int, int] | None = None,
) -> list[float]:
    texture_width, texture_height = texture_size or power_of_two_size(logical_size)
    logical_width, logical_height = logical_size
    return [
        0.0,
        logical_width / texture_width,
        0.0,
        logical_height / texture_height,
    ]
