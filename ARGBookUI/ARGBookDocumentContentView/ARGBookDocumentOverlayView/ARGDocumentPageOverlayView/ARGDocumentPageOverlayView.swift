//
//  ARGBookPageOverlayView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 07.11.2020.
//

import UIKit

class ARGDocumentPageOverlayView: UIView {

    @IBOutlet weak var pageNumberLabel: UILabel!
    
    func update(with page: ARGDocumentPage) {
        pageNumberLabel.text = (page.globalPageNumber > 0) ? String(page.globalPageNumber) : ""
    }
    
}
