//
//  HomeViewModel.swift
//  CatsSaver
//
//  Created by Egor on 08.09.2021.
//

import Foundation
import RxSwift
import RxDataSources
import RxRelay
import Alamofire
import Kingfisher

class HomeViewModel {
    
    // MARK: - Cвойства
    
    let dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfCustomData>(
        configureCell: { dataSource, collectionView, indexPath, data in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CatPreviewCell.identifier, for: indexPath) as? CatPreviewCell else { return UICollectionViewCell()}
            
            let url = URL(string: data.link)
            DispatchQueue.main.async {
                cell.imageView.kf.indicatorType = .activity
                cell.imageView.kf.setImage(with: url,
                                           options: [
                                            .processor(DownsamplingImageProcessor(size: cell.imageView.frame.size)),
                                            .scaleFactor(UIScreen.main.scale),
                                            .cacheOriginalImage,
                                            .originalCache(ImageCache.default)])
            }
            return cell
        }) { _, collectionView, kind, indexPath in
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterView", for: indexPath) as! FooterView
        view.configure()
        return view
    }
    
    let bag = DisposeBag()
    let dataSection: BehaviorRelay<[SectionOfCustomData]>
    private(set) var section: SectionOfCustomData
    private var pages: [Int]?
    private var inProgress = false // Отслеживает, запущен ли уже в данный момент процесс загрузки фотографий с сервера, чтобы не допустить создания нескольких запросов одновременно
    
    // MARK: - Инициализаторы
    
    init() {
        dataSection = BehaviorRelay<[SectionOfCustomData]>(value: [])
        section = SectionOfCustomData(header: "", items: [])
    }
    
    // MARK: - Методы
    
    func loadNewPhotos() {
                
        if !inProgress {
            inProgress = true
            if pages == nil {
                getPages { [weak self] pages in
                    guard let self = self else { return }
                    self.pages = pages
                    self.loadNewPage(page: self.pages!.removeLast())
                }
            } else {
                self.loadNewPage(page: self.pages!.removeLast())
            }
        }
    }
    
    /// - Загружает 20 фотографий с указанной страницы. Количество страниц определяется после вызова метода getPages, а сами страницы храняется в pages
    private func loadNewPage(page: Int) {
        
        let headers: HTTPHeaders = [
            CatAPI.HeaderData.key.rawValue: "f0ebf856-c45c-486d-8869-a65d01297783"
        ]
        let params: Parameters = [
            CatAPI.BodyData.limit.rawValue: 20,
            CatAPI.BodyData.page.rawValue: page,
            CatAPI.BodyData.order.rawValue: "ASC"
        ]
        
        NetworkManager.shared.makeRequest(url: CatAPI.urlValue.rawValue,
                                          params: params,
                                          headers: headers) { data in
            _ = ParserJSON.getPhotosData(from: data)
                .subscribe(onNext: { [weak self] data in
                    guard let self = self else { return }
                    self.section.appendNewItem(item: data)
                    self.dataSection.accept([self.section])
                }, onCompleted: { [weak self] in
                    guard let self = self else { return }
                    self.inProgress = false
                })
        }
    }
    
    /// - Метод нужен для того, чтобы определить, сколько в данный момент на сервере есть фотографий и сколько нужно страниц, чтобы отобразить их все по 20 штук
    func getPages(completion: @escaping ([Int]) -> Void) {
        let headers: HTTPHeaders = [
            CatAPI.HeaderData.key.rawValue: "f0ebf856-c45c-486d-8869-a65d01297783"
        ]
        let params: Parameters = [
            CatAPI.BodyData.limit.rawValue: 1
        ]
        
        NetworkManager.shared.makeRequest(url: CatAPI.urlValue.rawValue,
                                          params: params,
                                          headers: headers)
        { (responseHeaders: [AnyHashable : Any]) in
            
            guard let value = responseHeaders[CatAPI.HeaderData.pagination.rawValue] as? String,
                  let paginationCount = Int(value) else { return }
            
            let pagesCount = paginationCount / 20
            completion(Array(0..<pagesCount).shuffled())
        }
    }
}


/// - Тип для источника данных таблицы. Такой вид у него, потому что этот источник ориентирован на работу с секциями. В моем случае секция 1ы
struct SectionOfCustomData {
    var header: String
    var items: [Item]
}

extension SectionOfCustomData: SectionModelType {
    typealias Item = PhotoData
    
    init(original: SectionOfCustomData, items: [Item]) {
        self = original
        self.items = items
    }
    
    mutating func appendNewItem(item: Item) {
        items.append(item)
    }
}

struct PhotoData {
    let id: String
    let link: String
}
