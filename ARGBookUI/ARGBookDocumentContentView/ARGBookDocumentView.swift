//
//  ARGBookDocumentContentView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit
import ARGView

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
    
    func reloadIfNeeded(document: ARGBookDocument, settings: ARGBookReadingSettings, completion: (() -> Void)? = nil) {
        contentView.reloadIfNeeded(document: document,
                                   settings: settings,
                                   completion: completion)
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint) {
        contentView.scroll(to: navigationPoint)
    }
    
    func applyReadingSettings(_ settings: ARGBookReadingSettings, completionHandler: (() -> Void)? = nil) {
        contentView.applyReadingSettings(settings, completionHandler: completionHandler)
    }
    
}

extension ARGBookDocumentView: ARGNestedContiniousScrollContainer {
    
    func nestedScrollView(for scrollController: ARGContiniousScrollController) -> UIScrollView {
        return contentView.webView.scrollView
    }
    
    func nestedScrollViewContentReady(for scrollController: ARGContiniousScrollController) -> Bool {
        return contentView.layoutManager.layout?.isReady ?? false
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
