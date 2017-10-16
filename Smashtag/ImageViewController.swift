//
//  ImageViewController.swift
//  Cassini
//
//  Created by User on 13.10.2017.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController
{
    // MARK: User Interface
    
    @IBOutlet weak var scrollView: UIScrollView!
    {
        didSet {
            // to zoom we have to handle viewForZooming(in scrollView:)
            scrollView.delegate = self
            
            // and we must set our minimum and maximum zoom scale
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 3.0
            
            // most important thing to set in UIScrollView is contentSize
            scrollView.contentSize = imageView.frame.size
            scrollView.addSubview(imageView)
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBAction func toRootViewController(_ sender: UIBarButtonItem) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    
    fileprivate var imageView = UIImageView()
    
    var image : UIImage? {
        get {return imageView.image}
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
            autoZoomed = true
            zoomScaleToFit()
        }
    }
    
    // MARK: Private Implementation
    
    private func fetchImage() {
        autoZoomed = true
        if let url = imageURL {
            // this next line of code can throw an error
            // and it also will block the UI entirely while access the network
            // we really should be doing it in a separate thread
            spinner?.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async {
                [weak self] in
                let urlContents = try? Data(contentsOf: url)
                
                if let imageData = urlContents, url == self?.imageURL {
                    DispatchQueue.main.async {
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //imageURL = DemoURL.stanford  // for demo/testing purposes only
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil { // we're about to appear on screen so, if needed,
            fetchImage() // fetch image
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        zoomScaleToFit()
    }

    // MARK: Model
    
    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil { // if we're on screen
                fetchImage()        // then fetch image
            }
        }
    }
    
    fileprivate var autoZoomed = true
    
    private func zoomScaleToFit() {
        if !autoZoomed {return}
        if let sv = scrollView, image != nil &&
            (imageView.bounds.size.width > 0) &&
            (scrollView.bounds.size.width > 0) {
            let widhtRatio = scrollView.bounds.size.width / self.imageView.bounds.size.width
            let heightRatio = scrollView.bounds.size.height / self.imageView.bounds.size.height
            sv.zoomScale = (widhtRatio > heightRatio) ? widhtRatio : heightRatio
            sv.contentOffset = CGPoint(x: (imageView.frame.size.width - sv.frame.size.width) / 2, y: (imageView.frame.size.height - sv.frame.size.height) / 2)
        }
    }
}

// MARK: UIScrollViewDelegate
// Extension which makes ImageViewController conform to UIScrollViewDelegate
// Handles viewForZooming(in scrollView:)
// by returning the UIImageView as the view to transform when zooming

extension ImageViewController : UIScrollViewDelegate
{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        autoZoomed = false
    }
}
