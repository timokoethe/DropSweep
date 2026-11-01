const menuPreviewCategories = [
  { title: "Installers", count: 3, size: "684 MB", color: "text-muted" },
  { title: "Archives", count: 4, size: "412 MB", color: "text-muted" },
  { title: "PDFs", count: 3, size: "18 MB", color: "text-red-500" },
  { title: "Screenshots", count: 8, size: "42 MB", color: "text-green-500" },
  { title: "Images", count: 3, size: "64 MB", color: "text-purple-500" },
  { title: "Folders", count: 2, size: "296 MB", color: "text-blue-500" },
  { title: "Other Files", count: 1, size: "27 MB", color: "text-muted" },
];

function PreviewIcon({ kind, className = "" }: { kind: string; className?: string }) {
  const paths: Record<string, string> = {
    trash: "M4 6h16M9 6V3h6v3M6 6l1 15h10l1-15M10 10v7M14 10v7",
    folder: "M3 7V5h6l2 3h10v12H3V7Z",
    image: "M3 4h18v16H3ZM3 17l6-7 5 6 3-3 4 4M16 8h.01",
    file: "M5 3h9l5 5v13H5ZM14 3v6h5M8 13h8M8 17h6",
    refresh: "M20 7v5h-5M20 12a8 8 0 1 0-2 5",
    settings: "M9 3h6l1 4 4 2v6l-4 2-1 4H9l-1-4-4-2V9l4-2ZM12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6",
  };
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" className={className} aria-hidden="true">
      <path d={paths[kind] ?? paths.file} />
    </svg>
  );
}

export function MacAppPreview() {
  return (
    <div className="w-full max-w-85" role="img" aria-label="DropSweep app preview: Downloads grouped by category, with a confirmation before moving all listed items to Trash.">
      <div className="overflow-hidden rounded-2xl border border-border bg-card/98 text-left shadow-xl backdrop-blur-xl">
        <div className="flex items-center gap-2.5 px-4 pt-3 pb-1.25">
          <span
            aria-hidden="true"
            className="size-4.5 shrink-0 bg-current"
            style={{ mask: "url(/menu-bar-icon.png) center / contain no-repeat" }}
          />
          <span className="text-sm font-semibold">DropSweep</span>
          <div className="ml-auto flex gap-5 text-muted">
            <PreviewIcon kind="refresh" className="size-4" />
            <PreviewIcon kind="settings" className="size-5" />
          </div>
        </div>
        <div className="px-4 pb-3">
          <div className="flex items-baseline justify-between gap-2">
            <p className="text-[22px] font-bold tracking-tight">Downloads</p>
            <span className="text-[11px] font-medium text-blue-500">Open in Finder</span>
          </div>
          <p className="mt-1 text-sm font-medium text-muted">24 items · 1.5 GB</p>
        </div>
        <div className="border-y border-border">
          {menuPreviewCategories.map((category) => (
            <div key={category.title} className="relative flex min-h-11.5 items-center gap-2.5 px-4 py-1.5 after:absolute after:right-4 after:bottom-0 after:left-12.5 after:h-px after:bg-border last:after:hidden">
              <PreviewIcon kind={category.title === "Folders" ? "folder" : ["Images", "Screenshots"].includes(category.title) ? "image" : "file"} className={`size-6 shrink-0 ${category.color}`} />
              <div>
                <p className="text-sm font-semibold">{category.title}</p>
                <p className="text-xs text-muted">{category.count} {category.count === 1 ? "item" : "items"}</p>
              </div>
              <span className="ml-auto text-xs text-muted tabular-nums">{category.size}</span>
            </div>
          ))}
        </div>
        <div className="px-4 py-3">
          <div className="flex items-center justify-center gap-2 rounded-lg bg-blue-500 px-2 py-2 text-[13px] font-semibold text-white">
            <PreviewIcon kind="trash" className="size-4" />
            <span>Move Listed Items to Trash</span>
          </div>
        </div>
      </div>
    </div>
  );
}
