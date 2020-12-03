//
//  ARGBookPageSnapshotManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 20.11.2020.
//

import Foundation
import UIKit

struct ARGBookPageSnapshotInfo {
    
    var book: ARGBook
    
    var document: ARGBookDocument
    
    var settings: ARGBookReadingSettings
    
    var viewPort: CGSize
    
    var pageNumber: Int
    
}

extension ARGBookPageSnapshotInfo: ARGBookCacheFileStorageItem {
    
    var relativePath: URL {
        get {
            let filePath = URL(fileURLWithPath: "")
                .appendingPathComponent(book.uid)
                .appendingPathComponent(document.uid)
                .appendingPathComponent(NSCoder.string(for: viewPort))
                .appendingPathComponent(settings.appearanceAffectingStringRepresentation())
                .appendingPathComponent(String(pageNumber))
                .appendingPathExtension("png")
            
            return filePath
        }
    }
    
}

class ARGBookPageSnapshotCreator {
    
    weak var snapshotManager: ARGBookPageSnapshotManager?
    
    init(snapshotManager: ARGBookPageSnapshotManager) {
        self.snapshotManager = snapshotManager
    }
    
    func updateSnapshots(for documents:[ARGBookDocument], completionHandler: (() -> Void)? = nil) {
        if let document = documents.first,
           let snapshotManager = snapshotManager,
           let containerView = snapshotManager.pageCounter.contentSizeCache.containerView {
            var snapshotsCacheCreated = true
            
            if let pages = snapshotManager.pageCounter.pages(for: document) {
                let cacheCheckingGroup = DispatchGroup()
                
                for page in pages {
                    cacheCheckingGroup.enter()
                    snapshotManager.snapshot(for: page) { (image) in
                        if image == nil {
                            snapshotsCacheCreated = false
                        }
                        
                        cacheCheckingGroup.leave()
                    }
                }
                
                cacheCheckingGroup.notify(queue: .main) {
                    if snapshotsCacheCreated {
                        self.updateSnapshots(for: documents.filter {$0.uid != document.uid}, completionHandler: completionHandler)
                    } else {
                        let contentView = ARGBookDocumentContentView(frame: containerView.bounds)
                        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        containerView.addSubview(contentView)
                        contentView.isHidden = true
                        
                        weak var weakContentView = contentView
                        
                        contentView.load(document: document,
                                         layoutType: document.layoutType(for: snapshotManager.pageCounter.settings.scrollType),
                                         settings: snapshotManager.pageCounter.settings,
                                         cache: snapshotManager.pageCounter.contentSizeCache) { [weak self] in
                            weakContentView?.takeSnapshots { (images) in
                                let createNextSnapshotsBatch = {
                                    weakContentView?.removeFromSuperview()
                                    self?.updateSnapshots(for: documents.filter {$0.uid != document.uid}, completionHandler: completionHandler)
                                }
                                
                                if let images = images {
                                    var snapshots = [(UIImage, ARGBookPageSnapshotInfo)]()
                                    
                                    for (pageNumber, image) in images.enumerated() {
                                        if let snapshotManager = self?.snapshotManager {
                                            let info = ARGBookPageSnapshotInfo(book: snapshotManager.pageCounter.contentSizeCache.book,
                                                                               document: document,
                                                                               settings: snapshotManager.pageCounter.settings,
                                                                               viewPort: containerView.bounds.size,
                                                                               pageNumber: pageNumber + 1)
                                            snapshots.append((image, info))
                                        }
                                    }

                                    self?.snapshotManager?.save(snapshots: snapshots) {
                                        createNextSnapshotsBatch()
                                    }
                                } else {
                                    createNextSnapshotsBatch()
                                }
                            }
                        }
                    }
                }
            }
        } else {
            completionHandler?()
        }
    }
    
}

class ARGBookPageSnapshotManager: ARGBookPageSnapshotCache {
    
    var pageCounter: ARGBookPageCounter
    
    var snapshotsCache = NSCache<NSString, UIImage>()
    
    var fileStorage: ARGBookCacheFileStorage
    
    var snapshotCreator: ARGBookPageSnapshotCreator?
    
    var cacheObserver: NSObjectProtocol?
    
    init(pageCounter: ARGBookPageCounter, fileStorage: ARGBookCacheFileStorage) {
        snapshotsCache.countLimit = 10
        self.pageCounter = pageCounter
        self.fileStorage = fileStorage
        
        cacheObserver = NotificationCenter.default.addObserver(forName: ARGBookContentSizeCache.progressDidChangeNotification, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            if let progress = self?.pageCounter.contentSizeCache.progress {
                if progress == 1.0 {
                    self?.startCreatingSnapshots()
                }
            }
        }
    }
    
    func startCreatingSnapshots(completionHandler: (() -> Void)? = nil) {
        let documents = pageCounter.contentSizeCache.book.documents
        snapshotCreator = ARGBookPageSnapshotCreator(snapshotManager: self)
        snapshotCreator?.updateSnapshots(for: documents) { [weak self] in
            self?.snapshotCreator = nil
        }
    }
    
    func save(snapshots: [(object: UIImage, item: ARGBookPageSnapshotInfo)], completionHandler: (() -> Void)? = nil) {
        for snapshot in snapshots {
            snapshotsCache.setObject(snapshot.object, forKey: NSString(string: snapshot.item.relativePath.path))
        }
        
        fileStorage.save(items: snapshots, completionHandler: completionHandler)
    }
    
    func snapshot(for page: ARGDocumentPage, completionHandler: ((UIImage?) -> Void)?) {
        if let viewPort = pageCounter.contentSizeCache.containerView?.bounds.size {
            let info = ARGBookPageSnapshotInfo(book: pageCounter.contentSizeCache.book,
                                               document: page.startNavigationPoint.document,
                                               settings: pageCounter.settings,
                                               viewPort: viewPort,
                                               pageNumber: page.relativePageNumber)
            
            if let snapshot = snapshotsCache.object(forKey: NSString(string: info.relativePath.path)) {
                completionHandler?(snapshot)
            } else {
                fileStorage.read(item: info) { [weak self] (image) in
                    if let image = image as? UIImage {
                        self?.snapshotsCache.setObject(image, forKey: NSString(string: info.relativePath.path))
                    }
                    
                    completionHandler?(image as? UIImage)
                }
            }
        } else {
            completionHandler?(nil)
        }
    }
    
    deinit {
        if cacheObserver != nil {
            NotificationCenter.default.removeObserver(cacheObserver!)
        }
    }
    
}
