//
//  File.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 03.12.2020.
//

import Foundation
import UIKit

class ARGFlowableLayoutSettingsController : ARGBookReadingSettingsController {
    
    private(set) var pageSettingsString: String?
    
    override func setSettings(_ settings: ARGBookReadingSettings, pageSize: CGSize, completionHandler: (() -> Void)? = nil) {
        super.setSettings(settings, pageSize: pageSize) {
            let group = DispatchGroup()
            
            group.enter()
            let offset = UIOffset(horizontal: CGFloat(settings.horizontalMargin), vertical: CGFloat(settings.verticalMargin))
            self.setRelativePageMargins(offset) {
                group.leave()
            }
            
            group.notify(queue: .main) {
                completionHandler?()
            }
        }
    }
    
    func setRelativePageMargins(_ pageMargins: UIOffset, completionHandler: (() -> Void)? = nil) {
       //relativePageMargins = pageMargins
        
        if let pageSize = self.pageSize {
            let horizontalMargin = floor(pageSize.width / 100 * pageMargins.horizontal)
            let verticalMargin = floor(pageSize.height / 100 * pageMargins.vertical)
            let absolutePageMargins = UIEdgeInsets(top: max(verticalMargin, webView.safeAreaInsets.top),
                                                   left: max(horizontalMargin, webView.safeAreaInsets.left),
                                                   bottom: max(verticalMargin, webView.safeAreaInsets.bottom),
                                                   right: max(horizontalMargin, webView.safeAreaInsets.right))
            setAbsolutePageMargins(absolutePageMargins, completionHandler: completionHandler)
        }
    }
    
    func setAbsolutePageMargins(_ pageMargins: UIEdgeInsets, completionHandler: (() -> Void)? = nil) {
        contentEdgeInsets = pageMargins
        
        let pageWidth = floor(pageSize!.width - pageMargins.left - pageMargins.right)
        let pageHeight = floor(pageSize!.height - pageMargins.top - pageMargins.bottom)
        let topInset = floor(pageMargins.top)
        let rightInset = floor(pageMargins.right)
        let bottomInset = floor(pageMargins.bottom)
        let leftInset = floor(pageMargins.left)

        let pageSizeScript = "setPageSettings(\(pageWidth),\(pageHeight),\(topInset),\(rightInset),\(bottomInset),\(leftInset))"
        
        guard self.pageSettingsString != pageSizeScript else {
            completionHandler?()
            return
        }
        
        webView.evaluateJavaScript(pageSizeScript) { (result, error) in
            completionHandler?()
        }
    }
    
}

