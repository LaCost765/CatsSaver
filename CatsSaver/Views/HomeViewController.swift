//
//  HomeViewController.swift
//  CatsSaver
//
//  Created by Egor on 08.09.2021.
//

import UIKit
import RxCocoa
import Kingfisher

class HomeViewController: UIViewController {
    
    let viewModel = HomeViewModel()
    var selectedIndexPath: IndexPath!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.rx.setDelegate(self)
        collectionView.register(FooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FooterView")
        viewModel.loadNewPhotos()
        viewModel.dataSection.bind(to: collectionView.rx.items(dataSource: viewModel.dataSource))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
                  let image = cell.imageView.image,
                  let dest = segue.destination as? DetailViewController else { return }
            
            dest.setImage(image: image)
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
        selectedIndexPath = indexPath
    }
}

extension HomeViewController: ZoomingViewController {
    func zoomingImageView(for transition: ZoomTransitionDelegate) -> UIImageView? {
        if let indexPath = selectedIndexPath {
            let cell = collectionView.cellForItem(at: indexPath) as! CatPreviewCell
            return cell.imageView
        }
        
        return nil
    }
    
    func zoomingBackgroundView(for transition: ZoomTransitionDelegate) -> UIView? {
        return nil
    }
    
    
}


