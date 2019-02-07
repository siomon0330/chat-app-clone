//
//  IncomingMessages.swift
//  liChat
//
//  Created by Simon on 2/4/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessage{
    var collectionView:JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    //MARK: CreateMessage
    func createMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage?{
        var message: JSQMessage?
        let type = messageDictionary[kTYPE] as! String
        switch type {
        case kTEXT:
            message = createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
        
            message = createPictureMessage(messageDictionary: messageDictionary)
        case kVIDEO:
        
            print("video")
            
        case kAUDIO:
        
            print("audio")
        case kLOCATION:
        
            print("location")
        default:
            print("Unknown message type")
        }
        
        if message != nil{
            return message
        }else{
            return nil
        }
        
    }
    
    //MARK: Create message types
    func createTextMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage{
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        var date:Date!
        
        if let created = messageDictionary[kDATE]{
            if (created as! String).count != 14{
                date = Date()
            }else{
                date = dateFormatter().date(from: created as! String)
            }
        }else{
            date = Date()
        }
        
        let text = messageDictionary[kMESSAGE] as! String
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
        
    }
    
    
    func createPictureMessage(messageDictionary: NSDictionary) -> JSQMessage{
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        
        var date:Date!
        
        if let created = messageDictionary[kDATE]{
            if (created as! String).count != 14{
                date = Date()
            }else{
                date = dateFormatter().date(from: created as! String)
            }
        }else{
            date = Date()
        }
        
        
        let mediaItem = PhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutGoingStatusForUser(senderId: userId!)
        
        
        //download image
        downloadImage(imageUrl: messageDictionary[kPICTURE] as! String) { (image) in
            if image != nil{
                mediaItem?.image = image!
                self.collectionView.reloadData()
            }
        }
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    //MARK: Helper
    func returnOutGoingStatusForUser(senderId: String) -> Bool{
       
        return senderId == FUser.currentId()
    }
    
    
}









