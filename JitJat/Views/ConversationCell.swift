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
            timeLabel.text = getTimeString(timestamp: (message?.timestamp)!)
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
    
    func getTimeString(timestamp: TimeInterval) -> String {
        let fromDate = Date(timeIntervalSince1970: timestamp)
        let currentDate = Date()
        let formatter = DateFormatter()
        let calendar = NSCalendar(calendarIdentifier: .gregorian); calendar?.locale = .current
        var result = String()
        
        if let check = calendar?.isDate(fromDate, inSameDayAs: currentDate), check {
            formatter.dateStyle = .none; formatter.timeStyle = .short
            result = formatter.string(from: fromDate)
        } else if let check = calendar?.isDateInYesterday(fromDate), check {
            result = "Yesterday"
        } else if ((calendar?.date(byAdding: .day, value: -7, to: currentDate))!...currentDate).contains(fromDate) {
            result = (calendar?.weekdaySymbols[(calendar?.component(.weekday, from: fromDate))! - 1])!
        } else {
            formatter.dateStyle = .short; formatter.timeStyle = .none
            result = formatter.string(from: fromDate)
        }
        
        return result
    }
}
