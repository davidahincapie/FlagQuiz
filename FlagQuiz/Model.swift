//
//  Model.swift
//  FlagQuiz
//
//  Created by David Hincapie on 11/16/15.
//  Copyright © 2015 David Hincapie. All rights reserved.
//
import Foundation

// adopted by delegate so it can be notified when settings change
protocol ModelDelegate {
    func settingsChanged()
}

class Model {
    // keys for storing data in the app's NSUserDefaults
    private let regionsKey = "FlagQuizKeyRegions"
    private let guessesKey = "FlagQuizKeyGuesses"
    
    // reference to QuizViewController to notify it when settings change
    private var delegate: ModelDelegate! = nil
    
    var numberOfGuesses = 4 // number of guesses to display
    private var enabledRegions = [ // regions to use in quiz
        "Africa" : false,
        "Asia" : false,
        "Europe" : false,
        "North_America" : true,
        "Oceania" : false,
        "South_America" : false
    ]
    
    // variables for maintaining quiz data
    let numberOfQuestions = 10
    private var allCountries: [String] = [] // list of all flag names
    private var countriesInEnabledRegions: [String] = []
    
    // initialize the Settings from the app's NSUserDefaults
    init(delegate: ModelDelegate) {
        self.delegate = delegate
        
        // get the NSUserDefaults object for the app
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        // get number of guesses
        let tempGuesses = userDefaults.integerForKey(guessesKey)
        if tempGuesses != 0  {
            numberOfGuesses = tempGuesses
        }
        
        // get Dictionary containing the region settings
        if let tempRegions = userDefaults.dictionaryForKey(regionsKey) {
            self.enabledRegions = tempRegions as! [String : Bool]
        }
        
        // get a list of all the png files in the app's images group
        let paths = NSBundle.mainBundle().pathsForResourcesOfType(
            "png", inDirectory: nil)
        
        // get image filenames from paths
        for path in paths {
            if !(path as NSString).lastPathComponent.hasPrefix("AppIcon") {
                allCountries.append((path as NSString).lastPathComponent)
            }
        }
        
        regionsChanged() // populate countriesInEnabledRegions
    }
    
    // loads countriesInEnabledRegions
    func regionsChanged() {
        countriesInEnabledRegions.removeAll()
        
        for filename in allCountries {
            let region = filename.componentsSeparatedByString("-")[0]
            
            if enabledRegions[region]! {
                countriesInEnabledRegions.append(filename)
            }
        }
    }
    
    // returns Dictionary indicating the regions to include in the quiz
    var regions: [String : Bool] {
        return enabledRegions
    }
    
    // returns Array of countries for only the enabled regions
    var enabledRegionCountries: [String] {
        return countriesInEnabledRegions
    }
    
    // toggles a region on or off
    func toggleRegion(name: String) {
        enabledRegions[name] = !(enabledRegions[name]!)
        NSUserDefaults.standardUserDefaults().setObject(
            enabledRegions as NSDictionary, forKey: regionsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        regionsChanged() // populate countriesInEnabledRegions
    }
    
    // changes the number of guesses displayed with each flag
    func setNumberOfGuesses(guesses: Int) {
        numberOfGuesses = guesses
        NSUserDefaults.standardUserDefaults().setInteger(
            numberOfGuesses, forKey: guessesKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // called by SettingsViewController when settings change
    // to have model notify QuizViewController of the changes
    func notifyDelegate() {
        delegate.settingsChanged()
    }
    
    // return Array of flags to quiz based on enabled regions
    func newQuizCountries() -> [String] {
        var quizCountries: [String] = []
        var flagCounter = 0
        
        // add 10 random filenames to quizCountries
        while flagCounter < numberOfQuestions {
            let randomIndex = Int(arc4random_uniform(
                UInt32(enabledRegionCountries.count)))
            let filename = enabledRegionCountries[randomIndex]
            
            // if image's filename is not in quizCountries, add it
            if quizCountries.filter({$0 == filename}).count == 0 {
                quizCountries.append(filename)
                ++flagCounter
            }
        }
        
        return quizCountries
    }
}