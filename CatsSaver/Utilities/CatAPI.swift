//
//  CatAPI.swift
//  CatsSaver
//
//  Created by Egor on 14.09.2021.
//

import Foundation

enum CatAPI: String {
    
    case urlValue = "https://api.thecatapi.com/v1/images/search"
    
    enum HeaderData: String {
        case key = "x-api-key"
        case pagination = "pagination-count"
    }
    
    enum BodyData: String {
        case limit
        case page
        case order
    }
}
