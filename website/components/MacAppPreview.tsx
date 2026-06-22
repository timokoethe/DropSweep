const menuPreviewCategories = [
  { title: "Installers", count: 3 },
  { title: "Archives", count: 4 },
  { title: "PDFs", count: 3 },
  { title: "Screenshots", count: 8 },
  { title: "Folders", count: 2 },
  { title: "Other Files", count: 4 },
];

export function MacAppPreview() {
  return (
    <div className="w-full max-w-68">
      <div className="overflow-hidden rounded-xl border border-border bg-card text-left shadow-sm">
        <div className="px-4 pt-4 pb-2">
          <div className="space-y-1 text-sm">
            <p>Downloads: 24 items</p>
            {menuPreviewCategories.map((category) => (
              <p key={category.title}>
                {category.title}: {category.count}
              </p>
            ))}
          </div>
          <div className="my-2 h-px bg-border" />
          <div className="grid grid-cols-[1rem_1fr] items-center gap-2 text-sm font-medium text-red-500">
            <svg
              viewBox="0 0 16 16"
              fill="none"
              stroke="currentColor"
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="1.4"
              className="h-4 w-4"
              aria-hidden
            >
              <path d="M2.5 4.25h11M6 2.25h4M4.25 4.25l.6 9h6.3l.6-9M6.5 6.5v4.5M9.5 6.5v4.5" />
            </svg>
            <span>Move All Items to Trash</span>
          </div>
        </div>
        <div className="h-px bg-border" />
        <div className="space-y-1 px-3 py-2 text-sm">
          <div className="rounded px-1">Launch at Login</div>
          <div className="rounded px-1">Check for Updates…</div>
          <div className="rounded px-1">About DropSweep</div>
          <div className="flex items-center justify-between rounded px-1">
            <span>Quit DropSweep</span>
            <span className="text-muted">⌘Q</span>
          </div>
        </div>
      </div>
    </div>
  );
}
