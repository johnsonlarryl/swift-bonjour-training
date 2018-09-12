//
// Created by Larry Johnson on 8/19/18.
// Copyright (c) 2018 Larry Johnson. All rights reserved.
//

import Foundation


class BonjourNetworkServiceDelegate:NSObject, NetServiceDelegate{

    init(name:String) {

        super.init()
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


    func netServiceDidResolveAddress(_ service: NetService) {

        print(String(format: "%ld", service.port))

        print("Name: " + service.hostName!)//        for data:Data? in service.addresses ?? [] {
    }

}