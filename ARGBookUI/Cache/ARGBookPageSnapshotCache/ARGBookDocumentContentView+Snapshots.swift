//
//  ARGBookDocumentContentView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 20.11.2020.
//

import Foundation

class TestImage: UIImage {
    deinit {
        print("deinit image")
    }
}

extension ARGBookDocumentContentView {
    
    func createSnapshots(for document: ARGBookDocument, at page: Int, pageCount: Int, snapshots: [UIImage]? = nil, completionHandler: (([UIImage]?) -> Void)? = nil) {
        if page < pageCount {
            let navigationPoint = ARGBookNavigationPointInternal(document: document, position: CGFloat(page) / CGFloat(pageCount))
            
            scroll(to: navigationPoint) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let config = WKSnapshotConfiguration()
                    
                    if #available(iOS 13.0, *) {
                        config.afterScreenUpdates = true
                    } else {}
                    
                    self.webView.takeSnapshot(with: config) { (image, error) in
                        if let image = image {
                            var newSnapshots = snapshots ?? [UIImage]()
                            newSnapshots.append(TestImage(cgImage: image.cgImage!))
                            
                            self.createSnapshots(for: document,
                                                 at: page + 1,
                                                 pageCount: pageCount,
                                                 snapshots: newSnapshots,
                                                 completionHandler: completionHandler)
                        } else {
                            completionHandler?(snapshots)
                        }
                    }
                }
            }
        } else {
            completionHandler?(snapshots)
        }
    }
    
    func takeSnapshots(completionHandler: (([UIImage]?) -> Void)? = nil) {
        if let document = documentLoader.document {
            let settings = (layoutManager?.layout as! ARGBookDocumentSettingsControllerContainer).settingsController.settings!
            let ContentSizeContainerType =  document.layoutType(for: settings.scrollType) as! ARGBookDocumentContentSizeContainer.Type
            let pageSize = ContentSizeContainerType.pageSize(for: bounds.size,
                                                             settings: settings,
                                                             sizeClass: traitCollection.horizontalSizeClass)
            let pageCount = ContentSizeContainerType.pageCount(for: webView.scrollView.contentSize, pageSize: pageSize)
            
            createSnapshots(for: document, at: 0, pageCount: pageCount, completionHandler: completionHandler)
        }
        
    }
    
}
