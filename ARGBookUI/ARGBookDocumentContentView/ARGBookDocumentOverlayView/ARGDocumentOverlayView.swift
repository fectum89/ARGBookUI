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
//        didSet {
//            if document?.uid != oldValue?.uid {
//                if !isObservingCache {
//
//                }
//            }
//        }
 //   }
    
    var pageConverter: ARGBookPageConverter? {
        didSet {
            
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(collectionView)
        
        let identifier = String(describing: ARGBookDocumentPageCollectionViewCell.self)
        collectionView.register(ARGBookDocumentPageCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare(for document: ARGBookDocument, pageConverter: ARGBookPageConverter) {
        self.pageConverter = pageConverter
        self.document = document
        
        if !isObservingCache {
            pageConverter.bookCache.addObserver(self, forKeyPath: "progress", options: .initial, context: nil)
            isObservingCache = true
        } else {
            preparePages()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "progress" {
            preparePages()
        }
    }
    
    func preparePages() {
        if let document = self.document, let pageConverter = self.pageConverter {
            collectionView.isHidden = true
            if let pages = pageConverter.pages(for: document) {
                self.pages = pages
            }
            
            refreshView()
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

    func refreshView () {
        collectionView.dataSource = self

        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = self.bounds.size
        
        collectionView.performBatchUpdates {
            collectionView.collectionViewLayout.invalidateLayout()
        } completion: { (ready) in
            self.collectionView.reloadData()
        }
        
        self.collectionView.isHidden = false
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    
    deinit {
        pageConverter?.bookCache.removeObserver(self, forKeyPath: "progress")
    }
    
}

extension ARGDocumentOverlayView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ARGBookDocumentPageCollectionViewCell.self), for: indexPath) as! ARGBookDocumentPageCollectionViewCell
        
        if let page = pages?[indexPath.item] {
            cell.overlayView.set(page: page, pageCount: pageConverter?.pageCount)
        }
        
        return cell
    }
    
}

