//
//  FriendRequestsVC.swift
//  JitJat
//
//  Created by Aniruddha Prabhu on 2/26/19.
//  Copyright © 2019 Aniruddha Prabhu. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class FriendRequestsVC: UIViewController {
    
    var incoming = [User]()
    var outgoing = [User]()
    var ref = Database.database().reference()
    
    @IBOutlet weak var friendRequestsTableView: UITableView!
    
    @IBAction func dismissFriendRequestsView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userID = Auth.auth().currentUser?.uid
        ref.child("Users").child(userID!).child("FriendRequests").observe(.value, with: { (snapshot) in
            if let frqs = snapshot.value as? [String : String] {
                for (key, _) in frqs {
                    self.ref.child("Users").child(key).observeSingleEvent(of: .value, with: { (snap) in
                        let username = snap.childSnapshot(forPath: "username").value as? String ?? ""
                        let name = snap.childSnapshot(forPath: "name").value as? String ?? ""
                        let email = snap.childSnapshot(forPath: "email").value as? String ?? ""
                        let id = snap.key
                        let user = User(username: username, name: name, email: email, id: id)
                        
                        frqs[key] == "incoming" ? self.incoming.append(user) : self.outgoing.append(user)
                        self.friendRequestsTableView.reloadData()
                    }, withCancel: { (error) in
                        print(error.localizedDescription)
                    })
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendRequestsTableView.delegate = self
        friendRequestsTableView.dataSource = self
        friendRequestsTableView.tableFooterView = UIView()
    }
}
