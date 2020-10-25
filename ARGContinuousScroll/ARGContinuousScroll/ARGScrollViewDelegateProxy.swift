//
//  ARGScrollViewDelegateProxy.swift
//  ARGContinuousScroll
//
//  Created by Sergei Polshcha on 21.10.2020.
//

import UIKit

public class ARGScrollViewDelegateProxy: NSObject, UIScrollViewDelegate {
    
    var delegates: [NSObject & UIScrollViewDelegate] = [NSObject & UIScrollViewDelegate]()
    
    public func addDelegate(_ delegate: NSObject & UIScrollViewDelegate) {
        delegates.append(delegate)
    }
    
    public func removeDelegate(_ delegate: UIScrollViewDelegate) {
        delegates = delegates.filter {!$0.isEqual(delegate)}
    }
    
    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        for delegate in delegates {
            if delegate.responds(to: aSelector) {
                return delegate
            }
        }
        
        return super.forwardingTarget(for: aSelector)
    }
    
    public override func responds(to aSelector: Selector!) -> Bool {
        for delegate in delegates {
            if delegate.responds(to: aSelector) {
                return true
            }
        }
        
        return false
    }
    
}
