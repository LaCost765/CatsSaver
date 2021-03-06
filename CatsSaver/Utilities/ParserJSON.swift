//
//  ParserJSON.swift
//  CatsSaver
//
//  Created by Egor on 08.09.2021.
//

import Foundation
import RxSwift
import SwiftyJSON

class ParserJSON {
    
    static func getPhotosData(from jsonData: Data) -> Observable<PhotoData> {
        
        return Observable<PhotoData>.create { observer -> Disposable in
            
            let disposable = Disposables.create()
            let json = JSON(jsonData)
            guard let catsData = json.array else { return disposable }
            
            catsData.forEach { obj in
                if let url = obj["url"].string,
                   let id = obj["id"].string {
                    observer.onNext(PhotoData(id: id, link: url))
                }
            }
            observer.onCompleted()
            return disposable
        }
    }
}
