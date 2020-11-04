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
    
    var currentNavigationPoint: ARGBookNavigationPoint? {
        didSet {
            obtainCurrentNavigationPointCompletionHandler?(currentNavigationPoint)
            obtainCurrentNavigationPointCompletionHandler = nil
        }
    }
    
    var scrollCompletionHandler: (() -> Void)?
    
    var obtainCurrentNavigationPointCompletionHandler: ((ARGBookNavigationPoint?) -> Void)?
    
    init(document: ARGBookDocument) {
        self.document = document
    }
    
    func scrollToProperPoint () {
        if let navigationPoint = self.pendingNavigationPoint {
            self.scroll(to: navigationPoint, completionHandler: self.scrollCompletionHandler)
        } else {
            self.scroll(to: ARGBookDocumentStartNavigationPoint(), completionHandler: scrollCompletionHandler)
        }
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint, completionHandler: (() -> Void)? = nil) {
        self.pendingNavigationPoint = navigationPoint
        
        guard layout?.isReady ?? false else {
            self.scrollCompletionHandler = completionHandler
            return
        }
        
        layout?.scroll(to: navigationPoint, completionHandler: {
            self.updateCurrentNavigationPoint {
                completionHandler?()
                self.pendingNavigationPoint = nil
                self.scrollCompletionHandler = nil
            }
        })
    }
    
    func updateCurrentNavigationPoint (completionHandler: (() -> Void)? = nil) {
        self.layout?.webView.evaluateJavaScript("firstVisibleSpanElement()", completionHandler: { (result, error) in
            if let dictionary = result as? NSDictionary,
               let wordId = dictionary["id"] as? String {
                self.currentNavigationPoint = ARGBookNavigationPointInternal(document: self.document, elementID: wordId)
            }
            
            completionHandler?()
        })
    }
    
    func obtainCurrentNavigationPoint(completionHandler: ((ARGBookNavigationPoint?) -> Void)? = nil) {
        if layout?.isReady ?? false {
            updateCurrentNavigationPoint {
                completionHandler?(self.currentNavigationPoint)
            }
        } else {
            obtainCurrentNavigationPointCompletionHandler = completionHandler
        }
    }
    
}
