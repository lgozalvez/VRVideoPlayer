//
//  FullScreenButton+Extension.swift
//  VRVideoPlayer
//
//  Created by Jhonny Bill Mena on 7/4/19.
//  Copyright © 2019 com.monteroc. All rights reserved.
//

import Foundation

/// FullScreenButton configuration values.
@objc extension FullScreenButton {
    @objc public enum Appearance: Int {
        case dark = 0
        case light = 1
    }
    
    @objc public enum Background: Int {
        case vibrant = 0
        case opaque = 1
    }
    
    /// Determines de horizontal position.
    @objc public enum HPosition: Int {
        case right = 0
        case left = 1
    }
    
    /// Determines de vertical position.
    @objc public enum VPosition: Int {
        case top = 0
        case bottom = 1
    }
    
    @objc public enum Mode: Int {
        case fullScreen
        case normal
    }
}
