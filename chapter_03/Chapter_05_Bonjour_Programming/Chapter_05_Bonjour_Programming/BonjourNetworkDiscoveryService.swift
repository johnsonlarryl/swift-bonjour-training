//
// Created by Larry Johnson on 8/19/18.
// Copyright (c) 2018 Larry Johnson. All rights reserved.
//

import Foundation


class BonjourNetworkDiscoveryService:NSObject, NetServiceBrowserDelegate{

//    let SERVICE_TYPE:String = "_message._tcp"
    let SERVICE_TYPE:String = "_https._tcp"

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
            self._browser?.searchForServices(ofType: "_https._tcp", inDomain: "")
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

        DispatchQueue.main.async(execute: {
            let delegate = BonjourNetworkServiceDelegate(name: aNetService.name)
            aNetService.delegate = delegate
            aNetService.resolve(withTimeout: 5.0)
        })

        print("Resolved service")

        // Find the IPV4 address
        if let serviceIp = resolveIPv4(addresses: aNetService.addresses!) {
            print("Found IPV4:", serviceIp)
        } else {
            print("Did not find IPV4 address")
        }

//        if let data = aNetService.txtRecordData() {
//            let dict = NetService.dictionary(fromTXTRecord: data)
//            let value = String(data: dict["hello"]!, encoding: String.Encoding.utf8)
//
//            print("Text record (hello):", value!)
//            }
//        print(String(format: "Got service %p with hostname %@\n", aNetService, aNetService.hostName ?? ""))

        if !moreComing {
            updateUI()
        }
    }

    func netServiceDidResolveAddress(sender: NetService) {
        print(sender.addresses![0])
    }

    // Find an IPv4 address from the service address data
    func resolveIPv4(addresses: [Data]) -> String? {
        var result: String?

        for addr in addresses {
            let data = addr as NSData
            var storage = sockaddr_storage()
            data.getBytes(&storage, length: MemoryLayout<sockaddr_storage>.size)

            if Int32(storage.ss_family) == AF_INET {
                let addr4 = withUnsafePointer(to: &storage) {
                    $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
                        $0.pointee
                    }
                }

                if let ip = String(cString: inet_ntoa(addr4.sin_addr), encoding: .ascii) {
                    result = ip
                    break
                }
            }
        }

        return result
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove aNetService: NetService, moreComing: Bool) {
        while let elementIndex = services.index(of: aNetService) {
            services.remove(at: elementIndex)
        }

        if !moreComing {
            updateUI()
        }
    }
}