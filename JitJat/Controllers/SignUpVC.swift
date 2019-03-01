//
//  SignUpVC.swift
//  JitJat
//
//  Created by Aniruddha Prabhu on 2/26/19.
//  Copyright © 2019 Aniruddha Prabhu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import Toast_Swift

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref = Database.database().reference()
    var storageRef = Storage.storage().reference()
    
    @IBOutlet weak var cancelBTN: UIButton!
    @IBOutlet weak var clearBTN: UIButton!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var retypePasswordField: UITextField!
    
    @IBAction func cancelSignUp(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseProfilePicture(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            handlePictureSelection()
        }
    }
    
    @IBAction func createAccount(_ sender: Any) {
        handleSignUp()
    }
    
    override func viewDidLoad() {
        self.hideKeyboardTapAwayGesture()
        
        ViewAppearance.setupCircularImageView(view: profilePictureView)
    }
    
    private func handleSignUp() {
        // Safely unwrap the text fields
        guard let username = usernameField.text else { return }
        guard let name = nameField.text else { return }
        guard let email = emailField.text else { return }
        guard let password = passwordField.text else { return }
        guard let retypePassword = retypePasswordField.text else { return }
        
        // If a profile image was chosen & the entered passwords match,
        // proceed with creating the account.
        if let chosenImage = profilePictureView.image, password == retypePassword, let uploadData = chosenImage.jpegData(compressionQuality: 0.3) {
            Auth.auth().createUser(withEmail: email, password: password) { createdUser, error in
                guard let user = createdUser?.user else { return }
                let location = self.storageRef.child("ProfilePictures/\(user.uid).jpg")
                
                if error == nil && createdUser != nil { print("User created") }
                else { print("Error: \(error!.localizedDescription)") }
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("Username changed")
                        self.ref.child("Users").child(user.uid).setValue(["username": username])
                        self.ref.child("Users/\(user.uid)/name").setValue(name)
                        self.ref.child("Users/\(user.uid)/email").setValue(email)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
                location.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if let error = error { print(error.localizedDescription); return }
                    else {
                        location.downloadURL(completion: { (url, error) in
                            if let error = error { print(error.localizedDescription) }
                            else {
                                guard let url = url else { return }
                                self.ref.child("Users/\(user.uid)/profilePictureURL").setValue(url.absoluteString)
                            }
                        })
                    }
                })
            }
        } else if password != retypePassword {
            self.view.makeToast("Passwords do not match!", duration: 2.5, position: .center)
        } else if profilePictureView.image == nil {
            self.view.makeToast("Please pick an image for a profile picture.", duration: 2.5, position: .center)
        }
    }
    
    // Handles the selection of a profile picture & editing it.
    func handlePictureSelection() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Choose the edited image if available. Otherwise, the original.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var chosenImage: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            chosenImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            chosenImage = originalImage
        }
        
        if let chosenImage = chosenImage {
            profilePictureView.image = chosenImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
