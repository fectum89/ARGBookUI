//
//  ARGBookDocumentNavigationCommonLogic.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 18.10.2020.
//

import Foundation

class ARGBookDocumentNavigationCommonLogic {
    
    var layout: ARGBookDocumentLayout?
    
    var document: ARGBookDocument
    
    var pendingNavigationPoint: ARGBookNavigationPoint?
    
//    var currentNavigationPoint: ARGBookNavigationPoint? {
//        didSet {
//            obtainCurrentNavigationPointCompletionHandler?(currentNavigationPoint)
//            obtainCurrentNavigationPointCompletionHandler = nil
//        }
//    }
    
    //var scrollCompletionHandler: (() -> Void)?
    
    var obtainCurrentNavigationPointCompletionHandler: ((ARGBookNavigationPoint) -> Void)?
    
    init(document: ARGBookDocument) {
        self.document = document
    }
    
    func scrollToProperPoint () {
        if let navigationPoint = self.pendingNavigationPoint {
            self.scroll(to: navigationPoint)
        } else {
            self.scroll(to: ARGBookNavigationPointInternal(document: document, position: 0))
        }
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint, completionHandler: (() -> Void)? = nil) {
        self.pendingNavigationPoint = navigationPoint
        
        guard layout?.isReady ?? false else {
            //self.scrollCompletionHandler = completionHandler
            return
        }
        
        let scrollCompletion = {
            //self.updateCurrentNavigationPoint {
            completionHandler?()
            self.pendingNavigationPoint = nil
            
            self.obtainCurrentNavigationPointCompletionHandler?(self.currentNavigationPoint())
            self.obtainCurrentNavigationPointCompletionHandler = nil
            
            //self.scrollCompletionHandler = nil
           // }
        }
        
        if let navigationPoint = navigationPoint as? ARGBookAnchorNavigationPoint {
            layout?.scroll(to: navigationPoint.elementID) {
                scrollCompletion()
            }
        } else {
            layout?.scroll(to: navigationPoint.position) {
                scrollCompletion()
            }
        }
    }
    
    func currentNavigationPoint () -> ARGBookNavigationPoint {
        return ARGBookNavigationPointInternal(document: self.document, position: layout?.currentScrollPosition() ?? 0)
    }
    
    func obtainCurrentNavigationPoint(completionHandler: ((ARGBookNavigationPoint) -> Void)? = nil) {
        if layout?.isReady ?? false {
            completionHandler?(currentNavigationPoint())
        } else {
            obtainCurrentNavigationPointCompletionHandler = completionHandler
        }
    }
    
}
