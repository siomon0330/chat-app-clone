//
//  FinishRegistrationViewController.swift
//  liChat
//
//  Created by Simon on 1/31/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit
import ProgressHUD

class FinishRegistrationViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var coutryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var email:String!
    var password:String!
    var avatarImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: IBActions
    @IBAction func cancelButtonPress(_ sender: Any) {
        
        cleanTextFields()
        dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPress(_ sender: Any) {
        
        dismissKeyboard()
        ProgressHUD.show("Registering...")
        
        if nameTextField.text != "" && surnameTextField.text != "" &&
        coutryTextField.text != "" && cityTextField.text != "" &&
            phoneNumberTextField.text != ""{
            
            FUser.registerUserWith(email: email, password: password, firstName: nameTextField.text!, lastName: surnameTextField.text!, completion: { (error) in
                
                if error != nil{
                    ProgressHUD.dismiss()
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                }
                
                self.registerUser()
                
                
            })
            
        }else{
            ProgressHUD.showError("All fields are required")
        }
        
    }
    
    //MARK: Helpers
    func registerUser(){
        let fullName = nameTextField.text! + " " + surnameTextField.text!
        
        var tempDictionary : Dictionary = [kFIRSTNAME : nameTextField.text!,
                                           kLASTNAME : surnameTextField.text!,
                                           kFULLNAME : fullName,
                                           kCOUNTRY : coutryTextField.text!,
                                           kCITY : cityTextField.text!,
                                           kPHONE : phoneNumberTextField.text!]
                                           as [String : Any]
        if avatarImage == nil{
            imageFromInitials(firstName: nameTextField.text!, lastName: surnameTextField.text!,
                              withBlock: { (avatarInitials) in
                                
                                let avatarIMG = UIImageJPEGRepresentation(avatarInitials, 0.7)
                                let avatar = avatarIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
                                tempDictionary[kAVATAR] = avatar
            
                                self.finishRegistration(withValues: tempDictionary)
                                //finish registration
            })
        }else{
            
            let avatarData = UIImageJPEGRepresentation(avatarImage!, 0.7)
            let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
            tempDictionary[kAVATAR] = avatar
            
            self.finishRegistration(withValues: tempDictionary)
            //finish registration
            
        }
        
        
    }
    
    func finishRegistration(withValues: [String:Any]) {
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if error != nil{
                DispatchQueue.main.async {
                    ProgressHUD.showError(error?.localizedDescription)
                }
                return
            }
            
            ProgressHUD.dismiss()
            //go to app
            self.goToApp()
            
        }
    }
    
    func goToApp(){
        cleanTextFields()
        dismissKeyboard()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID: FUser.currentId()])
        
        let mainView = storyboard?.instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        self.present(mainView, animated: true, completion: nil)
        
    }
    
    
    func dismissKeyboard(){
        self.view.endEditing(false)
    }
    
    func cleanTextFields(){
        nameTextField.text = ""
        surnameTextField.text = ""
        coutryTextField.text = ""
        cityTextField.text = ""
        phoneNumberTextField.text = ""
    }
    
}
