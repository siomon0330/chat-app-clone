//
//  UserTableViewCell.swift
//  liChat
//
//  Created by Simon on 2/2/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit


protocol UserTableViewCellDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}

class UserTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    var indexPath: IndexPath!
    var delegate: UserTableViewCellDelegate?
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tapGestureRecognizer.addTarget(self, action: #selector(self.avatarTap))
        
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func generateCellWith(fUser: FUser, indexPath: IndexPath) {
        
        self.indexPath = indexPath
        
        self.fullNameLabel.text = fUser.fullname
        if fUser.avatar != ""{
            imageFromData(pictureData: fUser.avatar, withBlock: { (avatarImage) in
                if avatarImage != nil{
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
                
            })
        }
        
    }
    
    @objc func avatarTap(){
        
        delegate!.didTapAvatarImage(indexPath: indexPath)
    }
    
    
    
    

}
