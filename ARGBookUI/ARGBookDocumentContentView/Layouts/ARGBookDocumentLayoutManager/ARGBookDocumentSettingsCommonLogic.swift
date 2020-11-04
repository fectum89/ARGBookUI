//
//  ARGBookDocumentSettingsCommonLogic.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 18.10.2020.
//

import Foundation

class ARGBookDocumentSettingsCommonLogic {
    
    var layout: ARGBookDocumentLayout?
    
    var document: ARGBookDocument
    
    var documentStateManager: ARGBookDocumentStateManager?
    
    var pendingSettings: ARGBookReadingSettings?
    
    var applyingInProgress = false
    
    var cache: ARGBookCache
    
    init(document: ARGBookDocument, cache: ARGBookCache) {
        self.document = document
        self.cache = cache
    }
    
    func applyReadingSettings(_ settings: ARGBookReadingSettings?, completionHandler: (() -> Void)? = nil) {
        let applySettingsClosure = {
            self.layout?.applyReadingSettings(settings) {
                let waitForDom = { size in
                    self.waitForDOMReady(measuredSize: size) {
                        self.applyingInProgress = false
                        completionHandler?()
                    }
                }
                
                if let size = self.cache.contentSize(for: self.document, settings: settings!, viewPort: self.layout!.webView.bounds.size) {
                    waitForDom(size)
                } else {
                    self.layout?.measureContentSize { (size) in
                        waitForDom(size)
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
            documentStateManager = ARGBookDocumentStateManager(webView: self.layout!.webView, measuredSize: measuredSize)
            
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
