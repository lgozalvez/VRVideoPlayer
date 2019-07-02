//
//  VRVideoView.swift
//  VRVideoPlayer
//
//  Created by Jhonny Bill Mena on 7/1/19.
//  Copyright © 2019 com.monteroc. All rights reserved.
//

import Foundation
import AVFoundation
import Swifty360Player

/// Displays a video in 360º, uses device motion and gestures recognizers to nagivate throughout the video.
@objc public class VRVideoView: UIViewController {
    
    fileprivate var swifty360ViewController: Swifty360ViewController?
    fileprivate var customVideoURL: URL? = nil
    fileprivate var autoplay: Bool = false
    fileprivate var videoFrame: CGRect = .zero
    fileprivate(set) var videoPlayer: AVPlayer?
    
    /// Creates a VRVideoView object to display a video in 360º with the provided information.
    ///
    /// - Parameters:
    ///   - url: video URL to display in the view.
    ///   - frame: display position and size to display the video in.
    ///   - autoPlay: determines whether or not the video should start playing automatically. Defaults to `true`.
    @objc public init(show url: URL, in frame: CGRect, autoPlay: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        self.customVideoURL = url
        self.videoFrame = frame
        self.autoplay = autoPlay
        self.view.frame = frame
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
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let url = customVideoURL else { return }
        videoPlayer = AVPlayer(url: url)
        guard let videoPlayer = videoPlayer else { return }
        
        let motionManager = Swifty360MotionManager.shared
        swifty360ViewController = Swifty360ViewController(withAVPlayer: videoPlayer,
                                                          motionManager: motionManager)
        
        if let swifty360ViewController = swifty360ViewController {
            addChild(swifty360ViewController)
            view.addSubview(swifty360ViewController.view)
            swifty360ViewController.didMove(toParent: self)
        }
        
        if autoplay {
            videoPlayer.play()
        }
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
    
    /// Updates the given URL and "rebuils" the current view.
    ///
    /// - Parameter url: new url to update from.
    @objc public func update(url: URL) {
        stop()
        customVideoURL = url
        viewWillAppear(false)
    }
    
    /// Pause and set to `nil` the current video player.
    @objc public func stop() {
        videoPlayer?.pause()
        videoPlayer = nil
    }
    
    /// Equivalent to "reloading" this view.
    ///
    /// Call this method if you'd like to "resume" a video that has been stopped using the `.stop()` method.
    @objc public func startOver() {
        viewWillAppear(false)
    }
    
    /// Sets the current video frame to fill the screen bounds.
    ///
    /// - Parameters:
    ///   - animated: whether we should animate this transition or not.
    ///   - duration: Total duration of the animations, measured in seconds.
    ///               When `animated` is false, this value defaults to 0.0.
    @objc public func fullScreen(animated: Bool, duration: Double) {
        let _duration = animated ? duration : 0.0
        UIView.animate(withDuration: _duration) {
            self.view.frame = UIScreen.main.bounds
        }
    }
    
    /// Undo the current full screen, if any.
    ///
    /// This method sets the view frame to the original `frame` provided when creating this `VRVideoView`.
    ///
    /// - Parameters:
    ///   - animated: whether we should animate this transition or not.
    ///   - duration: Total duration of the animations, measured in seconds.
    ///               When `animated` is false, this value defaults to 0.0.
    @objc public func undoFullScreen(animated: Bool, duration: Double) {
        let _duration = animated ? duration : 0.0
        UIView.animate(withDuration: _duration) {
            self.view.frame = self.videoFrame
        }
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
