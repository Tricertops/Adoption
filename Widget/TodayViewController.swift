//
//  TodayViewController.swift
//  Widget
//
//  Created on 14 October 2015.
//  © 2015 Martin Kiss.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {
    
    let URL: NSURL! = NSURL(string: "https://developer.apple.com/support/app-store/")
    
    @IBOutlet var primaryLabel: NSTextField!
    @IBOutlet var secondaryLabel: NSTextField!
    
    let Defaults = NSUserDefaults.standardUserDefaults()
    let PrimaryCacheKey = "primary"
    var cachedPrimaryString: String {
        get { return Defaults.stringForKey(PrimaryCacheKey) ?? "" }
        set { Defaults.setObject(newValue, forKey: PrimaryCacheKey) }
    }
    let SecondaryCacheKey = "secondary"
    var cachedSecondaryString: String {
        get { return Defaults.stringForKey(SecondaryCacheKey) ?? "" }
        set { Defaults.setObject(newValue, forKey: SecondaryCacheKey) }
    }
    
    override var nibName: String? {
        return "TodayViewController"
    }
    
    @IBAction func openURL(sender: AnyObject) {
        /// The following crashes in simulator.
        // self.extensionContext?.openURL(self.URL, completionHandler: nil)
        
        /// The following doesn’t seem to work in Today View.
        NSWorkspace.sharedWorkspace().openURL(self.URL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.widgetPerformUpdateWithCompletionHandler { _ in }
    }
    
    func widgetPerformUpdateWithCompletionHandler(report: ((NCUpdateResult) -> Void)?) {
        guard self.URL != nil else {
            report?(.Failed)
            return
        }
        var primary = self.cachedPrimaryString
        var secondary = self.cachedSecondaryString
        let hasCache = !primary.isEmpty
        if !hasCache {
            NSLog("No cache.")
            primary = "Loading…"
            secondary = "As measured by the App Store."
        }
        else {
            NSLog("Using cached.")
        }
        self.showText(primary: primary, secondary: secondary)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(URL) { data, response, error in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                guard error == nil else {
                    if !hasCache {
                        self.showError(detail: error!.localizedDescription)
                    }
                    NSLog("Error: \(error!.localizedDescription)")
                    report?(.Failed)
                    return
                }
                guard data != nil else {
                    NSLog("No error, no content. WTF?")
                    report?(.Failed)
                    return
                }
                
                do {
                    let document = try NSXMLDocument(data: data!, options: NSXMLDocumentTidyHTML)
                    let (primary, secondary) = try self.parseDocument(document)
                    
                    self.showText(primary: primary, secondary: secondary)
                    
                    let noChange = (self.cachedPrimaryString == primary && self.cachedSecondaryString == secondary)
                    self.cachedPrimaryString = primary
                    self.cachedSecondaryString = secondary;
                    
                    if noChange {
                        NSLog("No change since last check.")
                        report?(.NoData)
                    }
                    else {
                        NSLog("Updated. Cached.")
                        report?(.NewData)
                    }
                }
                catch {
                    if !hasCache {
                        self.showError(detail: "Cannot parse the website, click to open.")
                    }
                    NSLog("Failed to parse the website.")
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
