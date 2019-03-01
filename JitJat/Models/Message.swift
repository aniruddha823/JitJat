//
//  Message.swift
//  JitJat
//
//  Created by Aniruddha Prabhu on 2/26/19.
//  Copyright © 2019 Aniruddha Prabhu. All rights reserved.
//

import Foundation
import UIKit

struct Message {
    let text : String
    let senderID : String
    let timestamp : Double
    let isIncomingMessage : Bool
    var senderName : String?
    let conversationKey : String?
    var profilePictureURL : String?
}
