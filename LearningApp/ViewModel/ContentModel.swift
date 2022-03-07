//
//  ContentModel.swift
//  LearningApp
//
//  Created by Sunghee Bang on 2021-09-29.
//

import Foundation

class ContentModel: ObservableObject {
    
    // List of modules
    @Published var modules = [Module]()
    
    // Current module
    @Published var currentModule: Module?
    var currentModuleIndex = 0
    
    // Current lesson
    @Published var currentLesson: Lesson?
    var currentLessonIndex = 0
    
    // Current Question
    @Published var currentQuestion: Questions?
    var currentQuestionIndex = 0
    
    // Current model explanation
    @Published var codeText = NSAttributedString()
    
    // Current selecte content and test
    @Published var currentContentSelected: Int?
    
    @Published var currentTestSelected:Int?
    
    var styleData:Data?
    
    
    init() {
        
        // Pare local style.html
        getLocalStyle()
        
        // Get Database modules
        getDatabaseModules()
        
        // Download remote json file and parse data
        // getRemoteData()
    }
    
    // MARK: - Data methods
    
    func getDatabaseModules() {
        
    }
    
    func getLocalStyle() {
        /*
        let jsonUrl = Bundle.main.url(forResource: "data", withExtension: "json")
        do {
            let jsonData = try Data(contentsOf: jsonUrl!)
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let modules = try jsonDecoder.decode([Module].self, from: jsonData)
                
                // Assign parsed modules to modules property
                self.modules = modules
                
            } catch {
                print(error)
            }
            
            
        } catch {
            print(error)
        }*/
        
        // Parse the style data
        let styleUrl = Bundle.main.url(forResource: "style", withExtension: "html")
        
        do {
            //Read the file into a data object
            let styleData = try Data(contentsOf: styleUrl!)
            self.styleData = styleData
        } catch {
            print("Couldn't parse style data")
        }
        
    }
    
    func getRemoteData() {
         
        // String path
        let urlString = "https://sydbang.github.io/learningapp-data/data2.json"
        
        // Create a url object
        let url = URL(string: urlString)
        guard url != nil else {
            // Couldn't create url
            return
        }
        
        // Create a URLRequest object
        let request = URLRequest(url: url!)
        
        // Get the session and kick off the task
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            // Check if there's an error
            guard error == nil else {
                // There was an error
                return
            }
            
            // Create json decoder
            let decoder = JSONDecoder()
            
            // Decode
            do {
                let modules = try decoder.decode([Module].self, from: data!)
                
                //Whenever you are going to make view code to update, this will make sure that main thread takes care of it when it gets the chance (and the back ground thread doesn't update the ui)
                DispatchQueue.main.async {
                    // Append parsed modules into modules property
                    self.modules += modules
                }
                
            } catch {
                print(error)
            }
            
        }
        // Kick off the data task
        dataTask.resume()
        
    }
    
    // MARK: - Module navigation methods
    
    func beginModule(_ moduleid:Int) {
        
        // Find the index or this module id
        for index in 0..<modules.count {
            if modules[index].id == moduleid {
                currentModuleIndex = index
                break
            }
        }
        // Set the current module
        currentModule = modules[currentModuleIndex]
    }
    
    // MARK: - Lesson navigation method
    
    func beginLesson(_ lessonIndex:Int) {
        
        // Check that the lesson index is within range of module lessons
        if lessonIndex < currentModule!.content.lessons.count {
            currentLessonIndex = lessonIndex
        } else {
            currentLessonIndex = 0
        }
        // Set the current lesson
        currentLesson = currentModule!.content.lessons[currentLessonIndex]
        // Set lessonDescription to lesson.explanation
        codeText = addStyling(currentLesson!.explanation)
        
    }
    
    // MARK: - Check next lesson exist
    func hasNextLesson() -> Bool {
        
        guard currentModule != nil else {
            return false
        }
        return (currentLessonIndex + 1 < currentModule!.content.lessons.count)
    }
    
    func beginTest(_ moduleId: Int) {
        // Set the current module
        beginModule(moduleId)
        // Set the current question
        currentQuestionIndex = 0
        
        // If there are questions, set the current question to the first one
        if currentModule?.test.questions.count ?? 0 > 0 {
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            // Set the question content
            codeText = addStyling(currentQuestion!.content)
        }
    }
    
    // MARK: - Advance to the next lesson
    func nextLesson() {
        // Advance the lesson index
        currentLessonIndex += 1
        // Check that it is within range
        if currentLessonIndex < currentModule!.content.lessons.count {
            // Set the current lesson property
            currentLesson = currentModule!.content.lessons[currentLessonIndex]
            codeText = addStyling(currentLesson!.explanation)
        } else {
            // Reset the lesson state
            currentLesson = nil
            currentLessonIndex = 0
        }
    }
    
    // MARK: - Advance to the next question
    func nextQuestion() {
        // Advance the question index
        currentQuestionIndex += 1
        // Check that it's within the range of questions
        if currentQuestionIndex < currentModule!.test.questions.count {
            // Set the current question property
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            codeText = addStyling(currentQuestion!.content)
        } else {
            // Reset the lesson state
            currentQuestion = nil
            currentQuestionIndex = 0
        }
    }
    
    // MARK: - Code Styling
    
    private func addStyling(_ htmlString: String) -> NSAttributedString {
        var resultString = NSAttributedString()
        var data = Data()
        
        //Add the styling data
        if styleData != nil {
            data.append(self.styleData!)
        }
        
        // Add the html data
        data.append(Data(htmlString.utf8))
        
    
        //Convert to attributed String
        
        // Technique 1
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            
            resultString = attributedString
        }
        //Technique 2 - if you need to handle the error use this technique
//        do {
//            let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
//            resultString = attributedString
//            }
//        } catch {
//            print("Couldn't turn html into attributed string")
//        }
        
        return resultString
    }
    
}
