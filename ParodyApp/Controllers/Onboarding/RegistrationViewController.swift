//
//  RegistrationViewController.swift
//  ParodyApp
//
//  Created by Dawson Chen on 6/14/22.
//

import UIKit
import FirebaseAuth

class RegistrationViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var registerEmailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty,
              let email = registerEmailTextField.text, !email.isEmpty,
              let name = nameTextField.text, !name.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
                  return
        }
        
        AuthManager.shared.registerUser(name: name, email: email, username: username, password: password) { success in
            DispatchQueue.main.async {
                if success {
                    print("successfully registered")
                    self.performSegue(withIdentifier: K.Segues.registerToSimpleHome, sender: self)
                } else {
                    let alert = UIAlertController(title: "Registration Failed",
                                                  message: "Please enter a unique email and username.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss",
                                                  style: .cancel,
                                                  handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
