//
//  ARGBookDocumentSizeManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 14.10.2020.
//

import UIKit

class ARGBookDocumentSizeManager: NSObject {
    
    var webView: WKWebView
    var measuredSize: CGSize
    var completionHandler: ((CGSize) -> Void)?
    
    init(webView: WKWebView, measuredSize: CGSize) {
        self.webView = webView
        self.measuredSize = measuredSize
    }
    
    func waitForDOMReady(completionHandler: ((CGSize) -> Void)? = nil) {
        self.completionHandler = completionHandler
        self.webView.scrollView.addObserver(self, forKeyPath: "contentSize", options: .initial, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let size = webView.scrollView.contentSize
        
        print("size of webView \(String(describing: webView.url?.lastPathComponent)) changed: " + NSCoder.string(for: size))
        
        if measuredSize == size {
            let completion = {
                self.completionHandler?(size)
            }
            
            completion()
        }
    }
    
    func stopObserving() {
        webView.scrollView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    deinit {
        stopObserving()
    }
    
}
