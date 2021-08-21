//
//  PPLColorPickerViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 6/19/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit

class PPLColorPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    weak var picker: UIPickerView!
    @Published private(set) var colorSelection: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(picker)
        picker.delegate = self
        picker.backgroundColor = PPLColor.quaternary
        picker.tintColor = .black
        picker.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        picker.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        picker.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.picker = picker
        if let selectedRow = ColorNames.list.firstIndex(of: PPLDefaults.instance.getDefaultColor()) {
            picker.selectRow(selectedRow, inComponent: 0, animated: false)
        }
    }
    
    // MARK: DATA SOURCE
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        ColorNames.list.count
    }
    
    // MARK: DELEGATE
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        ThemeColor.allThemes()[row]
//    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        45
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        colorSelection = ColorNames.list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return viewForAppColor(ColorNames.list[row])
    }

}

extension UIViewController {
    
    private static let colorViewTag = 3593
    private static let appThemeColorViewTag = 947593
    
    func defaultColorView(_ cell: PPLTableViewCell) -> UIView? {
        cell.rootView.viewWithTag(UIViewController.appThemeColorViewTag)
    }
    
    func removeDefaultColorView(_ cell: PPLTableViewCell) {
        cell.rootView.viewWithTag(UIViewController.appThemeColorViewTag)?.removeFromSuperview()
    }
    
    func viewForAppColor(_ color: String = PPLDefaults.instance.getDefaultColor()) -> UIView {
        let superView = UIView(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        superView.tag = UIViewController.appThemeColorViewTag
        let subview = UIView()
        subview.tag = UIViewController.colorViewTag
        subview.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(subview)
        subview.widthAnchor.constraint(equalToConstant: 40).isActive = true
        subview.heightAnchor.constraint(equalToConstant: 40).isActive = true
        subview.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        subview.centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
        subview.backgroundColor = PPLColor.primaryWithColor(color)
        return superView
    }
    
    @objc func updateForNewDefaultColor() {
        guard let colorView = view.viewWithTag(UIViewController.colorViewTag) else { return }
        colorView.backgroundColor = PPLColor.primary
    }
}
