//
//  ARGBookPageOverlayView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 07.11.2020.
//

import UIKit

class ARGDocumentPageOverlayView: UIView {

    @IBOutlet weak var pageNumberLabel: UILabel!
    //@IBOutlet weak var snapshotView: UIImageView!
    
    func update(with page: ARGDocumentPage, showSnapshot: Bool) {
        pageNumberLabel.text = (page.pageNumber > 0) ? String(page.pageNumber) : ""
//        snapshotView.isHidden = !showSnapshot
//
//        if showSnapshot {
//            page.loadSnapshot { (image) in
//                self.snapshotView.image = image
//            }
//        }
    }
    
}
