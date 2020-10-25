//
//  ARGBookModels.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import Foundation

@objc public protocol ARGBookNavigationPoint {
    
    @objc optional var document: ARGBookDocument {get}
    
    @objc optional var elementID: String {get}
    
    @objc optional var pageNumber: Int {get}
    
}

public class ARGBookDocumentStartNavigationPoint: ARGBookNavigationPoint {}
public class ARGBookDocumentEndNavigationPoint: ARGBookNavigationPoint {}

class ARGBookNavigationPointInternal: ARGBookNavigationPoint{
    
    var document: ARGBookDocument
    
    var elementID: String
    
    init(document: ARGBookDocument, elementID: String) {
        self.document = document
        self.elementID = elementID
    }
    
}

@objc public protocol ARGBookDocument {
    
    var filePath: String {get}
    
    var hasFixedLayout: Bool {get}
    
    var book: ARGBook? {get}
    
}

extension ARGBookDocument {
    public
    static func == (lhs: ARGBookDocument, rhs: ARGBookDocument) -> Bool {
        return lhs.filePath == rhs.filePath
    }
}

@objc public protocol ARGBook {
    
    var documents: [ARGBookDocument] {get}
    
    var contentDirectoryPath: String {get}
    
}

@objc public protocol ARGBookNavigationDelegate {
    
    func currentNavigationPointDidChange(_ navigationPoint: ARGBookNavigationPoint)
    
}
