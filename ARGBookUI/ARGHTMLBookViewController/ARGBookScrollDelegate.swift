//
//  ARGBookScrollDelegate.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 22.10.2020.
//

import UIKit
import ARGContinuousScroll

class ARGBookScrollDelegate: ARGContiniousScrollController {
    
    weak var bookView: ARGBookView?

     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        super.scrollViewDidEndDecelerating(scrollView)
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
