//
//  ViewController.swift
//  Chapter01_SwiftBasic
//
//  Created by Larry Johnson on 8/12/18.
//  Copyright © 2018 Larry Johnson. All rights reserved.
//

import UIKit


class ViewController: UIViewController,UITextFieldDelegate, UITableViewDataSource {
    var historyArray:[String] = []

    @IBOutlet var amountTextField: UITextField!

    @IBOutlet var tipPercentLabel: UILabel!
    
    @IBOutlet var tipPercentSlider: UISlider!
    
    @IBOutlet var totalAmountLabel: UILabel!

    @IBOutlet var historyTable: UITableView!

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /** The return value for dequeueReusableCell is AnyObject
        This will cause a runtime error if the object returned is not a UITableViewCell,
        but because this is an Apple API and the Objective-C version of this API returned a UITableViewCell object,
        you can be pretty sure that whatever object is returned will either be a UITableViewCell type or inherit from it.
        **/
        var aCell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier:"MY_CELL", for:indexPath) as UITableViewCell
        aCell.textLabel!.text = historyArray[indexPath.row]
        return aCell
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        amountTextField.text = "0.00"
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        var intValue:Int = Int(tipPercentSlider.value)
        tipPercentLabel!.text = numberFormatter.string(from: NSNumber(value: intValue))
        let amount = convertAmountTextStringToFloat()
        let percentage = 0.01 * tipPercentSlider.value
        let totalAmount = percentage * amount
        numberFormatter.numberStyle = .currency
        totalAmountLabel.text = numberFormatter.string(from: NSNumber(value: totalAmount))
        historyTable.register(UITableViewCell.self, forCellReuseIdentifier: "MY_CELL")
    }


    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }

    @IBAction func handleAddToHistory(sender:AnyObject) {
        var now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var totalAmount = totalAmountAsFloat()
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        let historyString = dateFormatter.string(from: now) + "-" + numberFormatter.string(from: NSNumber(value: totalAmount))!
        historyArray.append(historyString)
        historyTable.reloadData()
    }

    @IBAction func handlePercentageChanged(sender:AnyObject) {
        let numberFormmater = NumberFormatter()
        numberFormmater.numberStyle = .decimal
        var intValue = sliderValueAsInt()
        tipPercentLabel.text = numberFormmater.string(from: NSNumber(value: intValue))
        var totalAmountFloat = totalAmountAsFloat()
        numberFormmater.numberStyle = .currency
        totalAmountLabel.text = numberFormmater.string(from: NSNumber(value: totalAmountFloat))
    }

    func convertAmountTextStringToFloat() -> Float {
        var nsString = NSString(string: amountTextField.text!)
        return nsString.floatValue
    }

    func sliderValueAsInt() -> Int {
        var intValue:Int = Int(tipPercentSlider.value)
        return intValue
    }

    func totalAmountAsFloat() -> Float {
        var percentageFloat = 0.01 * Float(sliderValueAsInt())
        var amountFloat = convertAmountTextStringToFloat()
        var totalAmount = amountFloat + amountFloat * percentageFloat
        return totalAmount
    }

    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
