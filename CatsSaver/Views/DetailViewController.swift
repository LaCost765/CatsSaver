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
    
    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else { return }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Ошибка!", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Фото загружено", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
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
