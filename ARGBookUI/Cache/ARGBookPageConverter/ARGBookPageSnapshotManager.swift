//
//  ARGBookPageSnapshotManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 20.11.2020.
//

import Foundation

@objc public protocol ARGBookPageSnapshotFetcherDelegate: class {
    
    func pages(for: ARGBookDocument) -> [ARGDocumentPage]?
    
}

@objc public protocol ARGBookPageSnapshotFetcher {
    
    var delegate: ARGBookPageSnapshotFetcherDelegate? {set get}
    
    func snapshot(for page: ARGDocumentPage, completionHandler: ((UIImage?) -> Void)?)
    
}

class ARGBookPageSnapshotCreator {
    
    weak var snapshotManager: ARGBookPageSnapshotManager?
    
    init(snapshotManager: ARGBookPageSnapshotManager) {
        self.snapshotManager = snapshotManager
    }
    
    func updateSnapshots(for documents:[ARGBookDocument], completionHandler: (() -> Void)? = nil) {
        if let document = documents.first,
           let snapshotManager = snapshotManager,
           let containerView = snapshotManager.containerView {
            var snapshotsCacheCreated = true
            
            if let pages = snapshotManager.delegate?.pages(for: document) {
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
                                         layoutType: document.layoutType(for: snapshotManager.settings.scrollType),
                                         settings: snapshotManager.settings,
                                         cache: snapshotManager.cache) { [weak self] in
                            weakContentView?.takeSnapshots { (images) in
                                let createNextSnapshotsBatch = {
                                    weakContentView?.removeFromSuperview()
                                    self?.updateSnapshots(for: documents.filter {$0.uid != document.uid}, completionHandler: completionHandler)
                                }
                                
                                if let images = images {
                                    var snapshots = [(UIImage, ARGBookPageSnapshotInfo)]()

                                    for (pageNumber, image) in images.enumerated() {
                                        if let snapshotManager = self?.snapshotManager {
                                            let info = ARGBookPageSnapshotInfo(book: snapshotManager.cache.book,
                                                                               document: document,
                                                                               settings: snapshotManager.settings,
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
    
    deinit {
        print("deinit")
    }
    
}

class ARGBookPageSnapshotManager: ARGBookPageSnapshotFetcher {
    weak var delegate: ARGBookPageSnapshotFetcherDelegate? {
        didSet {
            if delegate != nil {
                
            }
        }
    }
    
    var snapshotsCache = NSCache<NSString, UIImage>()
    
    var fileManager: ARGBookPageSnapshotFileManager!
    
    var settings: ARGBookReadingSettings
    
    var cache: ARGBookCache
    
    var snapshotCreator: ARGBookPageSnapshotCreator?
    
    weak var containerView: UIView?
    
    var cacheObserver: NSObjectProtocol?
    
    init(fileManager: ARGBookPageSnapshotFileManager, cache: ARGBookCache, settings: ARGBookReadingSettings, containerView: UIView) {
        snapshotsCache.countLimit = 10
        self.fileManager = fileManager
        self.containerView = containerView
        self.settings = settings
        self.cache = cache
        
        cacheObserver = NotificationCenter.default.addObserver(forName: ARGBookCache.progressDidChangeNotification, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            if let progress = self?.cache.progress {
                if progress == 1.0 {
                    self?.startCreatingSnapshots()
                }
            }
        }
    }
    
    func startCreatingSnapshots(completionHandler: (() -> Void)? = nil) {
        let documents = cache.book.documents
        snapshotCreator = ARGBookPageSnapshotCreator(snapshotManager: self)
        snapshotCreator?.updateSnapshots(for: documents) { [weak self] in
            self?.snapshotCreator = nil
        }
    }
    
    func save(snapshots: [(image: UIImage, info: ARGBookPageSnapshotInfo)], completionHandler: (() -> Void)? = nil) {
        for snapshot in snapshots {
            snapshotsCache.setObject(snapshot.image, forKey: snapshot.info.key)
        }
        
        fileManager.save(snapshots: snapshots, completionHandler: completionHandler)
    }
    
    func snapshot(for page: ARGDocumentPage, completionHandler: ((UIImage?) -> Void)?) {
        if let viewPort = containerView?.bounds.size {
            let info = ARGBookPageSnapshotInfo(book: cache.book,
                                               document: page.startNavigationPoint.document,
                                               settings: settings,
                                               viewPort: viewPort,
                                               pageNumber: page.relativePageNumber)
            
            if let snapshot = snapshotsCache.object(forKey: info.key) {
                completionHandler?(snapshot)
            } else {
                fileManager.read(for: info) { (image) in
                    if let image = image {
                        self.snapshotsCache.setObject(image, forKey: info.key)
                    }
                    
                    completionHandler?(image)
                }
            }
        } else {
            completionHandler?(nil)
        }
    }
    
    deinit {
        print("deinit")
        
        if cacheObserver != nil {
            NotificationCenter.default.removeObserver(cacheObserver!)
        }
    }
    
}
