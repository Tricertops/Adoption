//
//  TodayViewController.swift
//  Widget
//
//  Created by Martin Kiss on 14.10.15.
//  Copyright © 2015 Tricertops. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {
    
    let URL: NSURL! = NSURL(string: "https://developer.apple.com/support/app-store/")
    
    @IBOutlet var primaryLabel: NSTextField!
    @IBOutlet var secondaryLabel: NSTextField!
    
    override var nibName: String? {
        return "TodayViewController"
    }
    
    @IBAction func openURL(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(self.URL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showText(primary: "Hello!")
        
        self.widgetPerformUpdateWithCompletionHandler { result in }
    }
    func widgetPerformUpdateWithCompletionHandler(report: ((NCUpdateResult) -> Void)?) {
        guard self.URL != nil else {
            report?(.Failed)
            return
        }
        //TODO: Download and parse website.
        report?(.NoData)
        
    }
    
    func showError(detail detail: String = "") {
        self.showText(primary: "Failed :(", secondary: detail)
    }
    
    func showText(primary primary: String, secondary: String = "") {
        let invisible = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let primaryTrimmed = primary.stringByTrimmingCharactersInSet(invisible)
        let secondaryTrimmed = secondary.stringByTrimmingCharactersInSet(invisible)
        
        self.primaryLabel.stringValue = primaryTrimmed
        self.secondaryLabel.stringValue = secondaryTrimmed
        
        self.secondaryLabel.hidden = secondaryTrimmed.isEmpty
    }
    
}
