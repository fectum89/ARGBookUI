//
//  ARGDocumentPage.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 08.11.2020.
//

import Foundation

@objc public class ARGDocumentPage: NSObject {
    
    @objc public var startNavigationPoint: ARGBookNavigationPoint
    
    @objc public var globalPageNumber: Int = 0
    
    var relativePageNumber: Int = 0
    
    weak var pageCounter: ARGBookPageCounter?
    
    init(startNavigationPoint: ARGBookNavigationPoint, pageCounter: ARGBookPageCounter) {
        self.startNavigationPoint = startNavigationPoint
        self.pageCounter = pageCounter
    }
    
}

extension ARGDocumentPage {
    
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
