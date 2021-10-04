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
        
        VStack {
            let lesson = model.currentLesson
            let url = URL(string: Constants.videoHostUrl + (lesson?.video ?? ""))
            
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
                        Rectangle()
                            .frame(height: 48)
                            .foregroundColor(.green)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            
                        Text("Next Lesson: \(model.currentModule!.content.lessons[model.currentLessonIndex+1].title)")
                            .foregroundColor(.white)
                            .bold()
                    }
                })
            }
        }
        .padding()
    }
}

struct ContentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentDetailView()
    }
}
