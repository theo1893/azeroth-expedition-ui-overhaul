---
name: run-aeui-asset-workflow
description: "Use the lightweight AEUI workflow for UI logic/layout changes, component asset generation with ImageGen 0.143.0, addon integration, game validation, cross-device handoff, and cleanup. Choose the smallest of the quick, asset, or release paths; do not create attempt ledgers or run repository-wide tests for ordinary edits."
---

# AEUI Lightweight Workflow

The purpose of this workflow is to reach Turtle WoW game validation quickly. Static
checks catch packaging and syntax mistakes; they do not prove that a UI works in game.

## Read only what the task needs

1. Read repository `AGENTS.md`.
2. Read `docs/GLOBAL_ART_BASELINE.md` only for visual work.
3. Read the target module's `SUBMODULES.md` and `PROGRESS.md`.
4. For visual work, also read that module's `ART_BASELINE.md` and
   `SUBMODULE_ART_BASELINES.md`.
5. If `docs/modules/<module>/CURRENT.md` exists, read it. A module may have at most
   one such temporary file.
6. For bitmap generation or editing, additionally read and use
   `../imagegen-0-143-0/SKILL.md`. Do not use another image generation path.

Do not read another module, historical Git commits, old attempts, or every manifest
unless the current task actually depends on them.

## Choose one path

### 1. Logic or layout change — default

Use this for Lua behavior, anchors, dimensions, provider compatibility, configuration,
or a fix that does not change accepted pixels.

1. Inspect the real pfUI, Blizzard, or third-party provider objects involved.
2. Change only the owning module and closely related runtime files.
3. Do not update documents merely because implementation details changed.
4. Run:

   ```text
   conda run -n py312 python tools/check.py quick --module <module>
   ```

5. Move immediately to focused game validation. A mock is not a substitute for the
   client. Record the result only when the user reports a meaningful game outcome.

The quick path must not run asset exporters, render every preview, scan historical
prompts, compare mutable Lua hashes, or execute repository-wide mock suites.

### 2. New or changed bitmap asset

Use this only when visible source pixels must change.

1. Map the asset to real runtime objects, states, safe areas, stretch/crop behavior,
   and z-order. Never bake dynamic text, icons, cooldowns, selection state, or real
   buttons into a static background.
2. Confirm that the proposed art fits the provider's actual display region. For a new
   art direction, first make a simple deterministic geometric mockup and show it to the
   user. This mockup uses no ImageGen and is not a source asset.
3. After the user confirms the mockup and generation scope, create or overwrite only
   `docs/modules/<module>/CURRENT.md`. Keep it short and current; include:
   component ID, real objects/states, final merged prompt, fixed reference files and
   hashes, transform/safe-area contract, actual ImageGen calls used, current candidate,
   and the next decision. Never append an attempt diary.
4. The final production prompt must explicitly merge the global, module, and submodule
   art baselines with the component contract. State silhouette, materials, palette,
   rough irregularity, lighting, wear, Alpha/background requirements, safe areas,
   forbidden baked content, and exact output purpose. It must be self-contained.
5. Use only `imagegen-0-143-0`. Each authorized segment has at most five actual
   ImageGen calls. Workflow/tool errors do not consume this budget. After each actual
   output, review it against the frozen visual and geometry boundaries; repair within
   those boundaries and stop on the first passing candidate. If five actual calls fail,
   stop for user review.
6. Review the candidate in a local preview using real typography, real icon/button
   geometry, and representative empty/short/typical/dense states. Run the component's
   display-region validator only when that contract exists and is relevant.
7. User acceptance freezes the exact candidate. Promote it to
   `assets/source/<module>/`, write or update its manifest, export runtime media, and
   integrate the media and adapter into `addon/` on the same device.
8. Run:

   ```text
   conda run -n py312 python tools/check.py assets --module <module>
   ```

9. Update the module `PROGRESS.md` once, delete its `CURRENT.md`, and remove that
   component's ignored `generated/` files after acceptance. Git history is the process
   history.

Manifests may hash immutable source and runtime media. Do not store or enforce hashes
for mutable Lua, TOC, Bootstrap, prose, previews, or test output.

### 3. Distribution or broad integration

Use this only when TOC/load order, addon packaging, shared runtime ownership, or several
modules changed together, or when the user explicitly requests a release audit.

Run:

```text
conda run -n py312 python tools/check.py release
```

This checks project-owned AEUI entry Lua plus changed provider Lua, TOC/loadable files,
runtime manifest media, and the fresh-checkout addon package. Vendored database and
translation files are not reparsed with a mismatched desktop Lua version. The check still
does not replace Turtle WoW validation.

## Documentation rules

- `AGENTS.md`: project boundaries, document index, compact module snapshot, and command
  entry points. Update only for a project rule, module-level milestone, or ownership
  change.
- `docs/PROGRESS.md`: one row per module. Update only when a module's phase or next gate
  changes.
- Module `SUBMODULES.md`: real objects and functional ownership only.
- Module `ART_BASELINE.md` and `SUBMODULE_ART_BASELINES.md`: stable visual prompts only.
- Module `PROGRESS.md`: current status, deployed paths/version, focused game checklist,
  and fallback. No chronology, command transcripts, attempt history, or mutable hashes.
- `CURRENT.md`: optional and temporary for one actively produced asset batch. Delete it
  on acceptance or abandonment.
- `README.md`: project introduction only.

An ordinary code fix should usually update zero documents. A failed game check may add
one concise current finding to module `PROGRESS.md`; replace stale text instead of
appending another dated paragraph.

## Game validation and cleanup

For each delivery, give the user a short checklist covering:

- the changed behavior or visual;
- one adjacent regression risk;
- the module-disable or provider-missing fallback when applicable;
- the expected `/aeui status` value only when it helps identify deployed code.

Only the user's Turtle WoW result can mark a component `P6`. When a component is fully
accepted, delete its `generated/`, temporary `handoff/`, and `CURRENT.md` data immediately.
Keep accepted source, manifests, addon runtime, stable baselines, current progress, and
minimal game evidence. No separate `P6-C` phase or closure test is required.

## Cross-device work

Normal synchronization consists only of tracked code, accepted source, runtime media,
manifests, and current progress. `generated/` remains ignored. If an unaccepted exact
candidate must move devices, place only that candidate and a tiny metadata JSON under
`handoff/<module>/<component>/`, commit it intentionally, and delete it immediately after
resume. Do not create a handoff ledger or copy the whole generated tree.

## Python runtime

Detect the operating system once per task:

- macOS: `conda run -n py312 python`;
- Linux: `python3` from the active project environment;
- Windows: the configured project Python, otherwise `py -3`.

On macOS, do not silently fall back from the `py312` Conda environment. Report the exact
environment error if it is unavailable.
