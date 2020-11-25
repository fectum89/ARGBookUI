//
//  ARGBookCacheFileManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 20.11.2020.
//

import Foundation

class ARGBookCacheFileManager {
    
    let contentSizeCacheFileName = "contentSize"
    
    var ioQueue = DispatchQueue(label: "ARGBookCacheFileManager I/O queue")
    var book: ARGBook
    
    init(book: ARGBook) {
        self.book = book
    }
    
    func readContentSize(for item: ARGPresentationItem, completionHandler: @escaping (CGSize?) -> Void) {
        ioQueue.async {
            let filePath = self.contentSizeCacheDirectory(for: item)
            if let contentSizeString = try? String(contentsOfFile: filePath.appendingPathComponent(self.contentSizeCacheFileName).path, encoding: .utf8) {
                let contentSize = NSCoder.cgSize(for: contentSizeString)
                
                DispatchQueue.main.async {
                    completionHandler(contentSize)
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            }
        }
    }
    
    func writeContentSize(_ contentSize: CGSize, for item: ARGPresentationItem, completionHandler: (() -> Void)? = nil) {
        ioQueue.async {
            let filePath = self.contentSizeCacheDirectory(for: item)
            try? NSCoder.string(for: contentSize).write(toFile: filePath.appendingPathComponent(self.contentSizeCacheFileName).path, atomically: true, encoding: .utf8)
            
            DispatchQueue.main.async {
                completionHandler?()
            }
        }
    }
    
    func contentSizeCacheDirectory(for item: ARGPresentationItem) -> URL {
        let filePath = ARGFileUtils.cacheDirectory()
            .appendingPathComponent(book.uid)
            .appendingPathComponent(item.document.uid)
            .appendingPathComponent(NSCoder.string(for: item.viewPort))
            .appendingPathComponent(item.settings.stringRepresentationForPageCache())
        
        try? FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: true, attributes: nil)
        
        return filePath
    }
    
}
