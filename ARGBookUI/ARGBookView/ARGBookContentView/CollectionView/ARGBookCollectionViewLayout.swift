//
//  ARGBookCollectionViewLayout.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 12.11.2020.
//

import Foundation

class ARGBookCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        sectionInset = .zero
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        estimatedItemSize = .zero
        super.prepare()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
