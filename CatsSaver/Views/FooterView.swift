//
//  FooterView.swift
//  CatsSaver
//
//  Created by Egor on 09.09.2021.
//

import UIKit

class FooterView: UICollectionReusableView {
        
    private let spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = .orange
        return view
    }()
    
    func configure() {
        backgroundColor = .none
        addSubview(spinner)
        spinner.startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        spinner.frame = bounds
    }
}
