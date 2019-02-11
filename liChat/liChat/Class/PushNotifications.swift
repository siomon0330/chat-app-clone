//
//  PushNotifications.swift
//  liChat
//
//  Created by Simon on 2/10/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import Foundation
import OneSignal



func sendPushNotification(memberToPush: [String], message: String){
    
    let updatedMembers = removeCurrentUserFromMembersArray(members: memberToPush)
    
    getMembersToPush(members: updatedMembers) { (userPushIds) in
        let currentUser = FUser.currentUser()!
//        OneSignal.postNotification(["Contents": ["en" : "\(currentUser.fullname) \n \(message)"], "ios_badgeType":"Increase", "ios_badgeCount":"1", "include_player_ids": userPushIds])
        
    //     OneSignal.postNotification(["contents": ["en": "Test Message"], "include_player_ids": userPushIds])
        
        
        
        
       
        
        OneSignal.postNotification(["contents": ["en" : "\(currentUser.fullname) \n \(message)"], "ios_badgeType":"Increase", "ios_badgeCount":"1", "include_player_ids": userPushIds], onSuccess: { ([AnyHashable : Any]?) in



        }) { (error) in
            print("..........................")
            print("\(error!.localizedDescription)")
        }
  }
    
   
}

func removeCurrentUserFromMembersArray(members:[String]) -> [String]{
    var updatedMembers:[String] = []
    for memberId in members{
        if memberId != FUser.currentId(){
            updatedMembers.append(memberId)
        }
    }
    return updatedMembers
}

func getMembersToPush(members:[String], completion: @escaping (_ usersArray:[String]) -> Void){
    var pushIds : [String] = []
    var count = 0
    for memberId in members{
        reference(.User).document(memberId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else{
                completion(pushIds)
                return
            }
            if snapshot.exists{
                let userDictionary = snapshot.data() as! NSDictionary
                let fUser = FUser(_dictionary: userDictionary)
                pushIds.append(fUser.pushId!)
                count += 1
                
                if members.count == count{
                    completion(pushIds)
                }
                
            }else{
                completion(pushIds)
                return
            }
        }
    }
    
}
