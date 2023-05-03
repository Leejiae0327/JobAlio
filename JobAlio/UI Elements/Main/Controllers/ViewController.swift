//
//  ViewController.swift
//  JobAlio
//
//  Created by jiea on 2021/06/23.
//

import UIKit
//import SwiftyGif
import WebKit

class ViewController: UIViewController{
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var popupView : WKWebView!
    //let logoAnimationView = LogoAnimationViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.addSubview(logoAnimationView)
        //logoAnimationView.pinEdgesToSuperView()
        //logoAnimationView.logoGifImageView.delegate = self
        
       
    }

}
