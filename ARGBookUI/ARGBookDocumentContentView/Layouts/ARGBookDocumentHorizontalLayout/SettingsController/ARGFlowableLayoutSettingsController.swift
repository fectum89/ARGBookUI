//
//  File.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 03.12.2020.
//

import Foundation
import UIKit

class ARGFlowableLayoutSettingsController : ARGBookReadingSettingsController {
    
    private(set) var relativePageMargins: UIOffset?
    
    private(set) var absolutePageMargins: UIOffset?
    
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
        relativePageMargins = pageMargins
        
        if let pageSize = self.pageSize {
            let absolutePageMargins = UIOffset(horizontal: floor(pageSize.width / 100 * pageMargins.horizontal), vertical: floor(pageSize.height / 100 * pageMargins.vertical))
            setAbsolutePageMargins(absolutePageMargins, completionHandler: completionHandler)
        }
    }
    
    func setAbsolutePageMargins(_ pageMargins: UIOffset, completionHandler: (() -> Void)? = nil) {
        absolutePageMargins = pageMargins
        
        let pageWidth = floor(pageSize!.width - pageMargins.horizontal * 2)
        let pageHeight = floor(pageSize!.height - pageMargins.vertical * 2)
        let topInset = floor(pageMargins.vertical)
        let rightInset = floor(pageMargins.horizontal)
        let bottomInset = floor(pageMargins.vertical)
        let leftInset = floor(pageMargins.horizontal)

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

