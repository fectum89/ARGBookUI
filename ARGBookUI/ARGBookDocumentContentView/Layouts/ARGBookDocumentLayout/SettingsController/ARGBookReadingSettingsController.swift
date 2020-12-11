//
//  File.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 03.12.2020.
//

import Foundation
import WebKit

class ARGBookReadingSettingsController {
    
    private(set) var webView: WKWebView
    
    private(set) var settings: ARGBookReadingSettings?

    private(set) var fontSize: Int64?
    
    private(set) var highlightColor: UIColor?
    
    private(set) var viewPortWidth: CGFloat?
    
    private(set) var fontFamily: String?
    
    private(set) var hyphenation: Bool?
    
    private(set) var alignment: ARGBookReadingSettingsAlignment? = nil

    private(set) var textColor: UIColor?

    private(set) var pageSize: CGSize?
    
    var contentEdgeInsets: UIEdgeInsets?

    var languageCode: String?
    
    init(webView: WKWebView) {
        self.webView = webView
    }

    func setSettings(_ settings: ARGBookReadingSettings, pageSize: CGSize, completionHandler: (() -> Void)? = nil) {
        self.settings = settings
        self.pageSize = pageSize
        
        let group = DispatchGroup()
        
        group.enter()
        setViewPortWidth(webView.bounds.width) {
            group.leave()
        }
        
        group.enter()
        setFontSize(settings.fontSize) {
            group.leave()
        }
        
        group.enter()
        setFontFamily(settings.fontFamily) {
            group.leave()
        }
        
        group.enter()
        setHighlightColor(settings.highlightColor) {
            group.leave()
        }
        
        group.enter()
        setTextColor(settings.textColor) {
            group.leave()
        }
                
        group.enter()
        setAlignment(settings.alignment) {
            group.leave()
        }
        
        group.enter()
        setHyphenation(settings.hyphenation) {
            group.leave()
        }
        
        group.notify(queue: .main) {
            completionHandler?()
        }
        
    }
    
    func setHighlightColor(_ color: UIColor, completionHandler: (() -> Void)? = nil) {
        guard highlightColor != color else {
            completionHandler?()
            return
        }
        
        highlightColor = color
        
        var redComponent: CGFloat = 0
        var blueComponent: CGFloat = 0
        var greenComponent: CGFloat = 0
        var alphaComponent: CGFloat = 0
        
        color.getRed(&redComponent, green: &greenComponent, blue: &blueComponent, alpha: &alphaComponent)
        
        webView.evaluateJavaScript("setHighlightColor('rgba(\(redComponent * 255), \(greenComponent * 255), \(blueComponent * 255), \(alphaComponent * 255))')") { (result, error) in
            completionHandler?()
        }
    }
    
    func setViewPortWidth(_ viewPortWidth: CGFloat, completionHandler: (() -> Void)? = nil) {
        guard self.viewPortWidth != viewPortWidth else {
            completionHandler?()
            return
        }
        
        self.viewPortWidth = viewPortWidth
        
        webView.evaluateJavaScript("setViewportWidth(\(viewPortWidth))") { (result, error) in
            completionHandler?()
        }
    }
    
    func setFontSize(_ fontSize: Int64, completionHandler: (() -> Void)? = nil) {
        guard self.fontSize != fontSize else {
            completionHandler?()
            return
        }
        
        self.fontSize = fontSize
        
        webView.evaluateJavaScript("setFontSize(\(fontSize))") { (result, error) in
            completionHandler?()
        }
    }
    
    func setFontFamily(_ fontFamily: String, completionHandler: (() -> Void)? = nil) {
        guard self.fontFamily != fontFamily else {
            completionHandler?()
            return
        }
        
        self.fontFamily = fontFamily
        
        webView.evaluateJavaScript("setFontFamily(\(fontFamily))") { (result, error) in
            completionHandler?()
        }
    }
    
    func setHyphenation(_ hyphenation: Bool, completionHandler: (() -> Void)? = nil) {
        guard self.hyphenation != hyphenation else {
            completionHandler?()
            return
        }
        
        self.hyphenation = hyphenation
        
        webView.evaluateJavaScript("hyphenate(\(hyphenation), '\(languageCode ?? "")')") { (result, error) in
            completionHandler?()
        }
    }

    func setTextColor(_ textColor: UIColor, completionHandler: (() -> Void)? = nil) {
        guard self.textColor != textColor else {
            completionHandler?()
            return
        }
        
        self.textColor = textColor
        
        var redComponent: CGFloat = 0
        var blueComponent: CGFloat = 0
        var greenComponent: CGFloat = 0
        var alphaComponent: CGFloat = 0
        
        textColor.getRed(&redComponent, green: &greenComponent, blue: &blueComponent, alpha: &alphaComponent)
        
        webView.evaluateJavaScript("setTextColor('rgba(\(redComponent * 255), \(greenComponent * 255), \(blueComponent * 255), \(alphaComponent * 255))')") { (result, error) in
            completionHandler?()
        }
    }
    
    func setAlignment(_ alignment: ARGBookReadingSettingsAlignment, completionHandler: (() -> Void)? = nil) {
        guard self.alignment != alignment else {
            completionHandler?()
            return
        }
        
        self.alignment = alignment
        
        webView.evaluateJavaScript("setTextAlignment('\(alignment.stringRepresentation())')") { (result, error) in
            completionHandler?()
        }
    }

}
