# Noto Serif SC SemiBold source record

- Distribution project: `google/fonts`
- Repository: https://github.com/google/fonts
- Pinned distribution commit: `7ff85c87f93ea6cca5f41c69f2e4edcb90240f26`
- Distribution source path: `ofl/notoserifsc/NotoSerifSC[wght].ttf`
- Recorded upstream project: `notofonts/noto-cjk`
- Recorded upstream commit: `985fa52c81c1d6692ccdd82bc3656e8fb932fd89`
- Embedded version: `2.003-H1`
- License: SIL Open Font License 1.1

## Source file

- Format: variable TrueType font
- File size: `25,125,512` bytes
- SHA-256: `050080d9255a86808f2945bffac582b31ef32bc36411ce29563b4961670c66f9`

Download URL:

```text
https://raw.githubusercontent.com/google/fonts/7ff85c87f93ea6cca5f41c69f2e4edcb90240f26/ofl/notoserifsc/NotoSerifSC%5Bwght%5D.ttf
```

## Distributed static instance

- Output: `NotoSerifSC-SemiBold.ttf`
- Weight: `600`
- Format: static TrueType font; the `fvar` table is absent
- File size: `14,854,180` bytes
- SHA-256: `e827457c14fb9cd2eaf2101b60393c76b6b074e42986bbe4b65f45557860d17c`
- Tool: FontTools `4.59.2`

Reproduction command:

```text
fonttools varLib.instancer NotoSerifSC-wght.ttf wght=600 --static --update-name-table --no-recalc-timestamp -o NotoSerifSC-SemiBold.ttf
```

Running the command twice with the pinned source and tool version produced byte-identical output.
