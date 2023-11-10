//
//  CustomPickerView.swift
//
//  Created by Sakhabaev Egor on 29.10.2023.
//

import SwiftUI

public struct CustomPickerView: View {

    public class Data: RowIdentifible, ObservableObject {

        public var id: String
        let title: String
        @Published var selectedOption: String
        let options: [String]
        public var onChangeValue: (_ value: String) -> Void

        public init(
            id: String? = nil,
            title: String,
            selectedOption: String,
            options: [String],
            onChangeValue: @escaping (_ value: String) -> Void
        ) {
            self.id = id ?? title
            self.title = title
            self.selectedOption = selectedOption
            self.options = options
            self.onChangeValue = onChangeValue
        }
    }

    @ObservedObject private var data: Data

    public init(data: Data) {
        self.data = data
    }

    public var body: some View {
        Picker(data.title, selection: $data.selectedOption) {
            ForEach(data.options, id: \.self) {
                Text($0)
                    .tag($0)
                // Hack to make whole row tappable
                    .contentShape(Rectangle())
            }
        }
        .font(.system(size: 17, weight: .medium))
        .tintColor(.secondary)
        .onChange(of: data.selectedOption, perform: data.onChangeValue)
        .standardListPadding()
        
    }
}

#Preview {
    VStack {
        CustomPickerView(
            data: .init(
                title: "Test",
                selectedOption: "Second",
                options: ["First", "Second", "Third"],
                onChangeValue: { newValue in
                    print("CustomPickerView onChangeValue: \(newValue)")
                }
            )
        )
        List {
            CustomPickerView(
                data: .init(
                    title: "Test",
                    selectedOption: "Third",
                    options: ["First", "Second", "Third"],
                    onChangeValue: { newValue in
                        print("CustomPickerView onChangeValue: \(newValue)")
                    }
                )
            )
        }
    }
}
