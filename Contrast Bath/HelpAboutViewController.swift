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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        HelpAboutText.text = "Use at own risk! This app comes with no guarantees and no warrantees. Please test this app first prior to use or use a backup timer to make sure this app meets your needs.\n\nHey! Thanks for using my contrast bath timer. I wrote this app so I could read a funny book (e.g. Terry Pratchett) while doing the contrast baths for my leg, instead of having to pay diligent attention to a timer and feeling sorry for myself.\n\nFor best results, please keep app running, i.e. don't hit home or switch apps. I've done my best to make sure it still works if you forget and start reading email or facebook, but this is my first iPhone app that I wrote in my nights and weekends becuase I thought it might be helpful, so I might have missed a few things.\n\nI love feedback! I've use this app every night for 2 months to test it out, but you might find or need things I'm not aware of, so I welcome your feedback!\n\nCheers!\n\nCopyright (c) 2015 Sara Ford. All rights reserved."
        
        
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
