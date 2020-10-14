//
//  ARGBookDocumentLoader.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 12.10.2020.
//

import UIKit

class ARGBookDocumentLoader: NSObject {
    var webView: WKWebView
    var document: ARGBookDocument?
    var isDocumentLoaded: Bool = false
    var completionHandler: ((Error?) -> Void)?
    
    init(webView: WKWebView) {
        self.webView = webView
    }
    
    func loadDocumentIfNeeded(_ document: ARGBookDocument, completionHandler: ((Error?) -> Void)? = nil) {
        if self.document?.filePath != document.filePath {
            isDocumentLoaded = false
            self.completionHandler = completionHandler
            
            self.document = document
            
            let allowedURL = URL(fileURLWithPath: document.bookFilePath)
            webView.loadFileURL(URL(fileURLWithPath: document.filePath), allowingReadAccessTo: allowedURL)
        } else {
            completionHandler?(nil)
        }
    }
}

extension ARGBookDocumentLoader: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isDocumentLoaded = true
        completionHandler?(nil)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        completionHandler?(nil)
    }
    
}
