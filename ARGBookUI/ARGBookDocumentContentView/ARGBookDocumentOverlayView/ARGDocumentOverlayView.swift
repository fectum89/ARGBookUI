//
//  ARGBookDocumentOverlayView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 07.11.2020.
//

import UIKit

class ARGDocumentOverlayView: UIView {

    var collectionView: UICollectionView?
    
    var pages: [ARGDocumentPage]?
    
    var isObservingCache = false
    
    var document: ARGBookDocument?
    
    var pageCounter: ARGBookPageCounter?
    
    var layout: (ARGBookDocumentSettingsControllerContainer & ARGBookDocumentScrollBehavior & ARGBookDocumentContentSizeContainer)?
    
    var cacheObserver: NSObjectProtocol?
    
    var pageOverlayViews: [ARGDocumentPageOverlayView]? {
        let visibleCells = collectionView?.visibleCells
        
        return visibleCells?.map { (cell) -> ARGDocumentPageOverlayView in
            let cell = cell as! ARGBookDocumentPageCollectionViewCell
            return cell.overlayView
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            conditionallyUpdateContentOffset()
        }
    }
    
    func prepare(for document: ARGBookDocument, pageCounter: ARGBookPageCounter, layout: (ARGBookDocumentSettingsControllerContainer & ARGBookDocumentScrollBehavior & ARGBookDocumentContentSizeContainer)?) {
        self.pageCounter = pageCounter
        self.document = document
        self.layout = layout
        
        collectionView?.removeFromSuperview()
        
        let layout = ARGBookCollectionViewLayout()
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView?.contentInsetAdjustmentBehavior = .never
        collectionView?.backgroundColor = .clear
        
        self.addSubview(collectionView!)
        
        let identifier = String(describing: ARGBookDocumentPageCollectionViewCell.self)
        collectionView?.register(ARGBookDocumentPageCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        
        collectionView?.addObserver(self, forKeyPath: "contentSize", options: .initial, context: nil)
        
        pageCounter.settings.configure(collectionView: collectionView!)

        if !isObservingCache {
            cacheObserver = NotificationCenter.default.addObserver(forName: ARGBookContentSizeCache.progressDidChangeNotification, object: nil, queue: .main) { [weak self] (_) in
                self?.preparePages()
            }

            isObservingCache = true
        }
        
        preparePages()
    }
    
    func preparePages() {
        if let document = self.document, let pageCounter = self.pageCounter {
            collectionView?.isHidden = true
            
            if let pages = pageCounter.pages(for: document) {
                self.pages = pages
                refreshView()
            }
        }
    }
    
    var contentOffset: CGPoint = .zero {
        didSet {
            conditionallyUpdateContentOffset()
        }
    }
    
    func conditionallyUpdateContentOffset() {
        if let collectionView = collectionView, collectionView.contentSize.width > 0 && collectionView.contentSize.height > 0{
            collectionView.contentOffset = contentOffset
        }
    }
    
    func refreshView () {
        if let layout = layout, let pageCounter = self.pageCounter {
            collectionView?.contentInset = layout.webView.scrollView.contentInset
            let documentLayout = type(of: layout)
            if let collectionViewLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                collectionViewLayout.itemSize = documentLayout.pageSize(for: collectionView!.bounds.size,
                                                          settings: pageCounter.settings,
                                                          sizeClass: self.traitCollection.horizontalSizeClass)
                
                collectionView?.dataSource = self
                collectionView?.isHidden = false
                collectionView?.reloadData()
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if view is UIButton {
            return view
        } else {
            return nil
        }
    }

    deinit {
        if cacheObserver != nil {
            NotificationCenter.default.removeObserver(cacheObserver!)
        }
        
        collectionView?.removeObserver(self, forKeyPath: "contentSize")
    }
    
}

extension ARGDocumentOverlayView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ARGBookDocumentPageCollectionViewCell.self), for: indexPath) as! ARGBookDocumentPageCollectionViewCell
        
        if let page = pages?[indexPath.item], let contentEdgeInsets = layout?.settingsController.contentEdgeInsets {
            cell.update(with: page, contentEdgeInsets: contentEdgeInsets)
        }
        
        return cell
    }

}
