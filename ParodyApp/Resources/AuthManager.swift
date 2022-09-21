//
//  AuthManager.swift
//  ParodyApp
//
//  Created by Dawson Chen on 6/15/22.
//

import Foundation
import FirebaseAuth
import FirebaseCore

public class AuthManager {

    static let shared = AuthManager()
    
    public func loginUser(username: String?, email: String?, password: String?, completion: @escaping (Bool) -> Void) {
        if let email = email, let password = password {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
        } else if let username = username {
            // implement this later - username sign in
            print(username)
        }
    }
    
    public func registerUser(name: String?, email: String?, username: String?, password: String?, completion: @escaping (Bool) -> Void) {
        DatabaseManager.shared.canCreateNewUser(email: email, username: username) { canCreate in
            if canCreate {
                if let email = email, let password = password {
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        guard authResult != nil, error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                } else if let username = username {
                    print(username)
                }
            } else {
                completion(false)
            }
        }
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges { error in
            if let e = error {
                print("Error setting user's name", e)
            } else {
                print("successfully set a user's name")
            }
        }
    }

}
