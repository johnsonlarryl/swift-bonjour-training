import Foundation


class BonjourNetworkDiscoveryService:NSObject, NetServiceBrowserDelegate, NetServiceDelegate{
    let SERVICE_TYPE:String = "_https._tcp"

    var nsNetService:NetService?

    var _browser:NetServiceBrowser!

    var services: [AnyHashable] = []

    init(name:String) {
        super.init()
        services = [AnyHashable](repeating: 0, count: 0)
    }

    func discoverService () {
        DispatchQueue.main.async(execute: {
            self._browser = NetServiceBrowser()
            self._browser?.delegate = self
            self._browser?.searchForServices(ofType: self.SERVICE_TYPE, inDomain: "")
        })
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind aNetService: NetService, moreComing: Bool) {
        services.append(aNetService)

        DispatchQueue.main.async(execute: {
            aNetService.delegate = self
            aNetService.resolve(withTimeout: 5.0)
        })
    }

    func netServiceDidResolveAddress(_ service: NetService) {

        print(String(format: "%ld", service.port))

        print("Name: " + service.hostName!)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove aNetService: NetService, moreComing: Bool) {
        while let elementIndex = services.index(of: aNetService) {
            services.remove(at: elementIndex)
        }

    }
}