//
//  DatabaseManager.swift
//  ParodyApp
//
//  Created by Dawson Chen on 6/15/22.
//

import Foundation
import FirebaseDatabase

public class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    /// Check if username and email are available for creation of new user
    public func canCreateNewUser(email: String?, username: String?, completion: (Bool) -> Void) {
        //implement later
        completion(true)
    }
}
