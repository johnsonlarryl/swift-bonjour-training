//
// Created by Larry Johnson on 8/19/18.
// Copyright (c) 2018 Larry Johnson. All rights reserved.
//

import Foundation


class BonjourNetworkDiscoveryServiceCopy:NSObject, NetServiceBrowserDelegate{

    let SERVICE_TYPE:String = "_message._tcp"

    let SERVICE_DOMAIN:String = "local"

    let SERVICE_DOMAIN_ALL:String = ""

    var serviceType:String?

    var serviceDomain:String?

    var nsNetService:NetService?

    var clientStreamArray:[OutputStream] = []

    var _browser:NetServiceBrowser!

    var _service: NetService!

    var services = [NetService]()

    var serviceFoundClosure: (([NetService]) -> Void)

    var isSearching = false

    var serviceTimeout: Timer = Timer()

    var timeout: TimeInterval = 1.0


    init(name:String) {
        serviceType = SERVICE_TYPE
        serviceDomain = SERVICE_DOMAIN
        self._browser = NetServiceBrowser()

        self._browser.includesPeerToPeer = true

        self.serviceFoundClosure = { (v) in
            return
        }

        self.isSearching = true

        super.init()

    }

    // this will look on the network for any _http._tcp bonjour services whose name
    // contains th string "webpack" and will set our debugEndpoint to whatever that
    // resolves to. this allows us to debug bundles over the network without complicated setup
//    func setupBonjour() {
//        let _ = bonjourBrowser.findService("_http._tcp") { (services) in
//            for svc in services {
//                if !svc.name.lowercased().contains("webpack") {
//                    continue
//                }
//                self.debugNetService = svc
//                svc.resolve(withTimeout: 1.0)
//                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//                    guard let netService = self.debugNetService else {
//                        return
//                    }
//                    self.debugEndpoint = "http://\(netService.hostName ?? ""):\(netService.port)"
//                    print("[BRWebViewController] discovered bonjour debugging service \(String(describing: self.debugEndpoint))")
//                    self.server.resetMiddleware()
//                    self.setupIntegrations()
//                    self.refresh()
//                }
//                break
//            }
//        }
//    }


    func discoverService () {
        DispatchQueue.main.async(execute: {
            self._browser = NetServiceBrowser()
            self._browser?.delegate = self
            self._browser?.searchForServices(ofType: "_message._tcp", inDomain: "")

//            self._browser.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
//            self._browser!.delegate = self
//            self._browser!.searchForRegistrationDomains()
//            self._browser!.searchForServices(ofType: self.serviceType!, inDomain: "")

            for service in self.services {
                if service.port == -1 {
                    print("service \(service.name) of type \(service.type)" +
                            " not yet resolved")
                    service.resolve(withTimeout: 0.0)
                } else {
//                    service.sear
                    let dict = NetService.dictionary(fromTXTRecord: service.txtRecordData()!)

                    var ipAdd = ""
                    if let address = service.addresses{
                        if let addressOfFirstDevice = address.first{
                            let theAddress = addressOfFirstDevice as Data
                            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                            if getnameinfo((theAddress as NSData).bytes.bindMemory(to: sockaddr.self, capacity: theAddress.count), socklen_t(theAddress.count),
                                    &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                                if let numAddress = String(validatingUTF8: hostname) {
                                    ipAdd = numAddress
                                }
                            }

                            print("IP Address: " + ipAdd + "\t" + "Port: " + String(service.port))
                        }
                    }
                }
            }
        })





    }



    func netServiceBrowser(aNetServiceBrowser: NetServiceBrowser, didFindService aNetService: NetService, moreComing: Bool) {
        print("Service appeared: \(aNetService)")
        services.append(aNetService)
        aNetService.resolve(withTimeout: 5.0)
    }

    func netServiceBrowser(browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        print(domainString)
    }


    func netServiceBrowser(browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print(errorDict)
    }

    func netServiceBrowser(browser: NetServiceBrowser, didRemoveService service: NetService, moreComing: Bool) {
        print("Service removed: \(service)")

    }

    func netService(sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print(errorDict)
    }

    func netServiceDidResolveAddress(sender: NetService) {
        print(sender.addresses![0])
    }

    func findService(_ identifier: String, domain: String = "local.", found: @escaping ([NetService]) -> Void) -> Bool {
        if !self.isSearching {
            self.serviceTimeout = Timer.scheduledTimer(timeInterval: timeout, target: self,
                    selector: #selector(BonjourNetworkDiscoveryServiceCopy.noServicesFound),
                    userInfo: nil, repeats: false)
            self._browser.searchForServices(ofType: identifier, inDomain: domain)
            self.serviceFoundClosure = found
            self.isSearching = true
            return true
        }
        return false
    }

    @objc func noServicesFound() {
        self.serviceFoundClosure(services)
        self._browser.stop()
        self.isSearching = false
    }

}