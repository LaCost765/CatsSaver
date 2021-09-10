//
//  DetailViewController.swift
//  CatsSaver
//
//  Created by Egor on 09.09.2021.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    private var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = self.image
        // Do any additional setup after loading the view.
    }
    
    func setImage(image: UIImage) {
        self.image = image
    }
}

extension DetailViewController: ZoomingViewController {
    func zoomingImageView(for transition: ZoomTransitionDelegate) -> UIImageView? {
        return imageView
    }
    
    func zoomingBackgroundView(for transition: ZoomTransitionDelegate) -> UIView? {
        return nil
    }
    
    
}
