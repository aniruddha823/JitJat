//
//  LoginVC.swift
//  JitJat
//
//  Created by Aniruddha Prabhu on 2/26/19.
//  Copyright © 2019 Aniruddha Prabhu. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField
import Toast_Swift

class LoginVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordField: SkyFloatingLabelTextField!
    @IBOutlet weak var loginBTN: UIButton!
    
    @IBAction func gotoSignUp(_ sender: Any) {
        performSegue(withIdentifier: "gotoSignUp", sender: nil)
    }
    
    @IBAction func appLogin(_ sender: Any) {
        handleLogIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self; emailField.returnKeyType = .done
        passwordField.delegate = self; passwordField.returnKeyType = .done
        passwordField.isSecureTextEntry = true
        loginBTN.backgroundColor = self.view.backgroundColor

        // Enable keyboard hiding when entering login details
        self.hideKeyboardTapAwayGesture()
    }
    
    // Handles the login process after clicking the "Login" button
    private func handleLogIn() {
        
        // Safely unwrap email & password fields
        guard let email = emailField.text else { return }
        guard let password = passwordField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if error == nil && user != nil {
                self.performSegue(withIdentifier: "login", sender: nil)
            } else {
                // Show warning upon incorrect email/password combination
                self.view.makeToast("Incorrect email & password. Please try again.", duration: 2.5, position: .center)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension UIViewController {
    func hideKeyboardTapAwayGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
