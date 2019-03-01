//
//  ChatVC.swift
//  JitJat
//
//  Created by Aniruddha Prabhu on 2/26/19.
//  Copyright © 2019 Aniruddha Prabhu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GrowingTextView

class ChatVC: UIViewController {
    
    let cellId = "id"
    var messages = [Message]()
    var ref = Database.database().reference()
    var currentID = Auth.auth().currentUser?.uid
    var conversationKey : String?
    
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    
    @IBAction func sendMessage(_ sender: Any) {
        if let currentID = currentID, let text = textView.text, text != "" {
            let timestamp = Double(NSDate().timeIntervalSince1970)
            var entry = ["text" : text,
                         "senderID" : currentID,
                         "timestamp" : timestamp] as [String : Any]
            self.ref.child("Conversations").child(conversationKey!).child("Messages").childByAutoId().updateChildValues(entry)
            
            self.ref.child("Users").child(currentID).observeSingleEvent(of: .value, with: { (snapshot) in
                let name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
                entry["senderName"] = name
                self.ref.child("Conversations").child(self.conversationKey!).child("latestMessage").setValue(entry)
                
                self.textView.text = ""
                self.messagesTableView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        messagesTableView.separatorStyle = .none
        messagesTableView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
        
        if let conversationKey = conversationKey, let currentID = Auth.auth().currentUser?.uid {
            self.ref.child("Conversations").child(conversationKey).child("Messages").queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) in
                let value = snapshot.value as? [String : Any]
                let text = value?["text"] as? String ?? ""
                let sender = value?["senderID"] as? String ?? ""
                let timestamp = value?["timestamp"] as? Double ?? 0
                
                let message = Message(text: text, senderID: sender, timestamp: timestamp, isIncomingMessage: currentID == sender, senderName: nil, conversationKey: conversationKey, profilePictureURL: nil)
                
                self.messages.append(message)
                self.messagesTableView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            textViewBottomConstraint.constant = keyboardHeight + 8
            view.layoutIfNeeded()
        }
    }
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
}
