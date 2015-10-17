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
        self.showText(primary: "Loading…", secondary: "This may take a while.")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(URL) { data, response, error in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                guard error == nil else {
                    self.showError(detail: error!.localizedDescription)
                    report?(.Failed)
                    return
                }
                guard data != nil else {
                    self.showError(detail: "There was no error, but also no content.")
                    report?(.Failed)
                    return
                }
                
                do {
                    let document = try NSXMLDocument(data: data!, options: NSXMLDocumentTidyHTML)
                    let (primary, secondary) = try self.parseDocument(document)
                    self.showText(primary: primary, secondary: secondary)
                    
                    //TODO: Compare previous text with new text.
                    report?(.NewData)
                }
                catch {
                    self.showError(detail: "Cannot parse the website.")
                    report?(.Failed)
                }
            }
        }
        task.resume();
    }
    
    func parseDocument(document: NSXMLDocument) throws -> (primary: String, secondary: String) {
        var node: NSXMLNode! = document.rootElement()
        while node != nil {
            if node.kind == .ElementKind {
                let element = node as! NSXMLElement
                
                if self.isChartDiv(element) {
                    let headerElement = element.elementsForName("h6").first
                    let footerElement = element.elementsForName("p").first
                    if self.isChartHeader(headerElement) && self.isChartFooter(footerElement) {
                        let header = headerElement?.stringValue ?? ""
                        let footer = footerElement?.stringValue ?? ""
                        return (header, footer)
                    }
                }
            }
            node = node?.nextNode
        }
        
        throw NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo: [:])
    }
    
    func isChartDiv(element: NSXMLElement?) -> Bool {
        return self.isElement(element, ofName: "div", ofClass: "chart")
    }
    
    func isChartHeader(element: NSXMLElement?) -> Bool {
        return self.isElement(element, ofName: "h6")
    }
    
    func isChartFooter(element: NSXMLElement?) -> Bool {
        return self.isElement(element, ofName: "p", ofClass: "footnote")
    }
    
    func isElement(element: NSXMLElement?, ofName: String, ofClass: String = "") -> Bool {
        guard let element = element else { return false }
        guard element.name == ofName else { return false }
        if ofClass.isEmpty { return true }
        guard let classNode = element.attributeForName("class") else { return false }
        guard let classValue = classNode.stringValue else { return false }
        guard let classValues: NSArray = classValue.componentsSeparatedByString(" ") else { return false }
        guard classValues.containsObject(ofClass) else { return false }
        return true
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
