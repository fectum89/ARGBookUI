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
    
    var scrollController: ARGContiniousScrollController!
    
    @objc public var book: ARGBook? {
        didSet {
            refreshView()
        }
    }
    
    @objc public var settings: ARGBookReadingSettings? {
        didSet {
            applySettings()
        }
    }
    
    @objc public var navigationPoint: ARGBookNavigationPoint?
    
    @objc public  var navigationDelegate: ARGBookNavigationDelegate?
    
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
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
    }
    
    public override var frame: CGRect {
        didSet {
            refreshView()
        }
    }
    
    public override var bounds: CGRect {
        didSet {
            refreshView()
        }
    }
    
    func refreshView () {
        guard book != nil, settings != nil else {
            return
        }
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = self.bounds.size
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    func applySettings() {
        guard book != nil, settings != nil else {
            return
        }
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var continiousScrollControllerDirection: ARGContinuousScrollDirection = .horizontal
        var collectionViewLayoutDirection: UICollectionView.ScrollDirection = .horizontal
        
        switch settings?.scrollType {
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
            self.scrollController = ARGContiniousScrollController(scrollView: collectionView, delegate: self, scrollDirection: continiousScrollControllerDirection)
            refreshView()
        } else {
            refreshView()
//            let visibleCells = collectionView.visibleCells
//
//            for cell in visibleCells {
//                if let cell = cell as? ARGDocumentCollectionViewCell {
//                    cell.documentView.applyReadingSettings(settings!)
//                }
//            }
        }
        
        scrollTo(navigationPoint)
    }
    
    func scrollTo(_ navigationPoint: ARGBookNavigationPoint?) {
        guard book != nil, settings != nil else {
            return
        }
        
        if let navigationPoint = navigationPoint {
            if let documentIndex = book!.documents.firstIndex(where: { (document) -> Bool in
                return document === navigationPoint.document
            }) {
                let targetIndexPath = IndexPath(item: documentIndex, section: 0)
                collectionView.scrollToItem(at: targetIndexPath, at: .top, animated: false)
                //let cell = collectionView.cellForItem(at: targetIndexPath) as! ARGDocumentCollectionViewCell
                //cell.documentView.scroll(to: navigationPoint)
            }
        }
    }

}

extension ARGBookView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return book?.documents.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ARGDocumentCollectionViewCell.self), for: indexPath) as! ARGDocumentCollectionViewCell

        if let document = book?.documents[indexPath.item], let settings = self.settings {
            cell.documentView.reloadIfNeeded(document: document,
                                             settings: settings)
            
            scrollController.addNestedScrollView(cell.documentView.contentView.webView.scrollView)
        }
        
        return cell
    }
    
//    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//
//    }
    
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
