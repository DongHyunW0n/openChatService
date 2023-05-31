//
//  MessageEntity.swift
//  ppakcoding-todo
//
//  Created by WonDongHyun on 2023/05/30.
//

import Foundation
import FirebaseDatabase

struct MessageEntity {
    var refId : String
    var senderID : String
    var senderNickname : String
    var message : String
    var createdAt : String
    
    init(_ snapshot: DataSnapshot){
        
        let value = snapshot.value as? NSDictionary
        
        self.refId = snapshot.key
        self.senderID =  value?["senderID"] as? String ?? ""
        self.senderNickname =  value?["senderID"] as? String ?? ""
        self.message =  value?["senderID"] as? String ?? ""
        self.createdAt =  value?["senderID"] as? String ?? ""

       
    }
}
