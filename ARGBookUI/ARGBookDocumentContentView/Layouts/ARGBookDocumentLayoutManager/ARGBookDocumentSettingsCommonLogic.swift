//
//  ARGBookDocumentSettingsCommonLogic.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 18.10.2020.
//

import Foundation

class ARGBookDocumentSettingsCommonLogic {
    
    var layout: ARGBookDocumentLayout?
    
    var webView: WKWebView
    
    var documentStateManager: ARGBookDocumentStateManager?
    
    var pendingSettings: ARGBookReadingSettings?
    
    var applyingInProgress = false
    
    init(webView: WKWebView) {
        self.webView = webView
    }
    
    func settingsCanBeApplied(_ settings: ARGBookReadingSettings?) -> Bool {
        if webView.isLoading || applyingInProgress {
            pendingSettings = settings
            return false
        } else {
            applyingInProgress = true
            return true
        }
    }
    
    func applyReadingSettings(_ settings: ARGBookReadingSettings?, completionHandler: (() -> Void)? = nil) {
        let applySettingsClosure = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.layout?.applyReadingSettings(settings) {
                    self.layout?.measureContentSize { (size) in
                        self.waitForDOMReady(measuredSize: size) {
                            self.applyingInProgress = false
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
