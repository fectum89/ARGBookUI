//
//  ARGBookDocumentVerticalLayout.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit
import ARGView

class ARGBookDocumentVerticalLayout: ARGBookDocumentLayout {
    override func applyReadingSettings(_ settings: ARGBookReadingSettings?, completionHandler: (() -> Void)? = nil) {
        super.applyReadingSettings(settings) {
            //
            self.measureContentSize() {
                completionHandler?()
            }
        }
    }
    
    override func measureContentSize(completionHander: (() -> Void)? = nil) {
        webView.arg_measure(.height) { measuredHeight, error in
            if let height = measuredHeight {
                let sizeManager = ARGBookDocumentSizeManager(webView: self.webView, measuredSize: CGSize(width: self.webView.bounds.size.width, height: height))
                sizeManager.waitForDOMReady { (size) in
                    let _ = sizeManager.measuredSize
                    self.isReady = true
                    completionHander?()
                }
            }
        }
    }
    
    override func scrollToStart() {
        DispatchQueue.main.async {
            self.webView.scrollView.contentOffset = CGPoint(x: self.webView.scrollView.contentOffset.x, y: 0)
        }
        
    }
    
    override func scrollToEnd() {
        webView.scrollView.contentOffset = CGPoint(x: webView.scrollView.contentOffset.x, y: webView.scrollView.contentSize.height - webView.scrollView.bounds.size.height)
    }
}
