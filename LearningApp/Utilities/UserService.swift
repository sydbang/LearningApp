//
//  UserService.swift
//  LearningApp
//
//  Created by Sunghee Bang on 2022-04-27.
//

import Foundation

class UserService {
    // When user logs in, or creates an account - 
    var user = User()
    
    static var shared = UserService()
    
    private init() {
    }
}
