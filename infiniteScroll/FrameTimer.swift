//
//  ProcessorTimer.swift
//  infiniteScroll
//
//  Created by Jonathan Morin on 11/9/19.
//  Copyright © 2019 Jonathan Morin. All rights reserved.
//

import Foundation
import UIKit

// MARK: -

final class FrameTimer {

    // MARK: - Types

    typealias TimerEventHandler = () -> ()

    // MARK: - Properties

    static private(set) var prevMilliSeconds: Int = Date.currentTimeInMilliSeconds()
    static private(set) var frameDelta: CGFloat = 0.0

    // MARK: - Init

    private init() { }

    // MARK: - Static Methods

    static func createUpdateTimer(repeatInterval: DispatchTimeInterval = .milliseconds(15),
                                  eventHandler: TimerEventHandler? = nil) -> DispatchSourceTimer? {
        prevMilliSeconds = Date.currentTimeInMilliSeconds()
        frameDelta = 0.0

        return createTimer(
            repeatInterval: repeatInterval,
            eventHandler: {
                // Update frameDelta and prevMilliseconds
                if let floatUpdateInterval = repeatInterval.toCGFloat() {
                    let currMilliSeconds = Date.currentTimeInMilliSeconds()
                    frameDelta = CGFloat(currMilliSeconds - prevMilliSeconds) / floatUpdateInterval / 1000.0
                    prevMilliSeconds = currMilliSeconds
                }

                if let eventHandler = eventHandler {
                    eventHandler()
                }
            }
        )
    }

    static func createAutoStartTimer(startTime: DispatchTimeInterval = .seconds(1),
                                     repeatInterval: DispatchTimeInterval = .seconds(5),
                                     eventHandler: TimerEventHandler? = nil) -> DispatchSourceTimer? {
        return createTimer(
            startTime: startTime,
            repeatInterval: repeatInterval,
            eventHandler: {
                if let eventHandler = eventHandler {
                    eventHandler()
                }
            }
        )
    }

    // MARK: - Private

    private static func createTimer(startTime: DispatchTimeInterval = .milliseconds(0),
                                    repeatInterval: DispatchTimeInterval = .milliseconds(15),
                                    eventHandler: TimerEventHandler? = nil) -> DispatchSourceTimer? {
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: DispatchTime.now() + startTime,
                       repeating: repeatInterval)
        timer.setEventHandler(handler: eventHandler)
        timer.resume()
        return timer
    }

}
