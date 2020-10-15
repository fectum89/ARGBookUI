////
////  ARGBookDocumentLayoutManager.swift
////  ARGBookUI
////
////  Created by Sergei Polshcha on 15.10.2020.
////
//
//import UIKit
//
//protocol ARGDocumentLayout {
//    
//    func applyReadingSettings(_ settings:ARGBookReadingSettings?, completionHandler: (() -> Void)?)
//    
//    func scroll(to navigationPoint:ARGBookNavigationPoint?, completionHandler: (() -> Void)?) -> Bool
//    
//    func scrollToStart()
//    
//    func scrollToEnd()
//    
//}
//
//class ARGBookDocumentLayoutManager: NSObject {
//    
//    var layout: ARGDocumentLayout?
//    var webView: WKWebView
//    
//    var isReady = false
//    var documentPrepared: Bool = false
//    
//    init(webView: WKWebView) {
//        self.webView = webView
//    }
//    
//    func update(with document: ARGBookDocument, settings: ARGBookReadingSettings) {
//        let LayoutClass = self.documentLayoutClass(for: document, scrollType: settings.scrollType)
//        
//        if self.layout == nil || type(of: self.layout) != LayoutClass {
//            self.layout = LayoutClass.init(webView: self.webView) as? ARGDocumentLayout
//        }
//        
//    }
//    
//    func documentLayoutClass<Layout: ARGBookDocumentLayout>(for document: ARGBookDocument, scrollType: ARGBookScrollType) -> Layout.Type {
//        if document.hasFixedLayout {
//            return ARGBookDocumentFixedLayout.self as! Layout.Type
//        } else {
//            switch scrollType {
//            case .horizontal, .paging:
//                return ARGBookDocumentHorizontalLayout.self as! Layout.Type
//            case .vertical:
//                return ARGBookDocumentVerticalLayout.self as! Layout.Type
//            }
//        }
//    }
//    
//    func prepare(completionHandler: (() -> Void)? = nil) {
//        if #available(iOS 13, *) {} else {
//            webView.evaluateJavaScript("setCSSRule('body', '-webkit-touch-callout', 'none')")
//        }
//        
//        webView.evaluateJavaScript("prepareDocument()") { (result, error) in
//            self.documentPrepared = true
//            completionHandler?()
//        }
//    }
//    
//    func applyReadingSettings(_ settings:ARGBookReadingSettings?, completionHandler: (() -> Void)? = nil) {
//        guard settings != nil else {
//            return
//        }
//        
//        let applySettingsClosure = {
//            self.settingsProvider.setSettings(settings) {
//                completionHandler?()
//            }
//        }
//        
//        if !documentPrepared {
//            prepare {
//                applySettingsClosure()
//            }
//        } else {
//            applySettingsClosure()
//        }
//    }
//    
//    func scroll(to navigationPoint:ARGBookNavigationPoint?, completionHandler: (() -> Void)? = nil) -> Bool {
//        guard isReady else {
//            return false
//        }
//        
//        if navigationPoint != nil {
//            
//        } else {
//            scrollToStart()
//        }
//        
//        return true
//    }
//    
//}
