//
//  WKWebView+Measuring.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 14.10.2020.
//

import Foundation
import WebKit

enum ARGBookDocumentDimension {
    
    case width
    
    case height
    
}

extension ARGBookDocumentDimension {
    
    func name() -> String {
        switch self {
        case .width:
            return "Width"
        case .height:
            return "Height"
        }
    }
    
}

extension WKWebView {
    
    func arg_measure(_ dimension: ARGBookDocumentDimension, completionHandler: ((CGFloat?, Error?) -> Void)? = nil) {
        evaluateJavaScript(script(for_: dimension)) { (result, error) in
            completionHandler?(result as? CGFloat, error)
        }
    }

    private func script(for_ dimension: ARGBookDocumentDimension) -> String {
        let script = """
                Math.max(
                  document.body.scroll\(dimension.name()), document.documentElement.scroll\(dimension.name()),
                  document.body.offset\(dimension.name()), document.documentElement.offset\(dimension.name()),
                  document.body.client\(dimension.name()), document.documentElement.client\(dimension.name())
                );
        """
        
        return script
    }
    
}

//                evaluateJavaScript("document.documentElement." + dimensionName) { (result, error) in
//
//                    if let dimension = result as? CGFloat {
//                        print("\(String(describing: self.webView.url?.lastPathComponent)) caclulated dimension: " + String(Float(dimension)))
//
//                        self.completionHandler = completionHandler
//                        self.waitForDOMReady()
//                    }

