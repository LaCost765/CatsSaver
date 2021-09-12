//
//  PhotoModel.swift
//  CatsSaver
//
//  Created by Egor on 10.09.2021.
//

import Foundation
import RealmSwift

class PhotoModel: Object {
    
    @objc dynamic var id: String
    @objc dynamic var link: String
    @objc dynamic var data: Data?
    
    init(id: String, link: String) {
        self.id = id
        self.link = link
    }
    
    override init() {
        self.id = ""
        self.link = ""
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
