//
//  ARGBookDocumentPageCollectionViewCell.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 07.11.2020.
//

import UIKit

class ARGBookDocumentPageCollectionViewCell: UICollectionViewCell {
    
    var overlayView: ARGDocumentPageOverlayView!
    
    var currentLayoutType: ARGBookDocumentPageOverlayCreator.Type? {
        didSet {
            if currentLayoutType == nil || currentLayoutType != oldValue {
                if overlayView != nil {
                    overlayView.removeFromSuperview()
                }
                
                overlayView = currentLayoutType?.overlayView(parentView: contentView)
            }
        }
    }
    
    func update(with page: ARGDocumentPage, showSnapshot: Bool) {
        if let converter = page.pageConverter {
            let overlayCreator = page.startNavigationPoint.document.layoutType(for: converter.settings.scrollType) as! ARGBookDocumentPageOverlayCreator.Type
            
            currentLayoutType = overlayCreator
            
            overlayView.update(with: page, showSnapshot: showSnapshot)
        }
    }
    
}
