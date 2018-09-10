//
//  ViewController.swift
//  Chapter_05_Bonjour_Programming
//
//  Created by Larry Johnson on 8/18/18.
//  Copyright © 2018 Larry Johnson. All rights reserved.
//

import UIKit


class ViewController: UIViewController{


    /* The table view will display incoming and outgoing messages of the chat session
     */
    @IBOutlet var messages: UITableView!


    @IBOutlet var startButton: UIButton!
    /* newMessage and text field and “Send” button will allow the user to send responses to incoming messages.
     */
    @IBOutlet weak var newMessage: UITextField!

    var messageStrings:[String] = []


    var bonjourNetworkService: BonjourNetworkService?

    var currentStatus:ServiceStatus?

    var bonjourNetworkDiscoveryService:BonjourNetworkDiscoveryService?


//    init() {
//
//    }
//    let browser = Browser(type: "message", proto: "tcp")


    /* The “Start” button will change its title depending on whether the Bonjour service is waiting to
       be started (“Start”) or is already active (“Stop”).
    */
    @IBAction func start(_ sender: Any) {

        if self.currentStatus! == .STOPPED {

            bonjourNetworkService?.startService()

        } else if self.currentStatus! == .ACTIVE {

            bonjourNetworkService?.stopService()

        }

        bonjourNetworkDiscoveryService?.discoverService()

    }

    func browseForService() {
//        browser.stop()
//        _browser.searchForServices(ofType: "_message._tcp.", inDomain: "local.")
    }

    @IBAction func browse(_ sender: Any) {

//        let browser = NetServiceBrowser()
//        browser.searchForServices(ofType: "_message._tcp.", inDomain: "local.")
//        browser.stop()
//        let browser = NetServiceBrowser()
//        browser.searchForServices(ofType: "_airplay._tcp.", inDomain: "local.")
//        browser.delegate = self
//                withExtendedLifetime((browser, delegate)) {
//                    RunLoop.main.run()
//                }

//        browser.delegate?.netServiceBrowser?(<#T##browser: NetServiceBrowser##Foundation.NetServiceBrowser#>, didFind: <#T##NetService##Foundation.NetService#>, moreComing: <#T##Bool##Swift.Bool#>)

    }

    @IBOutlet var status: UILabel!

    @IBAction func send(_ sender: Any) {
        if (self.newMessage.text!.count > 0) {

            if (self.currentStatus == ServiceStatus.ACTIVE) || (self.currentStatus == ServiceStatus.WAITING_FOR_SERVER_MESSAGE) {

                self.bonjourNetworkService!.sendResponse(responseString: self.newMessage!.text!)

            }

        }
    }
    



    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Do any additional setup after loading the view, typically from a nib

        self.messages.register(UITableViewCell.self, forCellReuseIdentifier: "messageCell")

        // create service object

        bonjourNetworkService = BonjourNetworkService(name: "karlChatService")

        bonjourNetworkDiscoveryService = BonjourNetworkDiscoveryService(name: "karlChatService")

        // setup notification observers

        NotificationCenter.default.addObserver( self, selector: Selector(("handleStatusNotification:")), name: .updateStatus, object: bonjourNetworkService)

        NotificationCenter.default.addObserver( self, selector: Selector(("handleMessageNotification:")), name: .updateMessages, object: bonjourNetworkService)

        self.currentStatus = ServiceStatus.STOPPED
    }


    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }

    func handleStatusNotification(notification:NSNotification) {

        // assume we're in the main thread

        let userInfo:Dictionary = notification.userInfo!

        let statusValue:String = userInfo["status"] as! String

        let notifyStatus = ServiceStatus(rawValue: statusValue)

        if nil != notifyStatus {

            self.currentStatus = notifyStatus

        } else {

            self.currentStatus = ServiceStatus.UKNONWN

        }

        // update the status label

        self.status.text = currentStatus!.rawValue

        // update the start button as needed

        if self.currentStatus == .STOPPED {

            self.startButton.titleLabel!.text = "Start"

        } else {

            self.startButton.titleLabel!.text = "Stop"

        }
    }

    func handleMessageNotification(notification:NSNotification) {

        // add a string to the list

        let messageText:String = notification.userInfo!["message"] as! String

        let received:Bool = notification.userInfo!["received"] as! Bool

        // construct the message string based on whether it's received or sent

        if true == received {

            // incoming

            messageStrings.append("received|||"+messageText)

        } else {

            // outgoing

            messageStrings.append("sent|||"+messageText)

        }

        // tell the table to reload

        self.messages.reloadData()

    }

    // MARK: data source methods

    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return (messageStrings.count)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {

        var cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier:"messageCell", for:indexPath) as UITableViewCell

        var messageRawText = messageStrings[indexPath.row]

        var messageArray = messageRawText.components(separatedBy: "|||")

        let type:String = messageArray[0]

        let message:String = messageArray[1]

        cell.textLabel!.text = message

        if type == "received" {

            // message comes from client

            cell.textLabel!.textColor = UIColor(red: 0.35, green: 0.75, blue: 0.35, alpha: 1.0)

        } else {

            // message comes from server

            cell.textLabel!.textColor = UIColor(red: 0.75, green: 0.15, blue: 0.30, alpha: 1.0)

        }

        return cell
    }

    // MARK: text field delegate methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true

    }




}
