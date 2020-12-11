//
//  ARGBookVerticalLayoutSettingsController.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 27.10.2020.
//

import UIKit

class ARGBookVerticalLayoutSettingsController: ARGBookReadingSettingsController {
    
    private(set) var marginsScript: String?
    
    override func setSettings(_ settings: ARGBookReadingSettings!, pageSize:CGSize, completionHandler: (() -> Void)? = nil) {
        super.setSettings(settings, pageSize: pageSize) {
            let group = DispatchGroup()
            
            group.enter()
            self.setRelativeHorizontalMargins(settings.horizontalMargin) {
                group.leave()
            }
            
            group.notify(queue: DispatchQueue.main) {
                completionHandler?()
            }
        }
    }
    
    func setRelativeHorizontalMargins(_ margins: Int64, completion: (() -> Void)?) {
        if let pageSize = self.pageSize {
            let horizontalMargin = floor(pageSize.width / 100 * CGFloat(margins))
            let insets = UIEdgeInsets(top: 0, left: max(horizontalMargin, webView.safeAreaInsets.left), bottom: 0, right: max(horizontalMargin, webView.safeAreaInsets.right))
            setAbsoluteHorizontalMargins(insets, completion: completion)
        }
    }
    
    func setAbsoluteHorizontalMargins(_ margins: UIEdgeInsets, completion: (() -> Void)?) {
        contentEdgeInsets = margins
        
        let pageWidth = floor(pageSize!.width - margins.left - margins.right)
        let pageHeight = floor(pageSize!.height - margins.top - margins.bottom)
        
        let marginsScript = "setPaddings(\(pageWidth), \(pageHeight), 0, \(margins.right), 0, \(margins.left))"
        
        guard self.marginsScript != nil || self.marginsScript != marginsScript else {
            completion?()
            return
        }
        
        webView.evaluateJavaScript(marginsScript) { (result, error) in
            completion?()
        }
    }
}

