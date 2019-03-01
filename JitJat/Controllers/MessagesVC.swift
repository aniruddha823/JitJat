//
//  MessagesVC.swift
//  JitJat
//
//  Created by Aniruddha Prabhu on 2/26/19.
//  Copyright © 2019 Aniruddha Prabhu. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MessagesVC: UIViewController {
    
    var messages = [String : Message]()
    var latestMessages = [Message]()
    var ref = Database.database().reference()
    var conversationKey : String?
    
    @IBOutlet weak var messagesTableView: UITableView!
    
    // Brings up the list of friends to chat with.
    @IBAction func composeMessage(_ sender: Any) {
        performSegue(withIdentifier: "composeMessage", sender: nil)
    }
    
    // Deselect the tableview upon coming back from a chat's view.
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = messagesTableView.indexPathForSelectedRow {
            print("deselecting")
            messagesTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.unselectedItemTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 0, green: 0.8718441521, blue: 0, alpha: 1)
        
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.tableFooterView = UIView()
        
        if let currentID = Auth.auth().currentUser?.uid {
            
            ref.child("Users").child(currentID).child("Conversations").observe(.value, with: { (snapshot) in
                if let frqs = snapshot.value as? [String : Bool] {
                    
                    for (key, _) in frqs {
                        self.ref.child("Conversations").child(key).child("latestMessage").observe(.value, with: { (snap) in
                            let text = snap.childSnapshot(forPath: "text").value as? String ?? ""
                            let senderID = snap.childSnapshot(forPath: "senderID").value as? String ?? ""
                            let timestamp = snap.childSnapshot(forPath: "timestamp").value as? Double ?? 0
                            
                            self.ref.child("Conversations/\(key)/Members").observeSingleEvent(of: .value, with: { (snapshot) in
                                if let members = snapshot.value as? [String : Bool] {
                                    for (memberKey, _) in members {
                                        if(memberKey != currentID) {
                                            self.ref.child("Users/\(memberKey)").observeSingleEvent(of: .value, with: { (snap) in
                                                
                                                let imgURL = snap.childSnapshot(forPath: "profilePictureURL").value as? String ?? ""
                                                let name = snap.childSnapshot(forPath: "name").value as? String ?? ""
                                                let message = Message(text: text, senderID: senderID, timestamp: timestamp, isIncomingMessage: currentID == senderID, senderName: name, conversationKey: key, profilePictureURL: imgURL)
                                                
                                                self.messages[key] = message
                                                self.latestMessages = Array(self.messages.values)
                                                self.latestMessages.sort(by: { $0.timestamp > $1.timestamp })
                                                
                                                DispatchQueue.main.async {
                                                    self.messagesTableView.reloadData()
                                                }
                                            })
                                            break
                                        }
                                    }
                                }
                            })
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
    
    // Immediately segue to a chat view after selecting someone to chat with.
    // This is performed when returning from the view to select a new person to chat with.
    @IBAction func unwindToMessages(segue : UIStoryboardSegue) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "gotoChat", sender: nil)
        }
    }
    
    // When going to a chat's view, set the conversation key with respect to it's value in Firebase.
    // This is done to identify a particular chat's unique messages, members, etc.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChatVC {
            vc.conversationKey = conversationKey
            vc.title = messages[conversationKey!]?.senderName
        }
    }
}

extension MessagesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return latestMessages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messagesTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ConversationCell
        let value = latestMessages[indexPath.row]
        cell.message = value
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = latestMessages[indexPath.row].conversationKey
        conversationKey = key
        
        self.performSegue(withIdentifier: "gotoChat", sender: nil)
    }
}
