"""Extract text-free component art from the approved workbench concept."""
import hashlib
import json
from pathlib import Path
from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'assets/source/professions/workbench-v2/approved.png'
MEDIA = ROOT / 'addon/AzerothExpeditionUI/Media/Professions'
im = Image.open(SOURCE).convert('RGBA')
records = []

def save(name, image, crop, ui):
    target = MEDIA / (name + '.tga')
    assert image.width <= 1024 and image.height <= 1024
    assert image.width & (image.width - 1) == 0 and image.height & (image.height - 1) == 0
    image.save(target, compression=None)
    records.append({'file': target.relative_to(ROOT).as_posix(),
                    'sha256': hashlib.sha256(target.read_bytes()).hexdigest(),
                    'source_regions': crop, 'size': list(image.size), 'ui': ui})

def crop_resize(box, size):
    src = im.crop(box)
    assert src.width >= size[0] and src.height >= size[1], (box, size)
    return src.resize(size, Image.Resampling.LANCZOS)

def chrome(name, box):
    # A dedicated 2 UI rim: source corners are never squeezed from the large frame.
    x0,y0,x1,y1 = box
    xs,ys = [x0,x0+8,x1-8,x1], [y0,y0+8,y1-8,y1]
    out = Image.new('RGBA',(32,32))
    dest=[0,4,28,32]
    for row in range(3):
        for col in range(3):
            if row == col == 1: continue
            patch=im.crop((xs[col],ys[row],xs[col+1],ys[row+1]))
            # Use only edge pixels; the concept's labels/icons are excluded.
            size=(dest[col+1]-dest[col],dest[row+1]-dest[row])
            if col==1: patch=patch.crop((0,0,24,patch.height))
            if row==1: patch=patch.crop((0,0,patch.width,24))
            assert patch.width >= size[0] and patch.height >= size[1]
            out.paste(patch.resize(size,Image.Resampling.LANCZOS),(dest[col],dest[row]))
    save(name,out,[box],[16,16])

def main():
    MEDIA.mkdir(parents=True, exist_ok=True)
    save('WorkbenchLeatherV2',im.crop((1100,700,1228,828)),[[1100,700,1228,828]],[64,64])
    # Standalone straight strips repeat at native density instead of stretching.
    for name,box in [('WoodTopV2',(180,8,436,40)),('WoodBottomV2',(180,1024,436,1056))]:
        save(name,im.crop(box),[box],[128,16])
    for name,box in [('WoodLeftV2',(8,280,40,536)),('WoodRightV2',(1437,280,1469,536))]:
        save(name,im.crop(box),[box],[16,128])
    for name,box in [('CornerTLV2',(0,0,64,64)),('CornerTRV2',(1413,1001,1477,1065)),
                     ('CornerBLV2',(0,1001,64,1065)),('CornerBRV2',(1413,1001,1477,1065))]:
        corner=crop_resize(box,(32,32))
        if name=='CornerTRV2': corner=ImageOps.flip(corner)
        save(name,corner,[box],[16,16])
    chrome('PanelRimV2',(701,207,1428,932))
    chrome('ButtonRimV2',(704,948,867,1010))
    chrome('InputRimV2',(937,948,1044,1010))
    for name,box in [('TitleLeftV2',(520,0,575,65)),('TitleRightV2',(902,0,954,65))]:
        out=Image.new('RGBA',(64,64));out.paste(crop_resize(box,(48,64)),(0,0))
        save(name,out,[box],[24,32])
    title=im.crop((1100,700,1228,764))
    title.paste(im.crop((600,0,728,6)),(0,0))
    title.paste(im.crop((600,59,728,65)),(0,58))
    save('TitleMiddleV2',title,[[1100,700,1228,764],[600,0,728,6],[600,59,728,65]],[64,32])
    # Single static thumb/glyph sprites, padded to power-of-two dimensions.
    sprites=[('ThumbV2',(628,258,650,294),(16,28)),
             ('ArrowUpV2',(628,222,653,249),(20,20)),
             ('ArrowDownV2',(628,925,653,953),(20,20)),
             ('ArrowLeftV2',(895,958,922,994),(20,28)),
             ('ArrowRightV2',(1052,958,1079,994),(20,28)),
             ('CloseV2',(1424,23,1450,49),(20,20))]
    for name,box,size in sprites:
        out=Image.new('RGBA',(32,32)); out.paste(crop_resize(box,size),(0,0))
        save(name,out,[box],[size[0]/2,size[1]/2])
    manifest={'schema':1,'component':'professions.workbench-v2','texels_per_ui_unit':2,
      'source':{'file':SOURCE.relative_to(ROOT).as_posix(),'sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest()},
      'runtime':records,'notes':'Only text-free border/fill/glyph regions are exported. Wood strips tile at native density; runtime labels and item icons are never baked.'}
    (SOURCE.parent/'WORKBENCH-V2_RuntimeManifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    # Contact sheet for visual checking of the actual exported media.
    sheet=Image.new('RGB',(768,((len(records)+3)//4)*160),(55,50,45))
    from PIL import ImageDraw
    draw=ImageDraw.Draw(sheet)
    for i,r in enumerate(records):
        sample=Image.open(ROOT/r['file']).convert('RGBA')
        sample.thumbnail((180,124))
        x,y=(i%4)*192,(i//4)*160
        sheet.paste(sample,(x,y+22),sample);draw.text((x+3,y+3),Path(r['file']).stem,fill='white')
    out=ROOT/'generated/professions';out.mkdir(parents=True,exist_ok=True)
    sheet.save(out/'workbench-v2-contact.png')
    print(f'Exported {len(records)} component textures')

if __name__ == '__main__': main()
