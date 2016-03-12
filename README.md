# Eureka Swift Validator Components

Eureka custom inline rows supporting SwiftValidator

Version 0.1

### Example

Define the rows and add the rules there (plus turn off autoValidation if you like):

```swift
form =
            Section("Insert your data")
            
            <<< SVTextRow() {
                $0.title = "Name"
                $0.placeholder = "Insert your full name"
                $0.rules = [RequiredRule(), FullNameRule(), MinLengthRule(length: 5), MaxLengthRule(length: 10)]
                $0.autoValidation = false
            }
```

If autoValidation is off, validate all the rows:

```swift
	@IBAction func saveClicked(sender: AnyObject) {
        let dataValid = form.validateAll()
        
        if dataValid {
            NSLog("Valid")
        } else {
            NSLog("Invalid")
        }
    }
```

### Screenshot
![Example](example.png)

### TODO
* pod specs
* Support for more types
