//
//  RealmManager.swift
//  CatsSaver
//
//  Created by Egor on 14.09.2021.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let instance = RealmManager()
    
    private init() { }
    
    func write<T: Object>(object: T) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(object, update: .modified)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func remove<Element, KeyType>(type: Element.Type, key: KeyType) where Element: Object {
        DispatchQueue.global(qos: .userInitiated).async {
            
            do {
                let realm = try Realm()
                guard let object = realm.object(ofType: type, forPrimaryKey: key)
                else { return }
                
                try realm.write {
                    realm.delete(object)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getObject<Element, KeyType>(type: Element.Type, key: KeyType) -> Element? where Element: Object {
    
        do {
            let realm = try Realm()
            return realm.object(ofType: type, forPrimaryKey: key)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
