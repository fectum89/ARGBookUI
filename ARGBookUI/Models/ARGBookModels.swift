//
//  ARGBookModels.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import Foundation
import UIKit

@objc public protocol ARGBookNavigationPoint {
    
    @objc var document: ARGBookDocument {get}
    
    @objc var position: CGFloat {get}
    
}

@objc public protocol ARGBookAnchorNavigationPoint: ARGBookNavigationPoint {

    @objc var elementID: String {get}

}

@objc public protocol ARGBookRangeNavigationPoint: ARGBookAnchorNavigationPoint {

    @objc var lastElement: String? {get}

}

@objc public protocol ARGBookmark {

    @objc var navigationPoint: ARGBookNavigationPoint {get}

    @objc var name: String {get}

}

@objc public protocol ARGBookHighlight {

    @objc var navigationPoint: ARGBookRangeNavigationPoint {get}

    @objc var note: String? {get}

    @objc var color: UIColor {get}

}

class ARGBookNavigationPointInternal: ARGBookNavigationPoint {

    var document: ARGBookDocument

    var elementID: String?

    var position: CGFloat

    init(document: ARGBookDocument, elementID: String? = nil, position: CGFloat) {
        self.document = document
        self.elementID = elementID
        self.position = position
    }

}

@objc public protocol ARGBookDocument {
    
    var uid: String {get}
    
    var filePath: String {get}
    
    var hasFixedLayout: Bool {get}
    
    var highlights: [ARGBookHighlight]? {get}
    
    var bookmarks: [ARGBookmark]? {get}
    
    var book: ARGBook? {get}
    
    var languageCode: String? {get}
    
}

extension ARGBookDocument {
        
    func layoutType(for scrollType: ARGBookScrollType) -> (ARGBookDocumentLayout).Type  {
        if self.hasFixedLayout {
            return ARGBookDocumentFixedLayout.self as (ARGBookDocumentLayout).Type
        } else {
            switch scrollType {
            case .horizontal, .paging:
                return ARGBookDocumentHorizontalLayout.self as (ARGBookDocumentLayout).Type
            case .vertical:
                return ARGBookDocumentVerticalLayout.self as (ARGBookDocumentLayout).Type
            }
        }
    }
    
}

@objc public protocol ARGBook {
    
    var uid: String {get}
    
    var documents: [ARGBookDocument] {get}
    
    var contentDirectoryPath: String {get}
    
}

@objc public protocol ARGBookNavigationDelegate {
    
    func currentNavigationPointDidChange(_ navigationPoint: ARGBookNavigationPoint)
    
}

@objc public protocol ARGBookDocumentOverlayDelegate {
    
    func removeBookmarks(for page: ARGDocumentPage)
    
    func presentNoteUI(for highlights: [ARGBookHighlight], sourceRect: CGRect, page: ARGDocumentPage)
    
    func createHighlight(highlight: ARGBookHighlight, for page: ARGDocumentPage)
    
    func updateHighlight(highlight: ARGBookHighlight, for page: ARGDocumentPage)
    
    func removeHighlight(highlight: ARGBookHighlight, for page: ARGDocumentPage)
    
}
