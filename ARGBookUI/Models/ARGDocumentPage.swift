//
//  ARGDocumentPage.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 08.11.2020.
//

import Foundation

@objc public class ARGDocumentPage: NSObject {
    
    @objc public var startNavigationPoint: ARGBookNavigationPoint
    
    @objc public var endNavigationPoint: ARGBookNavigationPoint
    
    @objc public var globalPageNumber: Int = 0
    
    var relativePageNumber: Int = 0
    
    weak var pageCounter: ARGBookPageCounter?
    
    var refreshHandler: (() -> ())?
    
    init(startNavigationPoint: ARGBookNavigationPoint, endNavigationPoint: ARGBookNavigationPoint, pageCounter: ARGBookPageCounter) {
        self.startNavigationPoint = startNavigationPoint
        self.endNavigationPoint = endNavigationPoint
        self.pageCounter = pageCounter
    }
    
}

extension ARGDocumentPage {
    
    //TBD
    @objc public var bookmarks: [ARGBookmark]? {
        get {
            var bookmarks = [ARGBookmark]()
            
            if let documentBookmarks = startNavigationPoint.document.bookmarks {
                for bookmark in documentBookmarks {
                    if bookmark.navigationPoint.position >= startNavigationPoint.position && bookmark.navigationPoint.position < endNavigationPoint.position {
                        bookmarks.append(bookmark)
                    }
                }
            }
            
            return bookmarks.isEmpty ? nil : bookmarks
        }
    }
    
    @objc public func refresh() {
        refreshHandler?()
    }
    
    //TBD
    var notes: [ARGBookHighlight]? {
        get {
            return nil
        }
    }

}
