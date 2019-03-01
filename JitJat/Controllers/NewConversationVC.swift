//
//  NewConversationVC.swift
//  JitJat
//
//  Created by Aniruddha Prabhu on 2/26/19.
//  Copyright © 2019 Aniruddha Prabhu. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NewConversationVC: UIViewController {
    
    var friends = [User]()
    var ref = Database.database().reference()
    var conversationKey : String?
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBAction func dismissNewConversation(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.tableFooterView = UIView()
        
        if let currentID = Auth.auth().currentUser?.uid {
            ref.child("Users").child(currentID).child("Friends").observe(.value, with: { (snapshot) in
                if let frqs = snapshot.value as? [String : Bool] {
                    for (key, _) in frqs {
                        self.ref.child("Users").child(key).observe(.value, with: { (snap) in
                            let username = snap.childSnapshot(forPath: "username").value as? String ?? ""
                            let name = snap.childSnapshot(forPath: "name").value as? String ?? ""
                            let email = snap.childSnapshot(forPath: "email").value as? String ?? ""
                            let id = snap.key
                            let user = User(username: username, name: name, email: email, id: id)
                            
                            self.friends.append(user)
                            self.friendsTableView.reloadData()
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MessagesVC {
            vc.conversationKey = conversationKey
        }
    }
}
