//
//  ViewController.swift
//  FlickFinder
//
//  Created by Sagar Choudhary on 13/11/18.
//  Copyright © 2018 Sagar Choudhary. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var textSearchField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var textSearchButton: UIButton!
    @IBOutlet weak var locationSearchButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        textSearchField.delegate = self
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: subscribe keyboard notification
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: unsubscribe keyboard notification
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @IBAction func textFieldSearch(_ sender: Any) {
        userDidTapView(self)
    }
    
    @IBAction func locationSearch(_ sender: Any) {
        userDidTapView(self)
    }
    
    private func resignIfFirstResponsder(textfield: UITextField) {
        if (textfield.isFirstResponder) {
            textfield.resignFirstResponder()
        }
    }
    
    private func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponsder(textfield: textSearchField)
        resignIfFirstResponsder(textfield: longitudeTextField)
        resignIfFirstResponsder(textfield: latitudeTextField)
    }
}


extension ViewController {
    private func enableUI(enabled: Bool) {
        photoLabel.isEnabled = enabled
        textSearchField.isEnabled = enabled
        latitudeTextField.isEnabled = enabled
        longitudeTextField.isEnabled = enabled
        textSearchButton.isEnabled = enabled
        locationSearchButton.isEnabled = enabled
        
        if (enabled) {
            textSearchButton.alpha = 1.0
            locationSearchButton.alpha = 1.0
        } else {
            textSearchButton.alpha = 0.5
            locationSearchButton.alpha = 0.5
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
}
