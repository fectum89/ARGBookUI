//
//  ARGBookPageOverlayView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 07.11.2020.
//

import UIKit

class ARGDocumentPageOverlayView: UIView {

    @IBOutlet weak var pageNumberLabel: UILabel!
    
    @IBOutlet weak var bookmarkButton: UIButton!
    
    var contentEdgeInsets: UIEdgeInsets? {
        didSet {
            setNeedsLayout()
        }
    }
    
    var page: ARGDocumentPage?
    
    func update(with page: ARGDocumentPage, contentEdgeInsets: UIEdgeInsets) {
        self.page = page
        self.contentEdgeInsets = contentEdgeInsets
        
        page.refreshHandler = { [unowned self] in
            self.setNeedsLayout()
        }
    }
    
    @objc func bookmarkButtonAction() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let page = page {
            bookmarkButton.alpha = page.bookmarks != nil ? 1 : 0
            pageNumberLabel.text = (page.globalPageNumber > 0) ? String(page.globalPageNumber) : ""
        }
        
        if let contentEdgeInsets = contentEdgeInsets {
            let delta: CGFloat = 5
            let extraInsets = UIEdgeInsets(top: delta, left: delta, bottom: delta, right: delta)
            let contentFrame = self.frame.inset(by: contentEdgeInsets).inset(by: extraInsets)
            
            subviews.forEach { (view) in
                view.isHidden = contentFrame.intersects(view.frame)
            }
        }
    }
    
}
