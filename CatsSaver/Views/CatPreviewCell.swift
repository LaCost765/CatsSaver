//
//  CatPreviewCell.swift
//  CatsSaver
//
//  Created by Egor on 08.09.2021.
//

import UIKit

class CatPreviewCell: UICollectionViewCell {

    // MARK: - Свойства
    
    static let identifier = "CatPreviewCell"
    @IBOutlet weak var imageView: UIImageView!
    var data: PhotoData?
    
    // MARK: - Методы
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 15
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}
