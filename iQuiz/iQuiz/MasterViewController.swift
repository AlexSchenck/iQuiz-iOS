//
//  MasterViewController.swift
//  iQuiz
//
//  Created by Alex N. Schenck on 11/2/15.
//  Copyright (c) 2015 Alex Schenck. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var objects : [Quiz] = QuizData().getQuizzes() // Show default
    var quizURL : String = "http://tednewardsandbox.site44.com/questions.json" // Use default
    var data = NSMutableData()
    let defaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var SettingsBarButton: UIBarButtonItem!

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
        
        // Load stored URL to get quizzes
        if let storedURL = defaults.stringForKey("url") {
            quizURL = storedURL
        }
        
        // Load previously saved quizzes in case of no internet connection
        if let storedObjects: AnyObject = defaults.objectForKey("quizList") {
            objects = makeQuizzes(storedObjects as! NSMutableArray)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // Create settings button
        self.navigationItem.leftBarButtonItem = SettingsBarButton
        
        // Set delegate and datasource for tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // Remove empty cells
        tableView.tableFooterView = UIView()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        // Download quizzes
        startConnection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Create settings popover
    @IBAction func gotoSettings(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let newURLAction = UIAlertAction(
            title: "New URL",
            style: UIAlertActionStyle.Default)
            { (action) in
                self.enterNewURL()
            }
        
        let refreshAction = UIAlertAction(
            title: "Refresh Quizzes",
            style: UIAlertActionStyle.Default)
            { (action) in
                self.startConnection()
            }
        
        let closeAction = UIAlertAction(
            title: "Close",
            style: UIAlertActionStyle.Cancel)
            { (action) in
            }
        
        alertController.addAction(newURLAction)
        alertController.addAction(refreshAction)
        alertController.addAction(closeAction)
        
        alertController.modalPresentationStyle = .Popover
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Create New URL popover
    func enterNewURL() {
        let alertController = UIAlertController(title: "Enter new URL", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        let closeAction = UIAlertAction(
            title: "Close",
            style: UIAlertActionStyle.Cancel)
            { (action) in
            }
        
        let OKAction = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default)
            { (action) in
                let tf = alertController.textFields?.first as? UITextField
                self.defaults.setValue(tf!.text, forKey: "url")
                
                self.startConnection()
            }
        
        alertController.addAction(closeAction)
        alertController.addAction(OKAction)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "New URL"
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Start retrieving quizzes
    func startConnection() {
        let path : String = quizURL
        var url : NSURL = NSURL(string: path)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        
        connection.start()
        
        println("Connection started!")
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.data.setData(data)
        
        println("Appended to data!")
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        println("Finished loading!")
        
        var jsonResult: NSMutableArray = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSMutableArray
        
        objects = makeQuizzes(jsonResult)
        defaults.setObject(jsonResult, forKey: "quizList")
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    func makeQuizzes(jsonResult: NSMutableArray!) -> [Quiz]{
        var newQuizList : [Quiz] = []
        
        for var i : Int = 0; i < jsonResult.count as Int; i++ {
            var currentQuiz: AnyObject = jsonResult[i]
            
            var newQuestions : [Question] = []
            var givenQuestions : [AnyObject] = currentQuiz["questions"] as! [AnyObject]
            
            for var j : Int = 0; j < count(givenQuestions); j++ {
                var currentQuestion: AnyObject = givenQuestions[j]
                
                var correct : Int = (currentQuestion["answer"] as! String).toInt()! - 1
                
                var newQuestion = Question(prompt: currentQuestion["text"] as! String, answers: currentQuestion["answers"] as! [String], correctAnswer: correct)
                
                newQuestions.append(newQuestion)
            }
            
            var newQuiz = Quiz(title: currentQuiz["title"] as! String, description: currentQuiz["desc"] as! String, imagePath: "", questions: newQuestions)
            
            newQuizList.append(newQuiz)
        }
        
        return newQuizList
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let chosen = objects[indexPath.row]
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as!DetailViewController
            controller.chosenQuiz = chosen
            controller.questionNumber = 0
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let q = self.objects[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("MasterCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = q.title
        cell.detailTextLabel?.text = q.description
        cell.imageView?.image = UIImage(named: q.imagePath)
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
    // Represents one quiz
    class Quiz {
        var title : String
        var description : String
        var imagePath : String
        var questions : [Question]
        
        init (title : String, description : String, imagePath : String, questions : [Question]) {
            self.title = title
            self.description = description
            self.imagePath = imagePath
            self.questions = questions
            
        }
        
        func addQuestion(question : Question) {
            questions.append(question)
        }
    }
    
    // Represents one question in a quiz
    class Question {
        var prompt : String
        var answers : [String]
        var correctAnswer : Int
        
        init (prompt : String, answers : [String], correctAnswer : Int) {
            self.prompt = prompt
            self.answers = answers
            self.correctAnswer = correctAnswer
        }
        
        func addAnswer(answer : String) {
            answers.append(answer)
        }
        
        func setCorrectAnswer(index : Int) {
            if index < count(answers) && index > -1 {
                correctAnswer = index
            }
        }
    }
    
    // Represents all default quizes in an array
    class QuizData {
        var data : [Quiz]
        
        init() {
            data = []
            
            let q1 = Quiz(title: "Math", description: "Like numbers? You won't after this.", imagePath: "math.jpg", questions: [])
            let q2 = Quiz(title: "Marvel Super Heroes", description: "Test your quiz might against these heroes!", imagePath: "marvel.jpeg", questions: [])
            let q3 = Quiz(title: "Science", description: "All the chem jokes Argon.", imagePath: "science.jpg", questions: [])
            
            let question1 = Question(prompt: "What is 2 + 2?", answers: ["1", "2", "3", "4"], correctAnswer: 3)
            let question2 = Question(prompt: "What is the derivative of 2x?", answers: ["2", "x", "2x", "2y"], correctAnswer: 0)
            let question3 = Question(prompt: "What is 3 factorial?", answers: ["3", "6", "9", "369"], correctAnswer: 1)
            
            q1.addQuestion(question1)
            q1.addQuestion(question2)
            q1.addQuestion(question3)
            data.append(q1)
            
            let question4 = Question(prompt: "Who is not a Marvel hero?", answers: ["Hulk", "Iron Man", "Captain Marvel", "Green Lantern"], correctAnswer: 3)
            let question5 = Question(prompt: "Who is not a part of the Avengers?", answers: ["Captain America", "Black Widow", "Batman", "Bruce Banner"], correctAnswer: 2)
            let question6 = Question(prompt: "What is Spiderman's alter ego?", answers: ["Joey McSpider", "Peter Parker", "Bobby EightLegs", "Mickey Van Der Tarantula"], correctAnswer: 1)
            
            q2.addQuestion(question4)
            q2.addQuestion(question5)
            q2.addQuestion(question6)
            data.append(q2)
            
            let question7 = Question(prompt: "What is not an element on the periodic table?", answers: ["Tin", "Silver", "Aluminum", "Graphite"], correctAnswer: 3)
            let question8 = Question(prompt: "What is the universal solvent?", answers: ["Fire", "Air", "Water", "Earth"], correctAnswer: 2)
            let question9 = Question(prompt: "What element has fewest protons?", answers: ["Lead", "Hydrogen", "Helium", "Mercury"], correctAnswer: 1)
            
            q3.addQuestion(question7)
            q3.addQuestion(question8)
            q3.addQuestion(question9)
            data.append(q3)
        }
        
        func getQuizzes() -> [Quiz] {
            return data
        }
    }
}