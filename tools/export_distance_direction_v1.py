"""Rotate the accepted high-resolution pointer into 108 two-texel UI frames."""
from pathlib import Path
from PIL import Image
import hashlib, json, math
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'assets/source/unitframes/distance-direction-v1'
source=SOURCE/'pointer-source.png'
src=Image.open(source).convert('RGBA')
side=math.ceil(math.hypot(*src.size))+4
master=Image.new('RGBA',(side,side))
master.paste(src,((side-src.width)//2,(side-src.height)//2))
atlas=Image.new('RGBA',(512,256))
for i in range(108):
    sample=master.rotate(i*360/108,resample=Image.Resampling.BICUBIC).resize((30,30),Image.Resampling.LANCZOS)
    frame=Image.new('RGBA',(32,32)); frame.paste(sample,(1,1))
    for edge in [(0,0,32,1),(0,31,32,32),(0,0,1,32),(31,0,32,32)]:
        assert frame.getchannel('A').crop(edge).getbbox() is None
    atlas.paste(frame,((i%16)*32,(i//16)*32))
atlas.putdata([(r,g,b,a) if a else (0,0,0,0) for r,g,b,a in atlas.getdata()])
target=ROOT/'addon/AzerothExpeditionUI/Media/UnitFrames/DistanceDirectionV1.tga'
atlas.save(target,compression=None)
def record(path):
    return dict(file=path.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(path.read_bytes()).hexdigest())
data=dict(module='unitframes',component='UF.DISTANCE.DIRECTION',phase='P5',status='accepted-runtime-integrated',
          source=record(source),runtime=dict(record(target),texture_size=[512,256],frame_count=108,columns=16,
          frame_size=[32,32],logical_size=[16,16],sampled_size=[32,32],texels_per_ui=2),
          rotation='counterclockwise from up; each frame derived directly from high-resolution source')
(SOURCE/'DISTANCE-DIRECTION-V1_RuntimeManifest.json').write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
print('PASS 108 frames: 2 texels/UI, transparent margins, 512x256 RGBA')
