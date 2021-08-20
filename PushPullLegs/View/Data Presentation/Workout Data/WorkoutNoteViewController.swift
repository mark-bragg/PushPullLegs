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

    weak var textView: UITextView!
    weak var toolbar: UIToolbar!
    weak var delegate: WorkoutNoteViewControllerDelegate!
    weak var dataSource: WorkoutNoteViewControllerDataSource!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addToolbar() {
        let toolbar = UIToolbar()
        toolbar.tintColor = PPLColor.white
        view.addSubview(toolbar)
        self.toolbar = toolbar
        constrainToolbar()
    }
    
    private func constrainToolbar() {
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func addToolbarItems() {
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        saveItem.tintColor = PPLColor.quaternary
        let separator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        cancelItem.tintColor = PPLColor.quaternary
        toolbar.setItems([cancelItem, separator, saveItem], animated: false)
    }
    
    @objc func save() {
        self.delegate.saveNote(textView.text)
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    private func addTextView() {
        let textView = UITextView()
        view.addSubview(textView)
        textView.text = self.dataSource.noteText()
        textView.font = UIFont.systemFont(ofSize: 22)
        self.textView = textView
    }
    
    private func constrainTextView(_ keyboardHeight: CGFloat) {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: toolbar.bottomAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardHeight).isActive = true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            constrainTextView(keyboardFrame.cgRectValue.height)
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
