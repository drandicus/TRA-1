//
//  Sign_Up.swift
//  TRA
//
//  Created by Neil Pineda on 11/7/15.
//  Copyright (c) 2015 CBI LLC. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import Bolts


class Sign_Up: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var First_Name: UITextField!
    @IBOutlet weak var Last_Name: UITextField!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var Retype_Password: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var Gender: UITextField!
    
    var user_birthday: NSDate?
    var birthday: String?
    var age: Int?
    var user_gender: String?
    var first_name: String?
    var last_name: String?
    var email_string: String?
    var password_string: String!
    var retype_password: String?
    var valid_email: Bool?
    var password_length: Int?
    var pickOption = ["", "Male", "Female"]
    
    //bool verification variables
    var tests_passed_bool: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        
        Gender.inputView = pickerView
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    /*
        Checks whether the conditions for segue-ing are met, if so, allows segue
    */
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
            if identifier == "Sign_Up_Segue" {
                // do not segue if password does not match
                if tests_passed_bool == false {
                    return false
                }
            }
        
        return true
    }
    
    /*
        How to pass variables
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "Sign_Up_Segue") {
            let CoreQuestions:Core_Question_Controller = segue.destinationViewController as! Core_Question_Controller
            CoreQuestions.email = self.email_string
        }
    }
    
    
    @IBAction func Sign_Up_Button(sender: AnyObject) {
        
        first_name = First_Name.text
        last_name = Last_Name.text
        email_string = Email.text
        password_string = Password.text
        retype_password = Retype_Password.text
        birthday = dateTextField.text
        user_gender = Gender.text
        
        
        //Acceptance tests
        //1.  User needs to meet password criteria *** Working
        password_length = password_string.characters.count
        if password_length < 5 || password_length > 16 {
            displayError("Password must be between 6-15 characters.")
            tests_passed_bool = false
            return
        }
        
        
        //2.  User needs to have password and retype password the same *** Working
        if password_string != retype_password {
            displayError("Passwords do not match.")
            tests_passed_bool = false
            return
        }
        
        //3.  Make sure all fields are filled *** Working
        if First_Name.text == "" || Email.text == "" || Password.text == "" || Retype_Password.text == ""{
            displayError("Please fill in all fields")
            tests_passed_bool = false
            return
        }
        
        //4. Make sure email is a valid email
        
        valid_email = validateEmail(email_string!)
        
        if valid_email == false{
            displayError("Not a Valid Email")
            tests_passed_bool = false
            return
        }
        
        //5. Make sure the user selected an age
        let differenceComponents = NSCalendar.currentCalendar().components(.Year, fromDate: user_birthday!, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0) )
        age = differenceComponents.year
        
        if birthday == "" {
            displayError("Select Birthday")
            tests_passed_bool = false
            return
        }
        
        //6.  Make sure the user selected gender
        if user_gender == "" {
            displayError("Select Gender")
            tests_passed_bool = false
            return
        }
        
        
        //7. Redundancy Check for emails within database.
        
        let query = PFQuery(className: "User")
        query.whereKey("Email", equalTo: email_string!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil && objects!.count != 0{
                self.displayError("Email already exists")
                return
                
            } else {
                
                let User = PFObject(className: "User")
                User.setObject(self.first_name!, forKey: "First_Name")
                User.setObject(self.last_name!, forKey: "Last_Name")
                User.setObject(self.email_string!, forKey: "Email")
                User.setObject(self.password_string!, forKey: "Password")
                User.setObject(self.age!, forKey: "Age")
                User.setObject(false, forKey: "Facebook")
                User.setObject(self.user_gender!, forKey: "Gender")
                User.saveInBackgroundWithBlock { (succeeded, error) -> Void in
                    if succeeded {
                        print("Object Uploaded")
                        self.tests_passed_bool = true
                        self.performSegueWithIdentifier("Sign_Up_Segue", sender: self)
                    }
                    else {
                    }
                }
            }
        }
    }
    
    func displayError(errorMessage: String!)-> Void{
        let alert = UIAlertView()
        alert.title = "Error"
        alert.message = errorMessage
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
    
    //date select code
    @IBAction func textFieldEditing(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }

    
    //date select code
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        dateTextField.text = dateFormatter.stringFromDate(sender.date)
        
        user_birthday = dateFormatter.dateFromString(dateTextField.text!)
        
    }    
    
    // gender select code
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Gender.text = pickOption[row]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
