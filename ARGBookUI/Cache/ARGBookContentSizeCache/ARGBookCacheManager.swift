//
//  ARGBookCacheManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 20.11.2020.
//

import Foundation
import UIKit

struct ARGPresentationItem {
    
    var book: ARGBook
    
    var document: ARGBookDocument
    
    var settings: ARGBookReadingSettings
    
    var viewPort: CGSize
    
}

extension ARGPresentationItem: ARGBookCacheFileStorageItem {
    
    var relativePath: URL {
        get {
            let filePath = URL(fileURLWithPath: "")
                .appendingPathComponent(book.uid)
                .appendingPathComponent(document.uid)
                .appendingPathComponent(NSCoder.string(for: viewPort))
                .appendingPathComponent(settings.layoutAffectingStringRepresentation())
            
            return filePath
        }
    }
    
}

class ARGBookCacheManager: ARGBookContentSizeCache {
    
    var contentSizeDictionary = [String : CGSize]()
    
    var cacheUpdater: ARGBookCacheUpdater?
    
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
        if let contentSize = contentSizeDictionary[item.relativePath.path] {
            completionHandler(contentSize)
        } else {
            fileStorage.read(item: item) { (contentSize) in
                if let contentSize = contentSize as? CGSize {
                    self.contentSizeDictionary[item.relativePath.path] = contentSize
                }
                
                completionHandler(contentSize as? CGSize)
            }
        }
    }
    
    func saveContentSize(_ contentSize: CGSize, for item: ARGPresentationItem, completionHandler: (() -> Void)? = nil) {
        self.contentSizeDictionary[item.relativePath.path] = contentSize
        fileStorage.save(items: [(contentSize, item)], completionHandler: completionHandler)
    }
    
    override func contentSize(for document: ARGBookDocument, settings: ARGBookReadingSettings, viewPort: CGSize) -> CGSize {
        let item = ARGPresentationItem(book: book, document: document, settings: settings, viewPort: viewPort)
        
        if let size = contentSizeDictionary[item.relativePath.path] {
            return size
        } else {
            return .zero
        }
    }

}
