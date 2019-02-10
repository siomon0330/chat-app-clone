//
//  InviteUserTableViewController.swift
//  liChat
//
//  Created by Simon on 2/9/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase



class InviteUserTableViewController: UITableViewController, UserTableViewCellDelegate{
  
    
    
    
    @IBOutlet weak var headerView: UIView!
    
    var allUsers: [FUser] = []
    var allUsersGroupped = NSDictionary() as! [String:[FUser]]
    var sectionTitleList: [String] = []
    
    var newMemberIds:[String] = []
    var currentMemberIds:[String] = []
    var group:NSDictionary!
    
    override func viewWillAppear(_ animated: Bool) {
        loadUsers(filter: kCITY)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ProgressHUD.dismiss()
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Users"
        tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title:"Done", style:.done, target:self, action:#selector(self.doneButtonPressed))]
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        currentMemberIds = group[kMEMBERS] as! [String]
    }

    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.allUsersGroupped.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = self.sectionTitleList[section]
        let users = self.allUsersGroupped[sectionTitle]
        return users!.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell

        let sectionTitle = self.sectionTitleList[indexPath.section]
        
        let users = self.allUsersGroupped[sectionTitle]
        
        
        cell.generateCellWith(fUser: users![indexPath.row], indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    //MARK: Tableview datasource
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sectionTitleList[section]
        
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
       
        return self.sectionTitleList
        
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return index
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let users = self.allUsersGroupped[sectionTitle]
        let selectedUser = users![indexPath.row]
        
        if currentMemberIds.contains(selectedUser.objectId){
            ProgressHUD.showError("Already in the group!")
            return
        }
        
        if let cell = tableView.cellForRow(at: indexPath){
            if cell.accessoryType == .checkmark{
                cell.accessoryType = .none
            }else{
                cell.accessoryType = .checkmark
            }
        }
        
        //add/remove users
        let selected = newMemberIds.contains(selectedUser.objectId)
        
        if selected{
            //remove
            let objectIndex = newMemberIds.index(of: selectedUser.objectId)!
            newMemberIds.remove(at: objectIndex)
        }else{
            //add to array
            newMemberIds.append(selectedUser.objectId)
        }
        
        print("new memebers \(newMemberIds)")
        print("current member \(currentMemberIds)")
        
        self.navigationItem.rightBarButtonItem?.isEnabled = newMemberIds.count > 0
        
    }
    
    
    
    //MARK:Load Users
    func loadUsers(filter:String){
        
        ProgressHUD.show()
        var query: Query!
        
        switch filter {
            
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
            
        case kCOUNTRY:
            query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country).order(by: kFIRSTNAME, descending: false)
            
        default:
            query = reference(.User).order(by: kFIRSTNAME, descending: false)
        }
        
        query.getDocuments { (snapShot, error) in
            self.allUsers = []
            self.sectionTitleList = []
            self.allUsersGroupped = [:]
            
            if error != nil{
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            
            guard let snapShot = snapShot else{
                ProgressHUD.dismiss()
                return
            }
            
            if !snapShot.isEmpty{
                for userDictionary in snapShot.documents{
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    
                    if fUser.objectId != FUser.currentId(){
                        self.allUsers.append(fUser)
                    }
                }
                
                //split to group
                self.splitDataIntoSections()
                self.tableView.reloadData()
                
            }
            
            
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
        
    }
    

    

    //MARK: IBActions
    @IBAction func filterSegmentValueChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            loadUsers(filter: kCITY)
        case 1:
            loadUsers(filter: kCOUNTRY)
        case 2:
            loadUsers(filter: "")
        default:
            return
        }
    }
    
    @objc func doneButtonPressed(){
        updateGroup(group: group)
    }
    
    
    //MARK: Users TableviewCell Delegate
    func didTapAvatarImage(indexPath: IndexPath) {
        
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
       
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let users = self.allUsersGroupped[sectionTitle]
        
        profileVC.user = users![indexPath.row]
        
        self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
   
    //MARK: Helper functions
    
    func updateGroup(group: NSDictionary){
        let tempMembers = currentMemberIds + newMemberIds
        let tempMembersToPush = group[kMEMBERSTOPUSH] as! [String] + newMemberIds
        let withValues = [kMEMBERS:tempMembers, kMEMBERSTOPUSH:tempMembersToPush]
        Group.updateGroup(groupId: group[kGROUPID] as! String, withValues: withValues)
        createRecentForNewMembers(groupId: group[kGROUPID] as! String, groupName: group[kNAME] as! String, membersToPush: tempMembersToPush, avatar: group[kAVATAR] as! String)
        updateExistingRecentWithNewValues(chatRoomId: group[kGROUPID] as! String, members: tempMembers, withValues: withValues)
        goToGroupChat(membersToPush: tempMembersToPush, members: tempMembers)
        
    }
    
    func goToGroupChat(membersToPush: [String], members:[String]){
        
    }
    
    
    fileprivate func splitDataIntoSections(){
        var sectionTitle:String = ""
        
        for i in 0..<self.allUsers.count {
            let currentUser = self.allUsers[i]
            
            //let firstChar = currentUser.firstname.first!
            let firstChar = pingying(name: currentUser.firstname).uppercased()
            let firstCharString = "\(String(describing: firstChar))"
            
            if firstCharString != sectionTitle{
                sectionTitle = firstCharString
                self.allUsersGroupped[sectionTitle] = []
                self.sectionTitleList.append(sectionTitle)
            }
            self.allUsersGroupped[firstCharString]?.append(currentUser)
            
        }
        
    }
    
    func pingying(name: String) -> String{
        let str = NSMutableString(string: name)
        CFStringTransform(str, nil, kCFStringTransformToLatin, false)
        CFStringTransform(str, nil, kCFStringTransformStripDiacritics, false)
        return str.substring(to: 1)
        
    }
    
    

}





