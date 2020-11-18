//
//  ARGBookDocumentSettingsCommonLogic.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 18.10.2020.
//

import Foundation

class ARGBookDocumentSettingsCommonLogic {
    
    var layout: ARGBookDocumentSettingsControllerContainer & ARGBookDocumentContentSizeContainer
    
    var documentPrepared: Bool = false
    
    var document: ARGBookDocument
    
    var documentStateManager: ARGBookDocumentStateManager?
    
    var pendingSettings: ARGBookReadingSettings?
    
    var applyingInProgress = false
    
    var cache: ARGBookCache
    
    init(document: ARGBookDocument, layout: ARGBookDocumentSettingsControllerContainer & ARGBookDocumentContentSizeContainer, cache: ARGBookCache) {
        self.document = document
        self.cache = cache
        self.layout = layout
    }
    
    func applyReadingSettings(_ settings: ARGBookReadingSettings, completionHandler: (() -> Void)? = nil) {
        let applySettingsClosure = {
            self.layout.apply(settings: settings) {
                let waitForDom = { size in
                    self.waitForDOMReady(measuredSize: size) {
                        self.applyingInProgress = false
                        completionHandler?()
                    }
                }
                
                let size = self.cache.contentSize(for: self.document, settings: settings, viewPort: self.layout.webView.bounds.size)
                
                if size != .zero {
                    waitForDom(size)
                } else {
                    self.layout.measureContentSize { (size) in
                        waitForDom(size)
                    }
                }
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
    
    
    func prepare(completionHandler: (() -> Void)? = nil) {
        if #available(iOS 13, *) {} else {
            layout.webView.evaluateJavaScript("setCSSRule('body', '-webkit-touch-callout', 'none')")
        }
        
        layout.webView.evaluateJavaScript("prepareDocument()") { (result, error) in
            self.layout.webView.evaluateJavaScript("onLoadSetup()") { (result, error) in
                self.documentPrepared = true
                completionHandler?()
            }
        }
    }
    
    func waitForDOMReady(measuredSize: CGSize?, completionHandler: (() -> Void)? = nil) {
        if let measuredSize = measuredSize {
            documentStateManager = ARGBookDocumentStateManager(webView: self.layout.webView, measuredSize: measuredSize)
            
            documentStateManager!.waitForDOMReady { (size) in
                self.documentStateManager = nil
                self.layout.isReady = true
                
                DispatchQueue.main.async {
                    completionHandler?()
                }
            }
        } else {
            completionHandler?()
        }
        
    }
    
    deinit {
        print("settings logic deallocated")
    }
    
}
