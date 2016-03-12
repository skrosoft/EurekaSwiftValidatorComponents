//
//  ViewController.swift
//  Examples
//
//  Created by Demetrio Filocamo on 12/03/2016.
//  Copyright © 2016 Novaware Ltd. All rights reserved.
//

import UIKit
import Eureka
import SwiftValidator

class ViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form =
            Section("Insert your data")
            
            <<< SVTextRow() {
                $0.title = "Name"
                $0.placeholder = "Insert your full name"
                $0.rules = [RequiredRule(), FullNameRule(), MinLengthRule(length: 5), MaxLengthRule(length: 10)]
                $0.autoValidation = false
            }
            
            <<< SVTextRow() {
                $0.title = "Email"
                $0.placeholder = ""
                $0.rules = [RequiredRule(), EmailRule()]
                $0.autoValidation = false
            }
            
            <<< SVTextRow() {
                $0.title = "Street"
                $0.placeholder = "First line"
                $0.rules = [RequiredRule(), MinLengthRule(length: 5), MaxLengthRule(length: 10)]
                $0.autoValidation = false
            }
            
            <<< SVTextRow() {
                $0.title = " "
                $0.placeholder = "Optional second line"
                $0.autoValidation = false
            }
            
            <<< SVTextRow() {
                $0.title = "City"
                $0.placeholder = ""
                $0.rules = [RequiredRule()]
                $0.autoValidation = false
            }
            
            <<< SVTextRow() {
                $0.title = "Post Code"
                $0.placeholder = ""
                $0.rules = [RequiredRule()]
                $0.autoValidation = false
            }
            
            <<< SVTextRow() {
                $0.title = "Country"
                $0.placeholder = ""
                $0.value = "United Kingdom"
                $0.rules = [RequiredRule()]
                $0.autoValidation = false
                }
            
            
            +++ Section("")
    }
    
    @IBAction func saveClicked(sender: AnyObject) {
        let dataValid = form.validateAll()
        
        if dataValid {
            NSLog("Valid")
        } else {
            NSLog("Invalid")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

