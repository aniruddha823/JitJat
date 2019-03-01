//
//  AddFriendsVC.swift
//  JitJat
//
//  Created by Aniruddha Prabhu on 2/26/19.
//  Copyright © 2019 Aniruddha Prabhu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class AddFriendsVC: UIViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    var users = [User]()
    var filteredUsers = [User]()
    var ref = Database.database().reference()
    
    @IBOutlet weak var usersTableView: UITableView!
    
    @IBAction func dismissAddFriends(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersTableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        usersTableView.tableFooterView = UIView()
        
        ref.child("Users").queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            let value = snapshot.value as? [String : Any]
            let username = value?["username"] as? String ?? ""
            let name = value?["name"] as? String ?? ""
            let email = value?["email"] as? String ?? ""
            let id = snapshot.key
            let user = User(username: username, name: name, email: email, id: id)
            print(name)
            self.users.append(user)
            //            self.usersTableView.insertRows(at: [IndexPath(row: self.users.count - 1, section: 0)], with: UITableView.RowAnimation.automatic)
            self.usersTableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        print(users.count)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filteredUsers = self.users.filter { user in
            let name = user.name
            return name.contains(self.searchController.searchBar.text!)
        }
        
        usersTableView.reloadData()
    }
}
