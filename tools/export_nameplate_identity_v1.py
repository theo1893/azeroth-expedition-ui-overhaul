"""Export accepted nameplate identity decorations at 2 texels per UI; no artwork changes."""
from pathlib import Path
import hashlib
import json
from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'assets/source/unitframes/nameplate-identity-v1'
MEDIA = ROOT / 'addon/AzerothExpeditionUI/Media/UnitFrames'
SPECS = [('left', 'NameplateIdentityCapLEFTV1', (8, 20), (32, 64), (0, 0)),
         ('right', 'NameplateIdentityCapRIGHTV1', (8, 20), (32, 64), (0, 0)),
         ('name', 'NameplateIdentityNameV1', (64, 10), (128, 32), (0, 0)),
         ('divider', 'NameplateIdentityDividerV1', (2, 14), (8, 32), (0, 0))]

def record(path):
    return {'file': path.relative_to(ROOT).as_posix(), 'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}

def main():
    sources, runtime = [], []
    for key, name, ui, texture_size, offset in SPECS:
        path = SOURCE / (key + '-source.png')
        source = Image.open(path).convert('RGBA')
        sampled = tuple(n * 2 for n in ui)
        art = ImageOps.contain(source, sampled, Image.Resampling.LANCZOS)
        sample = Image.new('RGBA', sampled)
        sample.paste(art, ((sampled[0]-art.width)//2, (sampled[1]-art.height)//2))
        texture = Image.new('RGBA', texture_size)
        texture.paste(sample, offset)
        texture.putdata([(r,g,b,a) if a else (0,0,0,0) for r,g,b,a in texture.getdata()])
        target = MEDIA / (name + '.tga')
        texture.save(target, compression=None)
        check = Image.open(target)
        assert check.mode == 'RGBA' and check.size == texture_size
        assert check.getchannel('A').getextrema()[0] == 0 and max(texture_size) <= 1024
        sources.append(dict(record(path), size=list(source.size)))
        runtime.append(dict(record(target), logical_size=list(ui), sampled_size=list(sampled),
                            texels_per_ui=2, texture_size=list(texture_size),
                            sample_box_exclusive=[*offset, offset[0]+sampled[0], offset[1]+sampled[1]]))
    data = dict(module='unitframes', component='UF.NAMEPLATE.IDENTITY', phase='P5',
                status='accepted-runtime-integrated', route='unitframes.nameplate-health-fill',
                sources=sources, runtime=runtime)
    (SOURCE/'NP-IDENTITY-V1_RuntimeManifest.json').write_text(json.dumps(data,indent=2)+'\n', encoding='utf-8')
    print('PASS identity V1: 4 RGBA textures at 2 texels/UI')

if __name__ == '__main__':
    main()
