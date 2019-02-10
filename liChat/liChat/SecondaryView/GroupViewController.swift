//
//  GroupViewController.swift
//  liChat
//
//  Created by Simon on 2/9/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit
import ProgressHUD

class GroupViewController: UIViewController {
    
    
    @IBOutlet weak var cameraButtonOutlet: UIImageView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var editButtonOutlet: UIButton!
    @IBOutlet var iconTapGesture: UITapGestureRecognizer!
    
    
    var group: NSDictionary!
    var groupIcon:UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraButtonOutlet.isUserInteractionEnabled = true
        cameraButtonOutlet.addGestureRecognizer(iconTapGesture)
        
        setupUI()
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title:"Invite Users", style:.plain, target: self, action:#selector(self.inviteUsers))]
        
    }

    //MARK: IBAction
    

    @IBAction func cameraIconTapped(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
    }
    
    @objc func inviteUsers(){
        
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "inviteUsersTableView") as! InviteUserTableViewController
        userVC.group = group
        self.navigationController?.pushViewController(userVC, animated: true)
        
    }
    
    //MARK: Helpers
    func setupUI(){
        self.title = "Group"
        groupNameTextField.text = group[kNAME] as? String
        imageFromData(pictureData: group[kAVATAR] as! String) { (image) in
            if image != nil{
                self.cameraButtonOutlet.image = image!.circleMasked
            }
        }
    }
    
    func showIconOptions(){
        let optionMenu = UIAlertController(title: "Choose group Icon", message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take/Choose Photo", style: .default) { (alert) in
            print("Camera")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        
        if groupIcon != nil{
            let resetAction = UIAlertAction(title: "Reset", style: .default, handler: { (alert) in
                self.groupIcon = nil
                self.cameraButtonOutlet.image = UIImage(named:"cameraIcon")
                self.editButtonOutlet.isHidden = true
            })
            
            optionMenu.addAction(resetAction)
        }
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancelAction)
        
        //for ipad not to crash
        if (UI_USER_INTERFACE_IDIOM() == .pad){
            if let currentPopoverpresentationController = optionMenu.popoverPresentationController{
                currentPopoverpresentationController.sourceView = editButtonOutlet
                currentPopoverpresentationController.sourceRect = editButtonOutlet.bounds
                
                currentPopoverpresentationController.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        }else{
            self.present(optionMenu, animated: true, completion: nil)
        }
        
        
        
        
        
    }
    
    
}
