//
//  ARGBookPageSnapshotCache.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 27.11.2020.
//

import Foundation

@objc public protocol ARGBookPageSnapshotCache {
    
    func snapshot(for page: ARGDocumentPage, completionHandler: ((UIImage?) -> Void)?)
    
}
