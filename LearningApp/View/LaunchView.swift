//
//  LaunchView.swift
//  LearningApp
//
//  Created by Sunghee Bang on 2022-04-06.
//

import SwiftUI

struct LaunchView: View {
    
    @State var loggedIn = false
    
    var body: some View {
        
        if loggedIn == false {
            // Show loggin view
            LoginView()
                .onAppear {
                    // Check if the user is logged in or out
                    
                }
        } else {
            // Show logged in view
            
        }
        
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
