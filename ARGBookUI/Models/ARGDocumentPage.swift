//
//  ARGDocumentPage.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 08.11.2020.
//

import Foundation

@objc public class ARGDocumentPage: NSObject {
    
    @objc public var startNavigationPoint: ARGBookNavigationPoint
    
    @objc public var pageNumber: Int = 0
    
    @objc public var relativePageNumber: Int = 0
    
    weak var pageConverter: ARGBookPageConverter?
    
    init(startNavigationPoint: ARGBookNavigationPoint, pageConverter: ARGBookPageConverter) {
        self.startNavigationPoint = startNavigationPoint
        self.pageConverter = pageConverter
    }
    
}

extension ARGDocumentPage {
    
    func loadSnapshot(completionHandler: ((UIImage?) -> Void)?) {
        pageConverter?.snapshotManager.snapshot(for: self, completionHandler: completionHandler)
    }
    
    //TBD
    var isBookmarked: Bool? {
        get {
            return nil
        }
    }
    
    //TBD
    var notes: [ARGBookHighlight]? {
        get {
            return nil
        }
    }

}
