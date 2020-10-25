//
//  ARGBookScrollDelegate.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 22.10.2020.
//

import UIKit
import ARGContinuousScroll

class ARGBookScrollDelegate: NSObject, UIScrollViewDelegate {
    
    var scrollController: ARGContiniousScrollController
    weak var navigationDelegate: ARGBookNavigationDelegate?
    
    init(scrollController: ARGContiniousScrollController, navigationDelegate: ARGBookNavigationDelegate?) {
        self.scrollController = scrollController
        self.navigationDelegate = navigationDelegate
        
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDidFinish()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollDidFinish()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollDidFinish()
        }
    }
    
    func scrollDidFinish() {
//        if let visibleViews = (scrollController.sortedContainers() ?? nil) as? [ARGBookDocumentView] {
//            if let documentView = visibleViews.first, let navigationDelegate = navigationDelegate {
//                if let navigationPoint = documentView.contentView.layoutManager?.navigationLogic.navigationPoint {
//                    navigationDelegate.currentNavigationPointDidChange(navigationPoint)
//                }
//                
//            }
//        }
    }
    
}
