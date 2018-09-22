//
// Created by Larry Johnson on 9/22/18.
// Copyright (c) 2018 Larry Johnson. All rights reserved.
//

import Foundation



private extension AudioPlayer {
    func stateDidChange() {
        switch state {
            case .idle:
              NotificationCenter.default.post(name: .playbackStopped, object: nil)
            case .playing(let item):
                NotificationCenter.default.post(name: .playbackStarted, object: item)
            case .paused(let item):
                NotificationCenter.default.post(name: .playbackPaused, object: item)
        }
    }
}

private extension AudioPlayer {
    enum State {
        case idle
        case playing(Item)
        case paused(Item)
    }
}

extension Notification.Name {
    static var playbackStarted: Notification.Name {
        return .init(rawValue: "AudioPlayer.playbackStarted")
    }

    static var playbackPaused: Notification.Name {
        return .init(rawValue: "AudioPlayer.playbackPaused")
    }

    static var playbackStopped: Notification.Name {
        return .init(rawValue: "AudioPlayer.playbackStopped")
    }
}

class AudioPlayer {
    class Item {
        var title:String = "Hey Young World."
        var duration:Float = 4.62

    }

    private var state = State.idle {
        // We add a property observer on 'state', which lets us run
        // run a function on each value change
        didSet { stateDidChange() }

    }

    func play(_ item:Item) {
        state = .playing(item)
//        startPlayback(with: item)
        print("Playing song!\t" + "Title : " + item.title + "\tDuration: " + getString(duration: item.duration))
    }

    func pause(_ item:Item) {
        switch state {
            case .idle, .paused:
            // Calling pause when we're not in a playing state
            // could be considered a programming error, but since
            // it doesn't do any harm, we simply break here.
                print("Pausing song!\t" + "Title : " + item.title + "\tDuration: " + getString(duration: item.duration))
                break
            case .playing:
                state = .paused(item)
//                pausePlayback()

        }
    }

    func stop(_ item:Item) {
        state = .idle
        print("Stopping song!\t" + "Title : " + item.title + "\tDuration: " + getString(duration: item.duration))
//        stopPlayback()
    }

    func getString(duration:Float) -> String {
        return String(format: "%.2f", duration)
    }
}
