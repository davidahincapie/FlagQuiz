//
//  SettingsViewController.swift
//  FlagQuiz
//
//  Created by David Hincapie on 11/16/15.
//  Copyright © 2015 David Hincapie. All rights reserved.
//
import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var guessesSegmentedControl: UISegmentedControl!
    @IBOutlet var switches: [UISwitch]!
    
    var model: Model! // set by QuizViewController
    private var regionNames = ["Africa", "Asia", "Europe",
        "North_America", "Oceania", "South_America"]
    private let defaultRegionIndex = 3
    
    // used to determine whether any settings changed
    private var settingsChanged = false
    
    // called when SettingsViewController is displayed
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // select segment based on current number of guesses to display
        guessesSegmentedControl.selectedSegmentIndex =
            model.numberOfGuesses / 2 - 1
        
        // set switches based on currently selected regions
        for i in 0 ..< switches.count {
            switches[i].on = model.regions[regionNames[i]]!
        }
    }
    
    // update guesses based on selected segment's index
    @IBAction func numberOfGuessesChanged(sender: UISegmentedControl) {
        model.setNumberOfGuesses(2 + sender.selectedSegmentIndex * 2)
        settingsChanged = true
    }
    
    // toggle region corresponding to toggled UISwitch
    @IBAction func switchChanged(sender: UISwitch) {
        for i in 0 ..< switches.count {
            if sender === switches[i] {
                model.toggleRegion(regionNames[i])
                settingsChanged = true
            }
        }
        
        // if no switches on, default to North America and display error
        if model.regions.values.lazy.filter({$0 == true}).count == 0 {
            model.toggleRegion(regionNames[defaultRegionIndex])
            switches[defaultRegionIndex].on = true
            displayErrorDialog()
        }
    }
    
    // display message that at least one region must be selected
    func displayErrorDialog() {
        // create UIAlertController for user input
        let alertController = UIAlertController(
            title: "At Least One Region Required",
            message: String(format: "Selecting %@ as the default region.",
                regionNames[defaultRegionIndex]),
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK",
            style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true,
            completion: nil)
    }
    
    // called when user returns to quiz
    override func viewWillDisappear(animated: Bool) {
        if settingsChanged {
            model.notifyDelegate() // called only if settings changed
        }
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


