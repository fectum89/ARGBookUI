//
//  ARGBookPageManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 03.11.2020.
//

import UIKit

protocol ARGBookPage {
    
    var bookCache: ARGBookCache {get}
    
    func pageNumber(for point: ARGBookNavigationPoint) -> Int
    
    func point(for pageNumber: Int) -> ARGBookNavigationPoint
    
}

class ARGBookPageManager: NSObject {
    
    var bookCache: ARGBookCache

    init(cache: ARGBookCache) {
        bookCache = cache
    }
    

    
}
