//
//  ARGBookDocumentContentView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit
import ARGContinuousScroll

class ARGBookDocumentView: UIView {
    var cacheView: ARGBookDocumentCacheView
    var contentView: ARGBookDocumentContentView
    var overlayView: ARGDocumentOverlayView
    
    override init(frame: CGRect) {
        cacheView = ARGBookDocumentCacheView()
        contentView = ARGBookDocumentContentView()
        overlayView = ARGDocumentOverlayView()
        
        super.init(frame: frame)
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(contentView)
        
        cacheView.frame = bounds
        cacheView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(cacheView)
        cacheView.isHidden = true

        overlayView.frame = bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(overlayView)
        
        contentView.webView.scrollView.addObserver(self, forKeyPath: "contentOffset", options: .initial, context: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            overlayView.collectionView.contentOffset = contentView.webView.scrollView.contentOffset
        }
    }
    
    func load(document: ARGBookDocument, settings: ARGBookReadingSettings, pageConverter: ARGBookPageConverter, completionHandler: (() -> Void)? = nil) {
        contentView.isHidden = true
        let layoutClass = document.layoutClass(for: settings.scrollType)
        
        overlayView.prepare(for: document, pageConverter: pageConverter)

        contentView.load(document: document, layoutClass: layoutClass, settings: settings, cache: pageConverter.bookCache) { [weak self] in
            self?.contentView.isHidden = false
            completionHandler?()
        }
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint) {
        contentView.scroll(to: navigationPoint)
    }
    
    override var description: String {
        let url = URL(fileURLWithPath: contentView.documentLoader.document?.filePath ?? "")
        return url.lastPathComponent
    }
    
    deinit {
        contentView.webView.scrollView.removeObserver(self, forKeyPath: "contentOffset")
        print("documentView deinit")
    }
    
}

extension ARGBookDocumentView: ARGNestedContiniousScrollContainer {
    
    func nestedScrollView(for scrollController: ARGContiniousScrollController) -> UIScrollView {
        return contentView.webView.scrollView
    }
    
    func nestedScrollViewContentReady(for scrollController: ARGContiniousScrollController) -> Bool {
        return contentView.layoutManager?.layout.isReady ?? false
    }
    
    func nestedScrollViewDesiredScrollPosition(_ position: ARGContinuousScrollPosition) {
        switch position {
        case .begin:
            contentView.scroll(to: ARGBookNavigationPointInternal(document: contentView.documentLoader.document!, position: 0))
        case .end:
            contentView.scroll(to: ARGBookNavigationPointInternal(document: contentView.documentLoader.document!, position: 1))
        }
    }
    

}
