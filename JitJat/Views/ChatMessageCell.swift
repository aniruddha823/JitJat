//
//  ChatMessageCell.swift
//  JitJat
//
//  Created by Aniruddha Prabhu on 2/26/19.
//  Copyright © 2019 Aniruddha Prabhu. All rights reserved.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    
    let messageLabel = UILabel()
    let messageBackground = UIView()
    var message : Message! {
        didSet {
            messageBackground.backgroundColor = message.isIncomingMessage ? #colorLiteral(red: 0, green: 0.7843137255, blue: 0, alpha: 1) : #colorLiteral(red: 0.9209835529, green: 0.921007216, blue: 0.9202515483, alpha: 1)
            messageLabel.textColor = message.isIncomingMessage ? #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            messageLabel.text = message.text
            
            if !message.isIncomingMessage {
                leadingConstraint.isActive = true; trailingConstraint.isActive = false
            } else {
                leadingConstraint.isActive = false; trailingConstraint.isActive = true
            }
        }
    }
    
    var leadingConstraint : NSLayoutConstraint!
    var trailingConstraint : NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        
        messageBackground.layer.cornerRadius = 10
        messageBackground.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageBackground)
        
        addSubview(messageLabel)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32).isActive = true
        messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        
        messageBackground.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -10).isActive = true
        messageBackground.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10).isActive = true
        messageBackground.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -10).isActive = true
        messageBackground.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 10).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
