//
//  ConversationCell.swift
//  JitJat
//
//  Created by Aniruddha Prabhu on 2/26/19.
//  Copyright © 2019 Aniruddha Prabhu. All rights reserved.
//

import Foundation
import UIKit

class ConversationCell: UITableViewCell {
    
    var message : Message? {
        didSet {
            nameLabel.text = message?.senderName
            messageLabel.text = message?.text
            timeLabel.text = setupTime(timestamp: (message?.timestamp)!)
            profilePictureView.layer.cornerRadius = profilePictureView.bounds.height / 2
            profilePictureView.layer.borderWidth = 2
            profilePictureView.layer.borderColor = #colorLiteral(red: 0, green: 0.7843137255, blue: 0, alpha: 1)
            profilePictureView.layer.masksToBounds = true
            profilePictureView.loadImageUsingCache(fromURL: message?.profilePictureURL ?? "")
        }
    }
    
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func setupTime(timestamp: Double) -> String {
        let df = DateFormatter(); df.dateStyle = .none; df.timeStyle = .short;
        let date = Date(timeIntervalSince1970: timestamp)
        return df.string(from: date)
    }
    
}
