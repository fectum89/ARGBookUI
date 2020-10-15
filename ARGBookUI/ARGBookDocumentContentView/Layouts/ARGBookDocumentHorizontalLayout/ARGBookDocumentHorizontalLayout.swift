//
//  ARGBookDocumentHorizontalLayout.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit
import ARGView

class ARGBookDocumentHorizontalLayout: ARGBookDocumentLayout {
    var settingsController: ARGFlowableLayoutSettingsProvider!
    
    required init(webView: WKWebView) {
        super.init(webView: webView)
        webView.scrollView.isPagingEnabled = true
        webView.scrollView.bounces = false
        self.settingsController = ARGFlowableLayoutSettingsProvider(webView: webView)
    }

    override func applyReadingSettings(_ settings: ARGBookReadingSettings?, completionHandler: (() -> Void)? = nil) {
        super.applyReadingSettings(settings) {
            self.settingsController.setSettings(settings) {
                self.measureContentSize() {
                    completionHandler?()
                }
            }
        }
    }
    
    override func measureContentSize(completionHandler: (() -> Void)? = nil) {
        webView.arg_measure(.width) { measuredWidth, error in
            if let width = measuredWidth {
                if width > self.webView.bounds.size.width {
                    self.webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: self.settingsController.absolutePageMargins.horizontal)
                } else {
                    self.webView.scrollView.contentInset = UIEdgeInsets()
                }
                
                self.waitForDOMReady(measuredSize: CGSize(width: width, height: self.webView.bounds.size.height), completionHandler: completionHandler)
            }
        }
    }
    
    override func scroll(to position: ARGContinuousScrollPosition) {
        switch position {
        case .begin:
            self.webView.scrollView.contentOffset = CGPoint(x: 0, y: self.webView.scrollView.contentOffset.y)
        case .end:
            webView.scrollView.contentOffset = CGPoint(x: webView.scrollView.contentSize.width - webView.scrollView.bounds.size.width, y: webView.scrollView.contentOffset.y)
        }
    }
    
}
