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
    
    // Current model explanation
    @Published var lessonDescription = NSAttributedString()
    
    
    var styleData:Data?
    
    init() {
        getLocalData()
    }
    
    // MARK: - Data methods
    
    func getLocalData() {
        
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
        }
        
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
        lessonDescription = addStyling(currentLesson!.explanation)
        
    }
    
    // MARK: - Check next lesson exist
    func hasNextLesson() -> Bool {
        return (currentLessonIndex + 1 < currentModule!.content.lessons.count)
    }
    
    // MARK: - Advance to the next lesson
    func nextLesson() {
        // Advance the lesson index
        currentLessonIndex += 1
        // Check that it is within range
        if currentLessonIndex < currentModule!.content.lessons.count {
            // Set the current lesson property
            currentLesson = currentModule!.content.lessons[currentLessonIndex]
            lessonDescription = addStyling(currentLesson!.explanation)
        } else {
            // Reset the lesson state
            currentLesson = nil
            currentLessonIndex = 0
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
