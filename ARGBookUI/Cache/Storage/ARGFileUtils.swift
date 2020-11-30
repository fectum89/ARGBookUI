//
//  ARGFileUtils.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 28.10.2020.
//

import UIKit

class ARGFileUtils: NSObject {
    
    class func cacheDirectory() -> URL {
        let arrayPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDirectoryPath = arrayPaths[0].appendingPathComponent(Bundle(for: self).bundleIdentifier!)

        if !FileManager.default.fileExists(atPath: cacheDirectoryPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: cacheDirectoryPath.path, withIntermediateDirectories: false, attributes: nil)
            } catch  {
                print(error)
            }
        }

        return cacheDirectoryPath
    }
    
}
