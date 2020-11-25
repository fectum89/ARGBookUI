//
//  ARGBookPageConverter.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 20.11.2020.
//

import Foundation

@objc public protocol ARGBookPageConverter {
    
    var bookCache: ARGBookCache {get}
    
    var snapshotManager: ARGBookPageSnapshotFetcher {get}
    
    var settings: ARGBookReadingSettings {get}
    
    var pageCount: Int {get}
    
    func page(for point: ARGBookNavigationPoint) -> ARGDocumentPage?
    
    func pages(for document: ARGBookDocument) -> [ARGDocumentPage]?
    
    func point(for pageNumber: Int) -> ARGBookNavigationPoint?
    
}

