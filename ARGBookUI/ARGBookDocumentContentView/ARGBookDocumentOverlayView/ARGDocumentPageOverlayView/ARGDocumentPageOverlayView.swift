//
//  ARGBookPageOverlayView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 07.11.2020.
//

import UIKit

class ARGDocumentPageOverlayView: UIView {

    @IBOutlet weak var pageNumberLabel: UILabel!
    
    var page: ARGDocumentPage? {
        didSet {
            pageNumberLabel.text = (page?.pageNumber != nil) ? String(page?.pageNumber! ?? 0) : ""
        }
    }
    
}
