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
    
    override init(frame: CGRect) {
        cacheView = ARGBookDocumentCacheView()
        contentView = ARGBookDocumentContentView()
        
        super.init(frame: frame)
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(contentView)
        
        cacheView.frame = bounds
        cacheView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(cacheView)
        cacheView.isHidden = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(document: ARGBookDocument, cache: ARGBookCache, completionHandler: (() -> Void)? = nil) {
        contentView.isHidden = true
        contentView.load(document: document, cache: cache) {
            self.contentView.isHidden = false
            completionHandler?()
        }
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint) {
        contentView.scroll(to: navigationPoint)
    }
    
    func applyReadingSettings(_ settings: ARGBookReadingSettings, completionHandler: (() -> Void)? = nil) {
        contentView.applyReadingSettings(settings) {
            self.contentView.isHidden = false
        }
    }
    
    override var description: String {
        let url = URL(fileURLWithPath: contentView.documentLoader.document!.filePath)
        return url.lastPathComponent
    }
    
}

extension ARGBookDocumentView: ARGNestedContiniousScrollContainer {
    
    func nestedScrollView(for scrollController: ARGContiniousScrollController) -> UIScrollView {
        return contentView.webView.scrollView
    }
    
    func nestedScrollViewContentReady(for scrollController: ARGContiniousScrollController) -> Bool {
        return contentView.layoutManager?.layout?.isReady ?? false
    }
    
    func nestedScrollViewDesiredScrollPosition(_ position: ARGContinuousScrollPosition) {
        switch position {
        case .begin:
            contentView.scroll(to: ARGBookDocumentStartNavigationPoint())
        case .end:
            contentView.scroll(to: ARGBookDocumentEndNavigationPoint())
        }
    }
    

}
