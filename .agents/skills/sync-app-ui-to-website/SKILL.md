---
name: sync-app-ui-to-website
description: Mirror DropSweep native macOS app UI changes into the Next.js marketing website. Use when SwiftUI menu text, category rows, controls, previewable state, screenshots, product messaging, or visual behavior in DropSweep/ changes and the website UI or copy should stay aligned, especially website/app/page.tsx menu previews and feature descriptions.
---

# Sync App UI to Website

## Overview

Keep the DropSweep website's product UI preview and copy aligned with the native macOS menu-bar app. Treat the app as the source of truth and update the website only where it represents that app behavior.

## Workflow

1. Read repo instructions:
   - `AGENTS.md` at the repo root.
   - `website/AGENTS.md` before touching anything under `website/`.
   - The relevant Next.js guide under `website/node_modules/next/dist/docs/` before editing website code, as required by `website/AGENTS.md`.

2. Inspect the app UI source:
   - Start with `DropSweep/MenuView.swift` for visible menu text, row structure, button labels, spacing, and menu width.
   - Read `DropSweep/MenuViewModel.swift` for formatted summary strings, category names, counts, size labels, and action labels.
   - Read `DropSweep/Sweeper.swift` only when category logic, hidden-file behavior, filesystem behavior, or scan totals changed.

3. Inspect the website representation:
   - Start with `website/app/page.tsx`.
   - Check `menuPreviewCategories`, hero copy, feature copy, category copy, and any JSX that renders the menu preview.
   - Check `website/app/globals.css` only when tokens, typography, or theme behavior need to reflect the app-facing change.

4. Map app UI changes to website changes:
   - If the app changes summary text, update the website menu preview summary.
   - If the app changes category titles, order, counts, size display, or row alignment, update `menuPreviewCategories` and the preview JSX.
   - If the app adds or removes a visible action, mirror it in the preview only if the website currently presents that action area.
   - If the app changes product behavior, update feature and category copy so claims remain true.
   - Preserve hidden-file and Trash-safety claims unless product requirements changed.

5. Keep the website realistic, not exhaustive:
   - Use plausible sample counts and sizes; do not expose real user filesystem data.
   - Keep preview labels close to the SwiftUI labels, but avoid overfitting to exact runtime values.
   - Prefer small, local edits in `website/app/page.tsx`.
   - Do not broaden website claims beyond Downloads cleanup.

6. Verify:
   - For app changes, run `xcodebuild -project DropSweep.xcodeproj -scheme DropSweep build` when practical.
   - For website changes, run the existing website checks from `website/package.json`, typically `npm run lint` and `npm run build` from `website/`.
   - If a check cannot run, report the reason and provide manual verification steps.

## Project Reference

Read `references/dropsweep-ui-map.md` when you need exact file responsibilities or a checklist for mapping native UI changes to website UI changes.
