//
//  LearningApp.swift
//  LearningApp
//
//  Created by Sunghee Bang on 2021-09-29.
//

import SwiftUI
import Firebase

@main
struct LearningApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(ContentModel())
                
        }
    }
}
