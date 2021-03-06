//
//  ARGBookDocumentLayoutManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 15.10.2020.
//

import UIKit

class ARGBookDocumentLayoutManager {
    
    var layout: ARGBookDocumentLayout
    
    var settingsLogic: ARGBookDocumentSettingsCommonLogic
    var navigationLogic: ARGBookDocumentNavigationCommonLogic
    
    var document: ARGBookDocument
    
    var documentLoaded: Bool = false {
        didSet {
            if documentLoaded {
                let _ = self.conditionallyApplyPendingSettings()
            }
        }
    }
    
    init(layout: ARGBookDocumentLayout, document: ARGBookDocument, cache: ARGBookContentSizeCache) {
        self.layout = layout
        self.document = document
        self.settingsLogic = ARGBookDocumentSettingsCommonLogic(document: document,
                                                                layout: layout as! ARGBookDocumentContentSizeContainer & ARGBookDocumentSettingsControllerContainer,
                                                                cache: cache)
        self.navigationLogic = ARGBookDocumentNavigationCommonLogic(document: document,
                                                                    layout: layout as! ARGBookDocumentScrollBehavior)
    }
    
    func settingsCanBeApplied(_ settings: ARGBookReadingSettings?) -> Bool {
        if !documentLoaded || settingsLogic.applyingInProgress {
            settingsLogic.pendingSettings = settings
            return false
        } else {
            settingsLogic.applyingInProgress = true
            return true
        }
    }
    
    func applyReadingSettings(_ settings: ARGBookReadingSettings, completionHandler: (() -> Void)? = nil) {
        let allowed = self.settingsCanBeApplied(settings)

        guard allowed else {
            completionHandler?()
            return
        }

        self.settingsLogic.applyReadingSettings(settings) {
            if !self.conditionallyApplyPendingSettings(completionHandler: completionHandler) {
                completionHandler?()
                self.navigationLogic.scrollToProperPoint()
            }
        }
    }
    
    func conditionallyApplyPendingSettings(completionHandler: (() -> Void)? = nil) -> Bool {
        if let pendingSettings = settingsLogic.pendingSettings {
            self.settingsLogic.pendingSettings = nil
            self.applyReadingSettings(pendingSettings, completionHandler: completionHandler)
            return true
        } else {
            return false
        }
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint, completionHandler: (() -> Void)? = nil) {
        navigationLogic.scroll(to: navigationPoint, completionHandler: completionHandler)
    }
    
    func obtainCurrentNavigationPoint(completionHandler: ((ARGBookNavigationPoint) -> Void)? = nil) {
        navigationLogic.obtainCurrentNavigationPoint(completionHandler: completionHandler)
    }
    
}
