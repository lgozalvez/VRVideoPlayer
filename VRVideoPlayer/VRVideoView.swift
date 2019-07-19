//
//  VRVideoView.swift
//  VRVideoPlayer
//
//  Created by Jhonny Bill Mena on 7/1/19.
//  Copyright © 2019 com.monteroc. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Swifty360Player

/// Displays a video in 360º, uses device motion and gestures recognizers to nagivate throughout the video.
@objc public class VRVideoView: UIViewController {
    
    fileprivate var swifty360ViewController: Swifty360ViewController?
    fileprivate var customVideoURL: URL? = nil
    fileprivate var autoplay: Bool = false
    fileprivate var showFullScreenButton: Bool = true
    fileprivate var videoFrame: CGRect = .zero
    fileprivate(set) var videoPlayer: AVPlayer?
    
    @objc public var delegate: VRVideoViewDelegate?
    public var isFullScreen: Bool = false
    
    // Key-value observing context
    fileprivate var playerItemContext = 0
    
    // fileprivate var videoPlayerViewCenter: CGPoint = .zero
    
    /// Creates a VRVideoView object to display a video in 360º with the provided information.
    ///
    /// - Parameters:
    ///   - url: video URL to display in the view.
    ///   - frame: display position and size to display the video in.
    ///   - autoPlay: determines whether or not the video should start playing automatically. Defaults to `true`.
    ///   - showFullScreenButton: determines whether or not the view should have the Full Screen Button visible.
    @objc public init(show url: URL, in frame: CGRect, autoPlay: Bool = true, showFullScreenButton: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        
        self.customVideoURL = url
        self.videoFrame = frame
        self.autoplay = autoPlay
        self.showFullScreenButton = showFullScreenButton

        self.view.frame = frame
        
        self.initView()
    }
    
    /// Creates a VRVideoView object to display a video in 360º with the provided information.
    ///
    /// - Parameters:
    ///   - url: video URL to display in the view.
    ///   - frame: display position and size to display the video in.
    ///   - autoPlay: determines whether or not the video should start playing automatically. Defaults to `true`.
    ///   - showFullScreenButton: determines whether or not the view should have the Full Screen Button visible.
    fileprivate init(show url: URL,
                     in frame: CGRect,
                     with videoPlayer:AVPlayer?,
                     autoPlay: Bool = true,
                     showFullScreenButton: Bool = true) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.customVideoURL = url
        self.videoFrame = frame
        self.autoplay = autoPlay
        self.showFullScreenButton = showFullScreenButton
        self.videoPlayer = videoPlayer
        self.view.frame = frame
        
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swifty360ViewController?.view.frame = self.view.bounds
    }
    
    @objc public func shouldHideTransitionView() -> Bool {
        return true
    }
    
    fileprivate func initView() {
        guard let url = customVideoURL else { return }
        
        if videoPlayer == nil {
            videoPlayer = AVPlayer(url: url)
            
            delegate?.loadingVideo()
            delegate?.videoStatusChangedTo(status: .loading)
            
            // Register as an observer of the player item's status property.
            videoPlayer?.currentItem?.addObserver(self,
                                                  forKeyPath: #keyPath(AVPlayerItem.status),
                                                  options: [.old, .new],
                                                  context: &playerItemContext)
        }
        
        guard let videoPlayer = videoPlayer else { return }
        
        let motionManager = Swifty360MotionManager.shared
        
        guard swifty360ViewController == nil else {
            if autoplay {
                videoPlayer.play()
            }
            return
        }
        swifty360ViewController = Swifty360ViewController(withAVPlayer: videoPlayer,
                                                          motionManager: motionManager)
        
        if let swifty360ViewController = swifty360ViewController {
            if showFullScreenButton {
                addDefaultFullScreenButton(on: swifty360ViewController.view)
            }
            
            addChild(swifty360ViewController)
            view.addSubview(swifty360ViewController.view)
            swifty360ViewController.didMove(toParent: self)
        }
        
        if autoplay {
            videoPlayer.play()
        }
    }
    
    @objc private func addDefaultFullScreenButton(on view: UIView) {
        /// This method assumes the button will dispatch another view controller [modally]
        /// this means we will have 1 full screen button with only one possible state in a VRVideoView.
        let mode: FullScreenButton.Mode = isFullScreen ? .fullScreen : .normal
        
        _ = FullScreenButton(view: view, mode: mode, handler: { _ in
            if self.isFullScreen {
                self.undoFullScreen(animated: true, duration: 0.3)
            } else {
                self.fullScreen(animated: true, duration: 0.3)
            }
        })
    }
    
    // FIXME: Add the proper custom button when entering in full-screen mode.
    // TODO: expose this interface when issues gets solved.
    @objc private func addFullScreenButton(
        appearance: FullScreenButton.Appearance = .dark,
        background: FullScreenButton.Background = .vibrant,
        hPosition: FullScreenButton.HPosition = .left,
        vPosition: FullScreenButton.VPosition = .top,
        isFullScreen: Bool = false) {
        
        let mode: FullScreenButton.Mode = isFullScreen ? .fullScreen : .normal
        guard let _view = swifty360ViewController?.view else { return }
        
        _ = FullScreenButton(view: _view, mode: mode, handler: { _ in
            if isFullScreen {
                self.undoFullScreen(animated: true, duration: 0.3)
            } else {
                self.fullScreen(animated: true, duration: 0.3)
            }
        }, appearance: appearance, background: background, hPosition: hPosition, vPosition: vPosition)
    }
    
    // MARK: - Convenience methods.
    
    @objc public func play() {
        videoPlayer?.play()
    }
    
    @objc public func pause() {
        videoPlayer?.pause()
    }
    
    /// Rotates the `view` by the given angle.
    ///
    /// - Parameter angle: Must be a floating point value [in Radians].
    @objc public func rotate(by angle: Float) {
        let _angle = CGFloat(angle)
        view.transform = CGAffineTransform(rotationAngle: _angle)
    }
    
    /// Rotates the `view` to the given `RotationMode`
    ///
    /// - Parameters:
    ///   - mode: mode to rotate the view.
    ///   - animated: whether we should animate this transition or not.
    ///   - duration: Total duration of the animations, measured in seconds.
    ///               When `animated` is false, this value defaults to 0.0.
    @objc public func rotate(_ mode: RotationMode, animated: Bool, duration: Double) {
        let _duration = animated ? duration : 0.0
        let _angle = CGFloat(angle(for: mode))
        UIView.animate(withDuration: _duration) {
            self.view.transform = CGAffineTransform(rotationAngle: _angle)
        }
    }
    
    /// Updates the player with the given URL.
    ///
    /// If this method gets called with the same URL that is currently playing,
    /// it just `refresh` the video playback.
    ///
    /// ## Refreshing policy
    /// This method assumes your video is a live-streaming, that means when updating it, we try to play to the most up-to-date video playback time.
    ///
    /// Remember, this policy only applies when you pass the same URL that is currently playing. If you pass a new URL, this method
    /// just loads and play as it's supposed to do.
    ///
    /// - note: This method follows the `autoPlay` policy dictated at initialization time.
    ///
    /// - Parameters:
    ///   - url: new url to update from.
    @objc public func update(url: URL) {
        update(url: url, isStreaming: true)
    }
    
    /// Updates the player with the given URL.
    ///
    /// If this method gets called with the same URL that is currently playing,
    /// it just `refresh` the video playback.
    ///
    /// ## Refreshing policy
    /// By `refresh` we mean that if the `isStreaming` property is true, it plays from the most up-to-date video playback time.
    /// Otherwise, if `isStreaming` is false, the player starts playing the video from the beginning.
    ///
    /// Remember, this policy only applies when you pass the same URL that is currently playing. If you pass a new URL, this method
    /// just loads and play as it's supposed to do.
    ///
    /// - note: This method follows the `autoPlay` policy dictated at initialization time.
    ///
    /// - Parameters:
    ///   - url: new url to update from.
    ///   - isStreaming: if true, refresh the video from the most up-to-date playback time, otherwise, plays from the beginning.
    @objc public func update(url: URL, isStreaming: Bool = true) {
        defer {
            if autoplay {
                videoPlayer?.play()
            }
        }
        
        /// If we get the same URL, do not create a new one,
        /// just make it seek the appropiate playback time.
        if customVideoURL == url  {
            if (videoPlayer?.currentItem != nil) {
                videoPlayer?.seek(to: isStreaming ? .positiveInfinity : .zero)
                return
            }
        }
        
        
        customVideoURL = url
        
        let item = AVPlayerItem(url: url)
        
        delegate?.loadingVideo()
        delegate?.videoStatusChangedTo(status: .loading)
        
        // Register as an observer of the player item's status property.
        item.addObserver(self,
                         forKeyPath: #keyPath(AVPlayerItem.status),
                         options: [.old, .new],
                         context: &playerItemContext)
        
        videoPlayer?.replaceCurrentItem(with: item)
        
        self.rewindVideo()
    }
    
    /// Invalidates the current playing video. Basically this throw away the video it was playing.
    ///
    /// To continue playing the same video you stopped, call `.startOver()` or `.startOver(streaming:)` methods.
    @objc public func stop() {
        videoPlayer?.pause()
        self.rewindVideo()
        videoPlayer?.replaceCurrentItem(with: nil)
    }
    
    /// Starts over the current playing video.
    ///
    /// Call this method after you stopped a video and want to play it again. [i.e. after calling the `.stop()` method.]
    ///
    /// If you call this method and there's a playing video, we apply the following policy:
    /// ## Refreshing policy
    /// This method assumes your video is a live-streaming, that means when updating it, we try to play to the most up-to-date video playback time.
    ///
    /// - note: This method follows the `autoPlay` policy dictated at initialization time.
    @objc public func startOver() {
        startOver(streaming: true)
    }
    
    /// Starts over the current playing video.
    ///
    /// Call this method after you stopped a video and want to play it again. [i.e. after calling the `.stop()` method.]
    ///
    /// If you call this method and there's a playing video, we apply the following policy:
    /// ## Refreshing policy
    /// By `refresh` we mean that if the `streaming` property is true, it plays from the most up-to-date video playback time.
    /// Otherwise, if `isStreaming` is false, the player starts playing the video from the beginning.
    ///
    /// - note: This method follows the `autoPlay` policy dictated at initialization time.
    @objc public func startOver(streaming: Bool = true) {
        defer {
            if autoplay {
                videoPlayer?.play()
            }
        }
        
        /// If there's already an item, do not create a new one,
        /// just make it seek the up-to-date stream.
        /// - warning: this only works for live streamming videos; to support normal videos,
        ///            we need to seek `.zero`.
        guard videoPlayer?.currentItem == nil else {
            videoPlayer?.seek(to: streaming ? .positiveInfinity : .zero)
            return
        }
        
        guard let url = customVideoURL else { return }
        let item = AVPlayerItem(url: url)
        
        delegate?.loadingVideo()
        delegate?.videoStatusChangedTo(status: .loading)
        
        // Register as an observer of the player item's status property.
        item.addObserver(self,
                         forKeyPath: #keyPath(AVPlayerItem.status),
                         options: [.old, .new],
                         context: &playerItemContext)
        videoPlayer?.replaceCurrentItem(with: item)
    }
    
    /// Sets the current video frame to fill the screen bounds.
    ///
    /// - Parameters:
    ///   - animated: whether we should animate this transition or not.
    ///   - duration: Total duration of the animations, measured in seconds.
    ///               When `animated` is false, this value defaults to 0.0.
    @objc public func fullScreen(animated: Bool, duration: Double) {
        guard let url = customVideoURL else { return }
        let fullScreenVC = VRVideoView(show: url,
                                       in: UIScreen.main.bounds,
                                       with: self.videoPlayer,
                                       autoPlay: true,
                                       showFullScreenButton: true)
        
        fullScreenVC.delegate = delegate
        fullScreenVC.isFullScreen = true
        
        UIApplication.topViewController().definesPresentationContext = true
        fullScreenVC.modalPresentationStyle = .overFullScreen
        fullScreenVC.modalTransitionStyle = .crossDissolve
        UIApplication.topViewController().present(fullScreenVC, animated: true, completion: nil)
    }
    
    
    /// Undo the current full screen, if any.
    /// This method just dismiss the current `VRVideoView`.
    ///
    /// - Parameters:
    ///   - animated: whether we should animate this transition or not.
    @objc public func undoFullScreen(animated: Bool, duration: Double) {
        dismiss(animated: animated, completion: nil)
    }
    
    fileprivate func rewindVideo() {
        videoPlayer?.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 10), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
}

// MARK: - Helper
@objc extension VRVideoView {
    /// Computes the angle for the given `RotationMode`
    ///
    /// - Parameter mode: position to rotate.
    /// - Returns: floating point representing the angle (in radians).
    ///            Remember iOS coordinate system is flipped,
    ///            also, positive values will lead to a counterclockwise rotation.
    @objc private func angle(for mode: RotationMode) -> Float {
        switch mode {
        case .right:
            return (90 * .pi) / 180
        case .left:
            return (270 * .pi) / 180
        case .down:
            return (180 * .pi) / 180
        case .up:
            return (360 * .pi) / 180
        }
    }
}

// MARK: - Observer
@objc extension VRVideoView {
    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?) {
        
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayer.status) {
            let status: AVPlayerItem.Status?
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)
            } else {
                status = .unknown
            }
            
            guard let _status = status else {
                delegate?.failedToLoadVideo()
                delegate?.videoStatusChangedTo(status: .failed)
                return
            }
            
            switch _status {
            case .readyToPlay:
                delegate?.readyToPlayVideo()
                delegate?.videoStatusChangedTo(status: .readyToPlay)
            case .failed:
                delegate?.failedToLoadVideo()
                delegate?.videoStatusChangedTo(status: .failed)
            case .unknown:
                delegate?.loadingVideo()
                delegate?.videoStatusChangedTo(status: .loading)
            @unknown default:
                delegate?.failedToLoadVideo()
                delegate?.videoStatusChangedTo(status: .failed)
            }
        }
    }
}
