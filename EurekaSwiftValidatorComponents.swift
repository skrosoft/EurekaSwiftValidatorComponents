//
//  EurekaCustomCells.swift
//
//  Created by Demetrio Filocamo on 29/01/2016.
//

import UIKit
import Foundation
import Eureka
import SwiftValidator
import WebKit

import ObjectiveC

/**
*  Protocol for cells that contain a UITextField that can be validated
*/
public protocol SVTextFieldCell : TextFieldCell {
    var errorColor : UIColor { get }
    func setErrorColor(_ errorColor: UIColor)
    var rules : [Rule]? { get }
    func setRules(_ rules: [Rule]?)
    var autoValidation : Bool { get }
    func setAutoValidation(_ autoValidation: Bool)
    var valid : Bool { get }

    func validate()
}

open class _SVFieldCell<T>: _FieldCell<T>, SVTextFieldCell where T: Equatable, T: InputTypeInitiable{

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy open var validationLabel: UILabel = {
        [unowned self] in
        let validationLabel = UILabel()
        validationLabel.translatesAutoresizingMaskIntoConstraints = false
        validationLabel.font = validationLabel.font.withSize(10.0)
        return validationLabel
    }()

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .default
        textField.autocapitalizationType = .sentences
        textField.keyboardType = .default

        self.height = {
            60
        }
        contentView.addSubview(validationLabel)

//        let viewDictionary = ["cell": self, "validationLabel": self.validationLabel, "textField": self.textField, "label": self.titleLabel!]
//        let fixedHeight: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("V:[validationLabel(15)]", options: .AlignAllCenterX, metrics: nil, views: viewDictionary)
//        let yPosition: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("V:[textField]-4-[validationLabel]", options: .AlignAllCenterX, metrics: nil, views: viewDictionary)
//        let xPosition: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[validationLabel]-|", options: .AlignAllCenterX, metrics: nil, views: viewDictionary)
        let sameLeading: NSLayoutConstraint = NSLayoutConstraint(item: self.contentView, attribute: .leading, relatedBy: .equal, toItem: self.validationLabel, attribute: .leading, multiplier: 1, constant: -20)
        let sameTrailing: NSLayoutConstraint = NSLayoutConstraint(item: self.textField, attribute: .trailing, relatedBy: .equal, toItem: self.validationLabel, attribute: .trailing, multiplier: 1, constant: 0)
        let sameBottom: NSLayoutConstraint = NSLayoutConstraint(item: self.contentView, attribute: .bottom, relatedBy: .equal, toItem: self.validationLabel, attribute: .bottom, multiplier: 1, constant: 4)
        let all: [NSLayoutConstraint] = [sameLeading, sameTrailing, sameBottom]
//        all += fixedHeight
//        all += yPosition
//        all += xPosition

        contentView.addConstraints(all)

        validationLabel.textAlignment = NSTextAlignment.right
        validationLabel.adjustsFontSizeToFitWidth = true
        validationLabel.text = ""
        resetField()


    }

    open func setRules(_ rules: [Rule]?) {
        self.rules = rules
    }

    open func setErrorColor(_ errorColor: UIColor) {
        self.errorColorI = errorColor
    }

    open func setAutoValidation(_ autoValidation: Bool) {
        self.autoValidationI = autoValidation
    }

    override open func textFieldDidChange(_ textField: UITextField) {
        super.textFieldDidChange(textField)

        if autoValidation {
            validate()
        }
    }

    // MARK: - Validation management

    open func validate() {
        if let v = self.validator {
            // Registering the rules
            if !rulesRegistered {
                v.unregisterField(textField)  //  in case the method has already been called
                if let r = rules {
                    v.registerField(textField, errorLabel: validationLabel, rules: r)
                }
                self.rulesRegistered = true
            }

            self.valid = true

            v.validate({
                (errors) -> Void in
                self.resetField()
                for (field, error) in errors {
                    self.valid = false
                    self.showError(field, error: error)
                }
            })
        } else {
            self.valid = false
        }
    }

    func resetField() {
        validationLabel.isHidden = true
        textField.textColor = UIColor.black
        self.textLabel?.textColor = UIColor.black
    }

    func showError(_ field: UITextField, error: SwiftValidator.ValidationError) {
        // turn the field to red
        field.textColor = errorColor
        if let ph = field.placeholder {
            let str = NSAttributedString(string: ph, attributes: [NSForegroundColorAttributeName: errorColor])
            field.attributedPlaceholder = str
        }
        self.textLabel?.textColor = errorColor
        self.validationLabel.textColor = errorColor
        error.errorLabel?.text = error.errorMessage // works if you added labels
        error.errorLabel?.isHidden = false
    }

    var validator: Validator? {
        get {
            if let fvc = formViewController() {
                return fvc.form.validator
            }
            return nil;
        }
    }
    fileprivate var rulesRegistered = false
    fileprivate var errorColorI : UIColor = UIColor.red
    fileprivate var autoValidationI = true

    open var errorColor : UIColor{
        get {
            return errorColorI
        }
    }
    open var autoValidation : Bool {
        get {
            return autoValidationI
        }
    }
    open var rules: [Rule]? = nil

    open var valid = false
}

//             FieldRow<T: Any, Cell: CellType where Cell: BaseCell, Cell: TypedCellType, Cell: TextFieldCell, Cell.Value == T>: Row<T, Cell>, FieldRowConformance, KeyboardReturnHandler
open class SVFieldRow<T: Any, Cell: CellType>: FieldRow<Cell> where Cell: BaseCell, Cell: TypedCellType, Cell: SVTextFieldCell, Cell.Value == T {
    public required init(tag: String?) {
        super.init(tag: tag)
    }

    open var errorColor: UIColor {
        get {
            return self.cell.errorColor
        }
        set {
            self.cell.setErrorColor(newValue)
        }
    }

    /*public var validator: Validator {
        get {
            return self.cell.validator
        }
        set {
            self.cell.setValidator(newValue)
        }
    }*/

    open var rules: [Rule]? {
        get {
            return self.cell.rules
        }
        set {
            self.cell.setRules(newValue)
        }
    }

    open var autoValidation: Bool {
        get {
            return self.cell.autoValidation
        }
        set {
            self.cell.setAutoValidation(newValue)
        }
    }

    open var valid: Bool {
        get {
            return self.cell.valid
        }
    }

    open func validate() {
        self.cell.validate()
    }
}

open class _SVTextRow: SVFieldRow<String, SVTextCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

open class _SVIntRow: SVFieldRow<Int, SVIntCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = NSLocale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        formatter = numberFormatter
    }
}

open class _SVEmailRow: SVFieldRow<String, SVEmailCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

open class _SVPhoneRow: SVFieldRow<String, SVPhoneCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

open class _SVPasswordRow: SVFieldRow<String, SVPasswordCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A String valued row where the user can enter arbitrary text.

public final class SVTextRow: _SVTextRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        /*onCellHighlight {
            cell, row in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight {
                cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }*/
    }
}

/// A row where the user can enter an integer number.
public final class SVIntRow: _SVIntRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        /*onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }*/
    }
}

/// A String valued row where the user can enter an email address.
public final class SVEmailRow: _SVEmailRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        /*onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }*/
    }
}

/// A String valued row where the user can enter a phone number.
public final class SVPhoneRow: _SVPhoneRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        /*onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }*/
    }
}

public final class SVPasswordRow: _SVPasswordRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        /*onCellHighlight { cell, row  in
         let color = cell.textLabel?.textColor
         row.onCellUnHighlight { cell, _ in
         cell.textLabel?.textColor = color
         }
         cell.textLabel?.textColor = cell.tintColor
         }*/
    }
}

open class SVTextCell: _SVFieldCell<String>, CellType  {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .default
        textField.autocapitalizationType = .sentences
        textField.keyboardType = .default
    }
}

open class SVIntCell : _SVFieldCell<Int>, CellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .default
        textField.autocapitalizationType = .none
        textField.keyboardType = .numberPad
    }
}

open class SVEmailCell : _SVFieldCell<String>, CellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
    }
}

open class SVPhoneCell : _SVFieldCell<String>, CellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func setup() {
        super.setup()
        textField.keyboardType = .phonePad
    }
}

open class SVPasswordCell: _SVFieldCell<String>, CellType  {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .asciiCapable
        textField.isSecureTextEntry = true
    }
}

// TODO extend _FieldCell and _FieldRow to avoid custom components
// TODO better way for styleTransformers

extension Form {

    fileprivate struct AssociatedKey {
        static var validator: UInt8 = 0
        static var dataValid: UInt8 = 0
    }

    var validator: Validator {
        get {
            if let validator = objc_getAssociatedObject(self, &AssociatedKey.validator) {
                return validator as! Validator
            } else {
                let v = Validator()
                self.validator = v
                return v
            }
        }

        set {
            objc_setAssociatedObject(self, &AssociatedKey.validator, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var dataValid: Bool {
        get {
            if let dv = objc_getAssociatedObject(self, &AssociatedKey.dataValid) {
                return dv as! Bool
            } else {
                let dv = false
                self.dataValid = dv
                return dv
            }
        }

        set {
            objc_setAssociatedObject(self, &AssociatedKey.dataValid, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func validateAll() -> Bool {
        dataValid = true

        let rows = allRows
        for row in rows {
            if row is SVTextRow {
                let svRow = (row as! SVTextRow)
                svRow.evaluateHidden()
                if !svRow.isHidden { // skip if hidden
                    svRow.validate()
                    let rowValid = svRow.valid
                    svRow.autoValidation = true // from now on autovalidation is enabled
                    if !rowValid && dataValid {
                        dataValid = false
                    }
                }
            }
        }
        return dataValid
    }
}
