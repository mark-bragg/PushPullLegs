//
//  CountdownPickerViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/30/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class CountdownPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    weak var picker: UIPickerView!
    @Published private(set) var countdownSelection: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(picker)
        picker.delegate = self
        picker.backgroundColor = .quaternary
        picker.tintColor = .black
        picker.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        picker.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        picker.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.picker = picker
        picker.selectRow(PPLDefaults.instance.countdown(), inComponent: 0, animated: false)
    }
    
    // MARK: DATA SOURCE
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        31
    }
    
    // MARK: DELEGATE
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        45
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countdownSelection = row
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return labelForCountdown(row)
    }
}

extension UIViewController {
    func labelForCountdown(_ seconds: Int? = PPLDefaults.instance.countdown()) -> UILabel {
        let countdownLabel = UILabel()
        countdownLabel.textAlignment = .center
        countdownLabel.font = UIFont.systemFont(ofSize: 36)
        countdownLabel.textColor = PPLColor.pplDarkGray
        if let seconds = seconds {
            countdownLabel.text = "\(seconds)"
            countdownLabel.sizeToFit()
        }
        return countdownLabel
    }
}
