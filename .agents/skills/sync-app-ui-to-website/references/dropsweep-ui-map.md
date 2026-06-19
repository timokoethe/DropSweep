# DropSweep UI Map

## Native App Source of Truth

- `DropSweep/MenuView.swift`: visible menu composition, row layout, destructive cleanup button label, menu width, and scan refresh triggers.
- `DropSweep/MenuViewModel.swift`: user-facing summary strings, formatted byte counts, category display names, category ordering, launch-at-login and app actions.
- `DropSweep/Sweeper.swift`: category membership, hidden-file skipping, Downloads-only scope, Trash behavior, and filesystem size calculation.

## Website Mirror Points

- `website/app/page.tsx`
  - `menuPreviewCategories`: sample category labels, order, counts, and any preview-only metrics such as size.
  - Hero paragraph: high-level behavior claim.
  - Menu preview JSX: visual row structure, action labels, dividers, keyboard hints, and alignment.
  - `features`: behavior and safety claims.
  - `categories`: recognizable category list and descriptions.
- `website/app/globals.css`: only shared visual tokens and global styling.
- `website/components/*`: only if the mirrored UI has moved into a component.

## Sync Checklist

Before editing:

- Read root and website AGENTS instructions.
- Read the relevant Next.js docs from `website/node_modules/next/dist/docs/`.
- Compare the app diff against the current website preview and copy.

During editing:

- Mirror visible labels and row order first.
- Then mirror layout changes that affect comprehension, such as right-aligned metadata columns.
- Then update product copy only where the app behavior changed.
- Keep sample data fake and internally consistent.

After editing:

- Build or lint the website.
- Build the app if Swift files changed in the same task.
- Mention any intentionally unsynced details, such as runtime-only values that cannot appear in static marketing copy.
