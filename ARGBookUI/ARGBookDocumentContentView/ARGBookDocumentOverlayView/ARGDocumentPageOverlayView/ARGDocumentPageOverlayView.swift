//
//  ARGBookPageOverlayView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 07.11.2020.
//

import UIKit

class ARGDocumentPageOverlayView: UIView {

    @IBOutlet weak var pageNumberLabel: UILabel!
    
    var contentEdgeInsets: UIEdgeInsets? {
        didSet {
            setNeedsLayout()
        }
    }
    
    func update(with page: ARGDocumentPage, contentEdgeInsets: UIEdgeInsets) {
        self.contentEdgeInsets = contentEdgeInsets
        pageNumberLabel.text = (page.globalPageNumber > 0) ? String(page.globalPageNumber) : ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let contentEdgeInsets = contentEdgeInsets {
            let delta: CGFloat = 5
            let extraInsets = UIEdgeInsets(top: delta, left: delta, bottom: delta, right: delta)
            let contentFrame = self.frame.inset(by: contentEdgeInsets).inset(by: extraInsets)
            pageNumberLabel.isHidden = contentFrame.intersects(pageNumberLabel.frame)
        }
    }
    
}
