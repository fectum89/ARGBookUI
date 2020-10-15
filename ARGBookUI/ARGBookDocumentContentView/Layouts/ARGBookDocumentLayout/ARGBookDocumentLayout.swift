//
//  ARGBookDocumentBaseLayout.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit
import WebKit
import ARGView

class ARGBookDocumentLayout: NSObject {
    var webView: WKWebView
    var settingsProvider: ARGBookReadingSettingsController
    var isReady = false
    var documentPrepared: Bool = false
    var documentStateManager: ARGBookDocumentStateManager?
    var navigationPoint: ARGBookNavigationPoint?
    
    required init(webView: WKWebView) {
        self.webView = webView
        self.settingsProvider = ARGBookReadingSettingsController(webView: webView)
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
    
    func applyReadingSettings(_ settings:ARGBookReadingSettings?, completionHandler: (() -> Void)? = nil) {
        guard settings != nil else {
            return
        }
        
        let applySettingsClosure = {
            self.settingsProvider.setSettings(settings) {
                completionHandler?()
            }
        }
        
        if !documentPrepared {
            prepare {
                applySettingsClosure()
            }
        } else {
            applySettingsClosure()
        }
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint?, completionHandler: (() -> Void)? = nil) -> Bool {
        guard isReady else {
            self.navigationPoint = navigationPoint
            return false
        }
        
        if navigationPoint != nil {
            
        } else {
            scroll(to: .begin)
        }
        
        return true
    }
    
    func scroll(to position: ARGContinuousScrollPosition) {
        
    }
    
    func waitForDOMReady(measuredSize: CGSize, completionHandler: (() -> Void)? = nil) {
        documentStateManager = ARGBookDocumentStateManager(webView: self.webView, measuredSize: measuredSize)
            
        documentStateManager!.waitForDOMReady { (size) in
            self.isReady = true
            self.documentStateManager = nil
            
            DispatchQueue.main.async {
                completionHandler?()
            }
        }
    }
    
    func measureContentSize(completionHandler: (() -> Void)? = nil) {

    }
    
}

extension ARGBookDocumentLayout {
    
    static func documentLayoutClass<Layout: ARGBookDocumentLayout>(for document: ARGBookDocument, scrollType: ARGBookScrollType) -> Layout.Type {
        if document.hasFixedLayout {
            return ARGBookDocumentFixedLayout.self as! Layout.Type
        } else {
            switch scrollType {
            case .horizontal, .paging:
                return ARGBookDocumentHorizontalLayout.self as! Layout.Type
            case .vertical:
                return ARGBookDocumentVerticalLayout.self as! Layout.Type
            }
        }
    }
    
}
