//
//  ResumeView.swift
//  LearningApp
//
//  Created by Sunghee Bang on 2022-05-09.
//

import SwiftUI

struct ResumeView: View {
    @EnvironmentObject var model: ContentModel
    @State var resumeSelected: Int?
    
    
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
    
    var destination: some View {
        
        return Group {
            let module = model.modules[user.lastModule ?? 0]
            
            // determine if we need to go into a contentDetailView or a TestView
            if user.lastLesson! > 0 {
                // Go to contentDetailView
                ContentDetailView()
                    .onAppear(perform: {
                        
                        // Fetch lessons and begin lesson
                        
                            model.getLessons(module: module) {
                                model.beginModule(module.id)
                                model.beginLesson(user.lastLesson!)
                            }
                })
                
            } else {
                // Go to TestView
                TestView()
                    .onAppear(perform: {
                        model.getQuestions(module: module) {
                            model.beginTest(module.id)
                            model.currentQuestionIndex = user.lastQuestion!
                        }
                    })
            }
        }
    }
    
    var body: some View {
        
        let module = model.modules[user.lastModule ?? 0]
        NavigationLink(destination: destination,
                       tag: module.id.hash,
                       selection: $resumeSelected) {
            ZStack {
                RectangleCard(color: .white)
                    .frame(height: 66)
                
                HStack {
                    VStack (alignment: .leading){
                        Text("Continue where you left off:")
                        Text(resumeTitle)
                            .bold()
                    }
                    .foregroundColor(.black)
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
}

struct ResumeView_Previews: PreviewProvider {
    static var previews: some View {
        ResumeView()
    }
}
