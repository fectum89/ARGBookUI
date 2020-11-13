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
        
        webView = ARGWebView(frame: frame, configuration: configuration)
        
        webView.frame = bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.isOpaque = false
        webView.clipsToBounds = true
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.allowsLinkPreview = false
        addSubview(webView)
        
        documentLoader = ARGBookDocumentLoader(webView: webView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var images = [UIImage]()
    
//    func takeSnapshots(offset: CGFloat) {
//        if offset >= 8200 {
//            return
//        }
//
//        //for offset in stride(from: 0, to: 8280, by: 414) {
//            let config = WKSnapshotConfiguration()
//            config.rect = CGRect(x: 0, y: 0, width: 414, height: 896)
//            self.webView.takeSnapshot(with: config) { (image, error) in
//                if image != nil {
//                    self.images.append(image!)
//                }
//
//                self.webView.scrollView.contentOffset = CGPoint(x: offset + 414, y: self.webView.scrollView.contentOffset.y)
//                self.takeSnapshots(offset: self.webView.scrollView.contentOffset.x)
//
//            }
//        }
    
      //  DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            //print("\(images)")
       // }
    
    func load<LayoutClass: ARGBookDocumentLayout>(document: ARGBookDocument, layoutClass: LayoutClass.Type, settings: ARGBookReadingSettings, cache: ARGBookCache, completionHandler: (() -> Void)? = nil) {
        if layoutManager == nil || !(layoutManager?.layout.isKind(of: layoutClass) ?? false) || layoutManager?.document.uid != document.uid {
            let layout = layoutClass.init(webView: webView)
            layoutManager = ARGBookDocumentLayoutManager(layout: layout, document: document, cache: cache)
            
            documentLoader.loadDocument(document) { [weak self] (newDocument, error) in
                self?.layoutManager?.documentLoaded = true
                self?.layoutManager?.applyReadingSettings(settings, completionHandler: completionHandler)
            }
        } else {
            layoutManager?.applyReadingSettings(settings, completionHandler: completionHandler)
        }
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint) {
        layoutManager?.scroll(to: navigationPoint)
    }
    
//    func applyReadingSettings(_ settings: ARGBookReadingSettings, completionHandler: (() -> Void)? = nil) {
//        layoutManager?.applyReadingSettings(settings, completionHandler: completionHandler)
//    }
    
    func obtainCurrentNavigationPoint(completionHandler: ((ARGBookNavigationPoint) -> Void)? = nil) {
        layoutManager?.obtainCurrentNavigationPoint(completionHandler: completionHandler)
    }
    
    func contentSize() -> CGSize {
        return CGSize(width: webView.scrollView.contentSize.width + webView.scrollView.contentInset.right,
                      height: webView.scrollView.contentSize.height + webView.scrollView.contentInset.bottom)
    }
    
    deinit {
        print("contentView deallocated")
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
