---
name: run-aeui-asset-workflow
description: "Run the repository-specific Azeroth Expedition UI component-asset workflow from contract and versioned prompt through fixed ImageGen 0.143.0 execution, semantic and technical review, revision, explicit user acceptance or rejection, source promotion, deterministic runtime export, tracker synchronization, target-client validation, and post-P6 closure cleanup. Use when generating, editing, reviewing, accepting, rejecting, promoting, exporting, validating, closing, or cleaning a fully accepted AEUI component, or when the user asks to continue the next UI asset step."
---

# AEUI Asset Workflow

Use this skill to keep every component asset on one traceable generate → review state
machine. This skill orchestrates the work; it does not replace the repository's fixed
`imagegen-0-143-0` executor.

## Read in this order

1. Read repository `AGENTS.md`, `docs/ASSET_PIPELINE.md`, and the relevant rows in
   `docs/implementation/OVERHAUL_TRACKER.md`.
2. Read the target module's visual specification, component specification, locked
   references, and current versioned prompt.
3. Read [state-machine.md](references/state-machine.md) for every operation.
4. Read [review-checklist.md](references/review-checklist.md) before reviewing,
   revising, rejecting, or presenting a candidate.
5. Read [repository-sync.md](references/repository-sync.md) before changing any
   tracked file or advancing a phase.
6. Read [record-templates.md](references/record-templates.md) when creating or
   updating a production prompt or review record.
7. For generation or image editing, additionally read
   `../imagegen-0-143-0/SKILL.md` and every reference that it requires.

Repository documents remain authoritative if this skill and the current checkout
disagree. Fix the skill and the authority document in the same change when the workflow
itself has changed.

## Select the operation

Infer only the narrowest operation authorized by the user:

| User intent | Operation | Highest allowed result |
|---|---|---|
| define, split, plan, write prompt | `prepare` | production draft |
| generate, edit, regenerate | `generate` | ignored raw candidate at `P3` |
| assess, inspect, compare, review | `review` | verdict and review evidence |
| correct, revise, try again | `revise` | new versioned `P3` candidate |
| reject, abandon this version | `reject` | recorded rejection; no source |
| accept, lock this asset | `accept` | confirmed source at `P4` |
| slice, atlas, integrate | `export` | tested runtime at `P5` |
| validate in Turtle WoW | `game-validate` | `P6` only after real-client evidence |
| finish, close, compact, clean completed work | `close` | `P6-C` after an approved cleanup plan |

“Continue” means proceed through the next unblocked gate shown by the tracker. It never
means silently accepting a candidate, promoting a source, or inventing missing runtime
geometry. It also never authorizes deleting intermediate files; closure requires a
version-specific cleanup plan and explicit user confirmation.

If the user asks only for an assessment, stay read-only. If the user explicitly asks to
generate, revise, accept, or export, perform the normal repository writes for that
operation.

## Enforce the gates

1. Do not generate without a complete component contract.
2. Do not execute a `production-draft` or a prompt version the user has not authorized.
3. Do not use a visual prototype as a runtime texture.
4. Do not present a candidate as viable until semantic structure has been checked.
5. Do not treat dimensions, Alpha, chroma-key cleanup, or connected regions as proof of
   correct anatomy, function, component identity, or style.
6. Do not copy anything into `assets/source/` without explicit user acceptance.
7. Do not export runtime media until the accepted source, crop/UV contract, safe areas,
   stretch rules, and target Frame geometry are known.
8. Do not mark `P6` without evidence from Turtle WoW `1.18.1`.
9. Do not remove intermediate or superseded files before `P6`, a verified final keep set,
   an exact cleanup inventory, and explicit user approval.

When a gate is blocked, state the missing evidence and perform any useful read-only
inspection still in scope. Do not create plausible-looking placeholder controls.

## Prepare

1. Resolve the exact module and component IDs from the tracker.
2. Map every visual object to a real pfUI, Blizzard, or external-provider object.
3. Record object count, state count, runtime size, source canvas, Alpha strategy, safe
   areas, stretch/crop rules, reference-image roles, forbidden baked content, acceptance
   preview, and fallback.
4. Rewrite the request against the locked art direction as a versioned professional
   prompt under `prompts/<module>/`.
5. Mark it `production-draft` and show the user the substantive changes. Wait for
   authorization before generation.

Do not split assets according to what is convenient for the model. Split them according
to runtime ownership, interaction state, z-order, and independent scaling behavior.

## Generate

1. Freeze the authorized prompt as `production`; never overwrite an executed version.
2. Use only `../imagegen-0-143-0/SKILL.md`. Do not call the current session's built-in
   image-generation tool.
3. Pass the approved execution body verbatim. Put absolute input paths, image-role
   mappings, and output instructions outside that body as required by the fixed executor.
4. Write raw, transparent, and preview files only under
   `generated/<module>/<component-or-batch>/<version>/`.
5. Record the executor version, session/result identifiers, exact output paths, and any
   executor-reported revised prompt. Never conceal an internal retry or silently replace
   the approved prompt with a different one.
6. Advance no further than `P3` until review and explicit user acceptance are complete.

## Review

Use the order in [review-checklist.md](references/review-checklist.md): semantic and
physical correctness first, then style, component contract, deterministic assembly, and
technical pixel checks. Inspect the image visually; metrics alone are insufficient.

For deterministic PNG metrics, run:

```bash
python3 .codex/skills/run-aeui-asset-workflow/scripts/inspect_candidate.py \
  /absolute/path/to/candidate.png
```

Pass repeated `--cell 'ID=x0,y0,x1,y1'` arguments when the production contract defines
fixed atlas cells. This checker reports Alpha, bounds, edge contact, SHA-256, and visible
green spill. It deliberately does not claim that a region is the correct logical object.

Produce a candidate preview at the real runtime size and intended z-order whenever the
asset participates in assembly. A contact sheet can prove inventory; only reassembly can
expose perspective, overlap, safe-area, stretch, and layer errors.

## Revise or reject

1. Lead with the verdict and the first failed gate.
2. Express corrections in structural terms: object identity, orientation, layer,
   perspective, overlap, free-motion space, crop, stretch, or state semantics.
3. Preserve the rejected prompt and execution record. Create a new prompt version for a
   new externally meaningful attempt.
4. Use a failed candidate as an edit input only when retaining its correct regions is
   intentional and the correction scope is explicit. Otherwise regenerate from the
   locked authority references to avoid carrying the defect forward.
5. Keep all failed images ignored under `generated/`; record durable rejection reasons in
   the prompt and tracker. Never create source or runtime files for a rejected version.

Preserve this evidence while production is active. After `P6`, the closure operation may
remove superseded tracked prompts and detailed attempt logs from the current tree only
after their necessary final provenance has been condensed and the user approves the exact
cleanup plan. Git history remains the historical archive.

## Accept

Acceptance must be explicit and version-specific. Then:

1. Copy only the accepted transparent master into
   `assets/source/<module>/<component>/`.
2. Add a source manifest containing SHA-256, dimensions, color mode, Alpha evidence,
   prompt path, executor/session provenance, accepted candidate path, component mapping,
   and forbidden runtime uses.
3. Update the prompt, component specification, and tracker in the same commit.
4. Mark `P4`; do not imply that runtime slicing or game validation has happened.

## Export and game-validate

Use deterministic tools for crop, Alpha, scale, atlas, format conversion, and preview.
Store reproducible intermediates in `generated/`. Commit runtime media only with its
manifest/UV mapping, Lua/XML ownership, tests, and documentation updates.

Mark `P5` only after static and relevant smoke tests pass. Mark `P6` only after real
Turtle WoW screenshots and interaction checks confirm scale, hit regions, state changes,
text safety, layering, fallback, and unaffected nonvisual behavior.

## Close after P6

Treat `P6` as fully accepted in game but not yet repository-closed. Read the terminal
cleanup rules in [repository-sync.md](references/repository-sync.md), then:

1. Verify the final prompt provenance, accepted source and manifest, deterministic
   exporter, runtime media/manifest, implementation, and P6 evidence.
2. Produce an exact component-scoped keep/delete inventory. Exclude shared assets, shared
   tools, active locked baselines, third-party evidence, licenses, and user originals.
3. Show the inventory to the user and obtain explicit approval before deletion.
4. Remove ignored raw/candidates/previews, superseded tracked prompts, obsolete
   component-only references/tools, and duplicated process narration approved in the
   plan. Do not purge Git history.
5. Compact the component specification and tracker to final contracts, final paths,
   final validation, and one concise closure result.
6. Run all relevant tests and confirm the checkout contains no dangling links or
   references to deleted files.
7. Mark `P6-C / component-closed` only in the same dedicated cleanup commit.

## Handoff

End each operation with:

- the exact component and prompt version;
- the current workflow substate and project phase;
- the verdict or artifact paths;
- the first remaining gate;
- for closure, the approved keep/delete inventory and final retained paths;
- tests run and their results;
- whether files are only local, committed, synchronized, or pushed.

Do not describe ignored generated files as durable cross-device assets.
