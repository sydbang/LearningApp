//
//  Models.swift
//  LearningApp
//
//  Created by Sunghee Bang on 2021-09-29.
//

import Foundation

struct Module: Decodable, Identifiable {
    var id:String = ""
    var category:String = ""
    var content:Content = Content()
    var test:Test = Test()
}

struct Content: Decodable, Identifiable {
    var id:String = ""
    var image:String = ""
    var time:String = ""
    var description:String = ""
    var lessons:[Lesson] = [Lesson]()
}

struct Lesson: Decodable, Identifiable {
    var id:String = ""
    var title:String = ""
    var video:String = ""
    var duration:String = ""
    var explanation:String = ""
}

struct Test: Decodable, Identifiable {
    var id:String = ""
    var image:String = ""
    var time:String = ""
    var description:String = ""
    var questions:[Question] = [Question]()
}

struct Question: Decodable, Identifiable {
    var id:String = ""
    var content:String = ""
    var correctIndex:Int = 0
    var answers:[String] = [String]()
}

class User{
    // struct gets passed arround as copy, class gets passed arround as a single thing
    var name: String = ""
    var lastModule: Int?
    var lastLesson: Int?
    var lastQuestion: Int?
}
