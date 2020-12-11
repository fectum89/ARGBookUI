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
    
    func update(with page: ARGDocumentPage, contentEdgeInsets: UIEdgeInsets) {
        if let counter = page.pageCounter {
            let overlayCreator = page.startNavigationPoint.document.layoutType(for: counter.settings.scrollType) as! ARGBookDocumentPageOverlayCreator.Type
            
            currentLayoutType = overlayCreator
            
            overlayView.update(with: page, contentEdgeInsets: contentEdgeInsets)
        }
    }
    
}
