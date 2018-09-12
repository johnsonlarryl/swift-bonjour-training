//
// Created by Larry Johnson on 8/19/18.
// Copyright (c) 2018 Larry Johnson. All rights reserved.
//

import Foundation


class BonjourNetworkService:NSObject, NetServiceDelegate{

    let SERVICE_PORT:Int32 = Int32(8192)

    let SERVICE_TYPE:String = "_message._tcp"

    let SERVICE_DOMAIN:String = "local"

    let SERVICE_DOMAIN_ALL:String = ""

    var serviceName:String?

    var servicePort:Int32

    var serviceDomain:String?

    var serviceType:String?

    var nsNetService:NetService?

    var clientStreamArray:[OutputStream] = []

    var _service: NetService!

    var serviceFoundClosure: (([NetService]) -> Void)

    var isSearching = false

    var serviceTimeout: Timer = Timer()

    var timeout: TimeInterval = 1.0


    init(name:String) {
        serviceName = name
        servicePort = SERVICE_PORT
        serviceDomain = SERVICE_DOMAIN
        serviceType = SERVICE_TYPE
        self.serviceFoundClosure = { (v) in
            return
        }
        super.init()
    }

    func startService() {
        DispatchQueue.main.async(execute: {
            self.nsNetService = NetService(domain: self.serviceDomain!, type: self.serviceType!, name: self.serviceName!, port: self.servicePort)
            self.nsNetService!.delegate = self
            self.nsNetService!.publish(options: NetService.Options.listenForConnections)
        })
    }

    func stopService() {
        // stop publishing
        nsNetService!.stop()

        nsNetService = nil
    }

    func sendResponse(responseString:String) {
        // if countElements(self.clientIDArray) > 0 {
        // Can only send if there's a connected client
        var topStream:OutputStream = self.clientStreamArray[0]

        // take it off the array
        self.clientStreamArray.remove(at: 0)

        self.sendMessageToClient(outputStream: topStream, message:responseString)

        // update the message list

        self.updateMessages(messageText: responseString, received:false)
        // }
    }

    func sendMessageToClient(outputStream:OutputStream, message:String) {
        // adjust the message by adding a carriage-return to signal EOF

        var adjustedMessage = message + "\n"

        // convert the message to a byte array
        let messageBytes = adjustedMessage.data(using: String.Encoding.utf8)!

        let messageLength = adjustedMessage.lengthOfBytes(using: .utf8)

        outputStream.open()

        var bytesWritten = messageBytes.withUnsafeBytes {outputStream.write($0, maxLength: messageLength) }

        if bytesWritten < 0 {
            let streamError = outputStream.streamError

            if nil != streamError {
                print("error writing to output stream: \(streamError.debugDescription)")
            }
        } else {
                print("unkonwn error occurred writing to output stream")
        }


    }

    // Called from `handleInput` with a complete message.
    func processMessage(message: Data) {
        // ...
    }

    func readMessagesFromClient(inputStream:InputStream) {

        let data = Data(reading: inputStream)
        let message = String(data: data, encoding: .utf8)
        self.updateMessages(messageText:message!, received: true)
    }

    func updateBonjourServiceStatus(status:ServiceStatus) {
        DispatchQueue.main.async(execute: {
            var userInfoDictionary = ["status": status.rawValue]

            NotificationCenter.default.post(name: .updateStatus, object: self, userInfo:userInfoDictionary)
        })
    }

    func updateMessages(messageText:String, received:Bool){
        DispatchQueue.main.async(execute: {
            // post a notification containing a userInfo directory of
            // "message" -> messageText and "received" -> true/false

            var userInfoDictionary:Dictionary<String, Any> = ["message" : messageText, "received" : received]

            NotificationCenter.default.post(name: .updateMessages, object: self, userInfo: userInfoDictionary)
        })
    }

    func netServiceWillPublish(sender:NetService) {
        // service hasn't started but is in progress
        updateBonjourServiceStatus(status: ServiceStatus.STARTING)
    }

    func netServiceDidPublish(sender: NetService) {
        // service has started
        updateBonjourServiceStatus(status: ServiceStatus.ACTIVE)
    }

    func netService(sender:NetService, didNotPublish errorDict: [NSObject:AnyObject]) {
        // failure to publish

        if (errorDict.count) > 0 {
            // write error into to log

            print("NSNetService failed to publish - error dictionary contents")

            for(key, value) in errorDict {
                print("key[\(key)] value [\(value)]")
            }
        }

        updateBonjourServiceStatus(status: ServiceStatus.FAILED_TO_START)
    }

    func netService(sender:NetService, didAcceptConnectionWithInputStream inputStream:InputStream, outputStream:OutputStream) {
        // connection accepted, with i/o streams

        // cache the output stream

        self.clientStreamArray.append(outputStream)

        // read the incoming text
        self.readMessagesFromClient(inputStream: inputStream)

        // update the status
        self.updateBonjourServiceStatus(status: ServiceStatus.WAITING_FOR_SERVER_MESSAGE)
    }

    func netServiceDidResolveAddress(_ service: NetService) {

        print(String(format: "%ld", service.port))

        print("Name: " + service.hostName!)//        for data:Data? in service.addresses ?? [] {
//            let addressBuffer = [Int8](repeating: 0, count: 100)

//            let socketAddress = data?.bytes as? sockaddr_in
//            let sockFamily = socketAddress?.sin_family
//            if sockFamily == AF_INET {
//                let addressStr = inet_ntop(sockFamily, &(socketAddress?.sin_addr), addressBuffer, MemoryLayout<addressBuffer>.size)
//
//                let port = ntohs(socketAddress.sin_port)
//                if addressStr && port != 0 {
//                    print("Found service at \(addressStr):\(port)")
//                    let urlString = "http://\(addressStr):\(port)"
//                    let url = URL(string: urlString)
//                    if let anUrl = url {
//                        UIApplication.shared.openURL(anUrl)
//                    }
//                }
//            }
//        }
    }

}