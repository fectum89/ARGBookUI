//
//  ARGBookDocumentNavigationCommonLogic.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 18.10.2020.
//

import Foundation

class ARGBookDocumentNavigationCommonLogic {
    
    var layout: ARGBookDocumentLayout?
    
    var navigationPoint: ARGBookNavigationPoint?
    
    func scrollToProperPoint () {
        if let navigationPoint = self.navigationPoint {
            self.scroll(to: navigationPoint)
        } else {
            self.scroll(to: ARGBookDocumentStartNavigationPoint())
        }
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint, completionHandler: (() -> Void)? = nil) {
        guard layout?.isReady ?? false else {
            self.navigationPoint = navigationPoint
            return
        }
        
        layout?.scroll(to: navigationPoint)
    }
    
}
