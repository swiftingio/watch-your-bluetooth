//
//  ViewController.swift
//  Peripheral
//
//  Created by Paciej on 20/05/2018.
//  Copyright © 2018 Maciej Piotrowski. All rights reserved.
//

import UIKit

class PeripheralViewController: UIViewController {
    @IBOutlet weak var advertisingButton: UIBarButtonItem!
    @IBOutlet weak var colorsSelector: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birdImageView: UIImageView!
    @IBOutlet weak var alphaSlider: UISlider!

    let peripheral = MyPeripheral()
    let colors = ["0080FF", "00FF00", "FF0000", "FEF935", "03FCFE", "FF4CFC", "A97946", "FFFFFF"]
    lazy var color: UIColor = {  UIColor(hex: colors.first!)!}()
    var alpha = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheral.setColor(colors.first!)
        peripheral.setAlpha(100)
        peripheral.setName("Birdy")
        nameTextField.delegate = self
        updateUI(with: color)
    }
    
    @IBAction func startAdveritisng(_ sender: AnyObject) {
        let text: String
        if (peripheral.isAdvertising) {
            peripheral.stopAdvertising()
            text = "Advertise"
        } else {
            peripheral.startAdvertising()
            text = "Stop"
        }
        advertisingButton.title = text
    }
    
    
    @IBAction func colorValueChanged(_ sender: AnyObject) {
        let value = colors[sender.selectedSegmentIndex]
        guard let color = UIColor(hex: value) else { return }
        self.color = color
        peripheral.setColor(value)
        updateUI(with: color)
    }
    
    @IBAction func alphaSliderValueChanged(_ sender: UISlider) {
        alpha = Int(sender.value)
        peripheral.setAlpha(alpha)
        updateUI(with: color)
    }
    
    func updateUI(with color: UIColor) {
        navigationController?.navigationBar.barTintColor = color
        nameTextField.backgroundColor = color
        colorsSelector.tintColor = color
        alphaSlider.tintColor = color
        birdImageView.tintColor = color.withAlphaComponent(CGFloat(alpha)/100)

    }
}

extension PeripheralViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        let new = text + string
        peripheral.setName(new)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

