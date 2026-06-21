//
//  MenuItemLabel.swift
//  DropSweep
//
//  Created by Timo Köthe on 21.06.26.
//

import SwiftUI

struct MenuItemLabel: View {
    let title: String
    let systemImage: String?
    let showsIcon: Bool

    init(_ title: String, systemImage: String? = nil, showsIcon: Bool = true) {
        self.title = title
        self.systemImage = systemImage
        self.showsIcon = showsIcon
    }

    var body: some View {
        if let systemImage, showsIcon {
            Label(title, systemImage: systemImage)
                .labelStyle(.titleAndIcon)
        } else {
            Text(title)
        }
    }
}

#Preview {
    MenuItemLabel("Title")
}
