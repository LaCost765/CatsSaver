//
//  DetailViewController.swift
//  CatsSaver
//
//  Created by Egor on 09.09.2021.
//

import UIKit
import AVFoundation
import Kingfisher
import RxSwift
import RealmSwift
import RxRealm

class DetailViewController: UIViewController {
    
    // MARK: - Свойства
    
    @IBOutlet weak var favoritesButton: UIBarButtonItem! // Кнопка может работать в двух режимах - добавить в избранное и удалить из избранного. Зависит от того, с какого экрана мы попали на этот вью контроллер. Из избранного - значит удаление, из поиска - добавление
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var viewModel: DetailViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            switch viewModel.source {
            case .search:
                self.favoritesButton.image = UIImage(systemName: "star")
            case .favorites:
                self.favoritesButton.image = UIImage(systemName: "trash")
            }
        }
    }
    
    // MARK: - Методы
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
    }

    /// - Метод конфигурации вью контроллера, который обязательно должен быть вызван перед его отображением
    func configure(source: DetailSource, photoData: PhotoData, image: UIImage?) {
        
        viewModel = DetailViewModel(photoData: photoData, source: source)
        guard let image = image else { return }
        let aspectFitRect = AVMakeRect(aspectRatio: image.size, insideRect: self.view.bounds)
        self.imageView.frame = aspectFitRect
        self.imageView.image = image
    }
    
    @IBAction func save(_ sender: UITabBarItem) {
        
        guard let viewModel = viewModel else { return }
        viewModel.savePhotoToDisk(completion: #selector(self.image(_:didFinishSavingWithError:contextInfo:)), completionTarget: self)
    }
    
    @IBAction func favoritesButtonTapped(_ sender: UITabBarItem) {
        guard let viewModel = viewModel else { return }
        viewModel.favoritesButtonTapped { result in
            let ac = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            switch result {
            case .success(let message):
                ac.title = message
            case .failure(let error):
                ac.title = "Ошибка!"
                ac.message = error.localizedDescription
            }
            DispatchQueue.main.async { [weak self] in
                self?.present(ac, animated: true)
            }
        } completionForDelete: { [weak self] in
            self?.imageView.image = nil
            self?.navigationController?.popViewController(animated: true)
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
