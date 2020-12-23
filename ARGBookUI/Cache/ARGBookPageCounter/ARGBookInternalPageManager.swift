//
//  ARGBookPageManager.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 03.11.2020.
//

import UIKit

class ARGBookInternalPageManager: ARGBookPageCounter {
    
    var contentSizeCache: ARGBookContentSizeCache
    
    var settings: ARGBookReadingSettings
    
    var pagesCache = [String: [ARGDocumentPage]]()
    
    var cachedPageCount: Int?
    
    var pageCount: Int {
        get {
            if cachedPageCount != nil {
                return cachedPageCount!
            }
            
            if let lastDocument = contentSizeCache.book.documents.last {
                if pagesCache[lastDocument.uid] == nil {
                    let _ = fillPagesCache(till: lastDocument)
                }
                
                if let lastPageNumber = pagesCache[lastDocument.uid]?.last?.globalPageNumber {
                    cachedPageCount = lastPageNumber
                    return lastPageNumber
                }
            }
            
            return 0
        }
    }
    
    init(cache: ARGBookContentSizeCache, settings: ARGBookReadingSettings) {
        self.contentSizeCache = cache
        self.settings = settings
    }
    
    func fillPagesCache(till targetDocument: ARGBookDocument) -> [ARGDocumentPage]? {
        var pageNumber: Int = 0
        if let targetDocumentIndex = contentSizeCache.book.documents.firstIndex(where: { (document) -> Bool in
            document.uid == targetDocument.uid
        }) {
            for index in 0...targetDocumentIndex {
                let document = contentSizeCache.book.documents[index]
                
                if let pages = pagesCache[document.uid] {
                    pageNumber += pages.count
                    continue
                } else {
                    if let pages = unnumberedPages(for: document) {
                        pages.forEach { (page) in
                            page.globalPageNumber = pageNumber + 1
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
        if let lastDocument = contentSizeCache.book.documents.last {
            if pagesCache[lastDocument.uid] == nil {
                let _ = fillPagesCache(till: lastDocument)
            }
        }
        
        for pages in pagesCache.values {
            for page in pages {
                if page.globalPageNumber == pageNumber {
                    return page.startNavigationPoint
                }
            }
        }
        
        return nil
    }
    
    func unnumberedPages(for document: ARGBookDocument) -> [ARGDocumentPage]? {
        if let containerView = contentSizeCache.containerView {
            let documentSize = contentSizeCache.contentSize(for: document,
                                                     settings: settings,
                                                     viewPort: containerView.bounds.size)
            if documentSize != .zero {
                let LayoutClass = document.layoutType(for: settings.scrollType) as! ARGBookDocumentContentSizeContainer.Type
                let pageSize = LayoutClass.pageSize(for: containerView.bounds.size,
                                                    settings: settings,
                                                    sizeClass: containerView.traitCollection.horizontalSizeClass)
                let pageCount = LayoutClass.pageCount(for: documentSize, pageSize: pageSize)
                var pages = [ARGDocumentPage]()
                
                for pageNumber in 0..<pageCount {
                    let startNavigationPoint = ARGBookNavigationPointInternal(document: document, position: CGFloat(pageNumber) / CGFloat(pageCount))
                    let endNavigationPoint = ARGBookNavigationPointInternal(document: document, position: CGFloat(pageNumber + 1) / CGFloat(pageCount))
                    let page = ARGDocumentPage(startNavigationPoint: startNavigationPoint, endNavigationPoint: endNavigationPoint, pageCounter: self)
                    page.relativePageNumber = pageNumber + 1
                    
                    pages.append(page)
                }
                
                return !pages.isEmpty ? pages : nil
            }
        }
        
        return nil
    }
    
}
