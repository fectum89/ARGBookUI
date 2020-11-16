//
//  ARGBookDocumentFixedLayout.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit

class ARGBookDocumentFixedLayout: ARGBookDocumentLayout {
    
    var webView: WKWebView
    
    var settingsController: ARGBookReadingSettingsController
    
    var isReady: Bool = false
    
    required init(webView: WKWebView) {
        self.webView = webView
        isReady = false
        self.settingsController = ARGFlowableLayoutSettingsController(webView: webView, pageSize: Self.pageSize(for: webView.bounds.size, sizeClass: webView.traitCollection.horizontalSizeClass))
    }
    
}

extension ARGBookDocumentFixedLayout: ARGBookDocumentContentSizeContainer {
    
    func measureContentSize(completionHandler: ((CGSize?) -> Void)? = nil) {}
    
    class func pageCount(for contentSize: CGSize, pageSize: CGSize) -> Int {
        return 1
    }
}
