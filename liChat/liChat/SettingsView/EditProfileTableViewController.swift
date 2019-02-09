//
//  EditProfileTableViewController.swift
//  liChat
//
//  Created by Simon on 2/8/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit
import ProgressHUD

class EditProfileTableViewController: UITableViewController {

    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet var avatarTapGestureRecognizer: UITapGestureRecognizer!
    var avatarImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        setupUI()
       
    }

   
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    //MARK: IBACtion
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if firstNameTextField.text != "" && lastNameTextField.text != "" && emailTextField.text != ""{
            ProgressHUD.show("Saving...")
            //block save button
            saveButtonOutlet.isEnabled = false
            
            let fullName = firstNameTextField.text! + " " + lastNameTextField.text!
            var withValues = [kFIRSTNAME:firstNameTextField.text!, kLASTNAME: lastNameTextField.text!, kFULLNAME: fullName]
            if avatarImage != nil{
                let avatarData = UIImageJPEGRepresentation(avatarImage!, 0.7)
                let avatarString = avatarData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
                withValues[kAVATAR] = avatarString
            }
            //update current user
            updateCurrentUserInFirestore(withValues: withValues, completion: { (error) in
                if error != nil{
                    DispatchQueue.main.async {
                        ProgressHUD.showError(error?.localizedDescription)
                        print("couldn't update user \(error?.localizedDescription)")
                    }
                    self.saveButtonOutlet.isEnabled = true
                    return
                }
                ProgressHUD.showSuccess("Saved")
                self.saveButtonOutlet.isEnabled = true
                self.navigationController?.popViewController(animated: true)
            })
        }else{
            ProgressHUD.showError("All fields are required!")
        }
    }
    
    
    @IBAction func avatarTap(_ sender: Any) {
        print("show iamge picker")
    }
    
    
    //MARK: Setup UI
    
    func setupUI(){
        let currentUser = FUser.currentUser()!
        avatarImageView.isUserInteractionEnabled = true
        firstNameTextField.text = currentUser.firstname
        lastNameTextField.text = currentUser.lastname
        emailTextField.text = currentUser.email
        
        if currentUser.avatar != ""{
            imageFromData(pictureData: currentUser.avatar, withBlock: { (image) in
                if image != nil{
                    self.avatarImageView.image =  image!.circleMasked
                }
                
            })
        }
        
    }

    

}
