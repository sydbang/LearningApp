//
//  ContentView.swift
//  LearningApp
//
//  Created by Sunghee Bang on 2021-10-01.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var model:ContentModel
    
    
    var body: some View {
        ScrollView {
            LazyVStack {
                
                // Confirm that current Module is set
                if model.currentModule != nil {
                    ForEach (0..<model.currentModule!.content.lessons.count) { index in
                        
                        NavigationLink(
                            destination:
                                ContentDetailView()
                                .onAppear(perform: {
                                    model.beginLesson(index)
                                }),
                            label: {
                                ContentViewRow(index: index)
                            })
                    }
                    
                }
            }
            .accentColor(.black)
            .padding()
            .navigationTitle("Learn\(model.currentModule?.category ?? "")")
        }
    }
}
