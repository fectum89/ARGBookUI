//
//  ARGBookCacheManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 28.10.2020.
//

import UIKit

@objc public class ARGBookContentSizeCache: NSObject {
    
    @objc public static var progressDidChangeNotification: NSNotification.Name {
        NSNotification.Name(rawValue: "ARGBookCacheManagerProgressDidChangeNotification")
    }
    
    @objc public var book: ARGBook
    
    @objc public var progress: CGFloat = 0 {
        didSet {
            NotificationCenter.default.post(name: Self.progressDidChangeNotification, object: self)
        }
    }
    
    @objc public func contentSize(for document: ARGBookDocument, settings: ARGBookReadingSettings, viewPort: CGSize) -> CGSize {
        return .zero
    }
    
    var fileStorage: ARGBookCacheFileStorage
    
    weak var containerView: UIView?
    
    init(book: ARGBook, fileStorage: ARGBookCacheFileStorage, containerView: UIView) {
        self.book = book
        self.containerView = containerView
        self.fileStorage = fileStorage
    }
    
}


