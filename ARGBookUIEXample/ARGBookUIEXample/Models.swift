//
//  TestBook.swift
//  Auri_Dev
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit
import ARGBookUI

class NavigationPoint: ARGBookNavigationPoint {
    
    var document: ARGBookDocument
    
    var position: CGFloat
    
    init(document: ARGBookDocument, position: CGFloat) {
        self.document = document
        self.position = position
    }

}

@objc class Document: NSObject, ARGBookDocument {
    
    var languageCode: String {
        get {
            "en"
        }
    }
    
    var highlights: [ARGBookHighlight]?
    
    var bookmarks: [ARGBookmark]?
    
    var uid: String {
        get {
            name
        }
    }
    
    var filePath: String
    var book: ARGBook?
    var hasFixedLayout: Bool = false
    
    var name: String {
        get {
            return URL(fileURLWithPath: filePath).lastPathComponent
        }
    }
    
    @objc init(filePath: String) {
        self.filePath = Bundle.main.bundlePath + "/" + filePath
    }
}

@objc class Book: NSObject, ARGBook {
    var uid: String
    
    var documents: [ARGBookDocument]
    
    var currentNavigationPoint: ARGBookNavigationPoint? {
        didSet {
            if let navigationPoint = currentNavigationPoint {
                let dictionaryPresentation = ["name" : (documents as! [Document]).first(where: { (document) -> Bool in
                    return document.name == (currentNavigationPoint?.document as! Document).name
                })?.name as Any,
                "progress": navigationPoint.position] as [String : Any]
                UserDefaults.standard.set(dictionaryPresentation, forKey: "currentNavigationPoint")
            }
        }
    }
    
    var contentDirectoryPath: String
    
    @objc init(directory: String, documents: [Document]) {
        self.uid = "book1"
        self.documents = documents
        self.contentDirectoryPath = directory
        if let savedDictionary = UserDefaults.standard.dictionary(forKey: "currentNavigationPoint"),
           let name = savedDictionary["name"] as? String,
           let progress = savedDictionary["progress"] as? CGFloat {
            if let document: Document = documents.first(where: { (document) -> Bool in
                document.name == name
            }) {
                self.currentNavigationPoint = NavigationPoint(document: document, position: progress)
                print("read navigationPoint: \(URL(fileURLWithPath: self.currentNavigationPoint!.document.filePath).lastPathComponent) - \(currentNavigationPoint!.position )")
            }
        }
        
    }
    
}

@objc class ReadingSettings: NSObject, ARGBookReadingSettings {
    var twoColumnsLayout: Bool = false
    
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

