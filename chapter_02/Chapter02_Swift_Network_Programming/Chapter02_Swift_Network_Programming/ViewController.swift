//
//  ViewController.swift
//  Chapter02_Swift_Network_Programming
//
//  Created by Larry Johnson on 8/17/18.
//  Copyright © 2018 Larry Johnson. All rights reserved.
//

import UIKit
#import Chapter02_Swift_Network_Programming-Bridging-Header.h


class ViewController: UIViewController {

    @IBOutlet var ipv4Label: UILabel!
    @IBOutlet var ipv6Label: UILabel!
    @IBOutlet var get_info_button: UIButton!

    @IBAction func handleGetInfo(_ sender: Any) {
        var ipv4Value = "Not Available"
        var ipv6Value = "Not Available"

        var ifAddr: UnsafeMutablePointer<ifaddrs> = nil

        var ipv4AddressFound: Bool = false
        var ipv6AddressFound: Bool = false

        var getSuccess = getifaddress(&ifAddr)

        if 0 == getSuccess {
            var ptr = ifAddr

            while (ptr != nil) {
                let flags = Int32(ptr.memory.ifa_flags)

            }
        }
    }

    override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    }


    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }



}
