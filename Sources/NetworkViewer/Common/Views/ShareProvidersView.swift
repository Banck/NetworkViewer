//
//  ShareProvidersView.swift
//  NetworkViewer
//
//  Created by Mакс T on 19.11.2024.
//

import SwiftUI

struct ShareProvidersView: View {
    let providers: [ShareProvider]
    let operations: [NetworkViewer.Operation]
    @Binding var shareData: ShareService.Result?
    
    var body: some View {
        ForEach(providers, id: \.displayName) { provider in
            if let shareItem = provider.shareData(for: operations) {
                Button {
                    shareData = provider.shareData(for: operations)
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
    }
}

