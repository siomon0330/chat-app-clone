//
//  GroupMemberCollectionViewCell.swift
//  liChat
//
//  Created by Simon on 2/8/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit

protocol GroupMemberCollectionViewCellDelegate {
    func didClickDeleteButton(indexPath: IndexPath)
}

class GroupMemberCollectionViewCell: UICollectionViewCell {
    var indexPath: IndexPath!
    var delegate: GroupMemberCollectionViewCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    
   
    @IBOutlet weak var imageView: UIImageView!
    func generateCell(user: FUser, indexPath: IndexPath){
        self.indexPath = indexPath
        nameLabel.text = user.fullname
        if user.avatar != ""{
            imageFromData(pictureData: user.avatar, withBlock: { (image) in
                if image != nil{
                    self.imageView.image = image!.circleMasked
                }
            })
        }
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate!.didClickDeleteButton(indexPath: indexPath)
    }
    
}
