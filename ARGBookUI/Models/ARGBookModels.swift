//
//  ARGBookModels.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import Foundation

@objc public protocol ARGBookNavigationPoint {
    
    var document: ARGBookDocument {get}
    
    var elementID: String {get}
    
    var pageNumber: Int {get}
    
}

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
