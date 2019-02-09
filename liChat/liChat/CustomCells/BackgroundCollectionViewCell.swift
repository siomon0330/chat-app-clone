//
//  BackgroundCollectionViewCell.swift
//  liChat
//
//  Created by Simon on 2/8/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit

class BackgroundCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(image:UIImage){
        self.imageView.image = image
    }
}
