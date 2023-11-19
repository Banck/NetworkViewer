//
//  viSearchableModifier.swift
//  
//
//  Created by Sakhabaev Egor on 19.11.2023.
//

import SwiftUI

struct viSearchableModifier: ViewModifier {

    let text: Binding<String>
    let prompt: Text?

    init(text: Binding<String>, prompt: Text? = nil) {
        self.text = text
        self.prompt = prompt
    }

    func body(content: Content) -> some View {

        if #available(iOS 15.0, *) {
            content
                .searchable(text: text, prompt: prompt)
        } else {
            content
        }
    }
}

extension View {

    func viSearchable(text: Binding<String>, prompt: Text? = nil) -> some View {
        modifier(viSearchableModifier(text: text, prompt: prompt))
    }
}
