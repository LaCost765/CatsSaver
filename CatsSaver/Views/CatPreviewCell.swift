//
//  CatPreviewCell.swift
//  CatsSaver
//
//  Created by Egor on 08.09.2021.
//

import UIKit

class CatPreviewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 15
        // Initialization code
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}
