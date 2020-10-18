//
//  ARGBookDocumentLayoutManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 15.10.2020.
//

import UIKit
import ARGView

class ARGBookDocumentLayoutManager: NSObject {
    
    var layout: ARGBookDocumentLayout?
    
    var documentStateManager: ARGBookDocumentStateManager?
    
    var webView: WKWebView
    
    var document: ARGBookDocument? {
        didSet {
            if document?.filePath != oldValue?.filePath {
                self.layout = nil
            }
        }
    }
    
    var layoutTypeChangedHandler: ((@escaping () -> Void)) -> Void
    
    var navigationPoint: ARGBookNavigationPoint?
    
    var pendingSettings: ARGBookReadingSettings?
    
    var applyingInProgress = false
    
    init(webView: WKWebView, layoutTypeChangedHandler: @escaping ((@escaping () -> Void)) -> Void) {
        self.webView = webView
        self.layoutTypeChangedHandler = layoutTypeChangedHandler
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
    
    func applyReadingSettings(_ settings: ARGBookReadingSettings?, completionHandler: (() -> Void)? = nil) {
        guard settings != nil && !webView.isLoading && !applyingInProgress else {
            pendingSettings = settings
            completionHandler?()
            return
        }
        
        if let document = self.document {
            applyingInProgress = true
            
            updateLayout(with: document, settings: settings!) {
                let applySettingsClosure = {
                    self.layout?.applyReadingSettings(settings) {
                        self.layout?.measureContentSize { (size) in
                            self.waitForDOMReady(measuredSize: size) {
                                self.applyingInProgress = false
                                
                                if self.pendingSettings != nil {
                                    self.applyReadingSettings(self.pendingSettings, completionHandler: completionHandler)
                                    self.pendingSettings = nil
                                } else {
                                    if let navigationPoint = self.navigationPoint {
                                        self.scroll(to: navigationPoint)
                                    } else {
                                        self.scroll(to: ARGBookDocumentStartNavigationPoint())
                                    }
                                    
                                    completionHandler?()
                                }
                            }
                        }
                    }
                }
                
                if let layout = self.layout {
                    if !layout.documentPrepared {
                        layout.prepare {
                            applySettingsClosure()
                        }
                    } else {
                        applySettingsClosure()
                    }
                }
            }
        }
        
    }
    
    func waitForDOMReady(measuredSize: CGSize?, completionHandler: (() -> Void)? = nil) {
        if let measuredSize = measuredSize {
            documentStateManager = ARGBookDocumentStateManager(webView: self.webView, measuredSize: measuredSize)
            
            documentStateManager!.waitForDOMReady { (size) in
                self.documentStateManager = nil
                self.layout?.isReady = true
                
                DispatchQueue.main.async {
                    completionHandler?()
                }
            }
        } else {
            completionHandler?()
        }
        
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint, completionHandler: (() -> Void)? = nil) {
        guard layout?.isReady ?? false else {
            self.navigationPoint = navigationPoint
            return
        }
        
        layout?.scroll(to: navigationPoint)
    }
    
}

extension ARGBookDocumentLayoutManager {
    
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
    
}

class ARGBookDocumentSettingsLogic {
    
    var layout: ARGBookDocumentLayout?
    
    var webView: WKWebView
    
    var documentStateManager: ARGBookDocumentStateManager?
    
    var pendingSettings: ARGBookReadingSettings?
    
    var applyingInProgress = false
    
    init(layout: ARGBookDocumentLayout, webView: WKWebView) {
        self.webView = webView
    }
    
    func applyReadingSettings(_ settings: ARGBookReadingSettings?, completionHandler: (() -> Void)? = nil) {
        guard settings != nil && !webView.isLoading && !applyingInProgress else {
            pendingSettings = settings
            completionHandler?()
            return
        }
        
        applyingInProgress = true
        
        let applySettingsClosure = {
            self.layout?.applyReadingSettings(settings) {
                self.layout?.measureContentSize { (size) in
                    self.waitForDOMReady(measuredSize: size) {
                        self.applyingInProgress = false
                        
                        if self.pendingSettings != nil {
                            self.applyReadingSettings(self.pendingSettings, completionHandler: completionHandler)
                            self.pendingSettings = nil
                        } else {
                            completionHandler?()
                        }
                    }
                }
            }
        }
        
        if let layout = self.layout {
            if !layout.documentPrepared {
                layout.prepare {
                    applySettingsClosure()
                }
            } else {
                applySettingsClosure()
            }
        }
    }
    
    func waitForDOMReady(measuredSize: CGSize?, completionHandler: (() -> Void)? = nil) {
        if let measuredSize = measuredSize {
            documentStateManager = ARGBookDocumentStateManager(webView: self.webView, measuredSize: measuredSize)
            
            documentStateManager!.waitForDOMReady { (size) in
                self.documentStateManager = nil
                self.layout?.isReady = true
                
                DispatchQueue.main.async {
                    completionHandler?()
                }
            }
        } else {
            completionHandler?()
        }
        
    }
    
}
