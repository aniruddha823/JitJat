//
//  Extensions.swift
//  JitJat
//
//  Created by Aniruddha Prabhu on 2/26/19.
//  Copyright © 2019 Aniruddha Prabhu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GrowingTextView

let imgCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCache(fromURL: String) {
        
        self.image = nil
        
        if let cachedImg = imgCache.object(forKey: fromURL as AnyObject) as? UIImage {
            self.image = cachedImg
            return
        }
        
        DispatchQueue.main.async {
            self.sd_setImage(with: URL(string: fromURL), completed: { (img, error, sdimgcachetype, url) in
                imgCache.setObject(img!, forKey: fromURL as AnyObject)
            })
        }
    }
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let value = Array(self.friends.values)[indexPath.row]
        cell.textLabel?.text = value.name
        cell.detailTextLabel?.text = value.username
        return cell
    }
}

extension AddFriendsVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searchController.isActive && searchController.searchBar.text != "") ? filteredUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let user = (searchController.isActive && searchController.searchBar.text != "") ? filteredUsers[indexPath.row] : users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.username
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let handle = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text
        let alert = UIAlertController(title: "Friend Request?", message: "Are you sure you want to request @" + handle! + " as a friend?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            let targetID = self.users[indexPath.row].id
            if let currentID = Auth.auth().currentUser?.uid {
                self.ref.child("Users/\(currentID)/FriendRequests/\(targetID)").setValue("outgoing")
                self.ref.child("Users/\(targetID)/FriendRequests/\(currentID)").setValue("incoming")
                print("changes made!")
            }
            
            self.usersTableView.deselectRow(at: indexPath, animated: false)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            self.usersTableView.deselectRow(at: indexPath, animated: false)
        }))
        
        self.present(alert, animated: true)
    }
}

extension FriendRequestsVC: UITableViewDelegate, UITableViewDataSource, AlertFromCell {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? outgoing.count : incoming.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Outgoing" : "Incoming"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendRequestsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FriendRequestCell
        
        cell.nameLabel.text = indexPath.section == 1 ? outgoing[indexPath.row].name : incoming[indexPath.row].name
        cell.usernameLabel.text = indexPath.section == 1 ? outgoing[indexPath.row].username : incoming[indexPath.row].username
        cell.setButtons(section: indexPath.section)
        cell.selectedUser = indexPath.section == 1 ? outgoing[indexPath.row] : incoming[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        friendRequestsTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func presentAlert(sender: FriendRequestCell) {
        self.present(sender.buttonAlert!, animated: true)
    }
}

extension NewConversationVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = friends[indexPath.row].name
        cell.detailTextLabel?.text = friends[indexPath.row].username
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentID = Auth.auth().currentUser?.uid {
            conversationKey = ref.child("Conversations").childByAutoId().key;
            
            self.ref.child("Users/\(currentID)/Conversations/\(conversationKey!)").setValue(true)
            self.ref.child("Users/\(friends[indexPath.row].id)/Conversations/\(conversationKey!)").setValue(true)
            self.ref.child("Conversations").child(conversationKey!).child("Members").setValue(["\(currentID)" : true,
                                                                                               "\(friends[indexPath.row].id)" : true])
            performSegue(withIdentifier: "gotoMessages", sender: nil)
        }
        
    }
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let msg = messages[indexPath.row]
        cell.message = msg
        
        return cell
    }
}

extension ChatVC: GrowingTextViewDelegate {
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
