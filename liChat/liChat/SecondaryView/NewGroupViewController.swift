 //
//  NewGroupViewController.swift
//  liChat
//
//  Created by Simon on 2/8/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker

 class NewGroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, GroupMemberCollectionViewCellDelegate, ImagePickerDelegate {

    @IBOutlet weak var editAvatarButtonOutlet: UIButton!
    @IBOutlet weak var groupIconImageView: UIImageView!
    @IBOutlet weak var groupSubjectTextField: UITextField!
    @IBOutlet weak var participantLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var memberIds:[String] = []
    var allMemebers:[FUser] = []
    var groupIcon : UIImage?
    
    @IBOutlet var iconTapGuesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        groupIconImageView.isUserInteractionEnabled = true
        groupIconImageView.addGestureRecognizer(iconTapGuesture)
        
        updateParticipantLabel()
    }

    
    //MARK: CollectionView datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMemebers.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! GroupMemberCollectionViewCell
        cell.delegate = self
        cell.generateCell(user: allMemebers[indexPath.row], indexPath: indexPath)
        return cell
    }
    
    //MARK: IBActions
    @objc func createButtonPressed(_ sender: Any){
        
        if groupSubjectTextField.text != ""{
            
            memberIds.append(FUser.currentId())
            
            let avatarData = UIImageJPEGRepresentation(UIImage(named:"groupIcon")!, 0.7)!
            var avatar = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
            
            if groupIcon != nil{
                let avatarData = UIImageJPEGRepresentation(groupIcon!, 0.4 )!
                avatar = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
            }
            
            let groupId = UUID().uuidString
            
            //create group
            let group = Group(groupId: groupId, subject: groupSubjectTextField.text!, ownerId: FUser.currentId(), members: memberIds, avatar: avatar)
            
            group.saveGroup()
            
            //create group recent
            startGroupChat(group: group)
            
            let chatVC = ChatViewController()
            chatVC.titleName = group.groupDictionary[kNAME] as? String
            chatVC.memberIds = group.groupDictionary[kMEMBERS] as! [String]
            chatVC.membersToPush = group.groupDictionary[kMEMBERSTOPUSH] as! [String]
            chatVC.chatRoomId = groupId
            chatVC.isGroup = true
            
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
            
            
        }else{
            ProgressHUD.showError("Name is required")
        }
    }
    
    
    
    @IBAction func groupIconTaped(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        showIconOptions()
        
    }
    
    
    
    
    //MARK: GroupMemberCollectionviewCell Delegate
    func didClickDeleteButton(indexPath: IndexPath) {
        allMemebers.remove(at: indexPath.row)
        memberIds.remove(at: indexPath.row)
        
        self.collectionView.reloadData()
        
        updateParticipantLabel()
        
    }
    
    //MARK: Helpers
    func showIconOptions(){
        let optionMenu = UIAlertController(title: "Choose group Icon", message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Take/Choose Photo", style: .default) { (alert) in
            let imagePicker = ImagePickerController()
            imagePicker.delegate = self
            imagePicker.imageLimit = 1
            self.present(imagePicker, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        
        if groupIcon != nil{
            let resetAction = UIAlertAction(title: "Reset", style: .default, handler: { (alert) in
                self.groupIcon = nil
                self.groupIconImageView.image = UIImage(named:"cameraIcon")
                self.editAvatarButtonOutlet.isHidden = true
            })
            
            optionMenu.addAction(resetAction)
        }
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancelAction)
        
        //for ipad not to crash
        if (UI_USER_INTERFACE_IDIOM() == .pad){
            if let currentPopoverpresentationController = optionMenu.popoverPresentationController{
                currentPopoverpresentationController.sourceView = editAvatarButtonOutlet
                currentPopoverpresentationController.sourceRect = editAvatarButtonOutlet.bounds
                
                currentPopoverpresentationController.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        }else{
            self.present(optionMenu, animated: true, completion: nil)
        }
        
        
        
        
        
    }
    
    
    
    func updateParticipantLabel(){
        participantLabel.text = "Participates: \(allMemebers.count)"
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title:"Create", style:.plain, target: self, action: #selector(self.createButtonPressed))]
        self.navigationItem.rightBarButtonItem?.isEnabled = allMemebers.count > 0
    }
    
    
    //MARK: ImagePicker Delegate
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 0{
            self.groupIcon = images.first!
            self.groupIconImageView.image = self.groupIcon!.circleMasked
            self.editAvatarButtonOutlet.isHidden = false
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
 
 
 
 
 
