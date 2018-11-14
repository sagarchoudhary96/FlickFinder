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
    
    //MARK: Search by text phrase
    @IBAction func textFieldSearch(_ sender: Any) {
        userDidTapView(self)
        enableUI(enabled: false)
        
        if !textSearchField.text!.isEmpty {
            photoLabel.text = "Searching . . ."
            var parameters: [String: String?] = getParamPair() as! [String : String]
            parameters[Constants.FlickrParameterKeys.Text] = textSearchField.text
            displayImageFromFlickrBySearch(parameters: parameters as [String : AnyObject])
        } else {
            enableUI(enabled: true)
            photoLabel.text = "Text Phrase is Empty"
        }
    }
    
    //MARK: Search by the location coordinate
    @IBAction func locationSearch(_ sender: Any) {
        userDidTapView(self)
        enableUI(enabled: false)
        
        if isValidTextFieldValue(textfield: latitudeTextField, forRange: Constants.Flickr.SearchLatRange) && isValidTextFieldValue(textfield: longitudeTextField, forRange: Constants.Flickr.SearchLongRange) {
            photoLabel.text = "Searching . . ."
            var parameters: [String: String?] = getParamPair() as! [String : String]
            parameters[Constants.FlickrParameterKeys.BoundingBox] = getbbox()
            displayImageFromFlickrBySearch(parameters: parameters as [String : AnyObject])
        } else {
            enableUI(enabled: true)
            photoLabel.text = "Latitude should be [-90.0, 90.0].\n Longitude should be [-180.0, 180.0]."
        }
    }
    
    // MARK: Check Validation for lat/long values
    private func isValidTextFieldValue(textfield: UITextField, forRange: (Double, Double)) -> Bool {
        
        if let value = Double(textfield.text!), !textfield.text!.isEmpty {
            return isValueInRange(value: value, min: forRange.0, max: forRange.1)
        } else {
            return false
        }
    }
    
    private func isValueInRange(value: Double, min: Double, max: Double) -> Bool {
        return !(value < min || value > max)
    }
    
    // MARK: get bboxString
    private func getbbox() -> String {
        // ensure bbox is bounded
        if let latitude = Double(latitudeTextField.text!), let longitude = Double(longitudeTextField.text!) {
            let minLong = max(longitude - Constants.Flickr.SearchBoxWidth, Constants.Flickr.SearchLongRange.0)
            let minLat =  max(latitude - Constants.Flickr.SearchBoxHeight, Constants.Flickr.SearchLatRange.0)
            let maxLong = min(longitude + Constants.Flickr.SearchBoxWidth, Constants.Flickr.SearchLongRange.1)
            let maxLat = min(latitude + Constants.Flickr.SearchBoxHeight, Constants.Flickr.SearchLatRange.1)
            return "\(minLong),\(minLat),\(maxLong),\(maxLat)"
        } else {
           return "0,0,0,0"
        }
    }
}

//MARK: ViewController: Configure UI

extension ViewController {
    
    // enable/disable UIViews
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
    
    private func displayImageFromFlickrBySearch(parameters: [String:AnyObject]) {
        print(flickrUrlFromParameters(parameters: parameters))
        enableUI(enabled: true)
        photoLabel.text = "DONE!"
    }
    
    //MARK: Create url from parameters
    private func flickrUrlFromParameters(parameters: [String: AnyObject]) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.Flickr.APIScheme
        urlComponents.host = Constants.Flickr.APIHost
        urlComponents.path = Constants.Flickr.APIBaseURL
        urlComponents.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            urlComponents.queryItems!.append(queryItem)
        }
        return urlComponents.url!
    }
}

//MARK: ViewController : UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    
    // textField delegate functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }

    // show/hide keyboard
    @objc func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    // get keyboard height
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponsder(textfield: UITextField) {
        if (textfield.isFirstResponder) {
            textfield.resignFirstResponder()
        }
    }
    
    // user tap search button
    private func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponsder(textfield: textSearchField)
        resignIfFirstResponsder(textfield: longitudeTextField)
        resignIfFirstResponsder(textfield: latitudeTextField)
    }
}
