//
//  SettingsTableViewController.swift
//  liChat
//
//  Created by Simon on 2/2/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return 3
    }

   
    //MARK: IBActions
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        
        FUser.logOutCurrentUser { (success) in
            if success {
                self.showLoginView()
            }
        }
    }
    
    func showLoginView(){
        
        let mainView = storyboard?.instantiateViewController(withIdentifier: "welcome")
        self.present(mainView!, animated: true, completion: nil)
    }
    

}
