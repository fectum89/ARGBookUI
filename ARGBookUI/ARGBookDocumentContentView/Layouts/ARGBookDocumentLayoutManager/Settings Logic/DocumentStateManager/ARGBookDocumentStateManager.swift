//
//  ARGBookDocumentSizeManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 14.10.2020.
//

import UIKit

class ARGBookDocumentStateManager: NSObject {
    
    var webView: WKWebView
    var measuredSize: CGSize
    var completionHandler: ((CGSize) -> Void)?
    var observingStopped = false
    
    init(webView: WKWebView, measuredSize: CGSize) {
        self.webView = webView
        self.measuredSize = measuredSize
    }
    
    func waitForDOMReady(completionHandler: ((CGSize) -> Void)? = nil) {
        self.completionHandler = completionHandler
        self.webView.scrollView.addObserver(self, forKeyPath: "contentSize", options: .initial, context: nil)
        
        self.perform(#selector(stopWaiting), with: nil, afterDelay: 2.0)
    }
    
    @objc func stopWaiting() {
        self.completionHandler?(webView.scrollView.contentSize)
        observingStopped = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard !observingStopped  else {
            return
        }
        
        let size = webView.scrollView.contentSize
        
        //print("size of webView \(String(describing: webView.url?.lastPathComponent)) changed: " + NSCoder.string(for: size))
        
        if measuredSize == size {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            stopWaiting()
        }
    }
    
    deinit {
        webView.scrollView.removeObserver(self, forKeyPath: "contentSize")
    }
    
}
