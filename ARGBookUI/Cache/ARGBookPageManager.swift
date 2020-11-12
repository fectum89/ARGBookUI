//
//  ARGBookPageManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 03.11.2020.
//

import UIKit

protocol ARGBookPageConverter {
    
    var bookCache: ARGBookCache {get}
    
    var settings: ARGBookReadingSettings {get}
    
    var pageCount: Int? {get}
    
    func page(for point: ARGBookNavigationPoint) -> ARGDocumentPage?
    
    func pages(for document: ARGBookDocument) -> [ARGDocumentPage]?
    
    func point(for pageNumber: Int) -> ARGBookNavigationPoint?
    
}

class ARGBookInternalPageManager: ARGBookPageConverter {
    
    var bookCache: ARGBookCache
    
    var settings: ARGBookReadingSettings
    
    var viewPort: CGSize
    
    var pagesCache = [String: [ARGDocumentPage]]()
    
    var cachedPageCount: Int?
    
    var pageCount: Int? {
        get {
            if cachedPageCount != nil {
                return cachedPageCount
            }
            
            if let lastDocument = bookCache.book.documents.last {
                if pagesCache[lastDocument.uid] == nil {
                    let _ = fillPagesCache(till: lastDocument)
                }
                
                if let lastPageNumber = pagesCache[lastDocument.uid]?.last?.pageNumber {
                    cachedPageCount = lastPageNumber
                    return lastPageNumber
                }
            }
            
            return nil
        }
    }
    
    init(cache: ARGBookCache, settings: ARGBookReadingSettings, viewPort: CGSize) {
        self.bookCache = cache
        self.settings = settings
        self.viewPort = viewPort
    }
    
    func fillPagesCache(till targetDocument: ARGBookDocument) -> [ARGDocumentPage]? {
        var pageNumber: Int = 0
        if let targetDocumentIndex = bookCache.book.documents.firstIndex(where: { (document) -> Bool in
            document.uid == targetDocument.uid
        }) {
            for index in 0...targetDocumentIndex {
                let document = bookCache.book.documents[index]
                
                if let pages = pagesCache[document.uid] {
                    pageNumber += pages.count
                    continue
                } else {
                    if let pages = unnumberedPages(for: document) {
                        pages.forEach { (page) in
                            page.pageNumber = pageNumber + 1
                            pageNumber += 1
                        }
                        
                        pagesCache[document.uid] = pages
                    } else {
                        break
                    }
                }
            }
        }
        
        return pagesCache[targetDocument.uid]
    }
    
    func pages(for targetDocument: ARGBookDocument) -> [ARGDocumentPage]? {
        if let pages = pagesCache[targetDocument.uid] {
            return pages
        } else {
            if let pages = fillPagesCache(till: targetDocument) {
                return pages
            } else {
                return unnumberedPages(for: targetDocument)
            }
        }
    }
    
    func page(for point: ARGBookNavigationPoint) -> ARGDocumentPage? {
        if let pages = pages(for: point.document) {
            for page in pages.reversed() {
                if page.startNavigationPoint.position <= point.position {
                    return page
                }
            }
        }
        
        return nil
    }
    
    func point(for pageNumber: Int) -> ARGBookNavigationPoint? {
        if let lastDocument = bookCache.book.documents.last {
            if pagesCache[lastDocument.uid] == nil {
                let _ = fillPagesCache(till: lastDocument)
            }
        }
        
        for pages in pagesCache.values {
            for page in pages {
                if page.pageNumber == pageNumber {
                    return page.startNavigationPoint
                }
            }
        }
        
        return nil
    }
    
    func unnumberedPages(for document: ARGBookDocument) -> [ARGDocumentPage]? {
        if let documentSize = bookCache.contentSize(for: document,
                                                    settings: settings,
                                                    viewPort: viewPort) {
            let LayoutClass = document.layoutClass(for: settings.scrollType)
            let pageCount = LayoutClass.pageCount(for: documentSize,
                                                       viewPort: viewPort)
            var pages = [ARGDocumentPage]()
            
            for pageNumber in 0..<pageCount {
                let position = CGFloat(pageNumber) / CGFloat(pageCount)
                let navigationPoint = ARGBookNavigationPointInternal(document: document, position: position)
                
                let page = ARGDocumentPage(startNavigationPoint: navigationPoint)
                
                pages.append(page)
            }
            
            return !pages.isEmpty ? pages : nil
        } else {
            return nil
        }
    }
}
