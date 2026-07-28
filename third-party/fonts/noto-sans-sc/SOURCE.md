# Noto Sans SC Medium source record

- Distribution project: `google/fonts`
- Repository: https://github.com/google/fonts
- Pinned distribution commit: `7ff85c87f93ea6cca5f41c69f2e4edcb90240f26`
- Distribution source path: `ofl/notosanssc/NotoSansSC[wght].ttf`
- Recorded upstream project: `notofonts/noto-cjk`
- Recorded upstream commit: `523d033d6cb47f4a80c58a35753646f5c3608a78`
- Embedded version: `2.004-H2`
- License: SIL Open Font License 1.1 with Reserved Font Name `Source`

## Source file

- Format: variable TrueType font
- File size: `17,772,300` bytes
- SHA-256: `a3041811a78c361b1de50f953c805e0244951c21c5bd412f7232ef0d899af0da`

Download URL:

```text
https://raw.githubusercontent.com/google/fonts/7ff85c87f93ea6cca5f41c69f2e4edcb90240f26/ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf
```

## Distributed static instance

- Output: `NotoSansSC-Medium.ttf`
- Weight: `500`
- Format: static TrueType font; the `fvar` table is absent
- File size: `10,589,136` bytes
- SHA-256: `d27380295503318833e1533734f4d147af6b2857eadae930f9f0c4e3e02ff8b2`
- Tool: FontTools `4.59.2`

Reproduction command:

```text
fonttools varLib.instancer NotoSansSC-wght.ttf wght=500 --static --update-name-table --no-recalc-timestamp -o NotoSansSC-Medium.ttf
```

Running the command twice with the pinned source and tool version produced byte-identical output. The generated primary font name does not use the reserved name `Source`.
