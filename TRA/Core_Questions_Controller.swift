//
//  Core_Questions_Controller.swift
//  TRA
//
//  Created by Diego Deveras on 11/22/15.
//  Copyright © 2015 CBI LLC. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI
import Bolts


struct AnswerStruct {
    var question:String, answer:String, weight:Int
}

struct QuestionStruct{
    var id: String;
    var text:String;
    var possibleAnswers:Array<String>;
}

class Core_Question_Controller: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var email: String?
    var index = 0
    
    @IBOutlet weak var questionCount: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTable: UITableView!
    @IBOutlet weak var notImportant: UIButton!
    @IBOutlet weak var important: UIButton!
    @IBOutlet weak var veryImportant: UIButton!
    @IBOutlet weak var next: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var currentWeight = -1
    var questions = [QuestionStruct]()
    var answers = [AnswerStruct]()
    var currentAnswer = -1
    var maxAnswer = 0
    var done = false
    
    
    /**
     Initializes the page
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.answerTable.delegate = self
        self.answerTable.dataSource = self
        self.answerTable.scrollEnabled = false
        self.backButton.hidden = true
        self.retrieveQuestions()
    }

    /**
     This function gets the proper questions from the Parse DB
     and stores it in the questions array
    */
    func retrieveQuestions(){
        
        self.questions = [QuestionStruct]()
        
        let query:PFQuery = PFQuery(className: "Questions")
        query.whereKey("core", equalTo:true)
        
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            
            for object in (objects)!{
                
                let questionID = (object.objectId)! as String
                let question = object as PFObject
                let questionText = question["question"] as? String
                let possibleAnswers = question["possibleAnswers"] as? Array<String>
                self.questions.append(QuestionStruct(id: questionID, text: questionText!, possibleAnswers: possibleAnswers!))
            }
            
            self.displayQuestion()
        }
    }
    
    /*
    Checks whether the conditions for segue-ing are met, if so, allows segue
    */
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return done
    }
    
    /*
    How to pass variables
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "Done_Segue") {
            let Home_Page:Home_View_Controller = segue.destinationViewController as! Home_View_Controller
            Home_Page.Email = email
        }
    }
    
    /**
     This function displays the question onto the UI
     Also serves to reset the UI
    */
    func displayQuestion(){
        
        self.questionCount.text = String(self.index + 1) + "/10 Questions Answered"
        self.questionLabel.text = self.questions[index].text
        
        self.notImportant.backgroundColor = UIColor.whiteColor()
        self.important.backgroundColor = UIColor.whiteColor()
        self.veryImportant.backgroundColor = UIColor.whiteColor()
        
        self.currentWeight = -1
        self.currentAnswer = -1
        
        dispatch_async(dispatch_get_main_queue()){
            self.answerTable.reloadData();
        }
    }
    
    /**
    These functions set the weight of the answer depending on the button selected
     */
    @IBAction func notImportantClick(sender: AnyObject) {
        self.notImportant.backgroundColor = UIColor.blueColor()
        self.important.backgroundColor = UIColor.whiteColor()
        self.veryImportant.backgroundColor = UIColor.whiteColor()
        self.currentWeight = 0
    }
    
    @IBAction func importantClick(sender: AnyObject) {
        self.notImportant.backgroundColor = UIColor.whiteColor()
        self.important.backgroundColor = UIColor.blueColor()
        self.veryImportant.backgroundColor = UIColor.whiteColor()
        
        self.currentWeight = 1
    }
    
    @IBAction func veryImportantClick(sender: AnyObject) {
        self.notImportant.backgroundColor = UIColor.whiteColor()
        self.important.backgroundColor = UIColor.whiteColor()
        self.veryImportant.backgroundColor = UIColor.blueColor()
        self.currentWeight = 2
    }
    
    /* This handles then the user selects the next option */
    @IBAction func nextClick(sender: AnyObject) {
        if !self.errorCheck() {
            return
        }
        
        self.backButton.hidden = false
        
        let newAnswer = AnswerStruct(question: self.questions[index].id, answer: self.questions[index].possibleAnswers[self.currentAnswer], weight: self.currentWeight)
        
        self.answers.append(newAnswer)
        self.index += 1
        
        if self.index == 9{
            self.next.setTitle("Done", forState: UIControlState.Normal)
        }
        
        if self.index == 10{
            self.saveAnswers()
        } else {
            self.displayQuestion()
        }
    }
    
    /* This function checks whether the user has properly answered the question */
    func errorCheck() -> Bool{
        return self.currentWeight != -1 || self.currentAnswer != -1
    }
    
    
    @IBAction func backClick(sender: AnyObject) {
        self.index -= 1
        if index == 0 {
            self.backButton.hidden = true
        } else if self.index == 8 {
            self.next.setTitle("Next", forState: UIControlState.Normal)
        }
        
        self.displayQuestion()
    }
    
    func saveAnswers(){
        done = true
        var parseObjects = [PFObject]()
        var counter = 0
        for answer in self.answers{
            let newAnswer:PFObject = PFObject(className: "Answer")
            newAnswer["user"] = self.email
            newAnswer["questionID"] = self.questions[counter].id
            newAnswer["answer"] = answer.answer
            newAnswer["Weight"] = answer.weight
            
            counter += 1
            
            parseObjects.append(newAnswer)
        }
        
        do {
            try PFObject.saveAll(parseObjects)
            performSegueWithIdentifier("Done_Segue", sender: nil)
        } catch _ {
            print("FUCK ALL Y'ALL")
        }
        
    }
    
    //Mark: Table View Methods
    
    /**
    This function sets up the cells in the table view
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (self.answerTable.dequeueReusableCellWithIdentifier("AnswerCell"))! as UITableViewCell
        cell.textLabel?.text = self.questions[index].possibleAnswers[indexPath.row]
        tableView.estimatedRowHeight = 10.0
        tableView.rowHeight = UITableViewAutomaticDimension
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping

        return cell
    }
    
    /**
     This function handles the number of rows in the table
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.questions.count == 0 {
            return 0
        }
        
        return self.questions[index].possibleAnswers.count
    }
    
    /*
     This function handles the event clicking for the UI table view row
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        self.currentAnswer = indexPath.row
    }
    
    
    
    
}