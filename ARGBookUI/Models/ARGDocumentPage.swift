//
//  ARGDocumentPage.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 08.11.2020.
//

import Foundation

@objc public class ARGDocumentPage: NSObject {
    
    var startNavigationPoint: ARGBookNavigationPoint
    
    var pageNumber: Int?
    
    init(startNavigationPoint: ARGBookNavigationPoint) {
        self.startNavigationPoint = startNavigationPoint
    }
    
}

extension ARGDocumentPage {
    //TBD
    var snapshot: UIImage? {
        get {
            return nil
        }
    }
    
    var isBookmarked: Bool? {
        get {
            return nil
        }
    }
    
    var notes: [ARGBookHighlight]? {
        get {
            return nil
        }
    }
    
}
