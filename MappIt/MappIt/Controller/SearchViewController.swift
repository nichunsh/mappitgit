// Nelly Shieh
// nichunsh@usc.edu
//
//  SearchViewController.swift
//  MappIt
//
//  Created by Nelly Shieh on 4/15/20.
//  Copyright © 2020 Nelly Shieh. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    private let searchEvents = TMEventModel.sharedInstance
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var keywordTF: UITextField!
    
    @IBOutlet weak var locationTF: UITextField!
    
    @IBOutlet weak var dateSC: UISegmentedControl!
    
    @IBOutlet weak var startDP: UIDatePicker!
    
    @IBOutlet weak var endDP: UIDatePicker!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var endView: UIView!
    
    @IBOutlet weak var startView: UIView!
    
    @IBOutlet weak var hiddenView: UIView!
    
    @IBOutlet weak var mappitImageView: UIImageView!
    
    // clears input
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keywordTF.text = ""
        locationTF.text = ""
        startDP.setDate(Date(), animated: false)
        searchEvents.reset()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // dismissess keyboard
    @IBAction func userDidTapBackground(_ sender: Any) {
        keywordTF.resignFirstResponder()
        locationTF.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        endView.alpha=0
        dateSC.selectedSegmentIndex = 0
        keywordTF.delegate = self
        locationTF.delegate = self
        activityIndicator.stopAnimating()
    }
    
    // how return key changes delegation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == keywordTF {
            keywordTF.resignFirstResponder()
            locationTF.becomeFirstResponder()
        } else {
            locationTF.resignFirstResponder()
        }
        return true
    }
    
    // changing type date input
    @IBAction func dateSCDidChange(_ sender: Any) {
        if dateSC.selectedSegmentIndex == 0 {
            keywordTF.resignFirstResponder()
            locationTF.resignFirstResponder()
            fadeOut()
        } else {
            keywordTF.resignFirstResponder()
            locationTF.resignFirstResponder()
            endDP.minimumDate = startDP.date.advanced(by: 86400)
            fadeIn()
            
        }
    }
    
    // animation
    func fadeIn() {
        let fade = UIViewPropertyAnimator(duration: 1, curve: .easeIn) {
            self.endView.alpha = 1
        }
        fade.startAnimation()
    }
    
    // animation
    func fadeOut() {
        let fade = UIViewPropertyAnimator(duration: 1, curve: .easeIn) {
            self.endView.alpha = 0
        }
        fade.startAnimation()
    }
    
    // start searching 
    @IBAction func searchButtonDidTapped(_ sender: Any) {
        
        activityIndicator.startAnimating()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        searchEvents.keyword = keywordTF.text
        searchEvents.city = locationTF.text
        
        searchEvents.startDatetime = dateFormatter.string(from: startDP.date)
        if dateSC.selectedSegmentIndex == 1 {
            searchEvents.endDateTime = dateFormatter.string(from: endDP.date)
        }
        
        searchEvents.getEvents { (events) in
            DispatchQueue.main.async{
                self.activityIndicator.stopAnimating()
                self.performSegue(withIdentifier: "toResults", sender: sender)
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    //}
    

}
