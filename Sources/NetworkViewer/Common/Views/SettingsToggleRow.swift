//
//  SettingsToggleRow.swift
//
//  Created by Sakhabaev Egor on 29.10.2023.
//

import SwiftUI

public struct SettingsToggleRow: View {
   
    public class Data: RowIdentifible, ObservableObject {

        public var id: String
        public let title: String
        @Published public var isOn: Bool
        public var onChangeToggle: (_ isOn: Bool) -> Void

        public init(
            id: String? = nil,
            title: String,
            isOn: Bool,
            onChangeToggle: @escaping (_ isOn: Bool) -> Void
        ) {
            self.id = id ?? title
            self.title = title
            self.isOn = isOn
            self.onChangeToggle = onChangeToggle
        }
    }

    @ObservedObject private var data: Data

    public init(data: Data) {
        self.data = data
    }

    public var body: some View {
        HStack() {
            Text(data.title)
                .font(.system(size: 17, weight: .medium))
            Spacer()
            Toggle("", isOn: $data.isOn)
                .onChange(of: data.isOn, perform: data.onChangeToggle)
        }
        .standardListPadding()
    }
}

#Preview {
    SettingsToggleRow(
        data: .init(
            id: nil,
            title: "Test Title",
            isOn: false,
            onChangeToggle: { newValue in
                print("onChangeToogle to \(newValue)")
            }
        )
    )
}
