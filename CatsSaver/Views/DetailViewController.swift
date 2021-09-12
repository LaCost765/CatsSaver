//
//  DetailViewController.swift
//  CatsSaver
//
//  Created by Egor on 09.09.2021.
//

import UIKit
import AVFoundation
import Kingfisher
import RxRealm
import RealmSwift
import RxSwift

class DetailViewController: UIViewController {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private var model: PhotoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
    }
    
    func configure(model: PhotoModel, image: UIImage?) {
        
        self.model = model
        guard let image = image else { return }
        let aspectFitRect = AVMakeRect(aspectRatio: image.size, insideRect: self.view.bounds)
        self.imageView.frame = aspectFitRect
        self.imageView.image = image
    }
    
    @IBAction func save(_ sender: UITabBarItem) {
        
        guard let model = model else { return }
        ImageCache.default.retrieveImage(forKey: model.link) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                guard let image = value.image else { return }
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func addToFavorites(_ sender: UITabBarItem) {
        guard let model = model else { return }
        ImageCache.default.retrieveImage(forKey: model.link) { result in
            switch result {
            case .success(let value):
                guard let image = value.image else { return }
                let modelCopy = PhotoModel(id: model.id, link: model.link)
                modelCopy.data = image.pngData()
                Observable.from(object: modelCopy)
                    .subscribe(Realm.rx.add())
                print(Realm.Configuration.defaultConfiguration.fileURL!)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
