//
//  AppDelegate.swift
//  Adoption
//
//  Created on 14 October 2015.
//  © 2015 Martin Kiss.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
}

