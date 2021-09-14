//
//  DetailViewModel.swift
//  CatsSaver
//
//  Created by Egor on 10.09.2021.
//

import Foundation
import RxRelay
import Kingfisher

/// - Нужно для удобства определения того, откуда мы пришли на DetailViewController
enum DetailSource {
    case favorites
    case search
}

class DetailViewModel {
    
    // MARK: - Cвойства
    
    let source: DetailSource
    let data: PhotoData
    
    // MARK: - Инициализаторы
    
    init(photoData: PhotoData, source: DetailSource) {
        self.data = photoData
        self.source = source
    }
    
    // MARK: - Методы
    
    func savePhotoToDisk(completion: Selector?, completionTarget: Any) {
        switch source {
        case .favorites:
            saveToDiskFromRealm(completion: completion, completionTarget: completionTarget)
        case .search:
            saveToDiskFromCache(completion: completion, completionTarget: completionTarget)
        }
    }
    
    private func saveToDiskFromCache(completion: Selector?, completionTarget: Any) {
        ImageCache.default.retrieveImage(forKey: data.link) { result in
            switch result {
            case .success(let value):
                guard let image = value.image else { return }
                UIImageWriteToSavedPhotosAlbum(image, completionTarget, completion, nil)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func saveToDiskFromRealm(completion: Selector?, completionTarget: Any) {
        guard let photo = RealmManager.instance.getObject(type: PhotoModel.self, key: data.id) else {
            print("Can not find object of type PhotoModel with id: \(data.id)")
            return
        }
        guard let data = photo.data,
              let image = KFCrossPlatformImage.init(data: data) else { return }
        UIImageWriteToSavedPhotosAlbum(image, completionTarget, completion, nil)
    }
    
    func favoritesButtonTapped(completionForAdd: @escaping (Result<String, Error>) -> Void,
                               completionForDelete: @escaping () -> Void) {
        switch source {
        case .favorites:
            deleteFromFavorites(completion: completionForDelete)
        case .search:
            addToFavorites(completion: completionForAdd)
        }
    }
    
    private func deleteFromFavorites(completion: () -> Void) {
        
        RealmManager.instance.remove(type: PhotoModel.self, key: data.id)
        completion()
    }
    
    
    private func addToFavorites(completion: @escaping (Result<String, Error>) -> Void) {
        
        ImageCache.default.retrieveImage(forKey: data.link) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                guard let image = value.image else { return }
                let model = PhotoModel(id: self.data.id, link: self.data.link)
                model.data = image.pngData()
                RealmManager.instance.write(object: model)
                completion(.success("Фото добавлено в избранные!"))
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
}
