//
//  ARGBookDocumentContentViewConfigurator.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit
import WebKit

class ARGBookWebViewConfigurator: NSObject {
    
    static func configuration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        
        let prepareScriptFilePath = Bundle(for: ARGBookDocumentContentView.self).path(forResource: "PrepareDocument", ofType: "js")
        let prepareScriptSource = try! String(contentsOfFile: prepareScriptFilePath!)
        let prepareScript = WKUserScript(source: prepareScriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        let settingsScriptFilePath = Bundle(for: ARGBookDocumentContentView.self).path(forResource: "Settings", ofType: "js")
        let settingsScriptSource = try! String(contentsOfFile: settingsScriptFilePath!)
        let settingsScript = WKUserScript(source: settingsScriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        let navigationScriptFilePath = Bundle(for: ARGBookDocumentContentView.self).path(forResource: "Navigation", ofType: "js")
        let navigationScriptSource = try! String(contentsOfFile: navigationScriptFilePath!)
        let navigationScript = WKUserScript(source: navigationScriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        configuration.userContentController.addUserScript(prepareScript)
        configuration.userContentController.addUserScript(settingsScript)
        configuration.userContentController.addUserScript(navigationScript)
        configuration.suppressesIncrementalRendering = true
       
        return configuration
    }

}
