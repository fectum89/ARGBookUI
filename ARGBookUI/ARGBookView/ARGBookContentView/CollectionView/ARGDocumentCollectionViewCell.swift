//
//  ARGDocumentCollectionViewCell.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 09.10.2020.
//

import UIKit

class ARGDocumentCollectionViewCell: UICollectionViewCell {
    
    var documentView: ARGBookDocumentView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        documentView = ARGBookDocumentView()
        documentView.frame = contentView.bounds
        documentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(documentView)
    }
    
    deinit {
        print("cell deinit")
    }
}
