//
//  FullScreenButton.swift
//  VRVideoPlayer
//
//  Created by Jhonny Bill Mena on 7/4/19.
//  Copyright © 2019 com.monteroc. All rights reserved.
//

import Foundation
import UIKit

@objc public class FullScreenButton: UIButton {

    /// View to present the button on top of.
    @objc weak var view: UIView?
    private var appearance: Appearance = .dark
    private var background: Background = .vibrant
    private var hPosition: HPosition = .left
    private var vPosition: VPosition = .top
    
    /// Full screen action.
    /// This closure gets called when the button gets touched (when firing `.touchUpInside` event).
    var handler: ((FullScreenButton) -> Void)?
    
    @objc init(view: UIView, handler: ((FullScreenButton) -> Void)? = nil) {
        self.view = view
        self.handler = handler
        super.init(frame: .init(x: 20, y: 10, width: 30, height: 30))
        
        view.addSubview(self)
        view.bringSubviewToFront(self)
        prepareButton()
        self.addTarget(self, action: #selector(perform(action:)), for: .touchUpInside)
    }
    
    // FIXME: some constraints are not working propertly. Also, opaque property needs some work.
    // TODO: document this initializer.
    @objc init(view: UIView,
               handler: ((FullScreenButton) -> Void)? = nil,
               appearance: Appearance = .dark,
               background: Background = .vibrant,
               hPosition: HPosition = .left,
               vPosition: VPosition = .top) {
        
        self.appearance = appearance
        self.background = background
        self.hPosition = hPosition
        self.vPosition = vPosition
        
        // Code from previous init
        self.view = view
        self.handler = handler
        super.init(frame: .init(x: 20, y: 10, width: 30, height: 30))
        
        view.addSubview(self)
        view.bringSubviewToFront(self)
        prepareButton()
        self.addTarget(self, action: #selector(perform(action:)), for: .touchUpInside)
        // End of Code from previous init
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func perform(action: FullScreenButton) {
        if let handler = action.handler {
            handler(self)
        }
    }
    
    @objc private func prepareButton() {
        // FIXME: some constraints are not working.
        translatesAutoresizingMaskIntoConstraints = false
        
        widthAnchor.constraint(equalToConstant: 60).isActive = true
        heightAnchor.constraint(equalToConstant: 40).isActive = true

        if let _view = view {
            switch hPosition {
            case .left:
                leftAnchor.constraint(equalTo: _view.layoutMarginsGuide.leftAnchor/*_view.leftAnchor*/, constant: 15).isActive = true
            case .right:
                rightAnchor.constraint(equalTo: _view.layoutMarginsGuide.rightAnchor/*_view.rightAnchor*/, constant: 15).isActive = true
            }
            
            switch vPosition {
            case .top:
                topAnchor.constraint(equalTo: _view.layoutMarginsGuide.topAnchor/*_view.topAnchor*/, constant: 15).isActive = true
            case .bottom:
                bottomAnchor.constraint(equalTo: _view.layoutMarginsGuide.bottomAnchor/*_view.bottomAnchor*/, constant: 15).isActive = true
            }
        }

        // Configure button icon and blur based on appearance.
        set(mode: .normal)
        
        var effect: UIBlurEffect
        if case .dark = appearance {
            effect = .init(style: .dark)
        } else {
            effect = .init(style: .light)
        }
        
        imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        // Set background color and blur.
        backgroundColor = .clear
        let blur = UIVisualEffectView(effect: effect)
        blur.translatesAutoresizingMaskIntoConstraints = true
        
        switch background {
        case .opaque:
            blur.isOpaque = true
            blur.alpha = 1
        case .vibrant:
            blur.isOpaque = false
        }

        clipsToBounds = true
        layer.cornerRadius = 10
        
        blur.frame = .init(x: 0, y: 0, width: 60, height: 40)
        blur.isUserInteractionEnabled = false
        blur.clipsToBounds = true
        blur.layer.cornerRadius = layer.cornerRadius
        
        blur.widthAnchor.constraint(equalToConstant: 60).isActive = true
        blur.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addSubview(blur)
        sendSubviewToBack(blur)
        
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            blur.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            blur.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            ])
    }
    
    /// Tell the button what's it's current state or mode.
    ///
    /// This method configure the button icons based on it's mode.
    ///
    /// - Parameter mode: determines the current button mode, `fullScreen` or `normal`.
    @objc public func set(mode: Mode) {
        if case .fullScreen = mode {
            setCloseIcon()
        } else {
            setExpandIcon()
        }
    }
    
    @objc private func setCloseIcon() {
        switch appearance {
        case .dark:
            let bundle = Bundle(for: type(of: self))
            let image = UIImage(named: "cancel_music_light_icon", in: bundle, compatibleWith: nil)
            setImage(image, for: .normal)
            imageView?.contentMode = .scaleAspectFit
            
            tintColor = .white
            setTitleColor(.white, for: .normal)
        case .light:
            let bundle = Bundle(for: type(of: self))
            let image = UIImage(named: "cancel_music_dark_icon", in: bundle, compatibleWith: nil)
            setImage(image, for: .normal)
            imageView?.contentMode = .scaleAspectFit
            
            tintColor = .black
            setTitleColor(.black, for: .normal)
        }
    }
    
    @objc private func setExpandIcon() {
        switch appearance {
        case .dark:
            let bundle = Bundle(for: type(of: self))
            let image = UIImage(named: "full_screen_light_icon", in: bundle, compatibleWith: nil)
            setImage(image, for: .normal)
            imageView?.contentMode = .scaleAspectFit
            
            tintColor = .white
            setTitleColor(.white, for: .normal)
        case .light:
            let bundle = Bundle(for: type(of: self))
            let image = UIImage(named: "full_screen_dark_icon", in: bundle, compatibleWith: nil)
            setImage(image, for: .normal)
            imageView?.contentMode = .scaleAspectFit
            
            tintColor = .black
            setTitleColor(.black, for: .normal)
        }
    }
}
