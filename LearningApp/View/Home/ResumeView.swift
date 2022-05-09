//
//  ResumeView.swift
//  LearningApp
//
//  Created by Sunghee Bang on 2022-05-09.
//

import SwiftUI

struct ResumeView: View {
    var body: some View {
        ZStack {
            RectangleCard(color: .white)
                .frame(height: 66)
            
            HStack {
                VStack (alignment: .leading){
                    Text("Continue where you left off:")
                    Text("Learn Swift: What are closure?")
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
