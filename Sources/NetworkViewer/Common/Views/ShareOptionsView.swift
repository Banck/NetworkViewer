//
//  ShareProvidersView.swift
//  NetworkViewer
//
//  Created by Mакс T on 19.11.2024.
//

import SwiftUI

struct ShareOptionsView: View {

    let data: Any
    @Environment(\.shareService) private var shareService: ShareService

    var body: some View {
        Menu {
            ForEach(shareService.providers, id: \.displayName) { provider in
                if provider.isAvailable(for: data) {
                    Button {
                        Task {
                            let items = await provider.shareData(for: data)
                            await MainActor.run {
                                let controller = UIActivityViewController(
                                    activityItems: [items],
                                    applicationActivities: nil
                                )
                                UIApplication.topViewController()?.present(controller, animated: true)
                            }
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
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
    }
}
