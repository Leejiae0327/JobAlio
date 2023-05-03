//
//  LogoAnimationView.swift
//  AnimatedGifLaunchScreen-Example
//
//  Created by Amer Hukic on 13/09/2018.
//  Copyright © 2018 Amer Hukic. All rights reserved.
//

import UIKit
import SwiftyGif

class LogoAnimationViewController: UIView {
    
    //open override var safeAreaInsets: UIEdgeInsets
    //open override var safeAreaLayoutGuide: UILayoutGuide
    
    let logoGifImageView: UIImageView = {
        guard let gifImage = try? UIImage(gifName: "jobalio_Splash.gif") else {
            return UIImageView()
        }
        return UIImageView(gifImage: gifImage, loopCount: 2)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        //backgroundColor = UIColor(white: 500.0 / 470.0, alpha: 1)
        //logoGifImageView.frame = UIScreen.main.bounds
        //let vc = ViewController().webView.frame.size
        //logoGifImageView.frame.size = vc
        //logoGifImageView.contentMode = .scaleAspectFit
        addSubview(logoGifImageView)
        
        //logoGifImageView.frame.size = CGSize(width: 414.0, height: 818.0)
        logoGifImageView.contentMode = .scaleToFill
        logoGifImageView.translatesAutoresizingMaskIntoConstraints = false
        logoGifImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoGifImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        ///logoGifImageView.widthAnchor.constraint(equalToConstant: 414).isActive = true
        //logoGifImageView.heightAnchor.constraint(equalToConstant: 818).isActive = true
        
        logoGifImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        logoGifImageView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        logoGifImageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        logoGifImageView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        
        
        
        
        
        
        print("frame: ", UIScreen.main.bounds)
    }
}

