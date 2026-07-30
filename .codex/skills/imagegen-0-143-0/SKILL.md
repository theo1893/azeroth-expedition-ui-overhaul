---
name: imagegen-0-143-0
description: "Generate, edit, modify, or transform bitmap images by delegating to the imagegen skill inside @openai/codex 0.143.0. Use when a Codex user asks for AI image generation, image editing, image modification, visual variants, reference-image-guided generation, local asset creation, marketing visuals, product imagery, photorealistic scenes, illustrations, or other raster image outputs and specifically needs the Codex 0.143.0 imagegen path."
---

# Imagegen 0.143.0

Use this skill to run image generation or image editing through a fixed Codex CLI version:
`@openai/codex@0.143.0`.

Do not call the current session's built-in `image_gen` tool for this skill. Delegate to a child Codex process with `$imagegen` in the prompt.

## Workflow

1. Clarify only if the request is missing a required subject, target image, or output destination.
2. Create the destination directory before running the command. Default to `./generated` when the user does not specify a path.
3. When the current repository also contains this wrapper skill, create an empty temporary
   working directory, pre-create its `generated/` child, and pass it through
   `codex exec -C <absolute-temp-dir> -s workspace-write`. Otherwise the fixed child can
   fail to save or rediscover this wrapper and recursively launch itself instead of
   resolving its built-in `$imagegen` skill.
4. For local input/reference/edit images, resolve each file to an absolute path first, then pass it with `-i <absolute-path>`. Do not use relative paths for image inputs.
5. `--image` is variadic in Codex `0.143.0`. Put a standalone `--` after the final image
   path and before the prompt; without it, the prompt can be consumed as another image path
   and `codex exec` fails with `No prompt provided via stdin`.
6. Put the user's image prompt after `$imagegen` verbatim. Do not rewrite, summarize, translate, expand, restructure, or "improve" the user's prompt.
7. Add only execution instructions that are not part of the image prompt, such as save
   location and final response format. Keep them in a separate `Execution instruction:`
   sentence after the verbatim prompt. That sentence must also state that the current
   child is already `@openai/codex@0.143.0`, must use its built-in `image_gen`, must not
   invoke this wrapper, and must not start another `codex`／`npx` subprocess.
8. Report the final usable output path. If read-only recovery was needed, report the
   recovered destination instead of the cache path alone.

Run the command directly:

```bash
npx --yes --package=@openai/codex@0.143.0 -- \
  codex exec \
  -C /absolute/path/to/empty-temp-directory \
  -s workspace-write \
  --skip-git-repo-check \
  -m gpt-5.5 \
  -c 'model_reasoning_effort="medium"' \
  -- \
  '$imagegen <verbatim user prompt>

Execution instruction: This Codex process is already @openai/codex@0.143.0. Fulfill the $imagegen request inside this process with its built-in image_gen tool. Do not read or invoke the imagegen-0-143-0 wrapper skill, and do not start any codex or npx subprocess. Save the final image to ./generated and output its absolute file path directly. No need to review and verify.'
```

With input images:

```bash
npx --yes --package=@openai/codex@0.143.0 -- \
  codex exec \
  -C /absolute/path/to/empty-temp-directory \
  -s workspace-write \
  --skip-git-repo-check \
  -m gpt-5.5 \
  -c 'model_reasoning_effort="medium"' \
  -i /absolute/path/to/assets/source.png \
  -i /absolute/path/to/assets/style-reference.jpg \
  -- \
  '$imagegen <verbatim user prompt>

Execution instruction: Image 1 is /absolute/path/to/assets/source.png. Image 2 is /absolute/path/to/assets/style-reference.jpg. This Codex process is already @openai/codex@0.143.0. Fulfill the $imagegen request inside this process with its built-in image_gen tool. Do not read or invoke the imagegen-0-143-0 wrapper skill, and do not start any codex or npx subprocess. Save the final image to ./generated and output its absolute file path directly. No need to review and verify.'
```

Attach assets by adding one `-i <absolute-path>` argument per image before the prompt:

```bash
npx --yes --package=@openai/codex@0.143.0 -- \
  codex exec \
  -C /absolute/path/to/empty-temp-directory \
  -s workspace-write \
  --skip-git-repo-check \
  -m gpt-5.5 \
  -c 'model_reasoning_effort="medium"' \
  -i /absolute/path/to/input.png \
  -i /absolute/path/to/reference.jpg \
  -- \
  '$imagegen <verbatim user prompt>

Execution instruction: Image 1 is /absolute/path/to/input.png. Image 2 is /absolute/path/to/reference.jpg. This Codex process is already @openai/codex@0.143.0. Fulfill the $imagegen request inside this process with its built-in image_gen tool. Do not read or invoke the imagegen-0-143-0 wrapper skill, and do not start any codex or npx subprocess. Save the final image to ./generated and output its absolute file path directly. No need to review and verify.'
```

### Windows PowerShell

On Windows PowerShell, do not pass a multiline prompt as an argument through `npx.cmd`,
and do not invoke `npx.ps1` with a splatted argument array:

- `npx.ps1` can reparse `@args` and resolve the wrong npm package.
- `npx.cmd` routes through `cmd.exe`; a multiline final argument can be truncated to its
  first line even when the process exits successfully.
- Resolve `npx.cmd`, put the complete `$imagegen ...` request plus the separate execution
  instruction on UTF-8 standard input, and use `-- -` after the final image. The `-`
  tells `codex exec` to read the initial instructions from stdin.

Use this pattern:

```powershell
$imagegenNpxCmd = (Get-Command npx.cmd -ErrorAction Stop).Source
$imagegenChildPrompt = '$imagegen ' + $verbatimPrompt + "`n`n" + $executionInstruction
$imagegenPreviousOutputEncoding = $OutputEncoding
$OutputEncoding = New-Object System.Text.UTF8Encoding($false)
try {
  $imagegenChildPrompt |
    & $imagegenNpxCmd --yes --package=@openai/codex@0.143.0 -- `
      codex exec -C $emptyTemporaryDirectory --skip-git-repo-check `
      -s workspace-write -m gpt-5.5 -c 'model_reasoning_effort="medium"' `
      -i $absoluteImage1 -i $absoluteImage2 -- -
} finally {
  $OutputEncoding = $imagegenPreviousOutputEncoding
}
```

Confirm the fixed child's printed `user` block contains the complete authorized prompt,
not only its first line. Treat a truncated transport as an internal failed attempt; record
its session/result, do not promote its output, and retry only with the same authorized body.
Also confirm that the child does not launch another fixed Codex process. Any observed
recursive `npx --package=@openai/codex@0.143.0 ... '$imagegen …'` invocation counts as
another fixed-executor call and must be interrupted and recorded.

## Prompt Preservation

Preserve the user's prompt exactly:

- Do not normalize wording.
- Do not add creative details.
- Do not convert the prompt into a schema.
- Do not add asset-type labels, taxonomy, style notes, or constraints that the user did not write.
- Do not fix grammar or spelling unless the user explicitly asks.
- If input image roles are not already stated by the user, describe only the absolute file-to-image mapping in `Execution instruction:` and leave the image prompt unchanged.

## Read-only child recovery

The fixed child can generate successfully while still being unable to copy or post-process
the image into the requested project directory because its shell sandbox is read-only.
When it reports an absolute generated-image cache path:

1. Copy that untouched file to the requested `generated/` destination as the raw result.
2. If it used a uniform chroma key, run the bundled deterministic
   `skills/.system/imagegen/scripts/remove_chroma_key.py` with a Python environment that
   already provides Pillow.
3. Keep both raw and transparent candidates under ignored `generated/`; do not promote
   either to tracked source assets without user review.
4. Record the fixed-version session, prompt file, raw path, transparent path, dimensions,
   and Alpha checks in the repository tracker.

## Reference

Read `references/usage.md` when you need examples for output paths, asset inputs, or command assembly.
