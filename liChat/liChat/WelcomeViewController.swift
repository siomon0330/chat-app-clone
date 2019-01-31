//
//  WelcomeViewController.swift
//  liChat
//
//  Created by Simon on 1/31/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //MARK: IBActions
    
    @IBAction func loginButtonPress(_ sender: Any) {
        dismissKeyboard()
        
    }
    
    @IBAction func registerButtonPress(_ sender: Any) {
        dismissKeyboard()
    }
    
    @IBAction func backgroundTap(_ sender: Any) {
        dismissKeyboard()
    }
    
    //MARK: HelperFunctions
    
    func dismissKeyboard(){
        self.view.endEditing(false)
    }
    
    func cleanTextFields(){
        emailTextField.text = ""
        passwordTextField.text = ""
        repeatPasswordTextField.text = ""
    }
    
    
    
}
