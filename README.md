Spacebrew for Swift
=====================
This repo contains the [Spacebrew](https://github.com/Spacebrew/spacebrew) Library for Swift. It's implementation borrows ideas from the various client implementations provided by the Spacebrew community.

Current Version: 0.1.0


Authors: Jamie Kosoy, Georg Fischer

To Do
--------------------
- Implement binary messages. They are currently not supported.
- Sometimes it appears that iOS apps do not disconnect from the Spacebrew server correctly. Creates a ping error on the server.

Dependancies
--------------------
This library is dependant on [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) and [Starscream](https://github.com/daltoniam/starscream) for Websocket communication.

These libraries have been included in the repo for the purpose of showing example files.

Installation
--------------------
Drag Spacebrew.swift, SwiftyJSON.swift and Websocket.swift into your project. From there, you can create a connect with the following command:

```swift
let sb = Spacebrew(host: "hostname", name: "Client Name", description: "Client Alias")
sb.delegate = self
        
sb.addPublish("buttonTapped", type: .BrewBool, def: String(0))
sb.addSubscribe("toggleBackground", type: .BrewBool)
  
sb.connect()

// later on in your code...

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
    println("Boolean received!")
}

func spacebrewBinaryMessageReceived(name: String, value: String, type: NSMutableData?) {
    println("Binary message received!")
}

```

### Additional Options

```swift

let sb = Spacebrew(host: "hostname", name: "Client Name", description: "Client Alias", Spacebrew.Options(port: 9090, debug: false, reconnect: false))



License
--------------------
The MIT License


Spacebrew for Swift © 2015 Arbitrary, http://www.arbitrary.io

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


Spacebrew Copyright © 2012 LAB at Rockwell Group, http://www.rockwellgroup.com/lab