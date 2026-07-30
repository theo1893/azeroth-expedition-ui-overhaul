---
name: run-aeui-asset-workflow
description: "Run the repository-specific Azeroth Expedition UI component-asset workflow with locked-baseline prompt provenance, compact per-component work files, art-language inheritance, and a bounded five-call autonomous generate-review-repair loop, from component contract and fixed ImageGen 0.143.0 execution through explicit acceptance or rejection, source promotion, runtime export, module-progress synchronization, target-client validation, and post-P6 work-file cleanup. Use when generating, editing, reviewing, accepting, rejecting, promoting, exporting, validating, closing, or cleaning an AEUI component, or when the user asks to continue the next UI asset step."
---

# AEUI Asset Workflow

Use this skill to keep every component asset on one traceable generate → review state
machine. This skill orchestrates the work; it does not replace the repository's fixed
`imagegen-0-143-0` executor.

## Read in this order

1. Read repository `AGENTS.md`. It is the project index and current overall snapshot.
2. Read `docs/GLOBAL_ART_BASELINE.md`, then the target module's `SUBMODULES.md`,
   `ART_BASELINE.md`, `SUBMODULE_ART_BASELINES.md`, `PROGRESS.md`, and every existing
   target-component file under `docs/modules/<module>/work/`.
3. Resolve every locked reference to the module/submodule baseline prompt that produced
   or semantically locked it. Read those prompt bodies in full. Also read explicitly
   linked upstream material baselines. A locked image without prompt provenance is an
   incomplete authority.
4. Read [state-machine.md](references/state-machine.md) for every operation.
5. Read [review-checklist.md](references/review-checklist.md) before reviewing,
   revising, rejecting, or presenting a candidate.
6. Read [repository-sync.md](references/repository-sync.md) before changing any
   tracked file or advancing a phase.
7. Read [record-templates.md](references/record-templates.md) when creating or
   updating a production prompt or review record.
8. For generation or image editing, additionally read
   `../imagegen-0-143-0/SKILL.md` and every reference that it requires.

Repository documents remain authoritative if this skill and the current checkout
disagree. Fix the skill and the authority document in the same change when the workflow
itself has changed.

## Resolve visual authority and inheritance

Treat runtime geometry and visual identity as two compatible but distinct authorities:

1. The component specification controls real objects, states, z-order, dimensions,
   safe areas, crop/stretch behavior, and forbidden baked content.
2. `assets/locked/<module>/` plus the versioned prompt provenance that produced it
   control object metaphor, silhouette language, material relationships, palette,
   brushwork, light direction, wear scale, and period identity.
3. The module `ART_BASELINE.md`, `SUBMODULE_ART_BASELINES.md`, and
   `docs/GLOBAL_ART_BASELINE.md` refine that locked identity.
4. Accepted `assets/source/` and structural references may constrain geometry or a
   named material sample, but may never become a higher visual authority than the
   locked baseline.
5. Failed candidates provide negative evidence only unless an edit operation explicitly
   names a region to preserve.

Before writing an execution body, create an in-file art-inheritance block that records:

- every locked baseline image and its provenance prompt path;
- the mandatory visual DNA extracted from those prompts;
- how each inherited rule is translated to this component batch;
- full-frame elements deliberately excluded by the component contract;
- conflicts between sources and the authority-based resolution.

Do not paste a prototype prompt mechanically. Preserve its invariant art language while
filtering out buttons, text, decoration, or geometry owned by other runtime components.
Do not use vague substitutes such as “same style” or “more epic” in place of the extracted
rules.

## Use the compact document lifecycle

Keep one active Markdown work file per incomplete component or tightly coupled asset batch:

```text
docs/modules/<module>/work/<COMPONENT-OR-BATCH>.md
```

The work file contains the current versioned execution body, component contract, prompt
inheritance, compact attempt ledger, execution evidence, review, and next gate. Do not
create a separate permanent Markdown file for every attempt, audit, preview, decision, or
runtime media list.

Before executing a prompt, commit the authorized work-file version so its exact body is in
Git history. During the bounded repair loop, append the failed attempt and the complete
derived repair body to the same work file, then commit them before the next invocation.
After loop exhaustion or user rejection, record the terminal rejection in that file.
Git history is the full archive; the current tree contains only the evidence needed for
the next decision.

When the component reaches `P6-C`, merge final stable visual clauses into
`SUBMODULE_ART_BASELINES.md`, final object ownership into `SUBMODULES.md`, and final paths
and validation into module `PROGRESS.md` and manifests. Then delete the component work file
and ignored generated directory. Never keep an empty `work/` directory by adding placeholder
files.

## Select the operation

Infer only the narrowest operation authorized by the user:

| User intent | Operation | Highest allowed result |
|---|---|---|
| define, split, plan, write prompt | `prepare` | production draft |
| generate, edit, regenerate | `generate` | internally reviewed candidate at `P3` after at most five fixed-executor calls |
| assess, inspect, compare, review | `review` | verdict and review evidence |
| correct, revise, try again | `revise` | new versioned `P3` candidate |
| reject, abandon this version | `reject` | recorded rejection; no source |
| accept, lock this asset | `accept` | confirmed source at `P4` |
| slice, atlas, integrate | `export` | tested runtime at `P5` |
| validate in Turtle WoW | `game-validate` | `P6` only after real-client evidence |
| finish, close, compact, clean completed work | `close` | `P6-C` after an approved cleanup plan |

“Continue” means proceed through the next unblocked gate shown by module progress. If that
gate is prompt authorization, stop after preparing and presenting the exact versioned
execution body, its repair envelope, and its five-call budget; “continue” or “next step”
alone does not authorize generation. Explicit authorization of that version covers its
bounded in-scope repair attempts, but never means silently accepting a candidate,
promoting a source, inventing missing runtime geometry, or deleting intermediates.
Generation and closure require explicit, version-specific confirmation.

If the user asks only for an assessment, stay read-only. If the user explicitly asks to
generate, revise, accept, or export, perform the normal repository writes for that
operation.

## Enforce the gates

1. Do not generate without a complete component contract.
2. Do not authorize or execute a production prompt without a complete locked-baseline
   provenance chain, an art-inheritance block, and a resolved authority/conflict audit.
3. Do not execute a `production-draft` or a prompt version the user has not explicitly
   authorized by version after seeing its execution body.
4. Do not use a visual prototype as a runtime texture.
5. Do not present a candidate as viable until semantic structure has been checked.
6. Do not treat dimensions, Alpha, chroma-key cleanup, or connected regions as proof of
   correct anatomy, function, component identity, or style.
7. Do not copy anything into `assets/source/` without explicit user acceptance.
8. Do not export runtime media until the accepted source, crop/UV contract, safe areas,
   stretch rules, and target Frame geometry are known.
9. Do not mark `P6` without evidence from Turtle WoW `1.18.1`.
10. Do not remove intermediate or superseded files before `P6`, a verified final keep set,
   an exact cleanup inventory, and explicit user approval.
11. Never invoke the fixed executor more than five times for one authorized execution
    body. The first generation is attempt 1; every invocation counts, including transport
    failures and unusable outputs.
12. Autonomous repair may change only the repairable wording, edit/regenerate choice, and
    use of an earlier output from the same loop. It may not change component identity,
    object/state count, authority order, reference roles, canvas/runtime contract,
    forbidden content, or add a new external input without new user authorization.

When a gate is blocked, state the missing evidence and perform any useful read-only
inspection still in scope. Do not create plausible-looking placeholder controls.

## Prepare

1. Resolve the exact module and component IDs from module `SUBMODULES.md` and
   `PROGRESS.md`.
2. Map every visual object to a real pfUI, Blizzard, or external-provider object.
3. Record object count, state count, runtime size, source canvas, Alpha strategy, safe
   areas, stretch/crop rules, reference-image roles, forbidden baked content, acceptance
   preview, and fallback.
4. Resolve the locked baseline image-to-prompt provenance chain and write the
   art-inheritance/conflict block before the creative body.
5. Rewrite the request against that resolved authority as the active versioned prompt in
   `docs/modules/<module>/work/<COMPONENT-OR-BATCH>.md`. State secondary source limits
   explicitly; never call an `assets/source/` derivative the highest visual authority.
6. Record the immutable repair envelope and `5`-call budget. For a batch with multiple
   independent execution bodies, state each body's budget and the worst-case aggregate
   call count.
7. Mark it `production-draft` and show the user the substantive changes. Wait for
   authorization before generation.

Do not split assets according to what is convenient for the model. Split them according
to runtime ownership, interaction state, z-order, and independent scaling behavior.

## Generate

1. Re-run the provenance, authority-order, and contradiction preflight. If any locked
   baseline prompt is unresolved or a derivative source outranks it, return to `prepare`.
2. Freeze the explicitly authorized prompt as `production`; never overwrite an executed
   version.
3. Freeze the repair envelope: component IDs, object/state inventory, visual authority,
   reference roles, canvas/runtime geometry, Alpha strategy, forbidden baked content,
   permitted edit inputs, and the maximum of five fixed-executor invocations.
4. Use only `../imagegen-0-143-0/SKILL.md`. Do not call the current session's built-in
   image-generation tool.
5. Pass attempt 1's approved execution body verbatim. Put absolute input paths,
   image-role mappings, and output instructions outside that body as required by the
   fixed executor.
6. Write raw, transparent, and preview files only under
   `generated/<module>/<component-or-batch>/<version>/`.
7. Record the executor version, attempt number, session/result identifiers, exact output
   paths, and any
   executor-reported revised prompt in the active work file. Never conceal an internal
   retry or silently replace an executed prompt.
8. Run the bounded loop below. Advance no further than `P3` until review and explicit
   user acceptance are complete.

## Run the bounded autonomous repair loop

Use one budget of at most `5` fixed ImageGen invocations for each explicitly authorized
execution body. Attempt 1 is the initial generation, so at most four derived repair
attempts remain. Increment the counter immediately before every invocation; a failed
transport, truncated prompt, executor error, or unusable image still consumes that
attempt. Do not grant “free” retries.

After every output:

1. Perform the complete review checklist in its required order, including direct visual
   inspection and real-size/z-order reassembly where the contract requires it.
2. If every internal gate passes, stop the loop immediately, record
   `candidate-reviewed / P3`, and present the candidate for user review. Internal passage
   is not user acceptance and cannot create tracked source or runtime media.
3. If a gate fails and fewer than five invocations have occurred, record the first failed
   gate, observable evidence, correct regions to preserve, and the next repair decision.
   Choose a scoped edit only when preserving the correct regions is intentional;
   otherwise regenerate from the locked authorities.
4. Write a complete derived repair body labeled `<authorized-version>.rN`. It may sharpen
   structural, compositional, material, or technical instructions inside the frozen
   envelope. It may use an earlier output from the same loop as an edit input unless the
   work file forbids that upload. It may not add new references or change the frozen
   contract.
5. Commit the failed-attempt record and the next complete repair body in the same work
   file before invoking that repair. Do not create one Markdown file per attempt.
6. If a repair requires a new object, state, reference role, external input, visual
   direction, canvas contract, or other envelope change, stop before invoking it and
   return to `prompt-draft` for explicit authorization; the remaining call budget does
   not broaden authority.
7. If attempt 5 still fails any internal gate, stop with
   `candidate-rejected / P3 / repair-budget-exhausted`, preserve all five attempt records,
   and ask the user to review the failure evidence and choose the next direction.

Deterministic crop, Alpha cleanup, metrics, and preview assembly do not consume ImageGen
calls, but they do not reset the counter and may never conceal a semantic, anatomical,
perspective, component-identity, or art-language failure.

## Review

Use the order in [review-checklist.md](references/review-checklist.md) for every loop
attempt: semantic and physical correctness first, then locked-baseline art inheritance,
component contract, deterministic assembly, and technical pixel checks. Compare the
candidate with both the locked image and the extracted prompt clauses; image similarity
alone cannot prove that the intended art language survived. Inspect the image visually;
metrics alone are insufficient.

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
3. For failed attempts 1–4 inside an authorized repair envelope, remain in the autonomous
   loop instead of asking the user to approve each repair. Preserve the executed body,
   execution record, review, and derived `.rN` body in Git before the next invocation.
4. Use a new user-authorized main/minor version when a correction crosses the frozen
   envelope. Do not disguise a new component contract as an in-loop repair.
5. Use a failed candidate as an edit input only when retaining its correct regions is
   intentional and the correction scope is explicit. Otherwise regenerate from the
   locked authority references to avoid carrying the defect forward.
6. Keep all failed images ignored under `generated/`; record in-loop failures in the
   work-file attempt ledger. Update module progress at loop success, budget exhaustion,
   or an authority blocker rather than duplicating every intermediate attempt. Never
   create source or runtime files for a rejected version.

Preserve the active work file while production is active. Do not preserve a forest of
superseded prompt files in the current tree. Git history remains the historical archive.

## Accept

Acceptance must be explicit and version-specific. Then:

1. Copy only the accepted transparent master into
   `assets/source/<module>/<component>/`.
2. Add a source manifest containing SHA-256, dimensions, color mode, Alpha evidence,
   prompt path, executor/session provenance, accepted candidate path, component mapping,
   and forbidden runtime uses.
3. Update the work file, source manifest, module `SUBMODULES.md`, and module
   `PROGRESS.md` in the same commit.
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
4. Remove ignored raw/candidates/previews, the component work file, obsolete
   component-only references/tools, and duplicated process narration approved in the
   plan. Do not purge Git history.
5. Compact `SUBMODULES.md`, `SUBMODULE_ART_BASELINES.md`, module `PROGRESS.md`, and
   manifests to final contracts, final paths, final validation, and one concise closure
   result.
6. Run all relevant tests and confirm the checkout contains no dangling links or
   references to deleted files.
7. Mark `P6-C / component-closed` only in the same dedicated cleanup commit.

## Handoff

End each operation with:

- the exact component and prompt version;
- fixed-executor attempts used, remaining budget, and whether the loop passed, exhausted,
  or stopped on an authority blocker;
- the current workflow substate and project phase;
- the verdict or artifact paths;
- the first remaining gate;
- for closure, the approved keep/delete inventory and final retained paths;
- tests run and their results;
- whether files are only local, committed, synchronized, or pushed.

Do not describe ignored generated files as durable cross-device assets.
