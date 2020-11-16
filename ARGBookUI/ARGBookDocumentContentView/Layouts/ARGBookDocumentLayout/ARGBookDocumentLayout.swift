//
//  ARGBookDocumentLayout.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 13.11.2020.
//

import Foundation

protocol ARGBookDocumentLayout {
    
    var webView: WKWebView {get set}
    
    var isReady: Bool {get set}
    
    init(webView: WKWebView)
    
}

protocol ARGBookDocumentSettingsControllerContainer: ARGBookDocumentLayout {
    
    var settingsController: ARGBookReadingSettingsController {get set}
    
}

extension ARGBookDocumentSettingsControllerContainer {
    
    mutating func apply(settings: ARGBookReadingSettings?, completionHandler: (() -> Void)? = nil) {
        isReady = false
        
        settingsController.setSettings(settings) {
            completionHandler?()
        }
    }
    
}

protocol ARGBookDocumentScrollBehavior: ARGBookDocumentLayout {
    
    func scroll(to position: CGFloat, completionHandler: (() -> Void)?)
    
    func scroll(to element: String, completionHandler: (() -> Void)?)
    
    func currentScrollPosition() -> CGFloat
    
}

protocol ARGBookDocumentContentSizeContainer: ARGBookDocumentLayout {
    
    func measureContentSize(completionHandler: ((CGSize?) -> Void)?)
    
    static func pageSize(for viewPort: CGSize, sizeClass: UIUserInterfaceSizeClass) -> CGSize
    
    static func pageCount(for contentSize: CGSize, pageSize: CGSize) -> Int
    
}

extension ARGBookDocumentContentSizeContainer {
    
    static func pageSize(for viewPort: CGSize, sizeClass: UIUserInterfaceSizeClass) -> CGSize {
        return viewPort
    }
    
}

protocol ARGBookDocumentPageOverlayCreator: ARGBookDocumentLayout {
    
    static func overlayView(parentView: UIView) -> ARGDocumentPageOverlayView
    
}

