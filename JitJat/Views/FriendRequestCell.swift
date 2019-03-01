//
//  FriendRequestCell.swift
//  JitJat
//
//  Created by Aniruddha Prabhu on 2/26/19.
//  Copyright © 2019 Aniruddha Prabhu. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class FriendRequestCell: UITableViewCell {
    
    var ref = Database.database().reference()
    var selectedUser: User?
    var delegate: AlertFromCell?
    var buttonAlert: UIAlertController?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var confirmBTN: UIButton!
    @IBOutlet weak var denyBTN: UIButton!
    
    @IBAction func confirmRequest(_ sender: Any) {
        if let selectedUser = selectedUser {
            let alert = UIAlertController(title: "Add Friend?", message: "Do you want to add @\(selectedUser.username) as a friend?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                
                if let currentID = Auth.auth().currentUser?.uid {
                    self.ref.child("Users/\(currentID)/Friends/\(selectedUser.id)").setValue(true)
                    
                    self.ref.child("Users/\(selectedUser.id)/Friends/\(currentID)").setValue(true)
                    
                    self.ref.child("Users/\(currentID)/FriendRequests/\(selectedUser.id)").removeValue()
                    
                    self.ref.child("Users/\(selectedUser.id)/FriendRequests/\(currentID)").removeValue()
                }
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            buttonAlert = alert
            self.delegate?.presentAlert(sender: self)
        }
    }
    
    @IBAction func denyRequest(_ sender: Any) {
        if let selectedUser = selectedUser {
            let alert = UIAlertController(title: "Delete Friend Request?", message: "Do you want to delete @\(selectedUser.username)'s friend request?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                
                if let currentID = Auth.auth().currentUser?.uid {
                    self.ref.child("Users/\(currentID)/FriendRequests/\(selectedUser.id)").removeValue()
                    self.ref.child("Users/\(selectedUser.id)/FriendRequests/\(currentID)").removeValue()
                }
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            buttonAlert = alert
            self.delegate?.presentAlert(sender: self)
        }
    }
    
    func setButtons(section: Int) {
        if section == 1 {
            confirmBTN.setImage(nil, for: .normal)
            confirmBTN.isEnabled = false
        }
    }
}

protocol AlertFromCell {
    func presentAlert(sender: FriendRequestCell)
}
