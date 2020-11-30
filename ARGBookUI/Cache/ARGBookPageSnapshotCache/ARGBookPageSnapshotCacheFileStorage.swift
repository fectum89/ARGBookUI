//
//  ARGBookPageSnapshotFileManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 21.11.2020.
//

import UIKit


class ARGBookPageSnapshotCacheFileStorage: ARGBookCacheFileStorage {
    
    var ioQueue = DispatchQueue(label: "ARGBookPageSnapshotCacheFileStorage I/O queue")
    
    var maxSize: UInt = 0
    
    func name() -> String {
        return "snapshots"
    }
    
    func read(item: ARGBookCacheFileStorageItem, completionHandler: @escaping (Any?) -> Void) {
        ioQueue.async {
            let filePath = self.prepareFilePath(for: item)
            
            let image = autoreleasepool {() -> UIImage? in
                let image = TestImage(contentsOfFile: filePath.path)
                return image
            }
            
            DispatchQueue.main.async {
                completionHandler(image)
            }
        }
    }
    
    func save(items: [(object: Any, item: ARGBookCacheFileStorageItem)], completionHandler: (() -> Void)?) {
        ioQueue.async {
            for pair in items {
                if let pngData = autoreleasepool(invoking: {() -> Data? in
                    let image = pair.object as! UIImage
                    return image.pngData()
                }) {
                    let filePath = self.prepareFilePath(for: pair.item, forWriting: true)
                    try? pngData.write(to: filePath, options: [.atomicWrite])
                }
            }
            
            DispatchQueue.main.async {
                completionHandler?()
            }
        }
    }
    
}
