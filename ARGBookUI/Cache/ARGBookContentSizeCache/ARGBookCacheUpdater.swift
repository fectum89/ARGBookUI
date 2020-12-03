//
//  ARGBookCacheUpdater.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 20.11.2020.
//

import Foundation
import UIKit

class ARGBookCacheUpdater {
    
    weak var containerView: UIView?
    
    weak var cacheManager: ARGBookCacheManager?
    
    init(containerView: UIView, cacheManager: ARGBookCacheManager) {
        self.containerView = containerView
        self.cacheManager = cacheManager
    }
    
    func updateCache(for documents: [ARGBookDocument], with settings: ARGBookReadingSettings, viewPort: CGSize, completionHandler: (() -> Void)? = nil) {
        if let containerView = self.containerView, let book = cacheManager?.book {
            if let document = documents.first {
                let item = ARGPresentationItem(book: book, document: document, settings: settings, viewPort: viewPort)
                
                cacheManager?.readContentSize(for: item) { (contentSize) in
                    if contentSize != nil {
                        if let cacheManager = self.cacheManager {
                            cacheManager.progress += 1 / CGFloat(book.documents.count)
                        }
                        
                        self.updateCache(for: documents.filter {$0.uid != document.uid},
                                         with: settings,
                                         viewPort: viewPort,
                                         completionHandler: completionHandler)
                    } else {
                        let contentView = ARGBookDocumentContentView(frame: containerView.bounds)
                        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        containerView.addSubview(contentView)
                        contentView.isHidden = true
                        
                        contentView.load(document: document, layoutType: document.layoutType(for: settings.scrollType), settings: settings, cache: self.cacheManager!) { [weak self] in
                            
                            contentView.removeFromSuperview()
                            
                            let contentSize = contentView.webView.scrollView.contentSize
                            self?.cacheManager?.saveContentSize(contentSize, for: item)
                            
                            if let cacheManager = self?.cacheManager {
                                cacheManager.progress += 1 / CGFloat(book.documents.count)
                            }
                            
                            self?.updateCache(for: documents.filter {$0.uid != document.uid},
                                              with: settings,
                                              viewPort: viewPort,
                                              completionHandler: completionHandler)
                            
                        }
                    }
                }
            } else {
                completionHandler?()
            }
        }
    }
    
}
