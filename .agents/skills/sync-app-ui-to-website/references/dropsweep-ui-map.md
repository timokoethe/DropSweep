# DropSweep UI Map

## Native App Source of Truth

- `DropSweep/MenuBar/MenuView.swift`: visible menu composition, row layout, destructive cleanup button label, menu width, and scan refresh triggers.
- `DropSweep/MenuBar/MenuViewModel.swift`: downloads summary strings, category ordering, counts, size inputs, launch-at-login state, and cleanup behavior.
- `DropSweep/MenuBar/CategorySummary.swift`: visible category row formatting, singular/plural category labels, count text, and size text.
- `DropSweep/App/DropSweepApp.swift`: menu-bar app actions, action labels, update-check action, about action, quit action, and keyboard shortcuts.
- `DropSweep/Services/Sweeper.swift`: category membership, hidden-file skipping, Downloads-only scope, Trash behavior, and filesystem size calculation.

## Website Mirror Points

- `website/components/MacAppPreview.tsx`
  - `menuPreviewCategories`: sample category labels, order, counts, and any preview-only metrics such as size.
  - Menu preview JSX: visual row structure, action labels, dividers, keyboard hints, and alignment.
- `website/app/page.tsx`
  - `MacAppPreview` placement in the page flow.
  - Hero paragraph: high-level behavior claim.
  - `features`: behavior and safety claims.
  - `categories`: recognizable category list and descriptions.
- `website/app/globals.css`: only shared visual tokens and global styling.
- Other `website/components/*`: only if page-level UI or shared controls changed.

## Sync Checklist

Before editing:

- Read root and website AGENTS instructions.
- Read the relevant Next.js docs from `website/node_modules/next/dist/docs/`.
- Compare the app diff against the current `MacAppPreview` component and page copy.

During editing:

- Mirror visible labels and row order first.
- Then mirror layout changes that affect comprehension, such as right-aligned metadata columns.
- Then update product copy only where the app behavior changed.
- Keep menu preview edits in `website/components/MacAppPreview.tsx` unless the page composition itself changed.
- Keep sample data fake and internally consistent.

After editing:

- Run the website checks when website files changed.
- Build the app when the current diff includes Swift app changes or the sync depends on changed app behavior, when practical.
- Mention any intentionally unsynced details, such as runtime-only values that cannot appear in static marketing copy.
