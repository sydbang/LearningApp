//
//  ContentDetailView.swift
//  LearningApp
//
//  Created by Sunghee Bang on 2021-10-01.
//

import SwiftUI

// import AVKit framework for video playing element
import AVKit

struct ContentDetailView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        let lesson = model.currentLesson
        let url = URL(string: Constants.videoHostUrl + (lesson?.video ?? ""))
        
        VStack {
            if url != nil {
                VideoPlayer(player: AVPlayer(url: url!))
                    .cornerRadius(10)
            }
            // TODO: Description
            CodeTextView()
            // Show Next lesson button, only if there is a next lesson
            
            if model.hasNextLesson() {
                Button(action: {
                    // Advance the lesson
                    model.nextLesson()
                }, label: {
                    
                    ZStack {
                        RectangleCard(color: Color.green)
                            .frame(height: 48)
                            
                        Text("Next Lesson: \(model.currentModule!.content.lessons[model.currentLessonIndex+1].title)")
                            .foregroundColor(.white)
                            .bold()
                    }
                })
            }
            else {
                // show the complete button instead
                Button(action: {
                    
                    // Cal next lesson
                    model.nextLesson()
                    
                    // Take user back to home view
                    model.currentContentSelected = nil
                }, label: {
                    
                    ZStack {
                        RectangleCard(color: Color.green)
                            .frame(height: 48)
                            
                        Text("Complete")
                            .foregroundColor(.white)
                            .bold()
                    }
                })
            }
        }
        .padding()
        .navigationBarTitle(lesson?.title ?? "")
    }
}

struct ContentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentDetailView()
    }
}
