//
//  HelpAboutViewController.swift
//  Contrast Bath Timer
//
//  Created by Sara Ford on 7/15/15.
//  Copyright (c) 2015 Sara Ford. All rights reserved.
//

import UIKit

class HelpAboutViewController: UIViewController {
    
    @IBOutlet weak var HelpAboutText: UITextView!
    @IBOutlet weak var debugMode: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // you have got to be kidding me. the switch control doesn't have an internal state??
        debugMode.setOn(debugModeOn, animated: false)
        
        HelpAboutText.text =
            "Use at own risk! This app comes with no guarantees and no warrantees. Please test this app first prior to use or use a backup timer to make sure this app meets your needs. Read more re test mode below. To hear and see the alarm go off when it is time to switch tubs, please allow Contrast Bath to send you notifications.\n\n" +
            "Hey! Thanks for using my contrast bath timer. I wrote this app so I could read a funny book (e.g. Terry Pratchett) while doing the contrast baths for my leg, instead of having to pay diligent attention to a timer and feeling sorry for myself.\n\n" +
            "If you want to test out this app quickly, turn on test mode at the bottom of this page. This mode set minutes to be only 10 seconds long. Set 10 minutes to just 2 minutes and you can fully test the app end-to-end in less than 30 seconds. Just make sure you turn off test mode before you start using it.\n\n"
            +
            "For best results, please keep app running, e.g. don't hit home or switch apps. I've done my best to make sure it still works if you start reading email or facebook. This is my first iPhone app that I wrote in my nights and weekends, so I really hope it is helpful.\n\n" +
            "I love feedback! I've use this app every night for 2 months to test it out, but you might find or need things I'm not aware of, so I welcome your feedback!\n\n" +
            "Alarm music is a trimmed 8 second version of Iron Bacon by Kevin MacLeod (incompetech.com)\n" +
            "Licensed under Creative Commons: By Attribution 3.0\n" +
            "http://creativecommons.org/licenses/by/3.0/\n\n" +
            "Copyright (c) 2015 Sara Ford. All rights reserved."
        
        
        HelpAboutText.font = UIFont(name: HelpAboutText.font.fontName, size: 18)
        
        HelpAboutText.scrollRangeToVisible(NSRange(location:0, length:0))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeHelpAbout(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func toggleDebugMode(sender: AnyObject) {
        
        if debugMode.on {
            debugMode.setOn(true, animated:true)
            debugModeOn = true
        } else {
            debugMode.setOn(false, animated:true)
            debugModeOn = false
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
    
}
