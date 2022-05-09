//
//  ResumeView.swift
//  LearningApp
//
//  Created by Sunghee Bang on 2022-05-09.
//

import SwiftUI

struct ResumeView: View {
    @EnvironmentObject var model: ContentModel
    
    let user = UserService.shared.user
    
    var resumeTitle: String {
        
        let module = model.modules[user.lastModule ?? 0]
        
        if user.lastLesson != 0 {
            // Resume lesson
            return "Learn \(module.category): Lesson \(user.lastLesson! + 1)"
        } else {
            // resume to test
            return "\(module.category) Test: Question \(user.lastQuestion! + 1)"
        }
        
    }
    
    var body: some View {
        ZStack {
            RectangleCard(color: .white)
                .frame(height: 66)
            
            HStack {
                VStack (alignment: .leading){
                    Text("Continue where you left off:")
                    Text(resumeTitle)
                        .bold()
                }
                Spacer()
                Image("play")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height:40)
            }
            .padding()
        }
    }
}

struct ResumeView_Previews: PreviewProvider {
    static var previews: some View {
        ResumeView()
    }
}
