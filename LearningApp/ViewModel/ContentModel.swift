//
//  ContentModel.swift
//  LearningApp
//
//  Created by Sunghee Bang on 2021-09-29.
//

import Foundation
import Firebase
import FirebaseAuth

class ContentModel: ObservableObject {
    
    // Authentication
    @Published var loggedIn = false
    
    // Reference to Cloud Firestore database
    let db = Firestore.firestore()
    
    // List of modules
    @Published var modules = [Module]()
    
    // Current module
    @Published var currentModule: Module?
    var currentModuleIndex = 0
    
    // Current lesson
    @Published var currentLesson: Lesson?
    var currentLessonIndex = 0
    
    // Current Question
    @Published var currentQuestion: Question?
    var currentQuestionIndex = 0
    
    // Current model explanation
    @Published var codeText = NSAttributedString()
    
    // Current selecte content and test
    @Published var currentContentSelected: Int?
    @Published var currentTestSelected:Int?
    
    var styleData:Data?
    
    
    init() {
    }
    // MARK: - Authentication Methods
    
    func checkLogin() {
        // Check if there's a current user 
        loggedIn = Auth.auth().currentUser != nil ? true: false
        
        // Check if user meta data has been fetched. If the user was already logged in from a previous session, we need to get their data in a separate call
        if UserService.shared.user.name == "" {
            getUserData()
        }
    }
    
    
    // MARK: - Data methods
    
    func saveData() {
        
        // optional binding
        if let loggedInUser = Auth.auth().currentUser {
            
            // Save the progress data locally
            let user = UserService.shared.user
            
            user.lastModule = currentModuleIndex
            user.lastLesson = currentLessonIndex
            user.lastQuestion = currentQuestionIndex
            
            // Save it to the database
            let db = Firestore.firestore()
            let ref = db.collection("users").document(loggedInUser.uid)
            ref.setData(["lastModule":user.lastModule ?? NSNull(),
                         "lastLesson":user.lastLesson ?? NSNull(),
                         "lastQuestion":user.lastQuestion ?? NSNull()], merge: true)
        }
        
    }
    
    func getLessons(module: Module, completion: @escaping () -> Void) {
        
        // Specify path
        let collection = db.collection("modules").document(module.id).collection("lessons")
        
        // Get documents
        collection.getDocuments { (snapshot, error) in
            if error == nil && snapshot != nil {
                
                // Create an array for lessons
                var lessons = [Lesson]()
                
                // Loop through the documents in the snapshot and build array of Lessons
                for doc in snapshot!.documents {
                    
                    // Create a new lesson instance
                    // we changed our model file to initialize parameters so that we don't have to parse out the doucment into variables and pass all of them in when creating an instance. Super easy way would have been to pass in a decoder to automatically parse the data into module instance but we would have to manually specify all parameters.
                    var l = Lesson()
                    
                    // Parse out the value from the document into lesson instance
                    l.id = doc["id"] as? String ?? UUID().uuidString
                    l.title = doc["title"] as? String ?? ""
                    l.video = doc["video"] as? String ?? ""
                    l.duration = doc["duration"] as? String ?? ""
                    l.explanation = doc["explanation"] as? String ?? ""
                    
                    // Add it to our array
                    lessons.append(l)
                }
                
                // Setting the lessons to the module
                
                // note: that you can't just do:
                // module.content.lessons = lessons
                // structs get passed around as copies class gets passed around as reference
                
                // Loop through published modules array and find the one that matches the id of the copy that got passed in
                for (index, m) in self.modules.enumerated() {
                    if module.id == m.id {

                        // m.content.lessons = lessons
                        //still get an error that m is a let constant - this is because m is still a struct and creates copies - so we loop through .enumerated()
                        
                        self.modules[index].content.lessons = lessons
                        
                        // Call completion closure
                        completion()
                    }
                }
            }
        }
    }
    
    func getQuestions(module: Module, completion: @escaping () -> Void) {
        // Specify path
        let collection = db.collection("modules").document(module.id).collection("questions")
        
        //Get documnents
        collection.getDocuments { (snapshot, error) in
            if error == nil && snapshot != nil {
                
                var questions = [Question]()
                
                for doc in snapshot!.documents {
                    
                    // Create new q instance
                    var q = Question()
                    
                    q.id = doc["id"] as? String ?? UUID().uuidString
                    q.answers = doc["answers"] as? [String] ?? [""]
                    q.content = doc["content"] as? String ?? ""
                    q.correctIndex = doc["correctIndex"] as? Int ?? 0
                    
                    questions.append(q)
                }
                
                // add questions to Modules
                for (index, m) in self.modules.enumerated() {
                    if m.id == module.id {
                        //modules.test.questions = questions <- cant do since its struct
                        self.modules[index].test.questions = questions
                        
                        completion()
                    }
                }
            }
        }
        
    }
    
    func getDatabaseData() {
        
        // Pare local style.html
        getLocalStyle()
        
        // specify path
        let collection = db.collection("modules")
        
        // get document
        collection.getDocuments { (snapShot, error) in
            if error == nil && snapShot != nil {
                
                // Create an array for the modules
                var modules = [Module]()
                
                // Loop through the documents returned
                for doc in snapShot!.documents {
                    
                    // Create a new module instance
                    var m = Module()
                    // Parse out the values from the document into the module instance
                    m.id = doc["id"] as? String ?? UUID().uuidString
                    m.category = doc["category"] as? String ?? ""
                    
                    // Parse the lesson content
                    let contentMap = doc["content"] as! [String:Any] // value can be multiple type
                    m.content.id = contentMap["id"] as? String ?? ""
                    m.content.description = contentMap["description"] as? String ?? ""
                    m.content.image = contentMap["image"] as? String ?? ""
                    m.content.time = contentMap["time"] as? String ?? ""
                    
                    // Parse the test content
                    let testMap = doc["test"] as! [String:Any] // casting
                    
                    m.test.id = testMap["id"] as? String ?? ""
                    m.test.description = testMap["description"] as? String ?? ""
                    m.test.image = testMap["image"] as? String ?? ""
                    m.test.time = testMap["time"] as? String ?? ""
                        
                    // Add it to our array
                    modules.append(m)
                }
                
                // Assign our modules to the published property
                // Since this will effect view code so: what ever that is relying on that published property it will update automatically
                DispatchQueue.main.async {
                    self.modules = modules
                }
            }
        }
    }
    
    func getUserData() {
        // Check that there is a loged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        // Get the meta data for the user
        let db = Firestore.firestore()
        let ref = db.collection("users").document(Auth.auth().currentUser!.uid)
        ref.getDocument { (snapshot, error) in
            // Check there is no error
            guard error == nil, snapshot != nil else {
                return
            }
            // Parse the data out and set the user meta data
            let data = snapshot!.data()
            let user = UserService.shared.user
            user.name = data?["name"] as? String ?? ""
            user.lastModule = data?["lastModule"] as? Int //?? nil
            user.lastLesson = data?["lastLesson"] as? Int //?? nil
            user.lastQuestion = data?["lastQuestion"] as? Int //?? nil
            
        }
        
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
    
    func beginModule(_ moduleid: String) {
        
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
    
    func beginLesson(_ lessonIndex: Int) {
        
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
    
    func beginTest(_ moduleId: String) {
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
        
        // Save the progress
        saveData()
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
        
        // Save the progress
        saveData()
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
