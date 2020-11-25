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

extension ARGBookDocumentSettingsControllerContainer where Self: ARGBookDocumentContentSizeContainer {
    
    mutating func apply(settings: ARGBookReadingSettings, completionHandler: (() -> Void)? = nil) {
        isReady = false
        
        let pageSize = Self.pageSize(for: webView.bounds.size,
                                     settings: settings,
                                     sizeClass: webView.traitCollection.horizontalSizeClass)
        
        settingsController.setSettings(settings, pageSize: pageSize) {
            completionHandler?()
        }
    }
    
}

protocol ARGBookDocumentScrollBehavior: ARGBookDocumentLayout {
    
    func scroll(to element: String, completionHandler: (() -> Void)?)
    
    static func scroll(scrollView: UIScrollView, to position: CGFloat)
    
    func currentScrollPosition() -> CGFloat
    
}

extension ARGBookDocumentScrollBehavior {
    
    func scroll(to position: CGFloat) {
        Self.scroll(scrollView: webView.scrollView, to: position)
    }
    
}

protocol ARGBookDocumentContentSizeContainer: ARGBookDocumentLayout {
    
    func measureContentSize(completionHandler: ((CGSize?) -> Void)?)
    
    static func pageSize(for viewPort: CGSize, settings: ARGBookReadingSettings, sizeClass: UIUserInterfaceSizeClass) -> CGSize
    
    static func pageCount(for contentSize: CGSize, pageSize: CGSize) -> Int
    
}

extension ARGBookDocumentContentSizeContainer {
    
    static func pageSize(for viewPort: CGSize, settings: ARGBookReadingSettings, sizeClass: UIUserInterfaceSizeClass) -> CGSize {
        return viewPort
    }
    
}

protocol ARGBookDocumentPageOverlayCreator: ARGBookDocumentLayout {
    
    static func overlayView(parentView: UIView) -> ARGDocumentPageOverlayView
    
}

