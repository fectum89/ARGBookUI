//
//  ARGBookPageSnapshotFileManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 21.11.2020.
//

import UIKit

struct ARGBookPageSnapshotInfo {
    var book: ARGBook
    var document: ARGBookDocument
    var settings: ARGBookReadingSettings
    var viewPort: CGSize
    var pageNumber: Int
    
    init(book: ARGBook, document: ARGBookDocument, settings: ARGBookReadingSettings, viewPort: CGSize, pageNumber: Int) {
        self.book = book
        self.document = document
        self.settings = settings
        self.viewPort = viewPort
        self.pageNumber = pageNumber
    }
    
    var key: NSString {
        get {
            let key = document.uid
                + NSCoder.string(for: viewPort)
                + settings.stringRepresentationForSnapshotsCache()
                + String(pageNumber)
            
            return NSString(string: key)
        }
    }
    
    func fileURL() -> URL {
        let filePath = ARGFileUtils.cacheDirectory()
            .appendingPathComponent(book.uid)
            .appendingPathComponent(document.uid)
            .appendingPathComponent(NSCoder.string(for: viewPort))
            .appendingPathComponent(settings.stringRepresentationForSnapshotsCache())
        
        try? FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: true, attributes: nil)
        
        let fileName = String(pageNumber) + ".png"
        
        return filePath.appendingPathComponent(fileName)
    }
}

class ARGBookPageSnapshotFileManager {
    var ioQueue = DispatchQueue(label: "ARGBookPageSnapshotFileManager I/O queue")
    
    //var book: ARGBook
    
    init(book: ARGBook) {
       // self.book = book
    }
    
    func read(for snapshotInfo: ARGBookPageSnapshotInfo, completionHandler: @escaping (UIImage?) -> Void) {
        ioQueue.async {
            let image = UIImage(contentsOfFile: snapshotInfo.fileURL().path)
            
            DispatchQueue.main.async {
                completionHandler(image)
            }
        }
    }
    
    func save(snapshots: [(image: UIImage, info: ARGBookPageSnapshotInfo)], completionHandler: (() -> Void)? = nil) {
        ioQueue.async {
            for snapshot in snapshots {
                if let pngData = autoreleasepool(invoking: { () -> Data? in
                    return snapshot.image.pngData()
                }) {
                    try? pngData.write(to: snapshot.info.fileURL(), options: [.atomicWrite])
                }
            }
            
            DispatchQueue.main.async {
                completionHandler?()
            }
        }
    }
}
