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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(page: ARGDocumentPage, pageConverter: ARGBookPageConverter) {
        let overlayCreator = page.startNavigationPoint.document.layoutType(for: pageConverter.settings.scrollType) as! ARGBookDocumentPageOverlayCreator.Type
        
        currentLayoutType = overlayCreator
        
        overlayView.page = page
    }
    
}
