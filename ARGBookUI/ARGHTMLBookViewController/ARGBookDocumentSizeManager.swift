//
//  ARGBookDocumentSizeManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 21.10.2020.
//

import UIKit

class ARGBookDocumentSizeManager: NSObject {
    
    var sizeDictionary = [String: CGSize]()
    var defaultSize: CGSize
    
    init(with defaultSize: CGSize) {
        self.defaultSize = defaultSize
    }

    func save(size: CGSize, for document: ARGBookDocument, settings: ARGBookReadingSettings) {
        sizeDictionary[document.filePath + settings.stringRepresentationForPageCache()] = size
    }
    
    func size(for document: ARGBookDocument, settings: ARGBookReadingSettings) -> CGSize {
        return sizeDictionary[document.filePath + settings.stringRepresentationForPageCache()] ?? defaultSize
    }
    
}
