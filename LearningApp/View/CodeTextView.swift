//
//  CodeTextView.swift
//  LearningApp
//
//  Created by Sunghee Bang on 2021-10-04.
//

import SwiftUI

struct CodeTextView: UIViewRepresentable {
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        return textView
    }
    func updateUIView(_ textView: UITextView, context: Context) {
        // Set the attrivuted text for the lesson
        textView.text = "Testing"
        //Scroll back to the top
    }
}

struct CodeTextView_Previews: PreviewProvider {
    static var previews: some View {
        CodeTextView()
    }
}
