//
//  ARGBookDocumentContentView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit
import ARGContinuousScroll

struct ARGBookDocumentPendingItem {
    var targetSize: CGSize
    var document: ARGBookDocument
    var settings: ARGBookReadingSettings
    var pageConverter: ARGBookPageConverter
    var navigationPoint: ARGBookNavigationPoint?
    var completionHandler: (() -> Void)?
}

class ARGBookDocumentView: UIView {
    var cacheView: ARGBookDocumentCacheView
    var contentView: ARGBookDocumentContentView
    var overlayView: ARGDocumentOverlayView
    
    var pendingItem: ARGBookDocumentPendingItem?
    
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
    
    public override var frame: CGRect {
        didSet {
            if let pendingItem = self.pendingItem {
                if frame.size == pendingItem.targetSize {
                    load(targetSize: frame.size, document: pendingItem.document, settings: pendingItem.settings, pageConverter: pendingItem.pageConverter, completionHandler: pendingItem.completionHandler)
                }
            }
        }
    }
    
    public override var bounds: CGRect {
        didSet {
            if let pendingItem = self.pendingItem {
                if bounds.size == pendingItem.targetSize {
                    load(targetSize: bounds.size, document: pendingItem.document, settings: pendingItem.settings, pageConverter: pendingItem.pageConverter, completionHandler: pendingItem.completionHandler)
                }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            overlayView.collectionView.contentOffset = contentView.webView.scrollView.contentOffset
        }
    }
    
    func load(targetSize: CGSize, document: ARGBookDocument, settings: ARGBookReadingSettings, pageConverter: ARGBookPageConverter, completionHandler: (() -> Void)? = nil) {
        if self.bounds.size == targetSize {
            contentView.isHidden = true
            let layoutType: (ARGBookDocumentLayout).Type = document.layoutType(for: settings.scrollType)
            
            self.overlayView.prepare(for: document, pageConverter: pageConverter, layoutType: layoutType as! ARGBookDocumentContentSizeContainer.Type)
            
            contentView.load(document: document, layoutType: layoutType, settings: settings, cache: pageConverter.bookCache) { [weak self] in
                self?.contentView.isHidden = false
                completionHandler?()
            }
            
            if let navigationPoint = pendingItem?.navigationPoint {
                contentView.scroll(to: navigationPoint)
            }
            
            pendingItem = nil
        } else {
            pendingItem = ARGBookDocumentPendingItem(targetSize: targetSize, document: document, settings: settings, pageConverter: pageConverter, completionHandler: completionHandler)
        }
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint) {
        if pendingItem != nil {
            pendingItem?.navigationPoint = navigationPoint
        } else {
            contentView.scroll(to: navigationPoint)
        }
    }
    
//    override var description: String {
//        let url = URL(fileURLWithPath: contentView.documentLoader.document?.filePath ?? "")
//        return url.lastPathComponent
//    }
    
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
