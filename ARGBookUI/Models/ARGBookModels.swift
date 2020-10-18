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

@objc public protocol ARGBookDocument {
    
    var filePath: String {get}
    
    var bookFilePath: String {get}
    
    var hasFixedLayout: Bool {get}
    
}

extension ARGBookDocument {
    public
    static func == (lhs: ARGBookDocument, rhs: ARGBookDocument) -> Bool {
        return lhs.filePath == rhs.filePath
    }
}

@objc public protocol ARGBook {
    
    var documents: [ARGBookDocument] {get}
    
}

@objc public protocol ARGBookNavigationInteractor {
    
    func currentNavigationPointDidChange(_ navigationPoint: ARGBookNavigationPoint)
    
    func currentNavigationPoint() -> ARGBookNavigationPoint?
    
}
