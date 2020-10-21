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
    var completionHandler: ((Bool, Error?) -> Void)?
    
    init(webView: WKWebView) {
        self.webView = webView
    }
    
    func loadDocumentIfNeeded(_ document: ARGBookDocument, completionHandler: ((Bool, Error?) -> Void)? = nil) -> Bool {
        if self.document?.filePath != document.filePath {
            loadDocument(document, completionHandler: completionHandler)
            return true
        } else {
            completionHandler?(false, nil)
            return false
        }
    }
    
    func loadDocument(_ document: ARGBookDocument, completionHandler: ((Bool, Error?) -> Void)? = nil) {
        isDocumentLoaded = false
        self.completionHandler = completionHandler
        
        self.document = document
        
        let allowedURL = URL(fileURLWithPath: document.book?.contentDirectoryPath ?? "")
        webView.loadFileURL(URL(fileURLWithPath: document.filePath), allowingReadAccessTo: allowedURL)
    }
    
    func reloadDocument(completionHandler: ((Error?) -> Void)?) {
        if let document = self.document {
            loadDocument(document) { (newDocument, error) in
                completionHandler?(error)
            }
        }
    }
    
}

extension ARGBookDocumentLoader: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isDocumentLoaded = true
        completionHandler?(true, nil)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        completionHandler?(false, error)
    }
    
}
