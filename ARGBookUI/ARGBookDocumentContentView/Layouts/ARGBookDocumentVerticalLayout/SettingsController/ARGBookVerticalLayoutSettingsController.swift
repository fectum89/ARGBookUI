//
//  ARGBookVerticalLayoutSettingsController.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 27.10.2020.
//

import UIKit

class ARGBookVerticalLayoutSettingsController: ARGBookReadingSettingsController {
    private(set) var relativeHorizontalMargins: Int64?
    private(set) var absoluteHorizontalMargins: Int64?
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
        relativeHorizontalMargins = margins
        
        if let pageSize = self.pageSize {
            let absoluteMargins = Int64(floor(pageSize.width / 100 * CGFloat(margins)))
            setAbsoluteHorizontalMargins(absoluteMargins, completion: completion)
        }
    }
    
    func setAbsoluteHorizontalMargins(_ margins: Int64, completion: (() -> Void)?) {
        absoluteHorizontalMargins = margins
        
        let marginsScript = "setPaddings(\(self.pageSize!.width), \(self.pageSize!.height), 0, \(margins), 0, \(margins))"
        
        guard self.marginsScript != nil || self.marginsScript != marginsScript else {
            completion?()
            return
        }
        
        webView.evaluateJavaScript(marginsScript) { (result, error) in
            completion?()
        }
    }
}

