// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import AppKit
import SpoofMacCore
import SwiftUI

struct StatusPill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption.bold())
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.16)))
            .foregroundStyle(color)
    }
}

struct InlineActionChip: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .frame(height: 22)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.primary.opacity(0.07)))
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.primary.opacity(0.10), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }
}

struct AlignedInputBox<Trailing: View>: View {
    let placeholder: String
    @Binding var text: String
    var monospaced: Bool = true
    @ViewBuilder let trailing: () -> Trailing

    init(
        placeholder: String,
        text: Binding<String>,
        monospaced: Bool = true,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.placeholder = placeholder
        self._text = text
        self.monospaced = monospaced
        self.trailing = trailing
    }

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .allowsHitTesting(false)
                }
                TextField("", text: $text)
                    .textFieldStyle(.plain)
                    .font(monospaced ? .system(size: 12.5, design: .monospaced) : .system(size: 12.5))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            trailing()
        }
        .padding(.horizontal, 10)
        .frame(height: 32)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color(nsColor: .textBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .stroke(Color.primary.opacity(0.16), lineWidth: 1)
        )
    }
}

struct AlignedFieldRow<Control: View>: View {
    let title: String
    let hint: String
    @ViewBuilder let control: () -> Control

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.bold())
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(hint)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .help(hint)
            }
            .frame(width: 235, alignment: .leading)

            control()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct NativePopUpItem: Equatable {
    let id: String
    let title: String
    let isSeparator: Bool

    init(id: String, title: String) {
        self.id = id
        self.title = title
        self.isSeparator = false
    }

    private init(separatorIndex: Int) {
        self.id = "__sep_\(separatorIndex)"
        self.title = ""
        self.isSeparator = true
    }

    static func separator(_ index: Int = 0) -> NativePopUpItem {
        NativePopUpItem(separatorIndex: index)
    }
}

struct NativePopUpButton: NSViewRepresentable {
    let items: [NativePopUpItem]
    @Binding var selection: String

    func makeCoordinator() -> Coordinator {
        Coordinator(selection: $selection)
    }

    func makeNSView(context: Context) -> NSPopUpButton {
        let button = NSPopUpButton(frame: .zero, pullsDown: false)
        button.bezelStyle = .rounded
        button.controlSize = .regular
        button.lineBreakMode = .byTruncatingMiddle
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.target = context.coordinator
        button.action = #selector(Coordinator.selectionChanged(_:))
        rebuildMenu(button, items: items, selection: selection)
        return button
    }

    func updateNSView(_ nsView: NSPopUpButton, context: Context) {
        context.coordinator.selection = $selection
        if context.coordinator.lastItems != items {
            rebuildMenu(nsView, items: items, selection: selection)
            context.coordinator.lastItems = items
        } else if let idx = nsView.itemArray.firstIndex(where: { ($0.representedObject as? String) == selection }) {
            if nsView.indexOfSelectedItem != idx {
                nsView.selectItem(at: idx)
            }
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSPopUpButton, context: Context) -> CGSize? {
        let width = proposal.width ?? nsView.intrinsicContentSize.width
        return CGSize(width: max(width, 60), height: 28)
    }

    private func rebuildMenu(_ button: NSPopUpButton, items: [NativePopUpItem], selection: String) {
        button.removeAllItems()
        guard let menu = button.menu else { return }
        var selectedIndex = -1
        for item in items {
            if item.isSeparator {
                menu.addItem(.separator())
            } else {
                let menuItem = NSMenuItem(title: item.title, action: nil, keyEquivalent: "")
                menuItem.representedObject = item.id
                menu.addItem(menuItem)
                if item.id == selection {
                    selectedIndex = menu.items.count - 1
                }
            }
        }
        if selectedIndex >= 0 {
            button.selectItem(at: selectedIndex)
        }
    }

    final class Coordinator: NSObject {
        var selection: Binding<String>
        var lastItems: [NativePopUpItem] = []

        init(selection: Binding<String>) {
            self.selection = selection
        }

        @objc func selectionChanged(_ sender: NSPopUpButton) {
            if let id = sender.selectedItem?.representedObject as? String {
                selection.wrappedValue = id
            }
        }
    }
}
