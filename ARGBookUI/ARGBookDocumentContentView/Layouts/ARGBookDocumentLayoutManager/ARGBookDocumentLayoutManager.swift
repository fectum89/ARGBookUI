//
//  ARGBookDocumentLayoutManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 15.10.2020.
//

import UIKit

class ARGBookDocumentLayoutManager {
    
    var layout: ARGBookDocumentLayout? {
        didSet {
            settingsLogic.layout = layout
            navigationLogic.layout = layout
        }
    }
    
    var settingsLogic: ARGBookDocumentSettingsCommonLogic
    var navigationLogic: ARGBookDocumentNavigationCommonLogic
    
    var webView: WKWebView
    
    var document: ARGBookDocument
    
    var documentLoaded: Bool = false {
        didSet {
            if documentLoaded {
                let _ = self.conditionallyApplyPendingSettings()
            }
        }
    }
    
    var layoutTypeChangedHandler: ((@escaping () -> Void)) -> Void
    
    init(webView: WKWebView, document: ARGBookDocument, cache: ARGBookCache, layoutTypeChangedHandler: @escaping ((@escaping () -> Void)) -> Void) {
        self.webView = webView
        self.document = document
        self.layoutTypeChangedHandler = layoutTypeChangedHandler
        self.settingsLogic = ARGBookDocumentSettingsCommonLogic(document: document, cache: cache)
        self.navigationLogic = ARGBookDocumentNavigationCommonLogic(document: document)
    }
    
    func updateLayout(with document: ARGBookDocument, settings: ARGBookReadingSettings,  completionHander: @escaping () -> Void) {
        let LayoutClass = Self.documentLayoutClass(for: document, scrollType: settings.scrollType)
        
        if self.layout == nil || !(self.layout?.isKind(of: LayoutClass) ?? false)  {
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
    
    func settingsCanBeApplied(_ settings: ARGBookReadingSettings?) -> Bool {
        if !documentLoaded || settingsLogic.applyingInProgress {
            settingsLogic.pendingSettings = settings
            return false
        } else {
            settingsLogic.applyingInProgress = true
            return true
        }
    }
    
    func applyReadingSettings(_ settings: ARGBookReadingSettings, completionHandler: (() -> Void)? = nil) {
        let allowed = self.settingsCanBeApplied(settings)
        
        guard allowed else {
            completionHandler?()
            return
        }
        
        updateLayout(with: document, settings: settings) {
            self.settingsLogic.applyReadingSettings(settings) {
                if !self.conditionallyApplyPendingSettings(completionHandler: completionHandler) {
                    completionHandler?()
                    self.navigationLogic.scrollToProperPoint()
                }
            }
        }
    }
    
    func conditionallyApplyPendingSettings(completionHandler: (() -> Void)? = nil) -> Bool {
        if let pendingSettings = settingsLogic.pendingSettings {
            self.settingsLogic.pendingSettings = nil
            self.applyReadingSettings(pendingSettings, completionHandler: completionHandler)
            return true
        } else {
            return false
        }
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint, completionHandler: (() -> Void)? = nil) {
        navigationLogic.scroll(to: navigationPoint, completionHandler: completionHandler)
    }
    
    func obtainCurrentNavigationPoint(completionHandler: ((ARGBookNavigationPoint?) -> Void)? = nil) {
        navigationLogic.obtainCurrentNavigationPoint(completionHandler: completionHandler)
    }
    
}
