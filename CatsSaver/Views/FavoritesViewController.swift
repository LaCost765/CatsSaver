//
//  FavoritesViewController.swift
//  CatsSaver
//
//  Created by Egor on 10.09.2021.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift
import RxRealm

class FavoritesViewController: UIViewController {

    // MARK: - Свойства
    
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedImageView: UIImageView?
    let bag = DisposeBag()
    
    // MARK: - Методы
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        
        // Биндим коллекцию на реалм
        let realm = try! Realm()
        let photos = realm.objects(PhotoModel.self)
        Observable.collection(from: photos)
            .bind(to: collectionView.rx.items(
                    cellIdentifier: CatPreviewCell.identifier,
                   cellType: CatPreviewCell.self)
            ) { (row, model, cell) in
                guard let data = model.data else { return }
                DispatchQueue.main.async {
                    cell.data = PhotoData(id: model.id, link: model.link)
                    cell.imageView.image = UIImage(data: data)
                }
            }.disposed(by: bag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            guard let cell = sender as? CatPreviewCell,
                  let dest = segue.destination as? DetailViewController,
                  let data = cell.data else { return }

            // Обязательно конфигурим DetailsViewController, прежде чем на него переходить
            dest.configure(source: .favorites, photoData: data, image: cell.imageView.image)
        }
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width / 2 - 10, height: collectionView.frame.height / 3 - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CatPreviewCell
        selectedImageView = cell.imageView
    }
}

extension FavoritesViewController: ZoomingViewController {
    func zoomingImageView(for transition: ZoomTransitionDelegate) -> UIImageView? {
        return selectedImageView
    }
    
    func zoomingBackgroundView(for transition: ZoomTransitionDelegate) -> UIView? {
        return nil
    }
}

