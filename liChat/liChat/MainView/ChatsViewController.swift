//
//  ChatsViewController.swift
//  liChat
//
//  Created by Simon on 2/2/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    var recentListner: ListenerRegistration!
    
    override func viewWillAppear(_ animated: Bool) {
        loadRecentChats()
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListner.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setTableViewHeader()
    }

   
    
    //MARK: IBActions
   
    @IBAction func createNewChatButtonPressed(_ sender: Any) {
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersTableView") as! UsersTableViewController
        self.navigationController?.pushViewController(userVC, animated: true)
        
    }
    
    
    //MARK: TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentChatTableViewCell
        
        let recent = recentChats[indexPath.row]
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        
        return cell
    }
    
    
    //MARK: load Recent chats
    func loadRecentChats(){
        
        
        recentListner = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else{
                return
            }
            
            self.recentChats = []
            if !snapshot.isEmpty{
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                for recent in sorted{
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil{
                        self.recentChats.append(recent)
                    }
                }
                
                self.tableView.reloadData()
            }
        })
        
    }
    
    //MARK: Custom tablebview header
    func setTableViewHeader(){
        let headerView = UIView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.size.width, height: 45))
        let buttonView = UIView(frame: CGRect(x:0, y:5, width: UIScreen.main.bounds.size.width, height: 35))
        let groupButton = UIButton(frame: CGRect(x:UIScreen.main.bounds.size.width-110, y:10, width: 100, height: 20))
        groupButton.addTarget(self, action: #selector(self.groupButtonPressed), for: .touchUpInside)
        groupButton.setTitle("New Group", for: .normal)
        let buttonColor = #colorLiteral(red: 0.1249395534, green: 0.4856737256, blue: 0.8982468247, alpha: 1)
        groupButton.setTitleColor(buttonColor, for: .normal)
        
        let lineView = UIView(frame: CGRect(x:0, y:headerView.frame.height-1, width: UIScreen.main.bounds.size.width, height: 1))
        lineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        buttonView.addSubview(groupButton)
        headerView.addSubview(buttonView)
        headerView.addSubview(lineView)
        tableView.tableHeaderView = headerView
        
//
//        print(buttonView.frame.width)
//        print(headerView.frame.width)
//        print(tableView.frame.width)
//        print(UIScreen.main.bounds.size.width)
        
    
        
        
    }
    
    @objc func groupButtonPressed(){
        
    }
    
}













