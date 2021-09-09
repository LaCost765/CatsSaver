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

struct SectionOfCustomData {
    var header: String
    var items: [Item]
}
extension SectionOfCustomData: SectionModelType {
    typealias Item = String
    
    init(original: SectionOfCustomData, items: [Item]) {
        self = original
        self.items = items
    }
    
    mutating func appendNewItem(item: Item) {
        
        items.append(item)
    }
}

class HomeViewModel {
    
    let dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfCustomData>(
        configureCell: { dataSource, collectionView, indexPath, link in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatPreviewCell", for: indexPath) as? CatPreviewCell else { return UICollectionViewCell()}
            
            let url = URL(string: link)
            cell.imageView.kf.indicatorType = .activity
            cell.imageView.kf.setImage(with: url,
                                       options: [
                                        .transition(.fade(0.2))])
            return cell
        }) { _, collectionView, kind, indexPath in
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterView", for: indexPath) as! FooterView
        view.configure()
        return view
    }

    
    let dataSection: BehaviorRelay<[SectionOfCustomData]>
    private var section: SectionOfCustomData
    
    init() {
        dataSection = BehaviorRelay<[SectionOfCustomData]>(value: [])
        section = SectionOfCustomData(header: "", items: [])
    }
    
    func loadNewPhotos() {
        
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
    
    private var pages: [Int]?
    private var inProgress = false
    private func loadNewPage(page: Int) {
        
        if !inProgress {
            inProgress = true
            let headers: HTTPHeaders = [
                "x-api-key": "f0ebf856-c45c-486d-8869-a65d01297783"
            ]
            let params: Parameters = [
                "limit": 20,
                "page": page,
                "order": "ASC"
            ]
            
            NetworkManager.shared.makeRequest(url: "https://api.thecatapi.com/v1/images/search",
                                              params: params,
                                              headers: headers) { data in
                ParserJSON.getLinksForPictures(from: data)
                    .subscribe(onNext: { [weak self] link in
                        guard let self = self else { return }
                        self.section.appendNewItem(item: link)
                        self.dataSection.accept([self.section])
                    }, onCompleted: { [weak self] in
                        guard let self = self else { return }
                        self.inProgress = false
                    })
            }
        }
    }
    
    func getPages(completion: @escaping ([Int]) -> Void) {
        let headers: HTTPHeaders = [
            "x-api-key": "f0ebf856-c45c-486d-8869-a65d01297783"
        ]
        let params: Parameters = [
            "limit": 1,
        ]
        
        NetworkManager.shared.makeRequest(url: "https://api.thecatapi.com/v1/images/search",
                                          params: params,
                                          headers: headers)
        { (responseHeaders: [AnyHashable : Any]) in
            
            guard let value = responseHeaders["pagination-count"] as? String,
                  let paginationCount = Int(value) else { return }
            
            let pagesCount = paginationCount / 20
            completion(Array(0..<pagesCount).shuffled())
        }
    }
}
