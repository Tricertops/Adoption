//
//  AppDelegate.swift
//  Adoption
//
//  Created by Martin Kiss on 14.10.15.
//  Copyright © 2015 Tricertops. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
}

