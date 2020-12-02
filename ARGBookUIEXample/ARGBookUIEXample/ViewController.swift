//
//  ViewController.swift
//  ARGBookUIEXample
//
//  Created by Sergei Polshcha on 18.10.2020.
//

import UIKit
import ARGBookUI

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var bookView: ARGBookUI.ARGBookView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var progressView: UIProgressView!
    
    var book: Book!
    
    var cacheObserver: NSObjectProtocol?
    
    lazy var settings: [ReadingSettings] = {
        let settings1 = ReadingSettings()
        settings1.fontSize = 150
        //settings1.hyphenation = false

        let settings2 = ReadingSettings()
        settings2.fontSize = 120
        settings2.scrollType = .vertical
        
        let settings3 = ReadingSettings()
        settings3.fontSize = 120
        settings3.horizontalMargin = 0
        settings3.verticalMargin = 5
        settings3.hyphenation = false
        settings3.alignment = .left
        settings3.twoColumnsLayout = true
        
        let settings4 = ReadingSettings()
        settings4.fontSize = 200
        settings4.horizontalMargin = 0
        settings4.verticalMargin = 0
        settings4.hyphenation = false
        settings4.scrollType = .vertical
        settings4.alignment = .left
        
        return [settings1, settings2, settings3, settings4]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookView.navigationDelegate = self
        
        let documents = [
            Document(filePath: "moby-dick/OPS/chapter_001.xhtml"),
            Document(filePath: "moby-dick/OPS/chapter_002.xhtml"),
            Document(filePath: "moby-dick/OPS/chapter_003.xhtml"),
            Document(filePath: "moby-dick/OPS/chapter_004.xhtml"),
            Document(filePath: "moby-dick/OPS/chapter_005.xhtml"),
            Document(filePath: "moby-dick/OPS/chapter_006.xhtml"),
            Document(filePath: "moby-dick/OPS/chapter_007.xhtml"),
            Document(filePath: "moby-dick/OPS/chapter_008.xhtml"),
            Document(filePath: "moby-dick/OPS/chapter_009.xhtml"),
            Document(filePath: "moby-dick/OPS/chapter_010.xhtml"),
        ]
        
        book = Book(directory: "moby-dick/", documents: documents)
        
        bookView.load(book: book)
        bookView.apply(settings: settings[0])
        
        if let currentPoint = book.currentNavigationPoint {
            bookView.scroll(to: currentPoint)
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapRecognizer.delegate = self
        bookView.addGestureRecognizer(tapRecognizer)
        
        cacheObserver = NotificationCenter.default.addObserver(forName: ARGBookContentSizeCache.progressDidChangeNotification, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            if let progress = self?.bookView.pageCounter?.contentSizeCache.progress {
                self?.progressView.isHidden = progress == 1.0
                self?.progressView.progress = Float(progress)
                self?.slider.isHidden = progress < 1.0
                self?.pageLabel.isHidden = progress < 1.0
                
                if progress == 1.0 {
                    self?.slider.minimumValue = 1
                    self?.slider.maximumValue = Float(self?.bookView.pageCounter?.pageCount ?? 0)
                    
                    if let navigationPoint = self?.bookView.currentNavigationPoint {
                        self?.refreshSlider(for: navigationPoint)
                    } else {
                        self?.refreshSlider(for: NavigationPoint(document: documents[0], position: 0))
                    }
                }
            }
            
        }
    }
    
    @objc func tapAction(_ gesture: UIGestureRecognizer) {
        settingsView.isHidden = !settingsView.isHidden
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func settingsButtonAction(_ sender: UIButton) {
        let settings = self.settings[sender.tag]
        bookView.apply(settings: settings)
    }
}

extension ViewController: ARGBookNavigationDelegate {
    
    func refreshSlider(for point: ARGBookNavigationPoint) {
        if let page = self.bookView.pageCounter?.page(for: point), page.globalPageNumber > 0 {
            self.slider.value = Float(page.globalPageNumber)
            pageLabel.text = "Page " + String(page.globalPageNumber) + " from " + String(bookView.pageCounter?.pageCount ?? 0)
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        if let point = bookView.pageCounter?.point(for: Int(slider.value)) {
            refreshSlider(for: point)
        }
    }
    
    @IBAction func pageSliderTouchCancel(_ sender: Any) {
        slidingDidFinish()
    }
    
    @IBAction func pageSliderTouchUpInside(_ sender: Any) {
        slidingDidFinish()
    }
    
    @IBAction func pageSliderTouchUpOutside(_ sender: Any) {
        slidingDidFinish()
    }
    
    @IBAction func pageSliderTouchDragExit(_ sender: Any) {
        slidingDidFinish()
    }
    
    func slidingDidFinish() {
        if let point = bookView.pageCounter?.point(for: Int(slider.value)) {
            bookView.scroll(to: point)
        }
    }
    
    func currentNavigationPointDidChange(_ navigationPoint: ARGBookNavigationPoint) {
        book?.currentNavigationPoint = navigationPoint
        self.refreshSlider(for: navigationPoint)
        print("write navigationPoint: \(URL(fileURLWithPath: navigationPoint.document.filePath).lastPathComponent) - \(navigationPoint.position)")
    }
    
}

