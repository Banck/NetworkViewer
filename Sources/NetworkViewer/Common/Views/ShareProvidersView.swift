//
//  ShareProvidersView.swift
//  NetworkViewer
//
//  Created by Mакс T on 19.11.2024.
//

import SwiftUI

struct ShareProvidersView: View {
    let operations: [NetworkViewer.Operation]
    @State private var shareData: ShareService.Result?
    @Environment(\.shareService) private var shareService: ShareService
    
    var body: some View {
        Menu {
            ForEach(shareService.providers, id: \.displayName) { provider in
                Button {
                    Task {
                        shareData = await provider.shareData(for: operations)
                    }
                } label: {
                    Label {
                        Text(provider.displayName)
                    } icon: {
                        if let image = provider.icon {
                            Image(uiImage: image)
                        }
                    }
                }
                .foregroundColor(.blue)
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .sheet(item: $shareData) { data in
            ActivityViewController(activityItems: [data.get()])
        }
    }
}
