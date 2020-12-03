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
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.allowsLinkPreview = false
        addSubview(webView)
        
        documentLoader = ARGBookDocumentLoader(webView: webView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(document: ARGBookDocument, layoutType: ARGBookDocumentLayout.Type, settings: ARGBookReadingSettings, cache: ARGBookContentSizeCache, completionHandler: (() -> Void)? = nil) {

        if layoutManager == nil || !(type(of:layoutManager!.layout) == layoutType) || layoutManager!.document.uid != document.uid {
            let layout = layoutType.init(webView: webView)
            layoutManager = ARGBookDocumentLayoutManager(layout: layout, document: document, cache: cache)
            
            documentLoader.loadDocument(document) { [weak self] (newDocument, error) in
                self?.layoutManager?.documentLoaded = true
                self?.layoutManager?.applyReadingSettings(settings, completionHandler: {
                    completionHandler?()
                })
            }
        } else {
            layoutManager?.applyReadingSettings(settings, completionHandler: completionHandler)
        }
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint, completionHandler: (() -> Void)? = nil) {
        layoutManager?.scroll(to: navigationPoint, completionHandler: completionHandler)
    }
    
    func obtainCurrentNavigationPoint(completionHandler: ((ARGBookNavigationPoint) -> Void)? = nil) {
        layoutManager?.obtainCurrentNavigationPoint(completionHandler: completionHandler)
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
