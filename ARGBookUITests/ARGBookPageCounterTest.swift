//
//  ARGBookPageCounterTest.swift
//  ARGBookUITests
//
//  Created by Sergei Polshcha on 11.11.2020.
//

import XCTest
@testable import ARGBookUI

let viewPort = CGSize(width: 100, height: 100)

class BookCacheFileManagerMock: ARGBookCacheFileStorage {
    
    var ioQueue: DispatchQueue = DispatchQueue(label: "test")
    
    var maxSize: UInt = 0
    
    func name() -> String {
        return ""
    }
    
    func read(item: ARGBookCacheFileStorageItem, completionHandler: @escaping (Any?) -> Void) {
        
    }
    
    func save(items: [(object: Any, item: ARGBookCacheFileStorageItem)], completionHandler: (() -> Void)?) {
        
    }
    
}

class BookCacheMock: ARGBookContentSizeCache {
    
    var sizes: [String: CGSize]!
    
    override var containerView: UIView? {
        get {
            UIView(frame: CGRect(x: 0, y: 0, width: viewPort.width, height: viewPort.height))
        } set {
            
        }
    }
    
    init(book: ARGBook, fileManager: ARGBookCacheFileStorage, sizes: [String: CGSize]) {
        super.init(book: book, fileStorage: fileManager, containerView: UIView())
        self.sizes = sizes
        self.fileStorage = fileStorage
    }
    
   override func contentSize(for document: ARGBookDocument, settings: ARGBookReadingSettings, viewPort: CGSize) -> CGSize {
        if let size = sizes[document.uid] {
            return size
        } else {
            return .zero
        }
    }
    
}

class ARGBookPageCounterTest: XCTestCase {
    
    func test_PagesForDocument_Filled_Single_Horizontal() throws {
        let documents = [TestDocumentMock(uid: "1")]
        let book = TestBookMock(documents: documents)
        let sizes = ["1": CGSize(width: 1000, height: 100)]
        let fileManager = BookCacheFileManagerMock()
        let cache = BookCacheMock(book: book, fileManager: fileManager, sizes: sizes)
        let settings = TestReadingSettingsMock()
        let pageManager = ARGBookInternalPageManager(cache: cache, settings: settings)
        let pages = pageManager.pages(for: documents[0])
        XCTAssert(pages?.count == 10)
        let page = pages!.last
        XCTAssert(page?.globalPageNumber == 10)
    }
    
    func test_PagesForDocument_Filled_Many_Horizontal() throws {
        let documents = [TestDocumentMock(uid: "0"),
                         TestDocumentMock(uid: "1"),
                         TestDocumentMock(uid: "2"),
                         TestDocumentMock(uid: "3")]
        let book = TestBookMock(documents: documents)
        let sizes = ["0": CGSize(width: viewPort.width * 10, height: viewPort.height),
                     "1": CGSize(width: viewPort.width * 1, height: viewPort.height),
                     "2": CGSize(width: viewPort.width * 5, height: viewPort.height),
                     "3": CGSize(width: viewPort.width * 20, height: viewPort.height)]
        let fileManager = BookCacheFileManagerMock()
        let cache = BookCacheMock(book: book, fileManager: fileManager, sizes: sizes)
        let settings = TestReadingSettingsMock()
        let pageManager = ARGBookInternalPageManager(cache: cache, settings: settings)
        let pages = pageManager.pages(for: documents[3])
        XCTAssert(pages?.count == 20)

        let firstPage = pages!.first
        XCTAssert(firstPage?.globalPageNumber == 17)

        let lastPage = pages!.last
        XCTAssert(lastPage?.globalPageNumber == 36)
    }

    func test_PagesForDocument_Unfilled_Many_Horizontal() throws {
        let documents = [TestDocumentMock(uid: "0"),
                         TestDocumentMock(uid: "1"),
                         TestDocumentMock(uid: "2"),
                         TestDocumentMock(uid: "3")]
        let book = TestBookMock(documents: documents)
        let sizes = ["0": CGSize(width: viewPort.width * 10, height: viewPort.height),
                     "1": .zero,
                     "2": .zero,
                     "3": CGSize(width: viewPort.width * 20, height: viewPort.height)]
        let fileManager = BookCacheFileManagerMock()
        let cache = BookCacheMock(book: book, fileManager: fileManager, sizes: sizes)
        let settings = TestReadingSettingsMock()
        let pageManager = ARGBookInternalPageManager(cache: cache, settings: settings)
        let pages = pageManager.pages(for: documents[3])
        XCTAssert(pages?.count == 20)

        let firstPage = pages!.first
        XCTAssert(firstPage?.globalPageNumber == 0)

        let lastPage = pages!.last
        XCTAssert(lastPage?.globalPageNumber == 0)
    }

    func test_PagesForDocument_Empty_Many_Horizontal() throws {
        let documents = [TestDocumentMock(uid: "0"),
                         TestDocumentMock(uid: "1"),
                         TestDocumentMock(uid: "2"),
                         TestDocumentMock(uid: "3")]
        let book = TestBookMock(documents: documents)
        let sizes = ["stub": CGSize.zero]
        let fileManager = BookCacheFileManagerMock()
        let cache = BookCacheMock(book: book, fileManager: fileManager, sizes: sizes)
        let settings = TestReadingSettingsMock()
        let pageManager = ARGBookInternalPageManager(cache: cache, settings: settings)
        let pages = pageManager.pages(for: documents[3])
        XCTAssert(pages == nil)
    }

    func test_PagesForDocument_Filled_Many_Vertical() throws {
        let documents = [TestDocumentMock(uid: "0"),
                         TestDocumentMock(uid: "1"),
                         TestDocumentMock(uid: "2"),
                         TestDocumentMock(uid: "3")]
        let book = TestBookMock(documents: documents)
        let sizes = ["0": CGSize(width: viewPort.width, height: viewPort.height * 10),
                     "1": CGSize(width: viewPort.width, height: viewPort.height * 5),
                     "2": CGSize(width: viewPort.width, height: viewPort.height * 15),
                     "3": CGSize(width: viewPort.width, height: viewPort.height * 1)]
        let fileManager = BookCacheFileManagerMock()
        let cache = BookCacheMock(book: book, fileManager: fileManager, sizes: sizes)
        let settings = TestReadingSettingsMock()
        settings.scrollType = .vertical
        let pageManager = ARGBookInternalPageManager(cache: cache, settings: settings)
        let pages = pageManager.pages(for: documents[2])
        XCTAssert(pages?.count == 15)

        let firstPage = pages!.first
        XCTAssert(firstPage?.globalPageNumber == 16)
    }

    func test_PagesForDocument_Unfilled_Many_Vertical() throws {
        let documents = [TestDocumentMock(uid: "0"),
                         TestDocumentMock(uid: "1"),
                         TestDocumentMock(uid: "2"),
                         TestDocumentMock(uid: "3")]
        let book = TestBookMock(documents: documents)
        let sizes = ["0": CGSize(width: viewPort.width, height: viewPort.height * 10),
                     "1": .zero,
                     "2": .zero,
                     "3": CGSize(width: viewPort.width, height: viewPort.height * 1)]
        let fileManager = BookCacheFileManagerMock()
        let cache = BookCacheMock(book: book, fileManager: fileManager, sizes: sizes)
        let settings = TestReadingSettingsMock()
        settings.scrollType = .vertical
        let pageManager = ARGBookInternalPageManager(cache: cache, settings: settings)
        let pages = pageManager.pages(for: documents[3])
        XCTAssert(pages?.count == 1)

        let firstPage = pages!.first
        XCTAssert(firstPage?.globalPageNumber == 0)
    }

    func test_PageForPoint_Unfilled_Many_Vertical() throws {
        let documents = [TestDocumentMock(uid: "0"),
                         TestDocumentMock(uid: "1"),
                         TestDocumentMock(uid: "2"),
                         TestDocumentMock(uid: "3")]
        let book = TestBookMock(documents: documents)
        let sizes = ["0": CGSize(width: viewPort.width, height: viewPort.height * 10),
                     "1": .zero,
                     "2": .zero,
                     "3": CGSize(width: viewPort.width, height: viewPort.height * 1)]
        let fileManager = BookCacheFileManagerMock()
        let cache = BookCacheMock(book: book, fileManager: fileManager, sizes: sizes)
        let settings = TestReadingSettingsMock()
        settings.scrollType = .vertical
        let pageManager = ARGBookInternalPageManager(cache: cache, settings: settings)

        let point1 = TestNavigationPointMock(document: documents[0], position: 0.0)
        let point2 = TestNavigationPointMock(document: documents[3], position: 0.0)
        let point3 = TestNavigationPointMock(document: documents[0], position: 0.99)

        let page1 = pageManager.page(for: point1)
        XCTAssert(page1?.globalPageNumber == 1)

        let page2 = pageManager.page(for: point2)
        XCTAssert(page2?.globalPageNumber == 0)

        let page3 = pageManager.page(for: point3)
        XCTAssert(page3?.globalPageNumber == 10)

    }

    func test_PageForPoint_Filled_Many_Horizontal() throws {
        let documents = [TestDocumentMock(uid: "0"),
                         TestDocumentMock(uid: "1"),
                         TestDocumentMock(uid: "2"),
                         TestDocumentMock(uid: "3")]
        let book = TestBookMock(documents: documents)
        let sizes = ["0": CGSize(width: viewPort.width * 10, height: viewPort.height),
                     "1": CGSize(width: viewPort.width * 1, height: viewPort.height),
                     "2": CGSize(width: viewPort.width * 5, height: viewPort.height),
                     "3": CGSize(width: viewPort.width * 20, height: viewPort.height)]
        let fileManager = BookCacheFileManagerMock()
        let cache = BookCacheMock(book: book, fileManager: fileManager, sizes: sizes)
        let settings = TestReadingSettingsMock()
        let pageManager = ARGBookInternalPageManager(cache: cache, settings: settings)

        let point1 = TestNavigationPointMock(document: documents[0], position: 0.5)
        let point2 = TestNavigationPointMock(document: documents[1], position: 0.0)
        let point3 = TestNavigationPointMock(document: documents[3], position: 0.99)

        let page1 = pageManager.page(for: point1)
        XCTAssert(page1?.globalPageNumber == 6)

        let page2 = pageManager.page(for: point2)
        XCTAssert(page2?.globalPageNumber == 11)

        let page3 = pageManager.page(for: point3)
        XCTAssert(page3?.globalPageNumber == 36)
    }

    func test_PointForPageNumber_Filled_Many_Horizontal() throws {
        let documents = [TestDocumentMock(uid: "0"),
                         TestDocumentMock(uid: "1"),
                         TestDocumentMock(uid: "2"),
                         TestDocumentMock(uid: "3")]
        let book = TestBookMock(documents: documents)
        let sizes = ["0": CGSize(width: viewPort.width * 10, height: viewPort.height),
                     "1": CGSize(width: viewPort.width * 1, height: viewPort.height),
                     "2": CGSize(width: viewPort.width * 5, height: viewPort.height),
                     "3": CGSize(width: viewPort.width * 20, height: viewPort.height)]
        let fileManager = BookCacheFileManagerMock()
        let cache = BookCacheMock(book: book, fileManager: fileManager, sizes: sizes)
        let settings = TestReadingSettingsMock()
        let pageManager = ARGBookInternalPageManager(cache: cache, settings: settings)

        let point1 = pageManager.point(for: 1)
        XCTAssert(point1?.document.uid == "0")
        XCTAssert(point1?.position == 0)

        let point2 = pageManager.point(for: 36)
        XCTAssert(point2?.document.uid == "3")
        XCTAssert(point2?.position == 0.95)
    }

    func test_PointForPageNumber_Unfilled_Many_Horizontal() throws {
        let documents = [TestDocumentMock(uid: "0"),
                         TestDocumentMock(uid: "1"),
                         TestDocumentMock(uid: "2"),
                         TestDocumentMock(uid: "3")]
        let book = TestBookMock(documents: documents)
        let sizes = ["0": CGSize(width: viewPort.width * 10, height: viewPort.height),
                     "1": .zero,
                     "2": .zero,
                     "3": CGSize(width: viewPort.width * 20, height: viewPort.height)]
        let fileManager = BookCacheFileManagerMock()
        let cache = BookCacheMock(book: book, fileManager: fileManager, sizes: sizes)
        let settings = TestReadingSettingsMock()
        let pageManager = ARGBookInternalPageManager(cache: cache, settings: settings)

        let point1 = pageManager.point(for: 1)
        XCTAssert(point1?.document.uid == "0")
        XCTAssert(point1?.position == 0)

        let point2 = pageManager.point(for: 36)
        XCTAssert(point2 == nil)
    }

    func test_pagecount_Filled_Many_Horizontal() throws {
        let documents = [TestDocumentMock(uid: "0"),
                         TestDocumentMock(uid: "1"),
                         TestDocumentMock(uid: "2"),
                         TestDocumentMock(uid: "3")]
        let book = TestBookMock(documents: documents)
        let sizes = ["0": CGSize(width: viewPort.width * 10, height: viewPort.height),
                     "1": CGSize(width: viewPort.width * 1, height: viewPort.height),
                     "2": CGSize(width: viewPort.width * 5, height: viewPort.height),
                     "3": CGSize(width: viewPort.width * 20, height: viewPort.height)]
        let fileManager = BookCacheFileManagerMock()
        let cache = BookCacheMock(book: book, fileManager: fileManager, sizes: sizes)
        let settings = TestReadingSettingsMock()
        let pageManager = ARGBookInternalPageManager(cache: cache, settings: settings)
        let _ = pageManager.fillPagesCache(till: documents[3])
        let count = pageManager.pageCount
        XCTAssert(count == 36)
    }

}
