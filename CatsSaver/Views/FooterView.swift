//
//  FooterView.swift
//  CatsSaver
//
//  Created by Egor on 09.09.2021.
//

import UIKit

class FooterView: UICollectionReusableView {
    
    private let catView: CatHeadView = {
        let view = CatHeadView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func configure() {
        backgroundColor = .none
        addSubview(catView)
        addConstraints()
    }
    
    func addConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(catView.widthAnchor.constraint(equalToConstant: 40))
        constraints.append(catView.heightAnchor.constraint(equalToConstant: 40))
        constraints.append(catView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10))
        constraints.append(catView.centerXAnchor.constraint(equalTo: self.centerXAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
}
