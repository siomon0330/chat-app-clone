//
//  ProfileViewTableViewController.swift
//  liChat
//
//  Created by Simon on 2/2/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit

class ProfileViewTableViewController: UITableViewController {

    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var blockButtonOutlet: UIButton!
    @IBOutlet weak var callButtonOutlet: UIButton!
    @IBOutlet weak var messageButtonOutlet: UIButton!
    
    var user:FUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0{
            return 0
        }else{
            return 30
        }
    }
    
    //MARK:IBActions
    
    @IBAction func chatButtonPressed(_ sender: Any) {
    }
   
    @IBAction func callButtonPressed(_ sender: Any) {
    }
    
    @IBAction func blockButtonPressed(_ sender: Any) {
    }
    
    //MARK: setup UI
    func setupUI(){
        if user != nil{
            self.title = "Profile"
            fullNameLabel.text = user?.fullname
            phoneNumberLabel.text = user?.phoneNumber
            
            updateBlockStatus()
            
            imageFromData(pictureData: user!.avatar, withBlock: { (avatarImage) in
                
                if avatarImage != nil{
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
                
            })
        }
    }
    
    func updateBlockStatus(){
        
    }
    
}
