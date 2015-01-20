//
//  Spacebrew.swift
//  Spacebrew
//
//  Created by Jamie Kosoy on 1/16/15.
//  Copyright (c) 2015 Arbitrary. All rights reserved.
//

import Foundation

public protocol SpacebrewDelegate : class {
    func spacebrewConnectionOpened()
    func spacebrewConnectionClosed()
    func spacebrewRangeMessageReceived(name:String, value:Int)
    func spacebrewBoolMessageReceived(name:String, value:Bool)
    func spacebrewStringMessageReceived(name:String, value:String)
    func spacebrewCustomMessageReceived(name:String, value:String, type:String)
    func spacebrewBinaryMessageReceived(name:String, value:String, type:NSMutableData?) // untested
}


public class Spacebrew {
    public enum BrewType {
        case BrewString
        case BrewRange
        case BrewBool
    }

    public struct Options {
        var port: Int = 9000 // Port number for the Spacebrew server
        var debug: Bool = false // Debug flag that turns on info and debug messaging (limited use)
        var reconnect: Bool = false
    }
    
    // maybe expand this into a class?
    public struct Message {
        var name: String = ""
        var type: BrewType = .BrewString
        var value: String = ""
        
        var _default: String = ""
    }
    
    private class Connection: WebSocketDelegate {
        private weak var delegate:Spacebrew?
        private var socket:WebSocket?

        init() {}
        
        func ready(delegate: Spacebrew) {
            self.delegate = delegate
 
            let host = self.delegate!.host + ":" + String(self.delegate!.options.port)
            
            self.socket = WebSocket(url: NSURL(scheme: "ws", host: host , path: "/")!)
            self.socket?.delegate = self
        }
        
        func connect() {
            socket?.connect()
        }
        
        func close() {
            self.socket?.disconnect()
        }
        
        // MARK: WebSocketDelegate
        func websocketDidConnect() {
            self.delegate?.websocketDidConnect()
        }
        
        func websocketDidDisconnect(error: NSError?) {
            self.delegate?.websocketDidDisconnect(error)
        }
        
        func websocketDidWriteError(error: NSError?) {
            self.delegate?.websocketDidWriteError(error)
        }
        
        
        func websocketDidReceiveMessage(text: String) {
            self.delegate?.websocketDidReceiveMessage(text)
        }
        
        func websocketDidReceiveData(data: NSData) {
            self.delegate?.websocketDidReceiveData(data)
        }
    }
    
    
    public weak var delegate: SpacebrewDelegate?

    private var host:String = "localhost"
    private var name:String = "Swift Spacebrew App"
    private var description:String = "A Spacebrew App from Swift"
    private var options: Options = Options()
    private var connection: Connection = Connection()
    
    private var isConnected:Bool = false
    private var isReconnecting:Bool = false
    
    private var pub = [Message]()
    private var sub = [Message]()

    public init(host:String, name:String, description:String, options:Options?) {
        self.host = host
        self.name = name
        self.description = description
        
        if(options != nil) {
            self.options = options!
        }
        
        self.connection.ready(self)
    }
    
    public convenience init(host:String, name:String, description:String) {
        self.init(host: host, name: name, description: description, options: nil)
    }

    public func connect() {
        self.connection.connect()
    }
    
    public func close() {
        if(self.isConnected) {
            self.connection.close()
            println("[close:Spacebrew] closing websocket connection")
        }

        self.isConnected = false
        self.isReconnecting = false
    }
    
    public func addSubscribe(name: String, type: BrewType) {
        self.sub.append(Message(name: name, type: type, value: "", _default: ""))
        self.updatePubSub()
    }
    
    public func addPublish(name: String, type: BrewType, def: String) {
        self.pub.append(Message(name: name, type: type, value: "", _default: def))
        self.updatePubSub()
    }
    
    private func updatePubSub() {
        if(!self.isConnected) {
            return
        }
        
        var config = [String:AnyObject]()
        config["name"] = self.name
        config["description"] = self.description
        config["options"] = [String]()
        
        // sub messages
        var subMessages = [AnyObject]()
        for sub in self.sub {
            var msg = [String:String]()
            msg["name"] = sub.name
            
            if(sub.type == .BrewString) {
                msg["type"] = "string"
            }
            else if(sub.type == .BrewRange) {
                msg["type"] = "range"
            }
            else if(sub.type == .BrewBool) {
                msg["type"] = "boolean"
            }

            subMessages.append(msg)
        }
        
        var sub = ["messages": subMessages]
        
        config["subscribe"] = sub

        // pub messages
        var pubMessages = [AnyObject]()
        for pub in self.pub {
            var msg = [String:String]()
            msg["name"] = pub.name

            if(pub.type == .BrewString) {
                msg["type"] = "string"
            }
            else if(pub.type == .BrewRange) {
                msg["type"] = "range"
            }
            else if(pub.type == .BrewBool) {
                msg["type"] = "boolean"
            }

            msg["default"] = pub._default

            pubMessages.append(msg)
        }

        var pub = ["messages": pubMessages]
        
        config["publish"] = pub

        let json = JSON(["config": config])
        
//        println(json.rawString()!)
        self.connection.socket?.writeString(json.rawString()!)
    }
    
    public func send(name: String, type: BrewType, value: String) {
        var message = [String:String]()
        message["clientName"] = self.name
        
        message["name"] = name

        if(type == .BrewString) {
            message["type"] = "string"
        }
        else if(type == .BrewRange) {
            message["type"] = "range"
        }
        else if(type == .BrewBool) {
            message["type"] = "boolean"
        }

        message["value"] = value
        
        var msg = ["message": message]
        
        let json = JSON(msg)
        
//        println(json.rawString()!)
        
        // TO DO: binary values
        self.connection.socket?.writeString(json.rawString()!)
    }

    // MARK: Connection
    // this isn't a delegate, per say, but we're treat it as if it were one.
    
    private func websocketDidConnect() {
        self.isConnected = true

        // if reconnect functionality is activated then insure we prevent further reconnections.
        self.isReconnecting = false

        // open
        self.updatePubSub()
        self.delegate?.spacebrewConnectionOpened()
    }
    
    private func websocketDidDisconnect(error: NSError?) {
        self.isConnected = false
        
        self.delegate?.spacebrewConnectionClosed()

        // TO DO: check to make sure that we actually need to reconnect. potentially check NSError if this doesn't just work outright?
        if(self.options.reconnect && !self.isReconnecting) {
            println("[_onClose:Spacebrew] setting up reconnect timer");
            self.isReconnecting = true

            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                if(!self.isConnected && self.isReconnecting) {
                    self.connect()
                    println("[reconnect:Spacebrew] attempting to reconnect to spacebrew");
                }
            })
        }
        
        self.delegate?.spacebrewConnectionClosed()
    }
    
    private func websocketDidWriteError(error: NSError?) {
        println("Spacebrew Websocket Error :: \(error!.localizedDescription)")
    }

    
    private func websocketDidReceiveMessage(text: String) {
        let binaryData = false // TO DO: implement binary data.
        let data = JSON(data:text.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // TO DO: something about targetTypes? see https://github.com/Spacebrew/spacebrew.js/blob/master/spacebrew_button/js/sb-1.4.1.js

        if let name = data["message"]["name"].string {
            if let value = data["message"]["value"].string {
                if let type = data["message"]["type"].string {
                    // for now only adding this if we have it, for backwards compatibility
                    let clientName = data["message"]["clientName"].stringValue
                    
                    print(name + ", " + value + ", " + type)
                    
                    if(binaryData) {
                        self.delegate?.spacebrewBinaryMessageReceived(name, value: value, type: NSMutableData())
                    }
                    else {
                        switch(type) {
                            case "boolean":
                                self.delegate?.spacebrewBoolMessageReceived(name, value: value == "true")
                            break
                            
                            case "string":
                                self.delegate?.spacebrewStringMessageReceived(name, value: value)
                            break
                            
                            case "range":
                                if var v:Int = value.toInt() {
                                    // clamping is done to mirror to ofxSpaceBrew.
                                    // see: https://github.com/Spacebrew/ofxSpacebrew/blob/master/src/ofxSpacebrew.cpp
                                    if(v > 1023 || v < 0) {
                                        println("Value is outside of range: 0 - 1023")
                                    }
                                    
                                    if(v <= 0) {
                                        v = 0
                                    }
                                    else if(v >= 1023) {
                                        v = 1023
                                    }

                                    self.delegate?.spacebrewRangeMessageReceived(name, value: v)
                                }
                                else {
                                    println("Value for range was not an integer! Ignoring")
                                }
                            break
                            
                            default:
                                self.delegate?.spacebrewCustomMessageReceived(name, value: value, type: type)
                            break
                        }
                    }
                }
            }
        }
        else {
            // illegal message
            return
        }
    }
    
    private func websocketDidReceiveData(data: NSData) {
        // jk: TO DO. handle binary data
        println("BINARY DATA")
    }


    
    
}