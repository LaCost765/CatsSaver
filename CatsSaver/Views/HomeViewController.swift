//
//  HomeViewController.swift
//  CatsSaver
//
//  Created by Egor on 08.09.2021.
//

import UIKit
import RxCocoa
import Kingfisher
import RxSwift

class HomeViewController: UIViewController {
    
    // MARK: - Свойства
    
    let viewModel = HomeViewModel()
    var selectedImageView: UIImageView? // нужно, чтобы при переходе на DetailViewController предоставить изображение для протокола ZoomingViewController
    let bag = DisposeBag()
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Методы
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Биндим коллекцию к источнику данных во viewModel
        collectionView.rx.setDelegate(self).disposed(by: bag)
        collectionView.register(FooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FooterView")
        viewModel.loadNewPhotos()
        viewModel.dataSection.bind(to: collectionView.rx.items(dataSource: viewModel.dataSource)).disposed(by: bag)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Используется, чтобы подгрузить новую страницу, когда коллекцию проскроллили до конца вниз. Высота футера - 50, соответственно, если опустились ниже - значит уже видим значок загрузки, значит грузим данные
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            guard let self = self else { return }
            let difference = maximumOffset - currentOffset
            
            if difference <= 50 {
                self.viewModel.loadNewPhotos()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            guard let cell = sender as? CatPreviewCell,
                  let index = collectionView.indexPath(for: cell),
                  let dest = segue.destination as? DetailViewController else { return }

            // Получаем данные для того, чтобы нужным образом сконфигурировать экран детализации фото кота
            let data = viewModel.section.items[index.item]
            dest.configure(source: .search, photoData: data, image: cell.imageView.image)
        }
    }
}
 

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width / 2 - 10, height: collectionView.frame.height / 3 - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CatPreviewCell
        selectedImageView = cell.imageView
    }
}

extension HomeViewController: ZoomingViewController {
    
    func zoomingImageView(for transition: ZoomTransitionDelegate) -> UIImageView? {
        return selectedImageView
    }
    
    func zoomingBackgroundView(for transition: ZoomTransitionDelegate) -> UIView? {
        return nil
    }
}


