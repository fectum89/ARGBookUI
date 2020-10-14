//
//  ARGBookDocumentContentView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit

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
