//
//  ARGBookDocumentVerticalLayout.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit

class ARGBookDocumentVerticalLayout: ARGBookDocumentLayout {
    
    override func prepare(completionHandler: (() -> Void)? = nil) {
        webView.scrollView.bounces = false
        webView.scrollView.isPagingEnabled = false
        webView.scrollView.contentInset = UIEdgeInsets()
        super.prepare(completionHandler: completionHandler)
    }
//    override func applyReadingSettings(_ settings: ARGBookReadingSettings?, completionHandler: (() -> Void)? = nil) {
//        super.applyReadingSettings(settings) {
//            //
////            self.measureContentSize() {
////                completionHandler?()
////            }
//        }
//    }
//
    
    override func measureContentSize(completionHandler: ((CGSize?) -> Void)? = nil) {
        webView.arg_measure(.height) { measuredHeight, error in
            if let height = measuredHeight {
                completionHandler?(CGSize(width: self.webView.bounds.size.width, height: height))
            } else {
                completionHandler?(nil)
            }
        }
    }
    
    override func scroll(to navigationPoint: ARGBookNavigationPoint, completionHandler: (() -> Void)?){
        switch navigationPoint {
        case is ARGBookDocumentStartNavigationPoint:
            self.webView.scrollView.contentOffset = CGPoint(x: self.webView.scrollView.contentOffset.x, y: 0)
        case is ARGBookDocumentEndNavigationPoint:
            webView.scrollView.contentOffset = CGPoint(x: webView.scrollView.contentOffset.x, y: webView.scrollView.contentSize.height - webView.scrollView.bounds.size.height)
        default:
            webView.evaluateJavaScript("scrollByVerticalToElementID(\(navigationPoint.elementID)") { (result, error) in
                completionHandler?()
            }
        }
    }

}
