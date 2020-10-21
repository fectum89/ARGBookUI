//
//  ARGBookDocumentContentView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit
import WebKit

class ARGBookDocumentContentView: UIView {
    
    var webView: WKWebView!
    
    var documentLoader: ARGBookDocumentLoader!
    var layoutManager: ARGBookDocumentLayoutManager?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let configuration = ARGBookWebViewConfigurator.configuration()
        
        webView = WKWebView(frame: frame, configuration: configuration)
        
        webView.frame = bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.isOpaque = false
        webView.clipsToBounds = true
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        addSubview(webView)
        
        documentLoader = ARGBookDocumentLoader(webView: webView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadIfNeeded(document: ARGBookDocument, settings: ARGBookReadingSettings, completion: (() -> Void)? = nil) {
        let newDocument = documentLoader.loadDocumentIfNeeded(document) { newDocument, error in
            self.layoutManager?.document = document
            
            self.layoutManager?.applyReadingSettings(settings) {
                completion?()
            }
        }
        
        if newDocument {
            self.layoutManager = ARGBookDocumentLayoutManager(webView: self.webView, layoutTypeChangedHandler: { documentReadyHandler in
                self.documentLoader.reloadDocument { (error) in
                    documentReadyHandler()
                }
            })
        }
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint) {
        layoutManager?.scroll(to: navigationPoint)
    }
    
    func applyReadingSettings(_ settings: ARGBookReadingSettings, completionHandler: (() -> Void)? = nil) {
        layoutManager?.applyReadingSettings(settings, completionHandler: completionHandler)
    }
    
}

extension ARGBookDocumentContentView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        documentLoader.webView(webView, didFinish: navigation)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        documentLoader.webView(webView, didFail: navigation, withError: error)
    }
    
}
