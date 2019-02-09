//
//  BlockedUsersViewController.swift
//  liChat
//
//  Created by Simon on 2/8/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit
import ProgressHUD


class BlockedUsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UserTableViewCellDelegate {
   
    
    @IBOutlet weak var tableView: UITableView!
    var blockedUserArray:[FUser] = []
    @IBOutlet weak var notificationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        navigationItem.largeTitleDisplayMode = .never
        loadUsers()

        // Do any additional setup after loading the view.
    }

    //MARK: TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notificationLabel.isHidden = blockedUserArray.count != 0
        return blockedUserArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        cell.delegate = self
        cell.generateCellWith(fUser: blockedUserArray[indexPath.row], indexPath: indexPath)
        
        return cell
    }
    
    //MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Unblock"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        var tempBlockedUsers = FUser.currentUser()!.blockedUsers
        let userIdToUnblock = blockedUserArray[indexPath.row].objectId
        tempBlockedUsers.remove(at: tempBlockedUsers.index(of: userIdToUnblock)!)
        blockedUserArray.remove(at: indexPath.row)
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID:tempBlockedUsers]) { (error) in
            if error != nil{
                ProgressHUD.showError(error?.localizedDescription)
            }
            tableView.reloadData()
        }
    }
    
    //MARK: load bloced users
    func loadUsers(){
        
        if FUser.currentUser()!.blockedUsers.count > 0{
            ProgressHUD.show()
            getUsersFromFirestore(withIds: FUser.currentUser()!.blockedUsers, completion: { (allBlockedUsers) in
                ProgressHUD.dismiss()
                self.blockedUserArray = allBlockedUsers
                self.tableView.reloadData()
            })
        }
    }
    
    //MARK: UserTableViewCell delegate
    func didTapAvatarImage(indexPath: IndexPath) {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
        profileVC.user = blockedUserArray[indexPath.row]
        self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    

}
