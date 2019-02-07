//
//  OutgoingMessages.swift
//  liChat
//
//  Created by Simon on 2/4/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import Foundation

class OutgoingMessages{
    let messageDictionary:NSMutableDictionary
    
    //MARK: Initializer
    //text message
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //picture message
    init(message: String, pictureLink: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        messageDictionary = NSMutableDictionary(objects: [message, pictureLink, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kPICTURE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    
    //MARK: send message
    
    func sendMessage(chatRoomId: String, messageDictionary: NSMutableDictionary, memberIds:[String], membersToPush:[String]){
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        
        for memberId in memberIds{
        reference(.Message).document(memberId).collection(chatRoomId).document(messageId).setData(messageDictionary as! [String : Any])
        }
        
        //update recent chat
        
        //send push notification
        
        
    }
    
    
    
}
