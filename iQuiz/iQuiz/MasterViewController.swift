//
//  MasterViewController.swift
//  iQuiz
//
//  Created by Alex N. Schenck on 11/2/15.
//  Copyright (c) 2015 Alex Schenck. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    class Quiz {
        var title : String
        var description : String
        var imagePath : String
        
        init (title : String, description : String, imagePath : String) {
            self.title = title
            self.description = description
            self.imagePath = imagePath
        }
    }
    
    class QuizData {
        var data : [Quiz]
        
        init() {
            data = []
            
            let q1 = Quiz(title: "Math", description: "Like numbers? You won't after this.", imagePath: "math.jpg")
            let q2 = Quiz(title: "Marvel Super Heroes", description: "Test your quiz might against these heroes!", imagePath: "marvel.jpeg")
            let q3 = Quiz(title: "Science", description: "All the chem jokes Argon.", imagePath: "science.jpg")
            
            data.append(q1)
            data.append(q2)
            data.append(q3)
        }
        
        func getQuizzes() -> [Quiz] {
            return data
        }
    }
    
    var detailViewController: DetailViewController? = nil
    var objects : [Quiz] = QuizData().getQuizzes()

    @IBOutlet weak var SettingsBarButton: UIBarButtonItem!

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        /*
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        */
        
        self.navigationItem.leftBarButtonItem = SettingsBarButton
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        tableView.tableFooterView = UIView()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
    }

    @IBAction func gotoSettings(sender: AnyObject) {
        let alertController = UIAlertController(title: "Settings", message: "Settings go here", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Sounds good", style: .Default) { (action) in
        }
        
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = objects[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object.title
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
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


}