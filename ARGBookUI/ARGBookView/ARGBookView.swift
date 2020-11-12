//
//  ARGBookView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 18.10.2020.
//

import UIKit
import ARGContinuousScroll

@objc public class ARGBookView: UIView {

    var collectionView: UICollectionView!
    
    var scrollController: ARGContiniousScrollController?
    
    var cacheManager: ARGBookCacheManager!
    var pageManager: ARGBookPageConverter!
    
    var book: ARGBook?
    
    var settings: ARGBookReadingSettings?
    
    var currentNavigationPoint: ARGBookNavigationPoint?
    
    @objc public weak var navigationDelegate: ARGBookNavigationDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(collectionView)
        
        let identifier = String(describing: ARGDocumentCollectionViewCell.self)
        let nib = UINib(nibName: identifier, bundle: Bundle(for: ARGDocumentCollectionViewCell.self))
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .clear
    }
    
    public override var frame: CGRect {
        didSet {
            if frame != oldValue {
                defferedRefreshView()
            }
        }
    }
    
    public override var bounds: CGRect {
        didSet {
            if bounds != oldValue {
                defferedRefreshView()
            }
        }
    }
    
    func defferedRefreshView() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(refreshView), object: nil)
        self.perform(#selector(refreshView), with: nil, afterDelay: 0.1)
    }
    
    public func load(book: ARGBook) {
        self.book = book
        cacheManager = ARGBookCacheManager(containerView: self, fileManager: ARGBookCacheFileManager(book: book))
        defferedRefreshView()
    }
    
    public func apply(settings: ARGBookReadingSettings, completionHandler: (() -> Void)? = nil) {
        guard book != nil, collectionView != nil else {
            return
        }
        
        self.settings = settings
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var continiousScrollControllerDirection: ARGContinuousScrollDirection = .horizontal
        var collectionViewLayoutDirection: UICollectionView.ScrollDirection = .horizontal
        
        switch settings.scrollType {
        case .vertical:
            collectionViewLayoutDirection = .vertical
            collectionView.isPagingEnabled = false
            collectionView.alwaysBounceHorizontal = false
            collectionView.alwaysBounceVertical = true
            continiousScrollControllerDirection = .vertical
        default:
            collectionViewLayoutDirection = .horizontal
            collectionView.isPagingEnabled = true
            collectionView.alwaysBounceHorizontal = true
            collectionView.alwaysBounceVertical = false
            continiousScrollControllerDirection = .horizontal
        }
        
        if self.scrollController == nil || layout.scrollDirection != collectionViewLayoutDirection {
            layout.scrollDirection = collectionViewLayoutDirection
            self.scrollController = ARGContiniousScrollController(scrollView: collectionView,
                                                                  delegate: self,
                                                                  scrollDirection: continiousScrollControllerDirection,
                                                                  proxyConfigurationHandler: { [weak self] (proxy: ARGScrollViewDelegateProxy) in
                                                                    proxy.addDelegate(self!)
                                                                  })
            
        }
        
        defferedRefreshView()
    }
    
    @objc func refreshView () {
        guard book != nil, settings != nil, collectionView != nil else {
            return
        }
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = self.bounds.size
        
        collectionView.dataSource = self
        
        pageManager = ARGBookInternalPageManager(cache: cacheManager, settings: settings!, viewPort: self.bounds.size)
        
        collectionView.collectionViewLayout.invalidateLayout()
        
       // DispatchQueue.main.async {
            self.collectionView.reloadData()
            
            self.cacheManager.startCacheUpdating(for: self.book!.documents, with: self.settings!, viewPort: self.bounds.size)
            
            if let navigationPoint = self.currentNavigationPoint {
                self.scroll(to: navigationPoint)
            }
       // }
    }

}

extension ARGBookView {
    
    public func scroll(to navigationPoint: ARGBookNavigationPoint) {
        self.currentNavigationPoint = navigationPoint
        
        guard book != nil, settings != nil, collectionView != nil else {
            return
        }
        
        if let documentIndex = book!.documents.firstIndex(where: { (document) -> Bool in
            return document === navigationPoint.document
        }) {
            let targetIndexPath = IndexPath(item: documentIndex, section: 0)
            //collectionView.scrollToItem(at: targetIndexPath, at: .top, animated: false)
        }
    }
    
}

extension ARGBookView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return book?.documents.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ARGDocumentCollectionViewCell.self), for: indexPath) as! ARGDocumentCollectionViewCell
        scrollController?.addNestedScrollView(cell.documentView.contentView.webView.scrollView)
        return cell
    }
    
}

extension ARGBookView: ARGContiniousScrollDelegate {
    
    public func visibleNestedScrollContainers(for scrollController: ARGContiniousScrollController) -> [UIView & ARGNestedContiniousScrollContainer]? {
        let views = collectionView.visibleCells.map { (cell) -> ARGBookDocumentView in
            let cell = cell as! ARGDocumentCollectionViewCell
            return cell.documentView
        }
        
        return views
    }
    
}

extension ARGBookView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ARGDocumentCollectionViewCell, let document = book?.documents[indexPath.item], let settings = self.settings {
            
            //cell.documentView.load(document: document, settings: settings, pageConverter: pageManager)
            
            if let navigationPoint = self.currentNavigationPoint, navigationPoint.document.filePath == book?.documents[indexPath.item].filePath {
               // cell.documentView.scroll(to: navigationPoint)
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDidFinish()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollDidFinish()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollDidFinish()
        }
    }
    
    func scrollDidFinish() {
        if let visibleViews = (scrollController?.sortedContainers() ?? nil) as? [ARGBookDocumentView] {
            if let documentView = visibleViews.first, let navigationDelegate = navigationDelegate {
                documentView.contentView.obtainCurrentNavigationPoint { (navigationPoint) in
                    self.currentNavigationPoint = navigationPoint
                    navigationDelegate.currentNavigationPointDidChange(navigationPoint)
                }
            }
        }
    }

}

