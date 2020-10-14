//
//  WKWebView+Scripts.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 11.10.2020.
//

import Foundation
import WebKit

extension WKWebView {
    func arg_evaluate(_ scripts: [String], completionHandler: ((Any?, Error?) -> Void)? = nil) {
        let group = DispatchGroup()
        
        var lastError: Error?
        var lastResult: Any?
        
        group.notify(queue: DispatchQueue.main) {
            if completionHandler != nil {
                completionHandler!(lastResult, lastError)
            }
        }
        
        for script in scripts {
            group.enter()
            evaluateJavaScript(script) { (result, error) in
                lastResult = result
                lastError = error
                group.leave()
            }
        }
        
    }
}

