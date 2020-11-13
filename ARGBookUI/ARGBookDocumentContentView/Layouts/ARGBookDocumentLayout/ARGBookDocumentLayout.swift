//
//  ARGBookDocumentBaseLayout.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit
import WebKit

class ARGBookDocumentLayout: NSObject {
    var webView: WKWebView
    var settingsController: ARGBookReadingSettingsController
    var isReady = false
    var documentPrepared: Bool = false
    
    required init(webView: WKWebView) {
        self.webView = webView
        let settingsControllerClass = Self.settingsControllerClass()
        self.settingsController = settingsControllerClass.init(webView: webView)
    }
    
    func prepare(completionHandler: (() -> Void)? = nil) {
        if #available(iOS 13, *) {} else {
            webView.evaluateJavaScript("setCSSRule('body', '-webkit-touch-callout', 'none')")
        }
        
        webView.evaluateJavaScript("prepareDocument()") { (result, error) in
            self.documentPrepared = true
            completionHandler?()
        }
    }
    
    class func settingsControllerClass<T: ARGBookReadingSettingsController>() -> T.Type {
        return ARGBookReadingSettingsController.self as! T.Type
    }
    
    func applyReadingSettings(_ settings:ARGBookReadingSettings?, completionHandler: (() -> Void)? = nil) {
        isReady = false
        
        self.settingsController.setSettings(settings) {
            completionHandler?()
        }
    }
    
    func scroll(to position: CGFloat, completionHandler: (() -> Void)? = nil) {
        
    }
    
    func scroll(to element: String, completionHandler: (() -> Void)? = nil) {
        
    }
    
    func measureContentSize(completionHandler: ((CGSize?) -> Void)? = nil) {

    }
    
    func currentScrollPosition() -> CGFloat {
        return 0
    }
    
    class func pageCount(for contentSize: CGSize, viewPort: CGSize) -> UInt {
        return 0
    }
    
    deinit {
        print("layout deinit")
    }
    
}
