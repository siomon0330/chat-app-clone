//
//  BackgroundCollectionViewController.swift
//  liChat
//
//  Created by Simon on 2/8/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit
import ProgressHUD

private let reuseIdentifier = "Cell"

class BackgroundCollectionViewController: UICollectionViewController {
    var backgrounds:[UIImage] = []
    let userDefaults = UserDefaults.standard
    
    private let imageNamesArr = ["bg0","bg1","bg2","bg3","bg4","bg5","bg6","bg7","bg8","bg9","bg10", "bg11"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageArray()
        self.navigationItem.largeTitleDisplayMode = .never
        
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(self.resetToDefault))
        self.navigationItem.rightBarButtonItem = resetButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return backgrounds.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BackgroundCollectionViewCell
        cell.generateCell(image: backgrounds[indexPath.row])
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        userDefaults.set(imageNamesArr[indexPath.row], forKey: kBACKGROUBNDIMAGE)
        userDefaults.synchronize()
        ProgressHUD.showSuccess("Set!")
    }
    
    //MARK: IBActions
    @objc func resetToDefault(){
        userDefaults.removeObject(forKey: kBACKGROUBNDIMAGE)
        userDefaults.synchronize()
        ProgressHUD.showSuccess("Reset!")
    }

    //MARK: Helpers
    func setupImageArray(){
        for imageName in imageNamesArr{
            let image = UIImage(named:imageName)
            if image != nil{
                backgrounds.append(image!)
            }
        }
    }
    

}
