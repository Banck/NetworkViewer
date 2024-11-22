//
//  ShareProvidersView.swift
//  NetworkViewer
//
//  Created by Mакс T on 19.11.2024.
//

import SwiftUI

struct ShareProvidersView: View {

    let operations: [NetworkViewer.Operation]
    @Environment(\.shareService) private var shareService: ShareService

    var body: some View {
        Menu {
            ForEach(shareService.providers, id: \.displayName) { provider in
                Button {
                    Task {
                        let controller = UIActivityViewController(
                            activityItems: [await provider.shareData(for: operations)?.value],
                            applicationActivities: nil
                        )
                        UIApplication.topViewController()?.present(controller, animated: true)
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
    }
}
