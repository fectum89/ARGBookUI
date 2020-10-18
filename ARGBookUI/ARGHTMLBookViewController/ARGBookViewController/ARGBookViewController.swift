//
//  ARGHTMLBookViewController.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 09.10.2020.
//

import UIKit
import ARGView

@objc public class ARGBookViewController: UIViewController {
    
    var scrollController: ARGContiniousScrollController!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var book: ARGBook!
    var interactor: ARGBookNavigationInteractor!
    
    @objc public var settings: ARGBookReadingSettings! {
        didSet {
            applyReadingSettings(settings)
        }
    }
    
    @objc public var navigationPoint: ARGBookNavigationPoint!
    
    @objc public init(book: ARGBook, interactor: ARGBookNavigationInteractor) {
        self.book = book
        self.interactor = interactor
        
        super.init(nibName: String(describing: ARGBookViewController.self), bundle: Bundle(for: ARGBookViewController.self))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let identifier = String(describing: ARGDocumentCollectionViewCell.self)
        let nib = UINib(nibName: identifier, bundle: Bundle(for: ARGDocumentCollectionViewCell.self))
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        switch settings.scrollType {
        case .vertical:
            layout.scrollDirection = .vertical
            collectionView.isPagingEnabled = false
        default:
            layout.scrollDirection = .horizontal
            collectionView.isPagingEnabled = true
        }
        
        self.scrollController = ARGContiniousScrollController(scrollView: collectionView, delegate: self, scrollDirection: .vertical)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = self.view.bounds.size
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        self.scrollTo(interactor.currentNavigationPoint())
    }
    
    func scrollTo(_ navigationPoint: ARGBookNavigationPoint?) {
        if let navigationPoint = navigationPoint {
            if let documentIndex = book.documents.firstIndex(where: { (document) -> Bool in
                return document === navigationPoint.document
            }) {
                let targetIndexPath = IndexPath(item: documentIndex, section: 0)
                collectionView.scrollToItem(at: targetIndexPath, at: .top, animated: false)
                let cell = collectionView.cellForItem(at: targetIndexPath) as! ARGDocumentCollectionViewCell
                cell.documentView.scroll(to: navigationPoint)
            }
        }
    }
    
    func applyReadingSettings(_ settings: ARGBookReadingSettings) {
        if collectionView != nil {
            
            let visibleCells = collectionView.visibleCells
            
            for cell in visibleCells {
                if let cell = cell as? ARGDocumentCollectionViewCell {
                     cell.documentView.applyReadingSettings(settings)
                }
            }
        }
    }
    
}

extension ARGBookViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return book.documents.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ARGDocumentCollectionViewCell.self), for: indexPath) as! ARGDocumentCollectionViewCell

        let document = book.documents[indexPath.item]
        cell.documentView.reloadIfNeeded(document: document,
                                         settings: settings)
        
        scrollController.addNestedScrollView(cell.documentView.contentView.webView.scrollView)
        
        return cell
    }
    
}

extension ARGBookViewController: ARGContiniousScrollDelegate {
    
    public func visibleNestedScrollContainers(for scrollController: ARGContiniousScrollController) -> [UIView & ARGNestedContiniousScrollContainer]? {
        let views = collectionView.visibleCells.map { (cell) -> ARGBookDocumentView in
            let cell = cell as! ARGDocumentCollectionViewCell
            return cell.documentView
        }
        
        return views
    }
    
}
