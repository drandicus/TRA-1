//
//  Home_View_Controller.swift
//  TRA
//
//  Created by Neil Pineda on 11/7/15.
//  Copyright (c) 2015 CBI LLC. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import Bolts

class Home_View_Controller: UIViewController {
    var Email: String?
    var Password: String?
    
    @IBOutlet weak var Email_Label: UILabel!
    @IBOutlet weak var Password_Label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Email_Label.text = Email
    }
    
    /*
    How to pass variables
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let questionPage:Core_Question_Controller = segue.destinationViewController as! Core_Question_Controller
        questionPage.email = self.Email
    }
    
}
