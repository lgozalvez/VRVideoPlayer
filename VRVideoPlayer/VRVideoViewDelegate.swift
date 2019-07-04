//
//  VRVideoViewDelegate.swift
//  VRVideoPlayer
//
//  Created by Jhonny Bill Mena on 7/6/19.
//  Copyright © 2019 com.monteroc. All rights reserved.
//

import Foundation

@objc public protocol VRVideoViewDelegate {
    
    /// This method gets called every time the `VideoView` update it's video.
    ///
    /// This method gets called after the corresponding specific status method.
    ///
    /// [i.e. when a `.loading` status gets fired,
    /// first we invoke the `loadingVideo()` method, and then this method gets called.]
    ///
    /// - Parameter status: new video status.
    @objc func videoStatusChangedTo(status: VideoStatus)
    
    @objc func loadingVideo()
    @objc func readyToPlayVideo()
    @objc func failedToLoadVideo()
}
