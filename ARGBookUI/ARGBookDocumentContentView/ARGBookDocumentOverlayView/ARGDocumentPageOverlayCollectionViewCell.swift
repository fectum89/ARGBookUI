//
//  ARGBookDocumentPageCollectionViewCell.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 07.11.2020.
//

import UIKit

class ARGBookDocumentPageCollectionViewCell: UICollectionViewCell {
    var overlayView: ARGDocumentPageOverlayView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        overlayView = UINib(nibName: String(describing: ARGDocumentPageOverlayView.self), bundle: Bundle(for: Self.self)).instantiate(withOwner: self, options: nil).first as? ARGDocumentPageOverlayView
        overlayView.frame = contentView.bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(overlayView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
