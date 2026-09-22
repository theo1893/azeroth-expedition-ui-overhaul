"""Export the approved native-ImageGen leather donor at 2 texels per UI unit."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageOps, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'assets/source/quests/ql-actions/QuestLogActionTabs_Master_v1.png'
RUNTIME = ROOT / 'addon/AzerothExpeditionUI/Media/Quests/QuestLogActionTabsV1.tga'
MANIFEST = SOURCE.with_name('QL-ACTIONS_RuntimeManifest_v1.json')
REVIEW = ROOT / 'generated/quests/footer-tabs'
SOURCE_SHA256 = 'dc9234944e587481f0815fb300765479990ef042db0379d50aa49079ec0a95b6'
BOXES = {64: (102, 88, 1152, 402), 58: (178, 510, 1079, 804), 50: (260, 900, 999, 1186)}
STATES = ('normal', 'hover', 'pressed', 'disabled')
LABELS = ('放弃任务', '分享任务', '退出', '收起详情', '显示标记', '隐藏标记', '清空标记', '重置标记')
ACTIONS = ((64, 64), (133, 64), (202, 64), (271, 50), (367, 58), (429, 58), (491, 58), (553, 58))


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def variants(normal: Image.Image) -> dict[str, Image.Image]:
    rgb, alpha = normal.convert('RGB'), normal.getchannel('A')
    disabled = Image.blend(rgb, ImageOps.grayscale(rgb).convert('RGB'), .65)
    images = {
        'normal': rgb,
        'hover': ImageEnhance.Brightness(rgb).enhance(1.16),
        'pressed': ImageEnhance.Brightness(rgb).enhance(.78),
        'disabled': ImageEnhance.Brightness(disabled).enhance(.76),
    }
    transparent = alpha.point(lambda value: 255 if value == 0 else 0)
    for key, image in images.items():
        image = image.convert('RGBA')
        image.putalpha(alpha)
        image.paste((0, 0, 0, 0), mask=transparent)
        assert image.getchannel('A').tobytes() == alpha.tobytes()
        images[key] = image
    return images


def preview(sprites: dict[int, dict[str, Image.Image]]) -> None:
    media = ROOT / 'addon/AzerothExpeditionUI/Media'
    book = Image.new('RGBA', (1352, 928))
    for x, side in ((0, 'Left'), (676, 'Right')):
        tile = Image.open(media / f'Quests/QuestLogShell{side}V4.tga').convert('RGBA')
        book.alpha_composite(tile.crop((0, 0, 676, 928)), (x, 0))
    font_path = Path('D:/Softwares/TurtleWoW/Fonts/FZXHLJW.ttf')
    if not font_path.is_file():
        font_path = media / 'Fonts/NotoSansSC-Medium.ttf'
    face = ImageFont.truetype(str(font_path), 20)
    title = ImageFont.truetype(str(media / 'Fonts/NotoSansSC-Medium.ttf'), 21)
    palette = {'normal': '#dec496', 'hover': '#f1d4a0', 'pressed': '#c6a572', 'disabled': '#958774'}
    board = Image.new('RGBA', (1392, 698), '#211c16')
    draw = ImageDraw.Draw(board)
    draw.text((20, 12), '原生 ImageGen 皮革签 · 实际 2× 采样／字体 · 三种宽度', font=title, fill='#e7d4b2')
    captions = ('普通（分享为禁用态）', '悬停', '按下（1 UI 下沉）', '禁用')
    for row, state in enumerate(STATES):
        y = 48 + row * 160
        draw.text((20, y), captions[row], font=title, fill='#cdb794')
        strip = book.crop((0, 776, 1352, 900))
        for index, (x, width) in enumerate(ACTIONS):
            current = 'disabled' if state == 'normal' and index == 1 else state
            press = 2 if current == 'pressed' else 0
            sprite = sprites[width][current]
            strip.alpha_composite(sprite, (x * 2, 36 + press))
            color = '#de8f73' if index == 0 and current == 'normal' else palette[current]
            label_width = face.getlength(LABELS[index])
            assert label_width <= width * 2 - 8, 'label exceeds its existing hitbox'
            ImageDraw.Draw(strip).text((x * 2 + width, 56 + press), LABELS[index], font=face, fill=color, anchor='mm')
        board.alpha_composite(strip, (20, y + 27))
    board.save(REVIEW / 'QuestLogActionTabsV1-in-context.png')


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=SOURCE)
    parser.add_argument('--review-only', action='store_true')
    args = parser.parse_args()
    assert digest(args.source) == SOURCE_SHA256, 'unexpected donor; do not replace accepted pixels silently'
    source = Image.open(args.source).convert('RGBA')
    assert source.size == (1254, 1254)
    # Native ImageGen left negligible alpha speckles in its transparent gutters.
    # Only alpha <= 8 is removed; RGB of every retained source pixel is untouched.
    alpha = source.getchannel('A').point(lambda value: value if value > 8 else 0)
    source.putalpha(alpha)
    atlas = Image.new('RGBA', (512, 256))
    sprites, records = {}, []
    for row, (width, box) in enumerate(BOXES.items()):
        band_top, band_bottom = round(row * source.height / 3), round((row + 1) * source.height / 3)
        band = source.crop((0, band_top, source.width, band_bottom))
        actual = band.getchannel('A').getbbox()
        assert (actual[0], actual[1] + band_top, actual[2], actual[3] + band_top) == box
        donor = source.crop(box)
        assert donor.width >= width * 2 and donor.height >= 40, 'upscaling is forbidden'
        fitted = ImageOps.contain(donor, (width * 2, 40), Image.Resampling.LANCZOS)
        normal = Image.new('RGBA', (width * 2, 40))
        normal.alpha_composite(fitted, ((width * 2 - fitted.width) // 2, (40 - fitted.height) // 2))
        # The 10 UI Chinese labels need a solid, uninterrupted central field.
        assert normal.getchannel('A').crop((width - 40, 12, width + 40, 30)).getextrema()[0] >= 220
        sprites[width] = variants(normal)
        record = {'logical_size_ui': [width, 20], 'sampled_size': [width * 2, 40],
                  'texels_per_ui_unit': 2, 'source_bbox': box,
                  'fitted_source_size': list(fitted.size), 'states': {}}
        for column, state in enumerate(STATES):
            x, y = column * 128 + (128 - width * 2) // 2, row * 64 + 12
            atlas.alpha_composite(sprites[width][state], (x, y))
            record['states'][state] = {'atlas_xyxy': [x, y, x + width * 2, y + 40],
                'texcoord': [x / 512, (x + width * 2) / 512, y / 256, (y + 40) / 256]}
        records.append(record)
    REVIEW.mkdir(parents=True, exist_ok=True)
    atlas.save(REVIEW / 'QuestLogActionTabsV1-atlas.png')
    preview(sprites)
    if not args.review_only:
        assert args.source.resolve() == SOURCE.resolve(), 'install only from the immutable source location'
        RUNTIME.parent.mkdir(parents=True, exist_ok=True)
        atlas.save(RUNTIME, format='TGA', compression=None)
        assert Image.open(RUNTIME).convert('RGBA').tobytes() == atlas.tobytes(), 'TGA pixel round-trip changed'
        manifest = {
            'schema_version': 1, 'module': 'quests', 'component': 'QL-ACTIONS-V1',
            'status': 'runtime-integrated-P5',
            'source': {'file': SOURCE.relative_to(ROOT).as_posix(), 'sha256': SOURCE_SHA256,
                       'size': list(source.size), 'generator': 'Codex native image_gen'},
            'transform': {'alpha_cleanup': 'alpha <= 8 becomes 0; retained RGB unchanged',
                          'resize': 'uniform LANCZOS containment plus transparent padding, never stretch or upscale',
                          'alpha_identical_across_states': True,
                          'hover_brightness': 1.16, 'pressed_brightness': .78,
                          'disabled_grayscale_mix': .65, 'disabled_brightness': .76,
                          'pressed_runtime_offset_ui': [0, -1]},
            'runtime': {'file': RUNTIME.relative_to(ROOT).as_posix(), 'sha256': digest(RUNTIME),
                        'texture_size': [512, 256], 'mode': 'RGBA', 'variants': records},
        }
        MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print('PASS action tabs: 3 widths, 4 matching-alpha states, 2x sampling, label clearance, 512x256 atlas')


if __name__ == '__main__':
    main()
