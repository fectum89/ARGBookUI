//
//  ARGBookCacheManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 28.10.2020.
//

import UIKit

@objc public class ARGBookCache: NSObject {
    
    @objc public static var progressDidChangeNotification: NSNotification.Name {
        NSNotification.Name(rawValue: "ARGBookCacheManagerProgressDidChangeNotification")
    }
    
    @objc public var book: ARGBook {
        get {
            fileManager.book
        }
    }
    
    @objc public var progress: CGFloat = 0 {
        didSet {
            NotificationCenter.default.post(name: Self.progressDidChangeNotification, object: self)
        }
    }
    
    func contentSize(for document: ARGBookDocument, settings: ARGBookReadingSettings, viewPort: CGSize) -> CGSize {
        return .zero
    }
    
    fileprivate var fileManager: ARGBookCacheFileManager!
    
}

struct ARGPresentationItem {
    
    var document: ARGBookDocument
    var settings: ARGBookReadingSettings
    var viewPort: CGSize
    
    init(document: ARGBookDocument, settings: ARGBookReadingSettings, viewPort: CGSize) {
        self.document = document
        self.settings = settings
        self.viewPort = viewPort
    }
    
    func key() -> String {
        return document.uid + NSCoder.string(for: viewPort) + settings.stringRepresentationForPageCache()
    }
    
}

class ARGBookCacheFileManager {
    
    let contentSizeCacheFileName = "contentSize"
    
    var ioQueue = DispatchQueue(label: "ARGBookCacheManager I/O queue")
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

class ARGBookCacheUpdater {
    
    weak var containerView: UIView?
    weak var cacheManager: ARGBookCacheManager?

    init(containerView: UIView, cacheManager: ARGBookCacheManager) {
        self.containerView = containerView
        self.cacheManager = cacheManager
    }
    
    func updateCache(for documents: [ARGBookDocument], with settings: ARGBookReadingSettings, viewPort: CGSize, completionHandler: (() -> Void)? = nil) {
        if let containerView = self.containerView {
            if let document = documents.first {
                let item = ARGPresentationItem(document: document, settings: settings, viewPort: viewPort)
                
                cacheManager?.readContentSize(for: item) { (contentSize) in
                    if contentSize != nil {
                        if let cacheManager = self.cacheManager {
                            cacheManager.progress += 1 / CGFloat(cacheManager.fileManager.book.documents.count)
                        }
                        
                        self.updateCache(for: documents.filter {$0.uid != document.uid},
                                         with: settings,
                                         viewPort: viewPort,
                                         completionHandler: completionHandler)
                    } else {
                        let contentView = ARGBookDocumentContentView(frame: containerView.bounds)
                        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        containerView.addSubview(contentView)
                        contentView.isHidden = true
                        
                        contentView.load(document: document, layoutType: document.layoutType(for: settings.scrollType), settings: settings, cache: self.cacheManager!) { [weak self] in
                            contentView.removeFromSuperview()
                            
                            let contentSize = contentView.webView.scrollView.contentSize
                            self?.cacheManager?.saveContentSize(contentSize, for: item)
                            
                            if let cacheManager = self?.cacheManager {
                                cacheManager.progress += 1 / CGFloat(cacheManager.fileManager.book.documents.count)
                            }
                            
                            self?.updateCache(for: documents.filter {$0.uid != document.uid},
                                             with: settings,
                                             viewPort: viewPort,
                                             completionHandler: completionHandler)
                        }
                    }
                }
            } else {
                completionHandler?()
            }
        }
    }
    
}

class ARGBookCacheManager: ARGBookCache {
    
    weak var containerView: UIView?
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
