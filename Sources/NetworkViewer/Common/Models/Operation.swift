//
//  Operation.swift
//
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import Foundation

public extension NetworkViewer {
    
    public struct Operation {

        let id: String
        let request: Request
        let response: Response?
        let responseData: Data
        let error: CustomError?
        let startAt: TimeInterval
        let endAt: TimeInterval?
        let isFromWebView: Bool
        /// WebView: response of a subframe navigation. Only the response is known, so there is no duration.
        let isFromIFrame: Bool
        /// WebView: the server redirected this request to `redirectURL`; the status code of the redirect is unknown.
        let redirectURL: String?

        public init(
            id: String,
            request: Request,
            response: Response?,
            responseData: Data,
            error: CustomError?,
            startAt: TimeInterval,
            endAt: TimeInterval?,
            isFromWebView: Bool = false,
            isFromIFrame: Bool = false,
            redirectURL: String? = nil
        ) {
            self.id = id
            self.request = request
            self.response = response
            self.responseData = responseData
            self.error = error
            self.startAt = startAt
            self.endAt = endAt
            self.isFromWebView = isFromWebView
            self.isFromIFrame = isFromIFrame
            self.redirectURL = redirectURL
        }
    }
}

extension NetworkViewer.Operation {

    /// Key the domain list groups operations by. WebView operations of a host get their own group.
    var domainKey: String {
        (URL(string: request.url)?.host ?? request.url) + (isFromWebView ? " " : "")
    }

    /// Search of the domain list.
    func matchesDomainSearch(_ searchText: String) -> Bool {
        searchText.isEmpty || request.url.lowercased().contains(searchText.lowercased())
    }
}
