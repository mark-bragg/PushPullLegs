//
//  WorkoutNoteViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/3/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit

@objc protocol WorkoutNoteViewControllerDelegate: NSObjectProtocol {
    @objc func saveNote(_ text: String)
}

@objc protocol WorkoutNoteViewControllerDataSource: NSObjectProtocol {
    @objc func noteText() -> String
}

class WorkoutNoteViewController: UIViewController {

    weak var textView: UITextView?
    weak var toolbar: UIToolbar?
    weak var delegate: WorkoutNoteViewControllerDelegate?
    weak var dataSource: WorkoutNoteViewControllerDataSource?
    private var padding: CGFloat = 12
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        addToolbar()
        addToolbarItems()
        addTextView()
        view.backgroundColor = PPLColor.primary
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addToolbar() {
        let toolbar = UIToolbar()
        view.addSubview(toolbar)
        toolbar.sizeToFit()
        self.toolbar = toolbar
    }
    
    private func addToolbarItems() {
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        saveItem.tintColor = .white
        let separator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        cancelItem.tintColor = .white
        toolbar?.setItems([cancelItem, separator, saveItem], animated: true)
    }
    
    @objc func save() {
        delegate?.saveNote(textView?.text ?? "")
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    private func addTextView() {
        let textView = UITextView()
        view.addSubview(textView)
        textView.text = dataSource?.noteText()
        textView.font = UIFont.systemFont(ofSize: 22)
        self.textView = textView
    }
    
    private func setTextViewFrame(_ keyboardHeight: CGFloat) {
        guard let textView, let toolbar else { return }
        let y = toolbar.frame.height + padding
        let width = view.frame.width - (2 * padding)
        let height = view.frame.height - y - keyboardHeight
        textView.frame = CGRect(x: padding, y: y, width: width, height: height)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            setTextViewFrame(keyboardFrame.cgRectValue.height)
        }
    }

}

extension UIViewController: WorkoutNoteViewControllerDelegate, WorkoutNoteViewControllerDataSource {
    func saveNote(_ text: String) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func presentNoteViewController() {
        let noteVc = WorkoutNoteViewController()
        noteVc.delegate = self
        noteVc.dataSource = self
        self.present(noteVc, animated: true, completion: nil)
    }
    
    func noteText() -> String {
        ""
    }
}
