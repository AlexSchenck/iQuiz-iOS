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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

