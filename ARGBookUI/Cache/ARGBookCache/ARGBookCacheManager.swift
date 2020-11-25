//
//  ARGBookCacheManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 20.11.2020.
//

import Foundation

class ARGBookCacheManager: ARGBookCache {
    
    var contentSizeDictionary = [String : CGSize]()
    var cacheUpdater: ARGBookCacheUpdater?
    
    init(containerView: UIView, fileManager: ARGBookCacheFileManager) {
        super.init()
        self.containerView = containerView
        self.fileManager = fileManager
    }
    
    func startCacheUpdating(for documents: [ARGBookDocument], with settings: ARGBookReadingSettings, viewPort: CGSize) {
        progress = 0.0
        
        if containerView != nil {
            self.cacheUpdater = ARGBookCacheUpdater(containerView: containerView!, cacheManager: self)
            cacheUpdater?.updateCache(for: documents, with: settings, viewPort: viewPort) { [weak self] in
                print("cache is ready")
                self?.progress = 1.0
                self?.cacheUpdater = nil
            }
        }
    }
    
    func readContentSize(for item: ARGPresentationItem, completionHandler: @escaping (CGSize?) -> Void) {
        if let contentSize = contentSizeDictionary[item.key()] {
            completionHandler(contentSize)
        } else {
            fileManager.readContentSize(for: item) { (contentSize) in
                if contentSize != nil {
                    self.contentSizeDictionary[item.key()] = contentSize!
                }
                
                completionHandler(contentSize)
            }
        }
    }
    
    func saveContentSize(_ contentSize: CGSize, for item: ARGPresentationItem, completionHandler: (() -> Void)? = nil) {
        self.contentSizeDictionary[item.key()] = contentSize
        fileManager.writeContentSize(contentSize, for: item, completionHandler: completionHandler)
    }
    
    override func contentSize(for document: ARGBookDocument, settings: ARGBookReadingSettings, viewPort: CGSize) -> CGSize {
        let item = ARGPresentationItem(document: document, settings: settings, viewPort: viewPort)
        if let size = contentSizeDictionary[item.key()] {
            return size
        } else {
            return .zero
        }
    }

}
