"""Export accepted satchel donor; UI geometry stays owned by Bagshui."""
from pathlib import Path
from PIL import Image
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
source = ROOT / 'assets/source/bagshui/frame-v1/SatchelDonorV1.png'
out = ROOT / 'addon/AzerothExpeditionUI/Media/Bagshui'
out.mkdir(parents=True, exist_ok=True)
im = Image.open(source).convert('RGBA')
im.resize((512, 512), Image.Resampling.LANCZOS).save(out / 'SatchelFrameV1.tga')
# Mirror a quiet central sample into a seamless repeat tile.
sample = im.crop((540, 540, 668, 668)).resize((64, 64), Image.Resampling.LANCZOS)
tile = Image.new('RGBA', (128, 128))
tile.paste(sample, (0, 0))
tile.paste(sample.transpose(Image.Transpose.FLIP_LEFT_RIGHT), (64, 0))
tile.paste(tile.crop((0, 0, 128, 64)).transpose(Image.Transpose.FLIP_TOP_BOTTOM), (0, 64))
tile.save(out / 'SatchelClothV1.tga')
files = [source, out / 'SatchelFrameV1.tga', out / 'SatchelClothV1.tga']
manifest = {'version': 1, 'corner_uv': [0, 0.125, 0.875, 1],
            'frame_border_ui': 12, 'cloth_tile_ui': 64, 'minimum_texels_per_ui': 2,
            'files': [{'path': p.relative_to(ROOT).as_posix(),
                       'size': list(Image.open(p).size),
                       'sha256': hashlib.sha256(p.read_bytes()).hexdigest()} for p in files]}
(source.parent / 'SatchelManifestV1.json').write_text(json.dumps(manifest, indent=2) + '\n')
assert tile.size == (128, 128)
print('Bagshui: frame and seamless cloth exported')
