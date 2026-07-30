# Imagegen 0.143.0 Usage

## One-shot generation

```bash
npx --yes --package=@openai/codex@0.143.0 -- \
  codex exec \
  -C /absolute/path/to/empty-temp-directory \
  -s workspace-write \
  --skip-git-repo-check \
  -m gpt-5.5 \
  -c 'model_reasoning_effort="medium"' \
  -- \
  '$imagegen Generate a professional, polished photorealistic image of Hong Kong Victoria Harbour at golden hour, with the skyline and harbour clearly visible. Place a large, clean, modern overlay text prominently in the center foreground. The poster must contain only this exact text, rendered clearly and verbatim: "https://eagleagentic.ai". Style: premium corporate campaign visual, realistic photography, elegant composition, sharp focus, balanced lighting, no clutter, no cartoon style. Composition: wide landscape view, poster centered and readable, harbour and skyline visible behind it, suitable for a professional website or marketing asset.

Execution instruction: Save the final image to ./generated and output its absolute file path directly. No need to review and verify.'
```

## Edit with a target image

```bash
npx --yes --package=@openai/codex@0.143.0 -- \
  codex exec \
  -C /absolute/path/to/empty-temp-directory \
  -s workspace-write \
  --skip-git-repo-check \
  -m gpt-5.5 \
  -c 'model_reasoning_effort="medium"' \
  -i /absolute/path/to/source.png \
  -- \
  '$imagegen Replace the background with a clean studio setting. Keep the product shape, label, proportions, and camera angle unchanged.

Execution instruction: Image 1 is /absolute/path/to/source.png. Save the final image to ./generated and output its absolute file path directly. No need to review and verify.'
```

## Generate from references

```bash
npx --yes --package=@openai/codex@0.143.0 -- \
  codex exec \
  -C /absolute/path/to/empty-temp-directory \
  -s workspace-write \
  --skip-git-repo-check \
  -m gpt-5.5 \
  -c 'model_reasoning_effort="medium"' \
  -i /absolute/path/to/style.jpg \
  -i /absolute/path/to/layout.png \
  -- \
  '$imagegen Generate a new website hero image with the same mood and composition, not a copy.

Execution instruction: Image 1 is /absolute/path/to/style.jpg. Image 2 is /absolute/path/to/layout.png. Save the final image to ./generated and output its absolute file path directly. No need to review and verify.'
```

## Manual command

```bash
npx --yes --package=@openai/codex@0.143.0 -- \
  codex exec \
  -C /absolute/path/to/empty-temp-directory \
  -s workspace-write \
  --skip-git-repo-check \
  -m gpt-5.5 \
  -c 'model_reasoning_effort="medium"' \
  -i /absolute/path/to/source.png \
  -- \
  '$imagegen <verbatim user prompt>

Execution instruction: Image 1 is /absolute/path/to/source.png. Save the final image to ./generated and output its absolute file path directly. No need to review and verify.'
```

`codex exec` accepts repeated `-i/--image <FILE>` arguments for image inputs.
Resolve local input images to absolute paths before passing them to `-i`.
Keep the image prompt verbatim. Put file-role mapping and save-path requirements only in the separate `Execution instruction:` line.

When this wrapper is stored inside the current repository, run the fixed child from an empty
temporary directory via `-C`, pre-create that directory's `generated/`, and use
`-s workspace-write`. In the separate execution instruction, state that this fixed child
must use its own built-in `image_gen` and must not invoke the wrapper or another
`codex`／`npx` subprocess. The standalone `--` after the final `-i` is required because
Codex `0.143.0` treats `--image` as variadic and can otherwise consume the prompt.

On Windows PowerShell, pass the complete multiline request through UTF-8 stdin and end the
argument list with `-- -`. Use `npx.cmd`, not `npx.ps1`; do not pass the multiline request
as a `npx.cmd` argument because `cmd.exe` can truncate it at the first newline. The full
PowerShell pattern is maintained in the parent `SKILL.md`.

For a bounded parent workflow, count only a request that returns an image or provider
evidence that built-in `image_gen` actually ran. A generated but unusable candidate counts;
a launch, transport, recursion, permission, upload, connection, or save error with no
generation evidence is a separately recorded process error and does not consume the image
budget.
