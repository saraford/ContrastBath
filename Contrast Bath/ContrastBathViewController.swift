//
//  ViewController.swift
//  Stopwatch
//
//  Created by Sara Ford on 6/14/15.
//  Copyright (c) 2015 Sara Ford. All rights reserved.
//

import UIKit
import AVFoundation

// Needed for the TimerPicker Lightbox view controller to send
// the minutes picked back to this main view controller
extension ContrastBathViewController: TimePickedDelegate {
    func updateData(data: String) {
       // NSLog("getting data from TimePickerDelegate")
        
        self.desiredTime = Int(data)
        self.displayTimeButton.setTitle("\(desiredTime):00", forState: UIControlState.Normal)
        
        // totalMinuteTime tracks # of minutes left
        // e.g. because we never start at "10:00" it's always "9:59"
        self.totalMinuteTime = desiredTime - 1
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

// for enabling debug mode from the help about page
var secondsInMinute:Int = 60
let debugSecondsInMinute = 10
let realSecondsInMinute = 60

// used by the HelpAbout Test mode button
var debugModeOn:Bool = false {
    didSet {
        
        if (debugModeOn) {
            secondsInMinute = debugSecondsInMinute
        }
        else {
            
            secondsInMinute = realSecondsInMinute
        }
        
    }
}

// to display the "what's new" message box
let currentRelease : Int = 12


// Main VC - was called "StopWatch" or "SW" in the original sample app
class ContrastBathViewController: UIViewController {
    
    let defaultTotalMinutes:Int = 10
    let smallFontSize:CGFloat = 17;
    let largeFontSize:CGFloat = 24;
    
    // at the end of each minute it kills off an alert that kicks off
    // the next minuteTimer loop
    var minuteTimer = NSTimer()
    
    // the total time in minutes the user has chosen
    var desiredTime:Int!
    
    // used to count whether we're switting to hot or switching to cold.
    var tubCounter:Int = 1;
    
    var totalTime:Int!
    var totalMinuteTime:Int!
    var minutes:Int!
    var seconds:Int!
    var keepPlayingAlarm:Bool = false;
    var alarmAudio:AVAudioPlayer!
    var myStopTime:NSDate!
    
    var colorEnabled = UIColor(netHex:0x007AFF)
    var colorDisabled = UIColor(netHex:0xB8B8B8)
    
    // if true, user opened app without tapping notification so we need to skip the real notification
    var skipBecauseUserDidNotTapNotification:Bool = false;
    
    @IBOutlet weak var DebugModeWarning: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet var displayTimeButton: UIButton!
    @IBOutlet weak var hotView: UIView!
    @IBOutlet weak var coldView: UIView!
    @IBOutlet weak var displayTimeLabel: UILabel!
    @IBOutlet weak var coldLabel: UILabel!
    @IBOutlet weak var hotLabel: UILabel!
    @IBOutlet weak var miscTub1Text: UILabel!
    @IBOutlet weak var miscTub2Text: UILabel!
    @IBOutlet weak var startInHotLabel: UILabel!
    @IBOutlet weak var helpAboutButton: HelpButton!
    
    // for handling missed/ignored notifications
    private var foregroundNotification: NSObjectProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Replace with real free music
        alarmAudio = AVAudioPlayer()
        alarmAudio = self.setupAudioPlayerWithFile("IronBacon", type:"m4a")
        alarmAudio.numberOfLoops = -1 // play until stop() is called
        alarmAudio.prepareToPlay();
        
        resetToDefaults()
        
        // needed for some reason - i forget
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        // this is the event that is fired after each scheduled 1 minute, regardless user taps or app is active
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAlertForSwitchFromNotification", name: "SwitchTubs", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetToDefaults", name: "Terminating", object: nil)
        
        // for handling the missed notification
        foregroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
            [unowned self] notification in
            
            // do whatever you want when the app is brought back to the foreground
            NSLog("yo! I'm back")
            
            // check we're running
            if (self.minuteTimer.valid) {
                
                // from docs: current scheduled local notifications - a notification is only current if it has *not* gone off yet. otherwise this list will be 0.
                let notifications = UIApplication.sharedApplication().scheduledLocalNotifications! as [UILocalNotification]
                
                // if the count is 0, means either user has tapped notification or has missed it
                if (notifications.count == 0) {
                    
                    // if Now > myStopTime, either user tapped or opened app after missing notification. either way we need to stop and clear the notifications
                    if (NSDate().compare(self.myStopTime) == .OrderedDescending) {
                        
                     //   NSLog("we're here")
                        
                        // pretend the user hit the notification
                        self.showAlertForSwitchFromNotification()
                        
                        // user did not tap
                        self.skipBecauseUserDidNotTapNotification = true
                    }
                    
                }
            }
        }
        
        //NSLog("I've loaded")
    }
    
    deinit {
        // make sure to remove the observer when this view controller is dismissed/deallocated
        
        NSNotificationCenter.defaultCenter().removeObserver(foregroundNotification)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        if NSUserDefaults.standardUserDefaults().objectForKey("firstTimeEver") == nil {
            
            // if first time ever launched
            NSUserDefaults.standardUserDefaults().setObject(1, forKey: "firstTimeEver")
            
            showNewReleaseLightbox("Hello!\n\nFor this app to work, please allow On My Nerves to send you notifications. You'll be asked in the next popup window.\n\nIf you don't accept, you'll never know when the alarm has gone off! O_o")
            
        }
        else if NSUserDefaults.standardUserDefaults().objectForKey("NewRelease" + String(currentRelease)) == nil {
            
            // display what's new if applicable
            showNewReleaseLightbox("What's new in release 1.1:\n\n• Easier to use 1st time setup UI\n\n• Minor bug fixes\n\n• This \"What's new\" popup window :)")
            
            NSUserDefaults.standardUserDefaults().setObject(1, forKey: "NewRelease" + String(currentRelease))
            
            // if there was a previous release, delete that bit on disk
            if NSUserDefaults.standardUserDefaults().objectForKey("NewRelease" + String(currentRelease - 1)) != nil {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("NewRelease" + String(currentRelease - 1))
            }
            
        }
        
        // get a reference to the app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // call didFinishLaunchWithOptions ... why?
        appDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: nil)
        
    }
    
    func showNewReleaseLightbox(textToShow:String) {
        let newReleaseViewController = storyboard?.instantiateViewControllerWithIdentifier("NewRelease") as! NewReleaseViewController
        
        // all this stuff needed to get the lightbox control effect
        newReleaseViewController.providesPresentationContextTransitionStyle = true
        newReleaseViewController.definesPresentationContext = true
        newReleaseViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        newReleaseViewController.textToShow = textToShow
        
        self.presentViewController(newReleaseViewController, animated: true, completion: nil)
    }

    
    
    override func viewWillAppear(animated: Bool) {
        
        if (debugModeOn) {
            DebugModeWarning.hidden = false;
        } else {
            DebugModeWarning.hidden = true;
        }
        
    }
    
    @IBAction func ShowTimerPicker(sender: UIButton) {
        
        let timerPickerVC = self.storyboard?.instantiateViewControllerWithIdentifier("myTimerPicker") as! TimerPickerViewController
        
        // all this stuff needed to get the lightbox control effect
        timerPickerVC.providesPresentationContextTransitionStyle = true
        timerPickerVC.definesPresentationContext = true
        timerPickerVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        // tell the picker what the previously-selected value is, if any.
        timerPickerVC.delegate = self
        timerPickerVC.prevSelectedTime = String(desiredTime)
        
        self.presentViewController(timerPickerVC, animated: false, completion: nil)
    }
    
    func resetToDefaults() {
        
        //println("resetToDefaults")
        
        // use 10 minutes for overall time and 60 seconds in each minute
        desiredTime = defaultTotalMinutes;
       // secondsInMinute = realSecondsInMinute
        
        // finish resetting the UI
        resetUI()
    }
    
    func resetUI() {
        
        // yeah, totalMinuteTime is a bad name but xcode sucks at refactoring. sorry.
        totalMinuteTime = desiredTime - 1
        
        tubCounter = 1
        
        displayTimeLabel.text = "Total time:"
        displayTimeButton.setTitle("\(desiredTime):00", forState: UIControlState.Normal)
        displayTimeButton.hidden = false;
        startStopButton.setTitle("Start", forState: UIControlState.Normal)
        
        dimBothTubs()
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // now you can enter debug mode. can't enter debug mode while running.
        helpAboutButton.enabled = true
        helpAboutButton.outlineColor = colorEnabled
        helpAboutButton.setTitleColor(colorEnabled, forState: UIControlState.Normal)
    }
    
    @IBAction func startStopTimer(sender: AnyObject) {
        
        // we're not running and need to start
        if !(minuteTimer.valid) {
            
            startStopButton.setTitle("Cancel", forState: UIControlState.Normal)
            totalTime = desiredTime * secondsInMinute
            minutes = desiredTime
            seconds = secondsInMinute
            
            // must always start in hot - how contrast baths work
            showFootInHot()
            
            // show countdown and hide time picker
            displayTimeButton.hidden = true
            displayTimeLabel.text = "\(desiredTime):00"
            
            //too late to enter debug mode
            helpAboutButton.enabled = false
            helpAboutButton.outlineColor = colorDisabled
            helpAboutButton.setTitleColor(colorDisabled, forState: UIControlState.Normal)
            
            startTimer()
        }
        else {
            
            // we're running and need to stop
            stopTimer()
            
            // reset the UI to state prior to starting
            resetUI()
        }
    }
    
//    // for the debug mode. it's only enabled when NSTimer isn't running
//    var debugModeEnabled:Bool = false
//    @IBAction func useDebugModeUI() {
//        
//        if (debugModeEnabled) {
//            // turn off debug mode
//            debugModeEnabled = false;
//            DebugModeWarning.hidden = true;
//            secondsInMinute = realSecondsInMinute
//        }
//        else {
//            // turn on debug mode
//            debugModeEnabled = true;
//            DebugModeWarning.hidden = false;
//            secondsInMinute = debugSecondsInMinute
//        }
//        
//    }
    
    func printTimeInterval(interval:NSTimeInterval) {
        let interval = Int(interval)
        let seconds = interval % secondsInMinute
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)

        let str = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        NSLog("Time Interval is \(str)")
    }
    
    func printDate(date:NSDate) {
        let formatter = NSDateFormatter();
        formatter.dateFormat = "HH:mm:ss";
        
        let defaultTimeZoneStr = formatter.stringFromDate(date);
        NSLog(defaultTimeZoneStr);
    }
    
    // Oh boy oh boy! here we go!!!
    var startTime:NSDate!
    func startTimer() {
        
        // so we grab the current time and the time 1 minute into the future and log
        startTime = NSDate()
      //  println("Start time at...")
        printDate(startTime)
        myStopTime = NSDate(timeIntervalSinceNow: NSTimeInterval(secondsInMinute))
     //   println("Stop time at...")
        printDate(myStopTime)
        
        // this minuteTimer is ONLY used to display the timer countdown in the UI
        // so each second it will go from 9:59, 9:58, blah blah blah
        // the notification below is what stops this timer
        minuteTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("updateMinuteTime"), userInfo: nil, repeats: true)
        
        // reset the skip
        skipBecauseUserDidNotTapNotification = false
        
        // schedule local notification
        let notification = UILocalNotification()
        notification.alertBody = "Switch tubs!"
        notification.alertAction = "It's time to switch tubs!!"
        //ROBERT: Why oh why won't this work? I've tried every stackoverflow q&a i could find.
        //        notification.soundName = "test2.caf"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(secondsInMinute))
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func stopTimer() {
        minuteTimer.invalidate()
     //   NSLog("timer stopped")
    }
    
    // the actual NSTimer loop - this is only used to update the 9:59 text and nothing else
    func updateMinuteTime() {
        
        //Find the difference between current time and the original start time
        let timeElapsed:NSTimeInterval = NSDate().timeIntervalSinceDate(startTime)
        let secondsElapsed = Int(round(timeElapsed))
        let displayTime = secondsInMinute - secondsElapsed
        
        //        printTimeInterval(timeElapsed)
        
        // UI prettiness because Apple can't give me a NSDate.Now.ToString()
        // gods I miss C#
        if (displayTime > 0) {
            if (displayTime > 9) {
                displayTimeLabel.text = "\(totalMinuteTime):\(displayTime)"
            }
            else {
                displayTimeLabel.text = "\(totalMinuteTime):0\(displayTime)"
            }
        }
        else {
            displayTimeLabel.text = "\(totalMinuteTime):00"
        }
    }
    
    // this is fired after every scheduled 1 minute interval via the notification service
    // this is fired regardless user taps notification or it comes while app is running
    func showAlertForSwitchFromNotification() {
        
        // skip only if we're being called from viewDidLoad to skip the call from the notification
        if !(skipBecauseUserDidNotTapNotification) {
            //TODO: Ideally I want to say "if user taps, don't play audio." but don't know how to detect.
            showAlertForSwitch(true)
        }
    }
    
    func showAlertForSwitch(playAlarm: Bool)  {
        
      //  NSLog("I'm stopping the timer")
        let trueStopTime = NSDate()
        
     //   NSLog("Stop Time:")
        printDate(trueStopTime)
        
        stopTimer()
        
        // so we know whether to switch to the next tub
        tubCounter++;
        
        if (playAlarm) {
            alarmAudio.play()
        }
        
        // clear the notification
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        if (totalMinuteTime == 0) {
            showAlert("Done!", message: "Have a good one! :)")
        }
        else {
            showAlert("Switch!", message: "Time to switch tubs!")
        }
    }
    
    // just a helper to show the alerts
    func showAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        
        // after the user dismisses the alert we can start the next 1 minute run
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
            action in self.stopPlayingAlertAndStartTimer()
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // called after the user hits OK on the alert
    // starts the next timer and switches tubs in the UI
    func stopPlayingAlertAndStartTimer() {
        
        if (alarmAudio.playing) {
            alarmAudio.stop()
        }
        
        // check to see if we're done with overall time
        if (totalMinuteTime > 0) {
            totalMinuteTime = totalMinuteTime - 1;
            
            // switch tub - if even # needs to be in cold
            if (tubCounter % 2 == 0) {
                showFootInCold()
            }
            else {
                // if odd # needs to be in hot
                showFootInHot()
            }
            
            startTimer()
        }
        else {
            
            // we're completely done with the timer. User saw it through till the end
            resetUI()
        }
        
    }
    
    // cut and pasted from SO
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        var audioPlayer:AVAudioPlayer?
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
        } catch let error as NSError {
            audioPlayer = nil
            print(error)
        }
        
        return audioPlayer!
    }
    
    func dimBothTubs() {
        hotView.backgroundColor = UIColor.clearColor()
        hotLabel.textColor = UIColor.blackColor()
        hotLabel.font.fontWithSize(smallFontSize)
        hotLabel.font = UIFont(name: hotLabel.font.fontName, size: smallFontSize)
        hotLabel.sizeToFit()
        coldView.backgroundColor = UIColor.clearColor()
        coldLabel.textColor = UIColor.blackColor()
        coldLabel.font = UIFont(name: coldLabel.font.fontName, size: smallFontSize)
        coldLabel.sizeToFit()
        showMiscTubText()
    }
    
    func showFootInHot() {
        hotView.backgroundColor = UIColor.redColor()
        hotLabel.textColor = UIColor.whiteColor()
        hotLabel.font = UIFont(name: hotLabel.font.fontName, size: largeFontSize)
        hotLabel.sizeToFit()
        coldView.backgroundColor = UIColor.clearColor()
        coldLabel.textColor = UIColor.grayColor()
        coldLabel.font = UIFont(name: hotLabel.font.fontName, size: smallFontSize)
        coldLabel.sizeToFit()
        hideMiscTubText()
    }
    
    func showFootInCold() {
        hotView.backgroundColor = UIColor.clearColor()
        hotLabel.textColor = UIColor.grayColor()
        hotLabel.font = UIFont(name: hotLabel.font.fontName, size: smallFontSize)
        hotLabel.sizeToFit()
        coldView.backgroundColor = UIColor.blueColor()
        coldLabel.textColor = UIColor.whiteColor()
        coldLabel.font = UIFont(name: coldLabel.font.fontName, size: largeFontSize)
        coldLabel.sizeToFit()
        hideMiscTubText()
    }
    
    func hideMiscTubText() {
        miscTub1Text.hidden = true;
        miscTub2Text.hidden = true;
        startInHotLabel.hidden = true;
    }
    
    func showMiscTubText() {
        miscTub1Text.hidden = false;
        miscTub2Text.hidden = false;
        startInHotLabel.hidden = false;
    }
    
}







