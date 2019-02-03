//
//  UsersTableViewController.swift
//  liChat
//
//  Created by Simon on 2/2/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD


class UsersTableViewController: UITableViewController, UISearchResultsUpdating {
    
   

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    var allUsers: [FUser] = []
    var filteredUsers: [FUser] = []
    var allUsersGroupped = NSDictionary() as! [String:[FUser]]
    var sectionTitleList: [String] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Users"
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
    
        
        loadUsers(filter: kCITY)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if searchController.isActive && searchController.searchBar.text != ""{
            return 1
        }else{
            return allUsersGroupped.count
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
            return filteredUsers.count
            
        }else{
            
            //find section title
            let sectionTitle = self.sectionTitleList[section]
            
            //user for given title
            let users = self.allUsersGroupped[sectionTitle]
            return users!.count
        }
       
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
             user = filteredUsers[indexPath.row]
            
        }else{
            
            let sectionTitle = self.sectionTitleList[indexPath.section]
            
            let users = self.allUsersGroupped[sectionTitle]
            user = users![indexPath.row]
            
        }
        
        cell.generateCellWith(fUser: user, indexPath: indexPath)
        return cell
    }
    
    //MARK: Tableview datasource
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != ""{
            return ""
        }else{
            print(sectionTitleList[section])
            return sectionTitleList[section]
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != ""{
            
            return nil
        }else{
            return self.sectionTitleList
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return index
    }
    
    
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
    
    @IBAction func filterSegmentValueChanged(_ sender: Any) {
        switch filterSegmentedControl.selectedSegmentIndex {
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
    
    //MARK: Search controller functions
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        filteredUsers = allUsers.filter({ (user) -> Bool in
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
        
    }
    
    //MARK: Helper functions
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
        var str = NSMutableString(string: name)
        CFStringTransform(str, nil, kCFStringTransformToLatin, false)
        CFStringTransform(str, nil, kCFStringTransformStripDiacritics, false)
        return str.substring(to: 1)
    
    }
    
    


}
