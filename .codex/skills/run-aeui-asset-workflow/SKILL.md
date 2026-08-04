---
name: run-aeui-asset-workflow
description: "Run the repository-specific Azeroth Expedition UI asset workflow: map real pfUI, Blizzard, and provider components; inherit locked art baselines; build a user-confirmed deterministic local preview; prepare self-contained prompts for fixed ImageGen 0.143.0; execute a bounded five-actual-generation generate-review-repair loop with workflow errors counted separately; publish minimal validated cross-device checkpoints; validate exact display regions; promote accepted source; export a fresh-checkout-installable addon; record P6 client validation; and close components or purge all module intermediates after whole-module acceptance. Use when preparing, simulating, generating, editing, reviewing, accepting, rejecting, handing off, resuming, exporting, integrating, validating, closing, or cleaning any AEUI component or module, including requests to continue the next UI asset step."
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
6. Read [display-region-gate.md](references/display-region-gate.md) before simulating,
   reviewing, exporting, game-validating, or assessing whether live plugin content fits
   the proposed art.
7. Read [prompt-completeness.md](references/prompt-completeness.md) before preparing or
   revising any production／`.rN` execution body.
8. Read [bounded-repair-loop.md](references/bounded-repair-loop.md) before any production
   generation or in-loop repair.
9. Read [cross-device-handoff.md](references/cross-device-handoff.md) before pausing,
   committing, pushing, resuming, or transferring an active component whose next gate
   depends on ignored pixels.
10. Read [repository-sync.md](references/repository-sync.md) before changing any
   tracked file or advancing a phase.
11. Read [record-templates.md](references/record-templates.md) when creating or
   updating a production prompt or review record.
12. For generation or image editing, additionally read
   `../imagegen-0-143-0/SKILL.md` and every reference that it requires.

Repository documents remain authoritative if this skill and the current checkout
disagree. Fix the skill and the authority document in the same change when the workflow
itself has changed.

## Resolve the Python runtime

Detect the current operating system before running any repository Python script or Skill
validator. Use one interpreter policy for the whole operation:

- macOS (`uname -s` returns `Darwin`): use
  `conda run -n py312 python`. Verify once with
  `conda run -n py312 python -c 'import sys; print(sys.executable)'`; do not fall back to
  `/usr/bin/python3`, an unqualified `python3`, or another Conda environment.
- Linux: use `python3` from the active project environment.
- Windows PowerShell: use `py -3` when available, otherwise `python` from the active
  project environment.

Record the selected interpreter and `--version` with test evidence. If the required
macOS `py312` environment is missing or lacks a dependency, stop and report that exact
environment error instead of silently switching interpreters.

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
6. A pre-production simulated instance image is deterministic local direction evidence
   only. It communicates layout, hierarchy, density, palette roles, and likely
   whole-screen weight with simple geometry and real text. It is never an art source,
   runtime texture, production edit input, substitute for locked baseline provenance,
   or evidence of final brushwork and microtexture.

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

## Make execution bodies complete, not merely longer

Apply [prompt-completeness.md](references/prompt-completeness.md). Every production or
`.rN` execution body must be self-contained; do not set a word-count minimum. Unknown
execution-critical values return the work to the component contract.

## Use the compact document lifecycle

Keep one active Markdown work file per incomplete component or tightly coupled asset batch:

```text
docs/modules/<module>/work/<COMPONENT-OR-BATCH>.md
```

The work file contains the current versioned local simulation specification and
production execution bodies, component contract, prompt inheritance, compact attempt
ledgers, execution evidence, review, user decisions, and next gate. Do not create a
separate permanent Markdown file for every attempt, audit, preview, decision, or runtime
media list.

Before executing a production prompt, commit the authorized work-file version so its
exact body is in Git history. A local geometric simulation may be rendered before that
commit; record its versioned specification, script command, path, hash, and review in the
same work file before presenting it. During the bounded production repair loop, append
the failed attempt and the complete derived repair body to the same work file, then
commit them before the next invocation. After loop exhaustion or user rejection, record
the terminal rejection in that file. Git history is the full archive; the current tree
contains only the evidence needed for the next decision.

When work will continue on another device and the next gate depends on exact ignored
pixels, publish only the state-specific payloads under
`handoff/<module>/<component>/` with
`manage_cross_device_handoff.py`. Keep `generated/` ignored. The checkpoint is a
temporary tracked transport layer, never visual authority, source, or runtime; replace
it instead of accumulating versions and remove it as soon as the exact pixels are no
longer required. Publish it only on a named short-lived collaboration branch, never the
default branch; integrate only the later clean state without handoff history.

When the component reaches `P6-C`, merge final stable visual clauses into
`SUBMODULE_ART_BASELINES.md`, final object ownership into `SUBMODULES.md`, and final paths
and validation into module `PROGRESS.md` and manifests. Then delete the component work file
and ignored generated directory. Never keep an empty `work/` directory by adding placeholder
files.

When the user explicitly accepts the declared whole-module P6 scope, perform terminal
module cleanup in the same operation. Preserve only durable baselines, final source and
manifests, deployable runtime/implementation/tests, licenses/shared dependencies, and a
minimal durable P6 evidence set. Delete the entire `generated/<module>/` tree, every module
work file, `handoff/<module>/`, and every separately inventoried legacy module-only
generated path. Module acceptance is standing authorization for these verified
module-scoped intermediates; a shared or ambiguous path remains protected and blocks
only that path pending direction.

## Select the operation

Infer only the narrowest operation authorized by the user:

| User intent | Operation | Highest allowed result |
|---|---|---|
| define, split, plan, write prompt | `prepare` | production draft and local simulation specification at `P2` |
| mock up, preview, simulate the likely in-game result | `simulate` | locally rendered, user-reviewable non-production visual direction at `P2` |
| generate, edit, regenerate | `generate` | internally reviewed candidate at `P3` after at most five actual ImageGen generations or edits |
| assess, inspect, compare, review | `review` | verdict and review evidence |
| correct, revise, try again | `revise` | new versioned `P3` candidate |
| reject, abandon this version | `reject` | recorded rejection; no source |
| accept, lock this asset | `accept` | confirmed source at `P4` |
| slice, atlas, integrate | `export` | tested, fresh-checkout-installable addon runtime at `P5` |
| validate in Turtle WoW | `game-validate` | `P6` only after real-client evidence |
| finish, close, compact, clean completed work | `close` | component or whole-module `P6-C` after the applicable cleanup gate |

“Continue” means proceed through the next unblocked gate shown by module progress. If a
pre-production preview is missing, build the deterministic local geometric simulation,
review it internally, and present it without an ImageGen authorization stop. If the next
gate is production prompt authorization, stop after presenting the exact versioned
production body, its repair envelope, and its five-call budget. “Continue” or “next step”
alone never authorizes ImageGen. Explicit production authorization covers its bounded
in-scope repair attempts, but never means silently accepting a candidate, promoting a
source, inventing missing runtime geometry, or deleting intermediates. Local simulation,
production generation, source acceptance, and component cleanup remain separate decisions.
Explicit acceptance of a declared whole-module P6 scope is the trigger for the mandatory
module cleanup defined below; do not request a redundant second deletion approval.

If the user asks only for an assessment, stay read-only. If the user explicitly asks to
generate, revise, accept, or export, perform the normal repository writes for that
operation.

## Enforce the gates

1. Do not generate without a complete component contract.
2. Do not authorize or execute a production prompt without a complete locked-baseline
   provenance chain, an art-inheritance block, and a resolved authority/conflict audit.
3. Do not authorize or execute an execution body until its self-contained prompt
   completeness audit passes; prompt length alone is never evidence of completeness.
4. Build pre-production simulations locally and deterministically. Do not call ImageGen,
   upload image inputs, use a provider session, or allocate an image-generation budget
   for this gate.
5. Do not execute a `production-draft` until the user has explicitly confirmed the
   corresponding pre-production simulated instance image and then explicitly authorized
   the final production version after seeing its execution body.
6. Never crop, slice, promote, export, or reuse a pre-production simulation as
   `assets/source/`, runtime media, a production edit input, or a replacement for a
   locked reference. User confirmation accepts only the recorded visual direction.
7. Do not use any other visual prototype as a runtime texture.
8. Do not present a production candidate as viable until semantic structure has been
   checked.
9. Do not treat dimensions, Alpha, chroma-key cleanup, or connected regions as proof of
   correct anatomy, function, component identity, or style.
10. Do not copy anything into `assets/source/` without explicit user acceptance.
11. Do not export runtime media until the accepted source, crop/UV contract, safe areas,
   stretch rules, and target Frame geometry are known.
12. Do not mark an export `runtime-exported / P5` until the runtime media, adapter and
   provider changes are loaded from tracked files under `addon/`, the relevant TOC/XML
   order is complete, and `validate_addon_package.py` proves a fresh checkout can be
   copied into `Interface/AddOns` without generation, export, patching, or local links.
13. Do not call a preview “real layout” or treat runtime as P6-ready until the exact
   display-region gate passes for empty, minimum, typical, maximum-density, and
   supported-mode cases. Background coverage alone is insufficient.
14. Do not mark `P6` without evidence from Turtle WoW `1.18.1`.
15. Do not remove intermediate or superseded files before `P6`, a verified final keep set,
   and an exact cleanup inventory. Component-only cleanup still requires explicit approval
   of that inventory. Explicit acceptance of the declared whole-module P6 scope, together
   with the repository standing rule, authorizes mandatory removal of verified module-only
   intermediates without a second approval; never include shared or ambiguous paths.
16. A pre-production simulation version uses `0` ImageGen calls by contract. Render it
   with a local deterministic script using simple geometric primitives, representative
   real text, real object counts, and explicit non-authoritative placeholders. Local
   rendering errors are ordinary tool errors, never image-generation attempts.
17. Never consume more than five actual ImageGen generations or edits for one authorized
   execution body. Count an attempt only when the fixed executor returns an image or a
   provider result proves that generation/editing actually ran. An unusable generated
   candidate still counts. A workflow, transport, wrapper, permission, prompt-transfer,
   upload, or save-path error with no generated image and no provider-generation evidence
   is recorded separately and does not consume the `0/5` image budget.
18. Autonomous production repair may change only the repairable wording,
    edit/regenerate choice, and use of an earlier output from the same loop. It may not
    change component identity, object/state count, authority order, reference roles,
    canvas/runtime contract, forbidden content, or add a new external input without new
    user authorization.
19. Before handing an active component to another device, validate its exact
    state-specific `handoff/<module>/<component>/` checkpoint. Do not claim that ignored
    `generated/` paths will cross devices, and do not use handoff payloads as source or
    addon runtime. Never publish temporary pixels on the default branch. Follow
    [cross-device-handoff.md](references/cross-device-handoff.md).

When a gate is blocked, state the missing evidence and perform any useful read-only
inspection still in scope. Do not create plausible-looking placeholder controls.

## Prepare

1. Resolve the exact module and component IDs from module `SUBMODULES.md` and
   `PROGRESS.md`.
2. Map every visual object to a real pfUI, Blizzard, or external-provider object.
3. Record object count, state count, runtime size, source canvas, Alpha strategy, safe
   areas, stretch/crop rules, reference-image roles, forbidden baked content, acceptance
   preview, and fallback.
4. Record a display-region contract that distinguishes source/atlas visible pixels,
   sampled UVs, assembled decorative caps, quiet content zones, live visible regions,
   hit regions, and provider-derived Frame sizes.
5. Resolve the locked baseline image-to-prompt provenance chain and write the
   art-inheritance/conflict block before the creative body.
6. Rewrite the request against that resolved authority as two separate active contracts in
   `docs/modules/<module>/work/<COMPONENT-OR-BATCH>.md`:
   - a deliberately simple deterministic local simulation specification for one
     representative in-game scene; and
   - the decomposed production asset body or bodies.
   State secondary source limits explicitly; never call an `assets/source/` derivative
   the highest visual authority.
7. Make the simulation show the target Frame's real proportions, current accepted/runtime
   neighboring UI, representative dynamic content and information density, intended
   z-order, and the proposed material/silhouette hierarchy. Represent these with simple
   rectangles, polygons, lines, ellipses, flat palette roles, and real localized text. It
   may simplify fine texture, crop seams, Alpha, and individual state sheets because it
   is not an asset candidate.
8. Run the self-contained prompt completeness audit above. Record its compact result in
   the work file and return to the component contract if any required value is unknown.
9. Record the simulation version, local script/specification, read-only reference roles,
   `0` ImageGen calls, non-production restrictions, and the exact visual decisions the
   user will be asked to judge.
10. Record the immutable production repair envelope and `5` actual-generation budget. For a batch
   with multiple independent execution bodies, state each body's budget and the
   worst-case aggregate actual-generation count. Process errors use a separate ledger.
11. Render and internally review the local simulation, mark it
    `simulation-reviewed`, show it to the user, and wait for direction confirmation.
    Production authorization cannot occur yet.

Do not split assets according to what is convenient for the model. Split them according
to runtime ownership, interaction state, z-order, and independent scaling behavior.

## Simulate before production

This is a mandatory low-cost direction gate, not an early asset-generation attempt.
Keep it visibly and procedurally separate from the mandatory post-candidate real-layout
simulation in `Review`.

1. Create a versioned simulation specification from the component contract. It must list
   target screen geometry, Frame bounds, real object count, representative high-density
   content, interaction states, z-order, flat palette roles, and which visual qualities
   are intentionally not represented.
   Derive each exact instance size from the live provider formula; an additional capacity
   envelope must be labeled non-real and cannot replace an exact instance.
2. Render it only with a local deterministic script. Prefer the bundled
   `scripts/render_geometric_mockup.py` when its primitives are sufficient. Do not call
   any image-generation tool, provider, browser service, or remote renderer, and do not
   upload locked/reference images.
3. Use simple geometric primitives and real localized text. Read-only references may
   inform proportions and palette roles, but do not paste, trace, crop, or transform
   their pixels into the simulation unless the component work explicitly needs a current
   runtime screenshot as surrounding context.
4. Store the render and optional comparison/zoom compositions only under
   `generated/<module>/<component-or-batch>/simulation/<version>/`. Record the
   specification, script command, output path, SHA-256, selected Python interpreter, and
   local rendering errors in the existing work file. Record ImageGen usage as `0/0`.
5. Internally verify only that the preview is understandable and faithful enough to judge
   the authorized scope: real Frame proportions, plausible screen placement, intended
   object metaphor, dominant materials, visual weight, palette, neighboring UI,
   representative content density, z-order, and interaction state. Do not reject it for
   missing production-grade Alpha, seams, exact state separation, or microtexture.
6. Present the simulated instance image with a short list of which decisions are
   representative and which details are deliberately non-authoritative. Do not start the
   production generate-review-repair loop in the same turn unless the user explicitly
   confirms the simulation and separately authorizes the final production version.
7. On user confirmation, record the accepted visible direction—layout, material hierarchy,
   silhouette, palette, visual weight, integration, and interaction-state impression—in
   the work file. Translate those decisions into the final production body and re-run its
   completeness audit before requesting production authorization.
8. On user rejection, return to `prompt-draft`, revise the local specification, render
   the next simulation version, and present it. Do not run the production five-call
   repair loop to repair a concept preview.
9. If the design changes materially after confirmation, invalidate that confirmation and
   create a new simulation version. Purely technical decomposition, transparent
   extraction, or slicing changes that preserve the confirmed visible composition do not
   require a new simulation.

If the operation pauses at `simulation-reviewed` for cross-device continuation, publish
the exact `review-preview` and optional `review-zoom` checkpoint before push. Once the
direction is confirmed and fully transcribed into the work file, remove that checkpoint.

Simulation confirmation never accepts source pixels. The simulation cannot be copied,
cropped, sliced, promoted, exported, or uploaded as a production edit/reference input.
Only its recorded verbal decisions may constrain production. Because the preview is
geometric, it also cannot prove final brushwork, material microtexture, Alpha quality,
atlas separation, or exact in-client rendering.

## Generate

1. Verify that the exact corresponding simulated instance version is
   `simulation-confirmed` and its accepted visible-direction clauses are present in the
   final production body. Then verify the user separately authorized that exact
   production body. Otherwise return to `Simulate before production` or `prepare`.
2. Re-run the provenance, authority-order, and contradiction preflight. If any locked
   baseline prompt is unresolved or a derivative source outranks it, return to `prepare`.
3. Freeze the explicitly authorized prompt as `production`; never overwrite an executed
   version.
4. Freeze the repair envelope: component IDs, object/state inventory, visual authority,
   reference roles, canvas/runtime geometry, Alpha strategy, forbidden baked content,
   permitted edit inputs, and the maximum of five actual ImageGen generations/edits.
5. Use only `../imagegen-0-143-0/SKILL.md`. Do not call the current session's built-in
   image-generation tool.
6. Pass attempt 1's approved execution body verbatim. Put absolute input paths,
   image-role mappings, and output instructions outside that body as required by the
   fixed executor.
7. Write raw, transparent, and preview files only under
   `generated/<module>/<component-or-batch>/<version>/`.
8. Record the executor version, attempt number, session/result identifiers, exact output
   paths, and any
   executor-reported revised prompt in the active work file. Never conceal an internal
   retry or silently replace an executed prompt.
9. Run the bounded loop below. Advance no further than `P3` until review and explicit
   user acceptance are complete.

## Run the bounded autonomous repair loop

Apply [bounded-repair-loop.md](references/bounded-repair-loop.md). One authorized
execution body receives at most `5` actual generations/edits including attempt 1.
Process errors without generated-image or provider-generation evidence use a separate
ledger and do not consume `0/5`. Stop immediately at internal passage or attempt-5
failure; neither condition is user acceptance.

## Review

Use the order in [review-checklist.md](references/review-checklist.md) for every loop
attempt: semantic and physical correctness first, then locked-baseline art inheritance,
component contract, deterministic assembly, and technical pixel checks. Compare the
candidate with both the locked image and the extracted prompt clauses; image similarity
alone cannot prove that the intended art language survived. Inspect the image visually;
metrics alone are insufficient.

For deterministic PNG metrics, run:

```bash
# macOS
conda run -n py312 python \
  .codex/skills/run-aeui-asset-workflow/scripts/inspect_candidate.py \
  /absolute/path/to/candidate.png
```

On Linux replace `conda run -n py312 python` with `python3`; on Windows PowerShell use
`py -3` or the active-environment `python` according to the runtime policy above.

Pass repeated `--cell 'ID=x0,y0,x1,y1'` arguments when the production contract defines
fixed atlas cells. This checker reports Alpha, bounds, edge contact, SHA-256, and visible
green spill. It deliberately does not claim that a region is the correct logical object.

Also run the exact region procedure in
[display-region-gate.md](references/display-region-gate.md). Record the contract and
report path/hash. A visually plausible composition fails if its chosen canvas height,
padding, or safe area does not exist in the live provider.

After every generated or edited production UI candidate, produce a deterministic
candidate real-layout simulation before internal passage or user review. Unlike the
rough pre-production simulated instance, this validation composition is exact and must:

- use the target Frame's real pixel geometry at `100%` runtime size;
- place the candidate over the newest accepted/runtime UI that will surround it, in the
  intended z-order, clipping and safe areas;
- instantiate the real object count and representative maximum/typical density rather
  than showing a few isolated samples;
- use realistic localized text, icons, values and state distribution for dynamic
  content, while keeping those values out of source art;
- show the current real fallback for unfinished neighboring components when available,
  or identify any simplified placeholder as non-authoritative in the work record and
  manifest; and
- record the preview path, hash, geometry, density and authoritative/non-authoritative
  scope.

For a repeated component, this means the actual target repetition: for example, a
23-row Quest Log asset must be simulated across all 23 row slots with realistic task
layout, not four symbols floating on an empty book. A contact sheet remains useful for
inventory, but a contact sheet, sparse demo, debug grid, or isolated component board
never substitutes for the candidate real-layout simulation. Store every simulation only
under `generated/`. Neither kind of simulation is source art, but the pre-production
simulation confirms a visual direction while this post-candidate simulation validates
the actual candidate at runtime geometry.

If review will continue on another device, publish the exact `candidate` and
`real-layout-preview` checkpoint, plus an optional `technical-preview`, before push. The
checkpoint must identify the committed work version and remaining attempt budget.

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
When the next action is a cross-device edit of the immediately preceding output, publish
that exact file as `repair-prepared / edit-input`; a review-only candidate checkpoint is
not implicit authorization to use its pixels as an edit input.

## Accept

Acceptance must be explicit and version-specific. Confirmation of the pre-production
simulation does not satisfy this requirement. Then:

1. Copy only the accepted transparent master into
   `assets/source/<module>/<component>/`.
2. Add a source manifest containing SHA-256, dimensions, color mode, Alpha evidence,
   prompt path, executor/session provenance, accepted candidate path, component mapping,
   and forbidden runtime uses.
3. Update the work file, source manifest, module `SUBMODULES.md`, and module
   `PROGRESS.md` in the same commit.
4. Remove the consumed component handoff after the accepted bytes and manifest are safely
   present under `assets/source/`.
5. Mark `P4`; do not imply that runtime slicing or game validation has happened.

## Export and game-validate

Use deterministic tools for crop, Alpha, scale, atlas, format conversion, and preview.
Store reproducible intermediates in `generated/`. Commit runtime media only with its
manifest/UV mapping, Lua/XML ownership, tests, and documentation updates.

An export is not complete when the atlas alone exists. In the same checkout:

1. Write every game-loaded media file under the owning addon, normally
   `addon/AzerothExpeditionUI/Media/<Module>/`; runtime Lua/XML/TOC must never load from
   `assets/source/`, `generated/`, `.codex/`, or `tools/`.
2. Connect the real adapter to the exported cells and states, preserve the provider's
   nonvisual behavior and fallback, and include any narrowly scoped pfUI bridge change
   under `addon/pfUI/`. Do not leave a patch or manual edit for the game device.
3. Ensure the addon TOC/XML/bootstrap loads every new runtime file in exact case and in a
   valid dependency order. Do not rely on a developer-machine symlink, Junction, ignored
   file, absolute path, provider cache, or untracked export.
4. Run the package gate with the selected OS interpreter, for example on macOS:

   ```text
   conda run -n py312 python \
     .codex/skills/run-aeui-asset-workflow/scripts/validate_addon_package.py \
     /absolute/path/to/repository \
     --report /absolute/path/to/generated/<module>/<batch>/addon-package-report.json
   ```

5. Treat `addon/` as the deployable artifact. A fresh checkout on the target device must
   need only `git pull` and copying/linking the required addon directories into
   `Interface/AddOns`; it must not run an exporter, ImageGen, Python, a patch script, or
   make a new Lua/pfUI edit before the game can load the completed work.

The package report must be `pass`, every required runtime file must already be tracked or
staged for the same commit, and component-specific smoke/contracts must pass before the
state can become `runtime-exported / P5`. Record the exact addon directories, adapter,
provider bridge, TOC/bootstrap entries, runtime manifests, report command/result, and
fallback in the current work and module `PROGRESS.md`.

Before treating P5 as P6-ready, repeat the display-region gate against the final atlas,
adapter constants, live anchors, and provider layout formula. A new or inherited failure
keeps the export at `display-region-blocked`; do not hide it behind a passing Lua smoke.

Mark `P5` only after static and relevant smoke tests pass. Mark `P6` only after real
Turtle WoW screenshots and interaction checks confirm scale, hit regions, state changes,
text safety, layering, fallback, and unaffected nonvisual behavior.

## Close after P6

Treat `P6` as accepted in game but not yet repository-closed. Read the terminal cleanup
rules in [repository-sync.md](references/repository-sync.md).

### Close one accepted component

1. Verify final prompt provenance, accepted source/manifest, deterministic exporter,
   runtime media/manifest, implementation, tests, and P6 evidence.
2. Produce an exact component-scoped keep/delete inventory. Exclude shared assets/tools,
   active locked baselines, third-party evidence, licenses, and user originals.
3. Show the inventory to the user and obtain explicit approval before deletion.
4. Remove the approved component-only simulations, raw/candidates/previews, work file,
   component handoff, obsolete references/tools, and duplicated process narration. Do
   not purge Git history.
5. Compact the four durable module documents and manifests, run relevant tests and link
   checks, and mark `P6-C / component-closed` in the dedicated cleanup commit.

### Close a fully accepted module

1. Freeze the declared module acceptance scope in module `PROGRESS.md`. Every included
   component must have real Turtle WoW P6 evidence or already be `component-closed`;
   intentionally excluded/deferred contracts remain concise durable facts, not active work.
2. Verify the final keep set. If the only P6 evidence is under `generated/`, promote the
   minimal accepted screenshots/records to `assets/references/<module>/p6/` with hashes
   before cleanup. Preserve final source/manifests, deterministic exporters needed to
   reproduce runtime, deployable addon code/media, tests, licenses, user originals, and
   genuine shared dependencies.
3. Condense all stable facts into the module's four durable documents and final manifests.
   No active component work may remain after module closure.
4. Build an exact ownership inventory for the canonical `generated/<module>/` tree, every
   module work file, obsolete module-only references/tools/caches, and legacy generated
   paths outside the canonical tree. New generated outputs outside
   `generated/<module>/` are forbidden. Resolve legacy ownership with component IDs,
   paths, hashes, Git history, and references; exclude every shared or ambiguous target.
5. The explicit whole-module P6 acceptance authorizes this verified module-only delete set
   under the standing project rule. Do not ask for a second approval. If ownership remains
   ambiguous, stop only that target and request direction rather than broadening deletion.
6. Remove the entire canonical `generated/<module>/` tree, all
   `docs/modules/<module>/work/` data, `handoff/<module>/`, every verified legacy
   module-only generated path, and the other inventoried intermediates. Use exact literal
   paths with no unresolved variables or globs; do not delete Git history or a shared
   parent directory.
7. Run `validate_module_closure.py` with module aliases/legacy paths, the fresh-checkout
   addon package validator, all relevant runtime/repository tests, Markdown link checks,
   and `git diff --check`. The module-closure report schema is
   `aeui-module-closure-report-v1` and must return `status=pass`.
8. Record the frozen scope, minimal durable P6 evidence, retained paths, validator command,
   aliases/legacy paths and pass result in module `PROGRESS.md`; mark
   `P6-C / module-closed` only in the same dedicated cleanup commit.

## Handoff

End each operation with:

- the exact component and prompt version;
- the pre-production simulation version, local renderer/specification, output path/hash,
  ImageGen usage `0/0`, whether the user confirmed it, and the accepted
  visible-direction clauses;
- actual ImageGen generations used, remaining image budget, separately recorded process
  errors, and whether the loop passed, exhausted, or stopped on an authority blocker;
- the current workflow substate and project phase;
- the verdict or artifact paths;
- the display-region contract/report path and hash, exact scenarios, result, and first
  failed region when applicable;
- the addon-package gate result, exact deployable `addon/` directories, and whether a
  fresh checkout requires any build, generation, patch, symlink, or remote-side code edit;
- the first remaining gate;
- the cross-device checkpoint path/state, payload roles and hashes, validator result, and
  whether it has been committed/pushed—or an explicit statement that no exact ignored
  pixels are needed for continuation;
- for component closure, the approved keep/delete inventory and final retained paths;
- for module closure, the frozen acceptance scope, deleted canonical/legacy generated
  roots, protected shared exclusions, retained P6 evidence, and module-closure validator;
- tests run, selected Python interpreter and version, and their results;
- whether files are only local, committed, synchronized, or pushed.

Do not describe ignored generated files as durable cross-device assets.
