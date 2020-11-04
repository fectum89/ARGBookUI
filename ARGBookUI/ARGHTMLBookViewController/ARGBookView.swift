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
    
    var book: ARGBook?
    
    var settings: ARGBookReadingSettings?
    
    var navigationPoint: ARGBookNavigationPoint?
    
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
                refreshView()
            }
        }
    }
    
    public override var bounds: CGRect {
        didSet {
            if bounds != oldValue {
                refreshView()
            }
        }
    }
    
    public func load(book: ARGBook) {
        self.book = book

        cacheManager = ARGBookCacheManager(book: book, containerView: self)

        refreshView()
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
        
        refreshView()
    }
    
    public func scroll(to navigationPoint: ARGBookNavigationPoint?) {
        self.navigationPoint = navigationPoint
        
        guard book != nil, settings != nil, collectionView != nil else {
            return
        }
        
        if let navigationPoint = navigationPoint {
            if let documentIndex = book!.documents.firstIndex(where: { (document) -> Bool in
                return document === navigationPoint.document
            }) {
                let targetIndexPath = IndexPath(item: documentIndex, section: 0)
                
                collectionView.scrollToItem(at: targetIndexPath, at: .top, animated: false)
//                if let visibleViews = (scrollController?.sortedContainers() ?? nil) as? [ARGBookDocumentView], let documentView = visibleViews.first {
//                    //documentView.scroll(to: navigationPoint)
//                }
//                let cell = collectionView.cellForItem(at: targetIndexPath) as! ARGDocumentCollectionViewCell
//                cell.documentView.scroll(to: navigationPoint)
            }
        }
    }
    
    @objc func refreshView () {
        guard book != nil, settings != nil, collectionView != nil else {
            return
        }
        
        collectionView.dataSource = self

        cacheManager.updateCache(for: book!.documents, with: settings!, viewPort: self.bounds.size)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = self.bounds.size
        
        collectionView.performBatchUpdates {
            collectionView.collectionViewLayout.invalidateLayout()
        } completion: { (ready) in
            self.collectionView.reloadData()
            self.scroll(to: self.navigationPoint)
        }
    }

}

extension ARGBookView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return book?.documents.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ARGDocumentCollectionViewCell.self), for: indexPath) as! ARGDocumentCollectionViewCell

        if let document = book?.documents[indexPath.item] {
            cell.documentView.load(document: document, cache: cacheManager)
            scrollController?.addNestedScrollView(cell.documentView.contentView.webView.scrollView)
        }
        
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
        if let cell = cell as? ARGDocumentCollectionViewCell, let settings = self.settings {
            cell.documentView.applyReadingSettings(settings)
            
            if let navigationPoint = self.navigationPoint, navigationPoint.document?.filePath == book?.documents[indexPath.item].filePath {
                cell.documentView.scroll(to: navigationPoint)
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
                    if navigationPoint != nil {
                        self.navigationPoint = navigationPoint
                        navigationDelegate.currentNavigationPointDidChange(navigationPoint!)
                    }
                }
            }
        }
    }

}

