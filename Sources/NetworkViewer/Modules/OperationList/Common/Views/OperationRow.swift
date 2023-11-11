//
//  SwiftUIView.swift
//  
//
//  Created by Sakhabaev Egor on 11.11.2023.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle().foregroundColor(.red)
                Text("POST")
                Text("200 OK")
                Text("15:18:20")
                Text("182 ms")
            }.fixedSize()
            Text("https://google.com")
        }
    }
}

#Preview {
    List {
        SwiftUIView()
    }
}
