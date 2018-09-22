//
//  NowPlayingViewController.swift
//  SwiftObservers
//
//  Created by Larry Johnson on 9/16/18.
//  Copyright © 2018 Larry Johnson. All rights reserved.
//

import UIKit


class NowPlayingViewController: UIViewController {
    let item = AudioPlayer.Item()

    let player = AudioPlayer()

    @IBOutlet var titleLabel: UITextField!
  
    @IBOutlet var durationLabel: UITextField!
    
    @IBAction func startButton(_ sender: UIButton) {
        player.play(item)
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        player.stop(item)
    }
    
    @IBAction func pauseButton(_ sender: Any) {
        player.pause(item)
    }

    
    override func viewDidLoad() {
    super.viewDidLoad()

        titleLabel.text = item.title
        durationLabel.text = "\(item.duration)"

        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playbackDidStart),
                                               name: .playbackStarted,
                                               object:nil)

    }

    @objc private func playbackDidStart(_ notification: Notification) {
        guard let item = notification.object as? AudioPlayer.Item else {
            let object = notification.object as Any
            assertionFailure("Invalid object: \(object)")
            return
        }

        titleLabel.text = item.title
        durationLabel.text = "\(item.duration)"
    }


    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }
}
