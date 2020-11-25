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
    
    var fileManager: ARGBookCacheFileManager!
    
    weak var containerView: UIView?
    
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


