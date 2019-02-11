//
//  Encryption.swift
//  liChat
//
//  Created by Simon on 2/10/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import Foundation
import RNCryptor

class ENcryption{
    class func encryptText(chatRoomId:String, message: String) -> String{
        let data = message.data(using: String.Encoding.utf8)
        let encryptedData = RNCryptor.encrypt(data: data!, withPassword: chatRoomId)
        return encryptedData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
        
    }
    class func decryptText(chatRoomId:String, encryptMessage: String) -> String {
        let decryptor = RNCryptor.Decryptor(password: chatRoomId)
        let encryptedData = NSData(base64Encoded: encryptMessage, options: NSData.Base64DecodingOptions(rawValue:0))
        var message : NSString = ""
        if encryptedData != nil{
            do{
                let decryptedData = try decryptor.decrypt(data: encryptedData! as Data)
                message = NSString(data: decryptedData, encoding: String.Encoding.utf8.rawValue)!
            }catch{
                print("error decrypting text \(error.localizedDescription)")
            }
        }
        return message as String
    }
}
