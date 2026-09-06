"""Export accepted readout pixels at two texels per UI unit."""
from pathlib import Path
import hashlib
import json
from PIL import Image
from runtime_texture_compat import pad_to_power_of_two, content_uv

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/source/actionbars/readouts-v1"
OUTPUT = ROOT / "addon/AzerothExpeditionUI/Media/ActionBars/Readouts"


def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    accepted = json.loads((SOURCE / "Readouts_SourceManifest_v1.json").read_text())
    for record in accepted["files"]:
        assert hashlib.sha256((ROOT / record["file"]).read_bytes()).hexdigest() == record["sha256"]
    records = []
    for name, size in [("ReadoutShell", (524, 28)), ("CastFill", (128, 32)), ("SwingFill", (128, 32))]:
        with Image.open(SOURCE / (name + "_SourceV1.png")) as source:
            sample = source.convert("RGBA").resize(size, Image.Resampling.LANCZOS)
        if name == "ReadoutShell":
            sample.paste((0, 0, 0, 0), (2, 2, 522, 26))
            assert sample.crop((2, 2, 522, 26)).getchannel("A").getextrema() == (0, 0)
        container = pad_to_power_of_two(sample)
        path = OUTPUT / (name + "V1.tga")
        container.save(path)
        records.append(dict(file=path.relative_to(ROOT).as_posix(),
            sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
            logical_size=[v // 2 for v in size], sampled_size=size,
            texture_size=container.size, texels_per_ui=2, content_uv=content_uv(size)))
    manifest = dict(schema="aeui-readouts-runtime-v1", phase="P5", files=records,
        shell_slices_ui=[4, 254, 4, 1, 12, 1], outset_ui=1,
        route="actionbars.readout-art", dynamic_owner="pfUI")
    (SOURCE / "Readouts_RuntimeManifest_v1.json").write_text(json.dumps(manifest, indent=2))
    print("PASS readout source hashes, transparent live area and 2x runtime export")


if __name__ == "__main__":
    main()
