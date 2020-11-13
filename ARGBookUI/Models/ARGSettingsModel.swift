//
//  ARGSettingsModel.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 11.10.2020.
//

import Foundation
import UIKit.UIColor

@objc public enum ARGBookScrollType: Int {
    case horizontal
    case vertical
    case paging
}

@objc public enum ARGBookReadingSettingsAlignment: Int64 {
    case left
    case justify
}


@objc public protocol ARGBookReadingSettings {
    
    var fontSize: Int64 {get}
    
    var alignment: ARGBookReadingSettingsAlignment {get}
    
    var fontFamily: String {get}
    
    var horizontalMargin: Int64 {get}
    
    var verticalMargin: Int64 {get}
    
    var hyphenation: Bool {get}
    
    var lineSpacing: Int64 {get}
    
    var paragraphIndent: Int64 {get}
    
    var paragraphSpacing: Int64 {get}
    
    var textColor: UIColor {get}
    
    var highlightColor: UIColor {get}
    
    var backGroundColor: UIColor {get}
    
    var scrollType: ARGBookScrollType {get}
    
}

extension ARGBookReadingSettings {
    
    func stringRepresentationForPageCache() -> String {
        return String(fontSize) + "."
            + String(alignment.rawValue) + "."
            + String(horizontalMargin) + "."
            + String(verticalMargin) + "."
            + String(hyphenation) + "."
            + String(lineSpacing) + "."
            + String(paragraphIndent) + "."
            + String(paragraphSpacing) + "."
            + String(scrollType.rawValue)
    }
    
    func stringRepresentationForSnapshotsCache() -> String {
        return stringRepresentationForPageCache() + "."
            + textColor.htmlRGBaColor + "."
            + highlightColor.htmlRGBaColor + "."
    }
    
}

extension ARGBookReadingSettings {
    
    func configure(collectionView: UICollectionView) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        switch scrollType {
        case .vertical:
            layout.scrollDirection = .vertical
            collectionView.isPagingEnabled = false
            collectionView.alwaysBounceHorizontal = false
            collectionView.alwaysBounceVertical = true
        default:
            layout.scrollDirection = .horizontal
            collectionView.isPagingEnabled = true
            collectionView.alwaysBounceHorizontal = true
            collectionView.alwaysBounceVertical = false
        }
    }
    
    
}
