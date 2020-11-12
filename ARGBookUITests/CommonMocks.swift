//
//  CommonMocks.swift
//  ARGBookUITests
//
//  Created by Sergei Polshcha on 11.11.2020.
//

import Foundation
@testable import ARGBookUI

class TestReadingSettingsMock: ARGBookReadingSettings {
    var fontSize: Int64 = 120
    
    var alignment: ARGBookReadingSettingsAlignment  = .justify
    
    var fontFamily = "IowanOldStyle-Roman"
    
    var horizontalMargin: Int64  = 10
    
    var verticalMargin: Int64  = 10
    
    var hyphenation = true
    
    var lineSpacing: Int64  = 10
    
    var paragraphIndent: Int64  = 10
    
    var paragraphSpacing: Int64  = 10
    
    var textColor = UIColor.red
    
    var highlightColor = UIColor.red
    
    var backGroundColor = UIColor.red
    
    var scrollType = ARGBookScrollType.horizontal
}

class TestBookMock: ARGBook {
    
    var uid: String = "stub"
    
    var documents: [ARGBookDocument]
    
    var contentDirectoryPath: String = "stub"
    
    init(documents: [ARGBookDocument]) {
        self.documents = documents
    }
    
}

class TestDocumentMock: ARGBookDocument {
    
    var highlights: [ARGBookHighlight]?
    
    var bookmarks: [ARGBookmark]?
    
    var uid: String
    
    var filePath: String = "stub"
    
    var book: ARGBook?
    
    var hasFixedLayout: Bool = false
    
    init(uid: String) {
        self.uid = uid
    }
}

class TestNavigationPointMock: ARGBookNavigationPoint {
    
    var document: ARGBookDocument
    
    var position: CGFloat
    
    init(document: ARGBookDocument,  position: CGFloat) {
        self.document = document
        self.position = position
    }

}
