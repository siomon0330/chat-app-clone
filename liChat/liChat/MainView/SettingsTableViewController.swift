//
//  SettingsTableViewController.swift
//  liChat
//
//  Created by Simon on 2/2/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit
import ProgressHUD

class SettingsTableViewController: UITableViewController {

    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var showAvatarStatusSwitch: UISwitch!
    
    @IBOutlet weak var versionLabel: UILabel!
    let userDefaults = UserDefaults.standard
    
    var avatarSwitchStatus = false
    var firstLoad : Bool?
    
    
    override func viewDidAppear(_ animated: Bool) {
        if FUser.currentUser() != nil{
            setupUI()
            loadUserDefaults()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.tableFooterView = UIView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if section ==  1{
            return 5
        }
        return 2
    }
    
    //TableView delegate
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        }
        
        return 30
    }
    
   
    //MARK: IBActions
    
    @IBAction func cleanCacheButtonPressed(_ sender: Any) {
        
        do{
            
            let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentsURL().path)
            for file in files{
                try FileManager.default.removeItem(atPath: "\(getDocumentsURL().path)/\(file)")
            }
            
            ProgressHUD.showSuccess("Cache cleaned.")
        }catch{
            ProgressHUD.showError("Couldn't clean media files, please try again")
        }
    }
   
    
    @IBAction func showAvatarSwitchValueChange(_ sender: UISwitch) {
        if sender.isOn{
            avatarSwitchStatus = true
        }else{
            avatarSwitchStatus = false
        }
        
        saveUserDefaults()
        
    }
    
    
    @IBAction func tellAFriendButtonPressed(_ sender: Any) {
        
        let text = "Hey! Let's chat on liChat \(kAPPURL)"
        let objectsToShare : [Any] = [text]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.setValue("Let's Chat on liChat", forKey: "subject")
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        
        FUser.logOutCurrentUser { (success) in
            if success {
                self.showLoginView()
            }
        }
    }
    
    
    
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        let optionMenu = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete the account?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (alert) in
            self.deleteUser()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            //cancel
        }
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        
        //for ipad not to crash
        if (UI_USER_INTERFACE_IDIOM() == .pad){
            if let currentPopoverpresentationController = optionMenu.popoverPresentationController{
                currentPopoverpresentationController.sourceView = deleteButtonOutlet
                currentPopoverpresentationController.sourceRect = deleteButtonOutlet.bounds
                currentPopoverpresentationController.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        }else{
            self.present(optionMenu, animated: true, completion: nil)
        }
        
    }
    
    
    func showLoginView(){
        
        let mainView = storyboard?.instantiateViewController(withIdentifier: "welcome")
        self.present(mainView!, animated: true, completion: nil)
    }
    
    //MARK: Setup UI
    func setupUI(){
        let currentUser = FUser.currentUser()
        fullNameLabel.text = currentUser?.fullname
        if currentUser?.avatar != ""{
            imageFromData(pictureData: currentUser!.avatar, withBlock: { (avatarImage) in
                if avatarImage != nil{
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            })
        }
        
        
        //set app version
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
            self.versionLabel.text = version
        }
        
    }
    
    
    //MARK:Delete User
    func deleteUser(){
        //delete locally
        userDefaults.removeObject(forKey: kPUSHID)
        userDefaults.removeObject(forKey: kCURRENTUSER)
        userDefaults.synchronize()
        
        //delete from firebase
        reference(.User).document(FUser.currentId()).delete()
        FUser.deleteUser { (error) in
            if error != nil{
                DispatchQueue.main.async {
                    ProgressHUD.showError("Counldn't delete user, please try again")
                }
                return
            }
            self.showLoginView()
        }
        
    }
    
    
    //MARK: UserDefaults
    func saveUserDefaults(){
        userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
        userDefaults.synchronize()
    }

    func loadUserDefaults(){
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        if !firstLoad!{
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
            userDefaults.synchronize()
        }
        avatarSwitchStatus = userDefaults.bool(forKey: kSHOWAVATAR)
        showAvatarStatusSwitch.isOn = avatarSwitchStatus
    }
}








