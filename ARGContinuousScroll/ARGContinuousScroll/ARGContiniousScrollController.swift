//
//  ARGContiniousScrollController.swift
//  ARGView
//
//  Created by Sergei Polshcha on 08.10.2020.
//  Copyright © 2020 Argentum. All rights reserved.
//

import UIKit

@objc public enum ARGContinuousScrollPosition: Int {
    case begin
    case end
}

@objc public enum ARGContinuousScrollDirection: Int {
    case horizontal
    case vertical
}

@objc public protocol ARGContiniousScrollDelegate: class {
    
    func visibleNestedScrollContainers(for scrollController: ARGContiniousScrollController) -> [UIView & ARGNestedContiniousScrollContainer]?
    
}

@objc public protocol ARGNestedContiniousScrollContainer: class {
    
    func nestedScrollView(for scrollController: ARGContiniousScrollController) -> UIScrollView
    
    func nestedScrollViewContentReady(for scrollController: ARGContiniousScrollController) -> Bool
    
    func nestedScrollViewDesiredScrollPosition(_ position: ARGContinuousScrollPosition)
}

@objc open class ARGContiniousScrollController: NSObject {
    var mainScrollView: UIScrollView!
    var scrollDirection: ARGContinuousScrollDirection!
    //var nestedScrollViews: [UIScrollView] = []
    var panGestureRecognizer: UIPanGestureRecognizer!
    var previousOffset: CGFloat = 0
    
    var mainScrollEnabled: Bool = true
    var nestedScrollEnabled: Bool = true
    
    var frameToFix: CGRect? {
        didSet {
            if frameToFix != nil && !mainScrollView.arg_onBegin(direction: scrollDirection)  && !mainScrollView.arg_onEnd(direction: scrollDirection) {
                mainScrollView.setContentOffset(frameToFix!.origin, animated: false)
            }
        }
    }
    
    @objc public weak var delegate: ARGContiniousScrollDelegate?
    
    var proxyDelegate: ARGScrollViewDelegateProxy!
    
    @objc public init(scrollView: UIScrollView, delegate: ARGContiniousScrollDelegate, scrollDirection: ARGContinuousScrollDirection) {
        super.init()
        
        mainScrollView = scrollView
        //proxyDelegate = ARGScrollViewDelegateProxy()
        mainScrollView.delegate = self
        //proxyDelegate.add(self)
        
        self.delegate = delegate
        
        self.scrollDirection = scrollDirection
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        panGestureRecognizer.delegate = self
        //scrollView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc public func addNestedScrollView(_ scrollView: UIScrollView) {
//        if !nestedScrollViews.contains(scrollView) {
//            nestedScrollViews.append(scrollView)
            scrollView.delegate = self
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.view == mainScrollView {
            let isForwardDirection = recognizer.velocity(in: mainScrollView).y < 0
            //print("main scroll direction: " + (isForwardDirection ? "forward" : "backward"))
        } else {
            let isForwardDirection = recognizer.velocity(in: mainScrollView).y < 0
            //print("nested scroll direction: " + (isForwardDirection ? "forward" : "backward"))
        }
    }
    
    func pointCoordinate(_ point: CGPoint) -> CGFloat {
        if scrollDirection == .horizontal {
            return point.x
        } else {
            return point.y
        }
    }
    
    func sizeDimension(_ size: CGSize) -> CGFloat {
        if scrollDirection == .horizontal {
            return size.width
        } else {
            return size.height
        }
    }

}

extension ARGContiniousScrollController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ARGContiniousScrollController: UIScrollViewDelegate {
    
    func sortedContainers(isForwardDirection: Bool) -> [UIView & ARGNestedContiniousScrollContainer]? {
        //sort containers in ascending order (left to right or up to down)
        let nestedScrollContainers = delegate?.visibleNestedScrollContainers(for: self)?.sorted(by: { (container1, container2) -> Bool in
            let point1 = container1.convert(container1.frame.origin, to: mainScrollView)
            let point2 = container2.convert(container2.frame.origin, to: mainScrollView)
            return pointCoordinate(point1) < pointCoordinate(point2)
        })
        
        //check are all containers really visible
//        if let firstContainer = nestedScrollContainers?.first, let lastContainer = nestedScrollContainers?.last {
//            let frame1 = firstContainer.convert(firstContainer.frame, to: mainScrollView)
//            let frame2 = lastContainer.convert(lastContainer.frame, to: mainScrollView)
//            let viewPortRect = CGRect(origin: mainScrollView.contentOffset, size: mainScrollView.frame.size)
//
//            if !frame1.intersects(viewPortRect) || !frame2.intersects(viewPortRect) {
//                print(" \(firstContainer) and \(lastContainer) are not visible \(nestedScrollContainers?.count)")
//                return nil
//            }
            
//            if isForwardDirection {
//                if !frame2.intersects(viewPortRect) {
//                    return nil
//                }
////                if pointCoordinate(point2) <= 0 || pointCoordinate(point2) >= sizeDimension(viewPortRect.size) {
////                    return nil
////                }
//            } else {
//                if !frame1.intersects(viewPortRect) {
//                    return nil
//                }
////                if pointCoordinate(point1) + sizeDimension(firstContainer.frame.size) <= 0 || pointCoordinate(point1) + sizeDimension(firstContainer.frame.size) >= sizeDimension(viewPortRect.size) {
////                    return nil
////                }
//            }
//        }
        
        let viewPortRect = CGRect(origin: mainScrollView.contentOffset, size: mainScrollView.frame.size)
        
        return nestedScrollContainers?.filter({ (container) -> Bool in
            let frame = container.convert(container.frame, to: mainScrollView)
            return frame.intersects(viewPortRect)
        })
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainScrollView {
            let forwardDirection = pointCoordinate(scrollView.contentOffset) - previousOffset > 0
            previousOffset = pointCoordinate(scrollView.contentOffset)
            
            if let nestedScrollContainers = sortedContainers(isForwardDirection: forwardDirection) {
                print("visible now: \(nestedScrollContainers)")
                
                let offsetRemainder = Int(pointCoordinate(scrollView.contentOffset)) % Int(sizeDimension(scrollView.bounds.size))
                let pagingTreshold = 15
                
                for containerView in nestedScrollContainers {
                    let offsetNearToPageEdge = (offsetRemainder < pagingTreshold || offsetRemainder > Int(sizeDimension(scrollView.bounds.size)) - pagingTreshold)
                    containerView.nestedScrollView(for: self).isScrollEnabled = offsetNearToPageEdge
                    //print("nested scrollView \(offsetNearToPageEdge ? "unlock" : "lock")")
                }
                
                //if mainScrollEnabled {
                    //var targetFrame: CGRect? = nil;

                    if (forwardDirection) {
                        if let firstContainer = nestedScrollContainers.first {
                            if !firstContainer.nestedScrollViewContentReady(for: self) || !firstContainer.nestedScrollView(for: self).arg_onEnd(direction: scrollDirection) {
                                frameToFix = firstContainer.convert(firstContainer.frame, to: mainScrollView) ;
                            }
                        }
                        
                        if let lastContainer = nestedScrollContainers.last, !lastContainer.isEqual(nestedScrollContainers.first) {
                            lastContainer.nestedScrollViewDesiredScrollPosition(.begin)
                        }
                    } else {
                        if let lastContainer = nestedScrollContainers.last {
                            if !lastContainer.nestedScrollViewContentReady(for: self) ||
                                (!lastContainer.nestedScrollView(for: self).arg_onBegin(direction: scrollDirection) && !mainScrollView.arg_onEnd(direction: scrollDirection)) {
                                frameToFix = lastContainer.convert(lastContainer.frame, to: mainScrollView)
                            }
                        }
                        
                        if let firstContainer = nestedScrollContainers.first, !firstContainer.isEqual(nestedScrollContainers.last) {
                            firstContainer.nestedScrollViewDesiredScrollPosition(.end)
                        }
                    }

//                    if targetFrame != nil {
//                        mainScrollEnabled = false;
//                        mainScrollFixedOffset = targetFrame!.origin;
//                       // print("lock main scrollView")
//                    }
               // }
            }
        } else {
            if scrollView.arg_onBegin(direction: scrollDirection) || scrollView.arg_onEnd(direction: scrollDirection) {
                //mainScrollEnabled = true
                frameToFix = nil
                //print("unlock main scrollView")
            }
        }
        
//        if !mainScrollEnabled && !mainScrollView.arg_onBegin(direction: scrollDirection)  && !mainScrollView.arg_onEnd(direction: scrollDirection) {
//            mainScrollView.setContentOffset(mainScrollFixedOffset, animated: false)
//        }
    }
}

extension UIScrollView {
    func arg_onBegin(direction: ARGContinuousScrollDirection) -> Bool {
        return direction == .horizontal ? contentOffset.x <= 0 : contentOffset.y <= 0
    }
    
    func arg_onEnd(direction: ARGContinuousScrollDirection) -> Bool {
        return direction == .horizontal ? contentOffset.x >= contentSize.width - bounds.size.width : contentOffset.y >= contentSize.height - bounds.size.height
    }
}
