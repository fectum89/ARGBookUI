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
    
    var pageConverter: ARGBookPageConverter?
    
    var layoutType: (ARGBookDocumentScrollBehavior & ARGBookDocumentContentSizeContainer).Type?
    
    var cacheObserver: NSObjectProtocol?
    
    var showSnapshots: Bool = true
    
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
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare(for document: ARGBookDocument, pageConverter: ARGBookPageConverter, layoutType: (ARGBookDocumentScrollBehavior & ARGBookDocumentContentSizeContainer).Type) {
        self.pageConverter = pageConverter
        self.document = document
        self.layoutType = layoutType
        
        pageConverter.settings.configure(collectionView: collectionView)
        
        if !isObservingCache {
            cacheObserver = NotificationCenter.default.addObserver(forName: ARGBookCache.progressDidChangeNotification, object: nil, queue: .main) { [weak self] (_) in
                self?.preparePages()
            }
            
            isObservingCache = true
        }
        
        preparePages()
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
        if let documentLayout = layoutType, let pageConverter = self.pageConverter{
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = documentLayout.pageSize(for: collectionView.bounds.size,
                                                      settings: pageConverter.settings,
                                                      sizeClass: self.traitCollection.horizontalSizeClass)
            
            reload(withSnapshots: true)
            collectionView.isHidden = false
        }
    }
    
    func reload(withSnapshots: Bool) {
        showSnapshots = withSnapshots
        collectionView.reloadData()
    }
    
//    func scroll(to position: CGFloat) {
//        if let documentLayout = layoutType {
//            documentLayout.scroll(scrollView: collectionView, to: position)
//        }
//    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    
    deinit {
        if cacheObserver != nil {
            NotificationCenter.default.removeObserver(cacheObserver!)
        }
        
        print("overlay deinit")
    }
    
}

extension ARGDocumentOverlayView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ARGBookDocumentPageCollectionViewCell.self), for: indexPath) as! ARGBookDocumentPageCollectionViewCell
        
        if let page = pages?[indexPath.item] {
            cell.update(with: page, showSnapshot: showSnapshots)
        }
        
        return cell
    }
    
}


