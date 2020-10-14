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

@objc public protocol ARGBookReadingSettings {
    
    var fontSize: Int64 {get}
    
    var alignment: Int64 {get}
    
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
