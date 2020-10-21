//
//  ARGBookDocumentLayoutManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 15.10.2020.
//

import UIKit

class ARGBookDocumentLayoutManager: NSObject {
    
    var layout: ARGBookDocumentLayout? {
        didSet {
            settingsLogic.layout = layout
            navigationLogic.layout = layout
        }
    }
    
    var settingsLogic: ARGBookDocumentSettingsCommonLogic
    var navigationLogic: ARGBookDocumentNavigationCommonLogic
    
    var webView: WKWebView
    
    var document: ARGBookDocument? {
        didSet {
            if document?.filePath != oldValue?.filePath {
                self.layout = nil
            }
        }
    }
    
    var layoutTypeChangedHandler: ((@escaping () -> Void)) -> Void
    
    init(webView: WKWebView, layoutTypeChangedHandler: @escaping ((@escaping () -> Void)) -> Void) {
        self.webView = webView
        self.layoutTypeChangedHandler = layoutTypeChangedHandler
        self.settingsLogic = ARGBookDocumentSettingsCommonLogic(webView: webView)
        self.navigationLogic = ARGBookDocumentNavigationCommonLogic()
    }
    
    func updateLayout(with document: ARGBookDocument, settings: ARGBookReadingSettings,  completionHander: @escaping () -> Void) {
        let LayoutClass = Self.documentLayoutClass(for: document, scrollType: settings.scrollType)
        
        if self.layout == nil || type(of: self.layout) != LayoutClass {
            let shouldCallClosure = self.layout != nil
            
            self.layout = LayoutClass.init(webView: self.webView) as ARGBookDocumentLayout
            
            if shouldCallClosure {
                layoutTypeChangedHandler {
                    completionHander()
                }
            } else {
                completionHander()
            }
        } else {
            completionHander()
        }
    }
    
    class func documentLayoutClass<Layout: ARGBookDocumentLayout>(for document: ARGBookDocument, scrollType: ARGBookScrollType) -> Layout.Type {
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
    
    func applyReadingSettings(_ settings: ARGBookReadingSettings, completionHandler: (() -> Void)? = nil) {
        let allowed = settingsLogic.settingsCanBeApplied(settings)
        
        guard allowed else {
            completionHandler?()
            return
        }
        
        if let document = self.document {
            updateLayout(with: document, settings: settings) {
                self.settingsLogic.applyReadingSettings(settings) {
                    if self.settingsLogic.pendingSettings != nil {
                        self.applyReadingSettings(self.settingsLogic.pendingSettings!, completionHandler: completionHandler)
                        self.settingsLogic.pendingSettings = nil
                    } else {
                        completionHandler?()
                        
                        self.navigationLogic.scrollToProperPoint()
                    }
                }
            }
        }
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint, completionHandler: (() -> Void)? = nil) {
        navigationLogic.scroll(to: navigationPoint, completionHandler: completionHandler)
    }
    
}
