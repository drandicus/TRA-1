//
//  Login_View.swift
//  TRA
//
//  Created by Neil Pineda on 11/7/15.
//  Copyright (c) 2015 CBI LLC. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import Bolts
import FBSDKCoreKit
import FBSDKLoginKit

class Login_View: UIViewController, FBSDKLoginButtonDelegate {
    
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let permissions = ["public_profile", "email", "user_friends"]
    
    var email_string: String?
    var password_string: String?
    
    //facebook login user data variables
    var email: String?
    var gender: String?
    var first_name: String?
    var last_name: String?
    var email_bool: Bool?
    var password_bool: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (FBSDKAccessToken.currentAccessToken() == nil)
        {
            print("Not logged in..")
        }
        else
        {
            print("Logged in..")
        }
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        self.password_bool = false
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
            if identifier == "Home_Segue" {
                
                print(password_bool, terminator: "")
                //do not segue if password or email are empty
                if userTextField.text == "" {
                    return false
                }
                
                else if passwordTextField.text == ""{
                    return false
                }
                
                // do not segue if email does not exist
                else if email_bool == false {
                    return false
                }
                // do not segue if password does not match
                else if password_bool == false {
                    return false
                }
            }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Fuck you Neil")
        if(segue.identifier == "Home_Segue") {
            
            let Home_Page:Home_View_Controller = segue.destinationViewController as! Home_View_Controller
            Home_Page.Email = self.email_string
            Home_Page.Password = self.password_string
        }
    }
    
    @IBAction func Sign_In(sender: AnyObject) {
        email_string = userTextField.text
        password_string = passwordTextField.text
        
        if email_string == "" {
            displayError("Type in Email")
            return
        }
        
        if password_string == "" {
            displayError("Type in Password")
            return
        }
        
        // validate password with email
        // case where email does not exist in database
        let query = PFQuery(className: "User")
        query.whereKey("Email", equalTo: email_string!)
        query.whereKey("Facebook", equalTo: false)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil && objects!.count == 0{
                self.displayError("Email does not exist.")
                self.email_bool = false
                return
            }
            else {
                //found email - okay for segue
                self.email_bool = true
                // validate password with email
                //TODO: ENCRYPT FUCKING PASSWORD
                query.whereKey("Password", equalTo: self.password_string!)
                query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if error == nil && objects!.count == 0{
                        self.displayError("Incorrect Password")
                        self.password_bool = false
                        return
                    }
                    else {
                        // segue to home page!
                        self.password_bool = true
                        self.performSegueWithIdentifier("Home_Segue", sender: self)
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
    
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        if error == nil
        {
            print("Login complete.")
            returnUserData()
            print(result)
        }
        else
        {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        print("User logged out...")
    }
    
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name, name, gender"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                let query = PFQuery(className: "User")
                query.whereKey("Email", equalTo: result.valueForKey("email")!)
                query.whereKey("Facebook", equalTo: true)
                query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if error != nil{
                        print("Error: \(error)")
                        return
                    }
                    
                    if objects!.count > 0{
                        //segue to home
                        //store email in core data or some fuckign where
                        print("I have properly signed in")
                        return
                    } else {
                        let upload = PFObject(className: "User")
                        
                        upload.setObject(result.valueForKey("first_name")!, forKey: "First_Name")
                        upload.setObject(result.valueForKey("last_name")!, forKey: "Last_Name")
                        upload.setObject(result.valueForKey("email")!, forKey: "Email")
                        upload.setObject(result.valueForKey("gender")!, forKey: "Gender")
                        upload.setObject(true, forKey: "Facebook")
                        
                        
                        upload.saveInBackgroundWithBlock { (succeeded, error) -> Void in
                            if succeeded {
                                print("Object Uploaded")
                            }
                        }
                        
                    }
                    
                }
                
                
            }
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}