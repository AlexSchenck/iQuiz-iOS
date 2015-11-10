//
//  DetailViewController.swift
//  iQuiz
//
//  Created by Alex N. Schenck on 11/2/15.
//  Copyright (c) 2015 Alex Schenck. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var QuestionPrompt: UILabel!
    @IBOutlet weak var QuestionAnswerPicker: UIPickerView!
    @IBOutlet weak var QuestionAnswerSubmitButton: UIButton!
    @IBOutlet weak var CorrectAnswer: UILabel!
    @IBOutlet weak var CorrectAnswerIndicator: UILabel!
    @IBOutlet weak var ContinueButton: UIButton!
    @IBOutlet weak var FinishButton: UIButton!
    @IBOutlet weak var ResultsLabel: UILabel!
    
    @IBOutlet var QuestionView: UIView!
    @IBOutlet var AnswerView: UIView!
    @IBOutlet var FinishView: UIView!
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return count(chosenQuiz.questions[questionNumber].answers)
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return chosenQuiz.questions[questionNumber].answers[row]
    }
    
    var chosenQuiz : MasterViewController.Quiz  = MasterViewController.Quiz(title: "", description: "", imagePath: "", questions: [])
    var questionNumber : Int = 0
    var chosenAnswer : Int = 0
    var numberCorrect : Int = 0
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        // Find out what view loaded, load resulting info into view
        // FinishView
        if (FinishView != nil)
        {
            ResultsLabel.text = "You're done! You got \(numberCorrect) right out of \(count(chosenQuiz.questions))."
        }
        else
        {
            var currentQuestion = chosenQuiz.questions[questionNumber]
            
            // QuestionView
            if (QuestionView != nil) {
                QuestionPrompt.text = currentQuestion.prompt
            }
            // AnswerView
            else if (AnswerView != nil) {
                CorrectAnswer.text = currentQuestion.answers[currentQuestion.correctAnswer]
                
                if (chosenAnswer == currentQuestion.correctAnswer)
                {
                    CorrectAnswerIndicator.text = "You were right!"
                    numberCorrect++
                }
                else
                {
                    CorrectAnswerIndicator.text = "Your answer was wrong :("
                }
                
                questionNumber++
                
                if (questionNumber < count(chosenQuiz.questions)) {
                    FinishButton.hidden = true
                }
                else {
                    ContinueButton.hidden = true
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let barItem = sender as? UIBarButtonItem {
        }
        else {
            // Set new chosen answer if it was QuestionView
            if (QuestionView != nil)
            {
                chosenAnswer = QuestionAnswerPicker.selectedRowInComponent(0)
            }
        
            // Go to next detailView if current view is not FinishView
            if (FinishView == nil)
            {
                let controller = segue.destinationViewController as! DetailViewController
                controller.navigationItem.backBarButtonItem?.target = self.navigationController
                controller.navigationItem.backBarButtonItem?.title = "Main Menu"
                controller.chosenQuiz = chosenQuiz
                controller.questionNumber = questionNumber
                controller.chosenAnswer = chosenAnswer
                controller.numberCorrect = numberCorrect
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

