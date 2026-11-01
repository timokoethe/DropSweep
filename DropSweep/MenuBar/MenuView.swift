//
//  MenuView.swift
//  DropSweep
//
//  Created by Timo Köthe on 24.05.26.
//

import AppKit
import SwiftUI

struct MenuView: View {
    @Bindable var vm: MenuViewModel

    var canCheckForUpdates = false
    var checkForUpdates: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            header
            overview
            Divider()
            categoryList
            Divider()
            footer
        }
        .frame(width: 340)
        .background(.thickMaterial)
        .onAppear {
            if !vm.isDeleting { vm.scanDownloadsFolder() }
            vm.refreshLaunchAtLoginStatus()
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image("MenuBarIcon")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .accessibilityHidden(true)
            Text("DropSweep")
                .font(.system(size: 14, weight: .semibold))
            Spacer()
            Button {
                vm.scanDownloadsFolder()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.borderless)
            .disabled(vm.isScanning || vm.isDeleting)
            .help("Refresh Downloads")
            .accessibilityLabel("Refresh Downloads")
            .keyboardShortcut("r", modifiers: .command)

            Menu {
                Toggle("Launch at Login", isOn: Binding(
                    get: { vm.launchAtLoginEnabled },
                    set: { vm.setLaunchAtLogin($0) }
                ))
                Button("Check for Updates…", action: checkForUpdates)
                    .disabled(!canCheckForUpdates)
                Button("About DropSweep") { vm.showAboutPanel() }
                Divider()
                Button("Quit DropSweep") { vm.quitApp() }
                    .keyboardShortcut("q", modifiers: .command)
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18))
                    .frame(width: 28, height: 28)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .help("Settings and app actions")
            .accessibilityLabel("Settings and app actions")
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 5)
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline) {
                Text("Downloads")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Button {
                    if let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Label("Open in Finder", systemImage: "folder")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.borderless)
                .tint(.accentColor)
            }
            Text("\(vm.itemsSummary) · \(vm.totalDisplaySize)")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private var categoryList: some View {
        ScrollView {
            VStack(spacing: 0) {
                if vm.isScanning || vm.isDeleting {
                    ProgressView(vm.isDeleting ? "Moving items to Trash…" : "Scanning Downloads…")
                        .frame(maxWidth: .infinity)
                        .padding(32)
                } else if let message = vm.scanErrorMessage {
                    statusMessage("Couldn’t read Downloads", detail: message, symbol: "exclamationmark.triangle")
                } else if vm.categories.isEmpty {
                    statusMessage("All clear", detail: "Your Downloads folder has no items to clean up.", symbol: "checkmark.circle")
                } else {
                    ForEach(vm.categories) { category in
                        DownloadCategoryRow(category: category)
                        if category.id != vm.categories.last?.id {
                            Divider()
                                .padding(.leading, 50)
                                .padding(.trailing, 16)
                        }
                    }
                }
            }
        }
        .frame(height: min(CGFloat(max(vm.categories.count, 2)) * 46, 322))
    }

    private func statusMessage(_ title: String, detail: String, symbol: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: symbol).font(.system(size: 24)).foregroundStyle(.secondary)
            Text(title).font(.headline)
            Text(detail).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
    }

    private var footer: some View {
        Button(action: confirmDeleteDownloads) {
            Label("Move Listed Items to Trash", systemImage: "trash")
                .font(.system(size: 13, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 26)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.regular)
        .disabled(!vm.canDeleteDownloads)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func confirmDeleteDownloads() {
        guard let confirmedItems = vm.itemsForDeletionConfirmation() else {
            return
        }

        let itemLabel = confirmedItems.count == 1 ? "item" : "items"
        let alert = NSAlert()

        alert.messageText = "Move \(confirmedItems.count) \(itemLabel) to the Trash?"
        alert.informativeText = "This moves all listed items from Downloads to the Trash."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Move to Trash")
        alert.addButton(withTitle: "Cancel")

        guard alert.runModal() == .alertFirstButtonReturn else {
            return
        }

        vm.deleteDownloads(confirmedItems)
    }
}

#Preview {
    MenuView(vm: MenuViewModel())
}
