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
    @objc public var pageManager: ARGBookPageConverter!
    
    var book: ARGBook?
    
    var settings: ARGBookReadingSettings?
    
    @objc public var currentNavigationPoint: ARGBookNavigationPoint?
    
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
        createCollectionView()
    }
    
    public override var frame: CGRect {
        didSet {
            if frame != oldValue {
                createCollectionView()
            }
        }
    }
    
    public override var bounds: CGRect {
        didSet {
            if bounds != oldValue {
                createCollectionView()
            }
        }
    }
    
    @objc func createCollectionView() {
        if collectionView != nil {
            scrollController = nil
            collectionView.removeFromSuperview()
        }
        
        let layout = ARGBookCollectionViewLayout()
        collectionView = ARGBookCollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
       
        let identifier = String(describing: ARGDocumentCollectionViewCell.self)
        let nib = UINib(nibName: identifier, bundle: Bundle(for: ARGDocumentCollectionViewCell.self))
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        
        self.addSubview(collectionView)
        
        if let settings = self.settings {
            apply(settings: settings)
        }
    }
    
    public func load(book: ARGBook) {
        self.book = book
        cacheManager = ARGBookCacheManager(containerView: self, fileManager: ARGBookCacheFileManager(book: book))
        refreshView()
    }
    
    public func apply(settings: ARGBookReadingSettings, completionHandler: (() -> Void)? = nil) {
        self.settings = settings
        
        guard book != nil, collectionView != nil else {
            return
        }
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let previousScrollDirection = layout.scrollDirection
        
        settings.configure(collectionView: collectionView)
        
        if self.scrollController == nil || layout.scrollDirection != previousScrollDirection {
            self.scrollController = ARGContiniousScrollController(scrollView: collectionView, delegate: self, scrollDirection: layout.scrollDirection, proxyConfigurationHandler: { [weak self] (proxy: ARGScrollViewDelegateProxy) in
                if let view = self {
                    proxy.addDelegate(view)
                }
            })
        }

        refreshView()
    }
    
    @objc func refreshView () {
        guard book != nil, settings != nil, collectionView != nil else {
            return
        }
        
        pageManager = ARGBookInternalPageManager(cache: cacheManager,
                                                 settings: settings!)
        
        cacheManager.startCacheUpdating(for: self.book!.documents,
                                        with: settings!,
                                        viewPort: bounds.size)
        
        collectionView.reloadData()
        
        if let navigationPoint = self.currentNavigationPoint {
            scroll(to: navigationPoint)
        }
    }
    
}

extension ARGBookView {
    
    public func scroll(to navigationPoint: ARGBookNavigationPoint) {
        self.currentNavigationPoint = navigationPoint
        
        guard book != nil, settings != nil, collectionView != nil else {
            return
        }
        
        navigationDelegate?.currentNavigationPointDidChange(navigationPoint)
        
        if let documentIndex = book!.documents.firstIndex(where: { (document) -> Bool in
            return document === navigationPoint.document
        }) {
            let targetIndexPath = IndexPath(item: documentIndex, section: 0)
            collectionView.scrollToItem(at: targetIndexPath, at: .top, animated: false)
            
            if let visibleViews = scrollController?.sortedContainers() as? [ARGBookDocumentView] {
                if !visibleViews.isEmpty, let visibleView = visibleViews.first {
                    if visibleView.contentView.documentLoader.document?.uid == navigationPoint.document.uid {
                        visibleView.scroll(to: navigationPoint)
                    }
                }
            }
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
            
            cell.documentView.load(targetSize: collectionView.bounds.size, document: document, settings: settings, pageConverter: pageManager)
            
            if let navigationPoint = self.currentNavigationPoint, navigationPoint.document.filePath == book?.documents[indexPath.item].filePath {
                cell.documentView.scroll(to: navigationPoint)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
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

