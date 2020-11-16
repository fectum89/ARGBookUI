//
//  ARGDocumentCollectionViewCell.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 09.10.2020.
//

import UIKit

class ARGDocumentCollectionViewCell: UICollectionViewCell {
    
    var documentView: ARGBookDocumentView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    
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
