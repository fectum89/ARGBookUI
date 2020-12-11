//
//  ARGBookDocumentOverlayView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 07.11.2020.
//

import UIKit

class ARGDocumentOverlayView: UIView {

    var collectionView: UICollectionView!
    
    var pages: [ARGDocumentPage]?
    
    var isObservingCache = false
    
    var document: ARGBookDocument?
    
    var pageCounter: ARGBookPageCounter?
    
    var layout: (ARGBookDocumentSettingsControllerContainer & ARGBookDocumentScrollBehavior & ARGBookDocumentContentSizeContainer)?
    
    var cacheObserver: NSObjectProtocol?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = ARGBookCollectionViewLayout()
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        
        self.addSubview(collectionView)
        
        let identifier = String(describing: ARGBookDocumentPageCollectionViewCell.self)
        collectionView.register(ARGBookDocumentPageCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        
        collectionView.addObserver(self, forKeyPath: "contentSize", options: .initial, context: nil)
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
            //collectionView.isHidden = true
            if let pages = pageCounter.pages(for: document) {
                self.pages = pages
                refreshView()
            }
        }
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
    
    var contentOffset: CGPoint = .zero {
        didSet {
            conditionallyUpdateContentOffset()
        }
    }
    
    func conditionallyUpdateContentOffset() {
        if collectionView.contentSize.width > 0 && collectionView.contentSize.height > 0 {
            collectionView.contentOffset = contentOffset
        }
    }
    
    func refreshView () {
        if let layout = layout, let pageCounter = self.pageCounter {
            let documentLayout = type(of: layout)
            let collectionViewLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            collectionViewLayout.itemSize = documentLayout.pageSize(for: collectionView.bounds.size,
                                                      settings: pageCounter.settings,
                                                      sizeClass: self.traitCollection.horizontalSizeClass)
            pageCounter.settings.configure(collectionView: collectionView)
            
            collectionView.performBatchUpdates {
                collectionViewLayout.invalidateLayout()
            } completion: { (ready) in
                self.collectionView.reloadData()
            }
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    
    deinit {
        if cacheObserver != nil {
            NotificationCenter.default.removeObserver(cacheObserver!)
        }
        
        collectionView.removeObserver(self, forKeyPath: "contentSize")
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
