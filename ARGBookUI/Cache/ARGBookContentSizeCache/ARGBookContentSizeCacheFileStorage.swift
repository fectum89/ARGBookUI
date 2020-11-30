//
//  ARGBookCacheFileManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 20.11.2020.
//

import Foundation

class ARGBookContentSizeCacheFileStorage: ARGBookCacheFileStorage {
    
    var ioQueue = DispatchQueue(label: "ARGBookContentSizeCacheFileStorage I/O queue")
    
    var maxSize: UInt = 0
    
    func read(item: ARGBookCacheFileStorageItem, completionHandler: @escaping (Any?) -> Void) {
        ioQueue.async {
            let filePath = self.prepareFilePath(for: item)
            
            if let contentSizeString = try? String(contentsOfFile: filePath.path, encoding: .utf8) {
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
    
    func save(items: [(object: Any, item: ARGBookCacheFileStorageItem)], completionHandler: (() -> Void)?) {
        ioQueue.async {
            for pair in items {
                let filePath = self.prepareFilePath(for: pair.item, forWriting: true)
                
                try? NSCoder.string(for: pair.object as! CGSize).write(toFile: filePath.path, atomically: true, encoding: .utf8)
                
                DispatchQueue.main.async {
                    completionHandler?()
                }
            }
        }
    }
    
    func name() -> String {
        return "contentSize"
    }
    
}
