//
// Created by Larry Johnson on 8/19/18.
// Copyright (c) 2018 Larry Johnson. All rights reserved.
//

import Foundation


class BonjourNetworkDiscoveryService:NSObject, NetServiceBrowserDelegate{

    let SERVICE_TYPE:String = "_message._tcp"

    let SERVICE_DOMAIN:String = "local"

    let SERVICE_DOMAIN_ALL:String = ""

    var serviceType:String?

    var serviceDomain:String?

    var nsNetService:NetService?

    var clientStreamArray:[OutputStream] = []

    var _browser:NetServiceBrowser!

    var _service: NetService!

    var searching = false
    var services: [AnyHashable] = []

//    var serviceFoundClosure: (([NetService]) -> Void)

    var isSearching = false

    var serviceTimeout: Timer = Timer()

    var timeout: TimeInterval = 1.0


    init(name:String) {
//        self.serviceFoundClosure = { (v) in
//            return
//        }
        super.init()

        services = [AnyHashable](repeating: 0, count: 0)
        searching = false
    }

    func discoverService () {
        DispatchQueue.main.async(execute: {
            self._browser = NetServiceBrowser()
            self._browser?.delegate = self
            self._browser?.searchForServices(ofType: "_message._tcp", inDomain: "")
        })
    }


    // Other methods
    func handleError(_ error: NSNumber?) {
        print("An error occurred. Error code = \(Int(error ?? 0))")
        // Handle error here
    }

    func updateUI() {
        if searching {
            // Update the user interface to indicate searching
            // Also update any UI that lists available services
        } else {
            // Update the user interface to indicate not searching
        }
    }

    // Sent when browsing begins
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {

    }

    // Sent when browsing stops
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {

    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind aNetService: NetService, moreComing: Bool) {
        services.append(aNetService)
        print(String(format: "Got service %p with hostname %@\n", aNetService, aNetService.hostName ?? ""))

        if !moreComing {
            updateUI()
        }
    }

    // Sent when a service disappears
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove aNetService: NetService, moreComing: Bool) {
        while let elementIndex = services.index(of: aNetService) { services.remove(at: elementIndex) }

        if !moreComing {
            updateUI()
        }
    }
//
//
//
//  The converted code is limited to 1 KB.
//  Please Sign Up (Free!) to remove this limitation.
//
//  %< ----------------------------------------------------------------------------------------- %<
}