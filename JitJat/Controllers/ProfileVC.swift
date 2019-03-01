//
//  ProfileVC.swift
//  JitJat
//
//  Created by Aniruddha Prabhu on 2/26/19.
//  Copyright © 2019 Aniruddha Prabhu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SkyFloatingLabelTextField
import SDWebImage

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var friends = [String : User]()
    var ref = Database.database().reference()
    var storageRef = Storage.storage().reference()
    var currentUser = Auth.auth().currentUser
    var isEditingProfile = false
    
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var nameField: SkyFloatingLabelTextField!
    @IBOutlet weak var usernameField: SkyFloatingLabelTextField!
    @IBOutlet weak var editBTN: UIButton!
    @IBOutlet weak var logoutBTN: UIButton!
    @IBOutlet weak var viewFriendRequestsBTN: UIButton!
    @IBOutlet weak var addFriendsBTN: UIButton!
    
    @IBAction func appLogout(_ sender: Any) {
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "appLogout", sender: nil)
    }
    
    @IBAction func editProfile(_ sender: UIButton) {
        if !isEditingProfile {
            isEditingProfile = true
            sender.setTitle("Done", for: .normal)
            
            profilePictureView.isUserInteractionEnabled = true
            nameField.isSelected = true
            nameField.isUserInteractionEnabled = true
            usernameField.isSelected = true
            usernameField.isUserInteractionEnabled = true
            logoutBTN.isEnabled = false
            viewFriendRequestsBTN.isEnabled = false
            addFriendsBTN.isEnabled = false
        } else {
            isEditingProfile = false
            sender.setTitle("Edit", for: .normal)
            
            profilePictureView.isUserInteractionEnabled = false
            nameField.isSelected = false
            nameField.isUserInteractionEnabled = false
            usernameField.isSelected = false
            usernameField.isUserInteractionEnabled = false
            logoutBTN.isEnabled = true
            viewFriendRequestsBTN.isEnabled = true
            addFriendsBTN.isEnabled = true
        }
    }
    
    @IBAction func gotoAddFriend(_ sender: Any) {
        performSegue(withIdentifier: "addFriend", sender: nil)
    }
    
    @IBAction func gotoFriendRequests(_ sender: Any) {
        performSegue(withIdentifier: "showFRQs", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {}
    
    @IBAction func chooseProfilePicture(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            handleProfilePictureSelection()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.tableFooterView = UIView()
        
        profilePictureView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        profilePictureView.layer.borderWidth = 0.5
        profilePictureView.layer.cornerRadius = profilePictureView.bounds.height / 2
        profilePictureView.contentMode = .scaleAspectFill
        profilePictureView.layer.masksToBounds = true
        
        ref.child("Users").child((currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            self.nameField.text = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            let profilePictureURL = snapshot.childSnapshot(forPath: "profilePictureURL").value as? String ?? ""
            self.profilePictureView.loadImageUsingCache(fromURL: profilePictureURL)
        }) { (error) in
            print(error.localizedDescription)
        }
        
        usernameField.text = currentUser?.displayName
        
        if let currentID = currentUser?.uid {
            ref.child("Users").child(currentID).child("Friends").observe(.value, with: { (snapshot) in
                if let frqs = snapshot.value as? [String : Bool] {
                    for (key, _) in frqs {
                        self.ref.child("Users").child(key).observe(.value, with: { (snap) in
                            let username = snap.childSnapshot(forPath: "username").value as? String ?? ""
                            let name = snap.childSnapshot(forPath: "name").value as? String ?? ""
                            let email = snap.childSnapshot(forPath: "email").value as? String ?? ""
                            let id = snap.key
                            let user = User(username: username, name: name, email: email, id: id)
                            
                            self.friends[key] = user
                            self.friendsTableView.reloadData()
                        }, withCancel: { (error) in
                            print(error.localizedDescription)
                        })
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    private func handleProfilePictureSelection() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var chosenImage: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            chosenImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            chosenImage = originalImage
        }
        
        if let chosenImage = chosenImage, let currentID = currentUser?.uid, let uploadData = chosenImage.jpegData(compressionQuality: 0.3) {
            profilePictureView.image = chosenImage
            
            let location = storageRef.child("ProfilePictures/\(currentID).jpg")
            location.delete { (error) in
                if let error = error { print(error.localizedDescription) }
            }
            
            location.putData(uploadData, metadata: nil) { (metadata, error) in
                if let error = error { print(error.localizedDescription); return }
                else {
                    location.downloadURL(completion: { (url, error) in
                        if let error = error { print(error.localizedDescription) }
                        else {
                            guard let url = url else { return }
                            self.ref.child("Users/\(currentID)/profilePictureURL").setValue(url.absoluteString)
                        }
                    })
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}
