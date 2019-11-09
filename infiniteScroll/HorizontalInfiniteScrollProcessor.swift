//
//  HorizontalInfiniteScrollCollectionViewProcessor.swift
//  infiniteScroll
//
//  Created by Jonathan Morin on 10/22/19.
//  Copyright © 2019 Jonathan Morin. All rights reserved.
//

import UIKit

// MARK: -

/// This class will auto scroll a collection view horizontally
class HorizontalInfiniteScrollCollectionViewProcessor: NSObject {

    // MARK: - Types

    typealias DefaultCallback = () -> ()
    typealias TimerEventHandler = DefaultCallback
    typealias CollectionViewRotateContentCallback = DefaultCallback
    typealias CollectionViewSelectContentCallback = (IndexPath) -> ()

    enum ScrollDirection {
        case right
        case left
    }

    // MARK: - Properties

    /// Move Delta (how fast to move scroll); Default = 1.0
    var moveDelta: CGFloat = 1.0

    /// How often to run the update; Default = .milliseconds(15)
    var processorTimerUpdateInterval: DispatchTimeInterval = .milliseconds(15)

    /// How often to run auto start (if user has interacted with the collection view); Default = .seconds(5)
    var autoStartTimerUpdateInterval: DispatchTimeInterval = .seconds(5)

    /// Time interval to auto resume after a cell has been selected; Default = .seconds(5)
    var autoResumeTimerUpdateInterval: DispatchTimeInterval = .seconds(5)

    /// Direction to scroll collection view; Default = .right
    var scrollDirection: ScrollDirection = .right

    /// Right now we only handle specific sized collection view cells; Default = CGSize(width: 50, height: 50)
    var collectionViewCellSize: CGSize = CGSize(width: 50, height: 50)

    /// Spacing between collection view cells; Default = 0.0
    var collectionViewMinSpacing: CGFloat = 0.0

    /// Callback for collection view cell selection
    var collectionViewSelectContentCallback: CollectionViewSelectContentCallback?

    /// Callback to request that you rotate your collection view content data array
    ///
    /// NOTE: You need to properly rotate your content array based on the scroll direction
    ///
    /// Scroll Direction:
    ///     right = remove last, prepend
    ///     left = remove first, append
    var collectionViewRotateContentCallback: CollectionViewRotateContentCallback?

    // MARK: - Private Properties

    private(set) var parentController: UIViewController?
    private(set) var collectionView: UICollectionView?
    private(set) var contentOffset: CGPoint = CGPoint(x: 0, y: 0)
    private(set) var processorTimer: DispatchSourceTimer?
    private(set) var autoStartTimer: DispatchSourceTimer?
    private(set) var prevMilliSeconds: Int = Date.currentTimeInMilliSeconds()
    private(set) var frameDelta: CGFloat = 0.0
    private(set) var paused: Bool = true

    // MARK: - Init

    /// Instantiate instance with a UICollectionView
    ///
    /// - Parameter collectionView: the collection view to auto scroll
    required init(collectionView: UICollectionView) {
        super.init()

        self.collectionView = collectionView

        create()
    }

    // MARK: - Deinit

    deinit {
        destroy()
    }

}

// MARK: - Internal Methods

extension HorizontalInfiniteScrollCollectionViewProcessor {

    /// Call this when the controller you instantiated InfiniteScrollCollectionViewProcessor in gets destroyed
    func destroy() {
        processorTimer?.cancel()
        processorTimer = nil

        autoStartTimer?.cancel()
        autoStartTimer = nil

        parentController = nil
        collectionView = nil
    }

    /// Tells the processor too resume scrolling and reset the auto start timer
    func resumeProcessor() {
        autoStartTimer?.schedule(deadline: DispatchTime.now(),
                                 repeating: autoStartTimerUpdateInterval)
        autoStartTimer?.resume()
    }

}

// MARK: - UICollectionViewDelegate

extension HorizontalInfiniteScrollCollectionViewProcessor: UICollectionViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pauseProcessor()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }

            // Set collection view scroll view contentOffset to our contentOffset
            scrollView.contentOffset = self.contentOffset
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        pauseProcessor()

        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                let collectionView = self.collectionView else {
                return
            }

            // Set our contentOffset to collection view scroll view contentOffset
            self.contentOffset = scrollView.contentOffset
            collectionView.setContentOffset(self.contentOffset,
                                            animated: false)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        stopProcessor()

        // Now to collection view that something was selected
        if let collectionViewSelectContentCallback = collectionViewSelectContentCallback {
            collectionViewSelectContentCallback(indexPath)
        }
    }

}

// MARK: - Private Methods

extension HorizontalInfiniteScrollCollectionViewProcessor {

    private func create() {
        createProcessorTimer()
        createAutoStartTimer()
    }

    private func process() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                !self.paused,
                let collectionView = self.collectionView else {
                    return
            }

            var rotateContent = false

            // Increment content offset by moveDelta
            switch self.scrollDirection {
            case .right:
                self.contentOffset.x -= (self.moveDelta * self.frameDelta)
                if (self.contentOffset.x <= 0) {
                    // Calculate new offset, which is the current offset minus the width of a cell
                    let contentOffsetX = self.contentOffset.x
                    let cellWidth = self.collectionViewCellSize.width + self.collectionViewMinSpacing
                    let newContentOffsetX = (contentOffsetX + cellWidth)
                    self.contentOffset.x = newContentOffsetX
                    rotateContent = true
                }
            case .left:
                self.contentOffset.x += (self.moveDelta * self.frameDelta)
                if (self.contentOffset.x >= (collectionView.contentSize.width - collectionView.bounds.width)) {
                    // Calculate new offset, which is the current offset minus the width of a cell
                    let contentOffsetX = self.contentOffset.x
                    let cellWidth = self.collectionViewCellSize.width + self.collectionViewMinSpacing
                    let newContentOffsetX = (contentOffsetX - cellWidth)
                    self.contentOffset.x = newContentOffsetX
                    rotateContent = true
                }
            }

            // Should we tell collection view content to rotate the content array?
            if rotateContent {
                if let collectionViewRotateContentCallback = self.collectionViewRotateContentCallback {
                    collectionViewRotateContentCallback()
                }
            }

            // Update collection view content offset
            collectionView.setContentOffset(self.contentOffset,
                                            animated: false)
        }
    }

    private func pauseProcessor() {
        paused = true

        autoStartTimer?.suspend()
        autoStartTimer?.schedule(deadline: DispatchTime.now() + .seconds(5),
                                 repeating: autoStartTimerUpdateInterval)
        autoStartTimer?.resume()
    }

    private func stopProcessor() {
        paused = true

        autoStartTimer?.suspend()
    }

    private func createProcessorTimer() {
        processorTimer = createTimer(
            repeatInterval: processorTimerUpdateInterval,
            eventHandler: { [weak self] in
                guard let self = self else {
                    return
                }

                // Update frameDelta and prevMilliseconds
                if let floatUpdateInterval = self.processorTimerUpdateInterval.toCGFloat() {
                    let currMilliSeconds = Date.currentTimeInMilliSeconds()
                    self.frameDelta = CGFloat(currMilliSeconds - self.prevMilliSeconds) / floatUpdateInterval / 1000.0
                    self.prevMilliSeconds = currMilliSeconds
                }

                self.process()
            }
        )
    }

    private func createAutoStartTimer() {
        autoStartTimer = createTimer(
            startTime: .seconds(1),
            repeatInterval: autoStartTimerUpdateInterval,
            eventHandler: { [weak self] in
                guard let self = self else {
                    return
                }
                if self.paused {
                    self.paused = false
                }
            }
        )
    }

    private func createTimer(startTime: DispatchTimeInterval = .milliseconds(0),
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
