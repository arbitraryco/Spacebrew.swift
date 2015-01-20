//
//  ViewController.swift
//  Spacebrew
//
//  Created by Jamie Kosoy on 1/16/15.
//  Copyright (c) 2015 Arbitrary. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SpacebrewDelegate {
    var sb:Spacebrew?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        println("Connecting!")
        
        self.sb = Spacebrew(host: "localhost", name: "Swift Test", description: "This is an iOS app in Swift")
        
        self.sb!.delegate = self
        
        self.sb!.addPublish("buttonTapped", type: .BrewBool, def: String(0))
        self.sb!.addSubscribe("toggleBackground", type: .BrewBool)
        
        self.sb!.connect()
        
        let btn = UIButton(frame: CGRectMake(0, 0, 100, 100))
        btn.center = self.view.center
        btn.backgroundColor = UIColor.blueColor()
        btn.setTitle("Tap me!", forState: .Normal)
        btn.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: .TouchDown)
        btn.addTarget(self, action: Selector("buttonReleased:"), forControlEvents: UIControlEvents.TouchUpInside)
        btn.addTarget(self, action: Selector("buttonReleased:"), forControlEvents: UIControlEvents.TouchUpOutside)
        
        self.view.addSubview(btn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buttonPressed(sender:AnyObject?) {
        println("Button pressed!")
        self.sb!.send("buttonTapped", type: .BrewBool, value: "true")
    }
    
    func buttonReleased(sender:AnyObject?) {
        println("Button released!")
        self.sb!.send("buttonTapped", type: .BrewBool, value: "false")
    }
    
    
    func disconnectFromSpacebrew() {
        println("Quitting!")
        self.sb!.close()
    }
    
    // MARK: SpacebrewDelegate
    
    func spacebrewConnectionOpened() {
        println("Connected!")
    }
    
    func spacebrewConnectionClosed() {
        println("Closed!")
    }
    
    func spacebrewCustomMessageReceived(name: String, value: String, type: String) {
        println("Custom message received!")
    }
    
    func spacebrewRangeMessageReceived(name: String, value: Int) {
        println("Range received!")
    }
    
    func spacebrewStringMessageReceived(name: String, value: String) {
        println("String received!")
    }
    
    func spacebrewBoolMessageReceived(name: String, value: Bool) {
        println("Bool received!")
        
        if(name == "toggleBackground") {
            if(value) {
                self.view.backgroundColor = UIColor.greenColor()
            }
            else {
                self.view.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
    func spacebrewBinaryMessageReceived(name: String, value: String, type: NSMutableData?) {
        println("Binary message received!")
    }
    
}

