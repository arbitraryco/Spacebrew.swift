//
//  ViewController.swift
//  SliderExample
//
//  Created by Georg Fischer on 21.01.15.
//  Copyright (c) 2015 Georg Fischer. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SpacebrewDelegate {

    var appName = "slider example"

    var slider1Label:UILabel?
    var slider2Label:UILabel?
    var slider3Label:UILabel?
    
    var slider1:UISlider?
    var slider2:UISlider?
    var slider3:UISlider?
    
    var sb:Spacebrew?

    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add Slider Labels
       
        self.slider1Label = UILabel(frame:CGRect(x: CGFloat(20), y: CGFloat(40), width: self.view.frame.size.width - CGFloat(40), height: CGFloat(40)))
        self.slider1Label!.text = "Input Slider 1"
        self.view.addSubview(self.slider1Label!)
        
        self.slider2Label = UILabel(frame:CGRect(x: CGFloat(20), y: CGFloat(140), width: self.view.frame.size.width - CGFloat(40), height: CGFloat(40)))
        self.slider2Label!.text = "Input Slider 2"
        self.view.addSubview(slider2Label!)
        
        self.slider3Label = UILabel(frame:CGRect(x: CGFloat(20), y: CGFloat(240), width: self.view.frame.size.width - CGFloat(40), height: CGFloat(40)))
        self.slider3Label!.text = "Input Slider 3"
        self.view.addSubview(self.slider3Label!)
        
        // Add Sliders
        
        self.slider1 = UISlider(frame: CGRect(x: CGFloat(20), y: CGFloat(60), width: self.view.frame.size.width - CGFloat(40), height: CGFloat(40)))
        self.view.addSubview(self.slider1!)
        
        self.slider2 = UISlider(frame: CGRect(x: CGFloat(20), y: CGFloat(160), width: self.view.frame.size.width - CGFloat(40), height: CGFloat(40)))
        self.view.addSubview(self.slider2!)
        
        self.slider3 = UISlider(frame: CGRect(x: CGFloat(20), y: CGFloat(260), width: self.view.frame.size.width - CGFloat(40), height: CGFloat(40)))
        self.view.addSubview(self.slider3!)
        
        self.setupUI()
        self.setupSpacebrew()
    }
    
    func setupUI () {
        println("Setting up the UI listeners")
        
        self.slider1!.addTarget(self, action: "sliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.slider1!.minimumValue = 0
        self.slider1!.maximumValue = 1023
        self.slider1!.value = 500
        self.slider1!.tag = 1
        
        self.slider1Label!.text = "Input Slider 1: \(self.slider1!.value)"
        
        self.slider2!.addTarget(self, action: "sliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.slider2!.minimumValue = 0
        self.slider2!.maximumValue = 1023
        self.slider2!.value = 500
        self.slider2!.tag = 2
        
        self.slider2Label!.text = "Input Slider 1: \(self.slider2!.value)"
        
        self.slider3!.addTarget(self, action: "sliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.slider3!.minimumValue = 0
        self.slider3!.maximumValue = 1023
        self.slider3!.value = 500
        self.slider3!.tag = 3
        
        self.slider3Label!.text = "Input Slider 3: \(self.slider3!.value)"
    }
    
    func setupSpacebrew () {
        var randomId = "\(Int(arc4random_uniform(UInt32(10000))))"
        self.appName = "\(self.appName) \(randomId)"
        
        println("Setting up spacebrew connection")
        
        self.sb = Spacebrew(host: "localhost", name: self.appName, description: "Sliders for sending and displaying SpaceBrew range messages")
        self.sb!.delegate = self
        self.sb!.addPublish("slider1", type: Spacebrew.BrewType.BrewRange, def: "500")
        self.sb!.addPublish("slider2", type: Spacebrew.BrewType.BrewRange, def: "500")
        self.sb!.addPublish("slider3", type: Spacebrew.BrewType.BrewRange, def: "500")
        self.sb!.addSubscribe("slider1", type: Spacebrew.BrewType.BrewRange)
        self.sb!.addSubscribe("slider2", type: Spacebrew.BrewType.BrewRange)
        self.sb!.addSubscribe("slider3", type: Spacebrew.BrewType.BrewRange)
        self.sb!.connect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sliderValueChanged(sender:UISlider) {
        println("Sent new range message: slider\(sender.tag), \(sender.value)")
        self.sb!.send("slider\(sender.tag)", type: Spacebrew.BrewType.BrewRange, value: NSString(format: "%.4f", sender.value))
        
        if (sender.tag == 1) {
            self.slider1Label!.text = "Input Slider 1: \(sender.value)"
        }
        
        if (sender.tag == 2) {
            self.slider2Label!.text = "Input Slider 2: \(sender.value)"
        }
        
        if (sender.tag == 3) {
            self.slider3Label!.text = "Input Slider 3: \(sender.value)"
        }
    }
    
    // MARK: SpacebrewDelegate
    
    func spacebrewConnectionOpened() {
        println("Connected as \(self.appName)")
    }
    
    func spacebrewConnectionClosed() { }
    func spacebrewCustomMessageReceived(name: String, value: String, type: String) { }
    
    func spacebrewRangeMessageReceived(name: String, value: Int) {
        println("Received new range message: \(name), \(value)")

        if (name == "slider1") {
            self.slider1!.value = Float(value)
            self.slider1Label!.text = "Input Slider 1: \(self.slider1!.value)"
        }
        
        if (name == "slider2") {
            self.slider2!.value = Float(value)
            self.slider2Label!.text = "Input Slider 2: \(self.slider2!.value)"
        }
        
        if (name == "slider3") {
            self.slider3!.value = Float(value)
            self.slider3Label!.text = "Input Slider 3: \(self.slider3!.value)"
        }
    }
    
    func spacebrewStringMessageReceived(name: String, value: String) { }
    func spacebrewBoolMessageReceived(name: String, value: Bool) { }
    func spacebrewBinaryMessageReceived(name: String, value: String, type: NSMutableData?) { }
}

