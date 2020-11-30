//
//  ARGBookCacheFileManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 27.11.2020.
//

import Foundation

protocol ARGBookCacheFileStorageItem {
    
    var relativePath: URL {get}
    
}

protocol ARGBookCacheFileStorage {
    
    var ioQueue: DispatchQueue {get}
    
    var maxSize: UInt {get set}
    
    func name() -> String
    
    func read(item: ARGBookCacheFileStorageItem, completionHandler: @escaping (Any?) -> Void)
    
    func save(items: [(object: Any, item: ARGBookCacheFileStorageItem)], completionHandler: (() -> Void)?)
    
}

extension ARGBookCacheFileStorage {
    
    func prepareFilePath(for item: ARGBookCacheFileStorageItem, forWriting: Bool = false) -> URL {
        let storageDirectory = ARGFileUtils.cacheDirectory().appendingPathComponent(name(), isDirectory: true)
        let path = storageDirectory.appendingPathComponent(item.relativePath.deletingLastPathComponent().path)
        
        if forWriting {
            //handle max size here
            
            var isDirectory: ObjCBool = false
            
            if !FileManager.default.fileExists(atPath: path.path, isDirectory: &isDirectory) || isDirectory.boolValue == false {
                try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            }
        }
        
        return path.appendingPathComponent(item.relativePath.lastPathComponent)
    }
    
}
