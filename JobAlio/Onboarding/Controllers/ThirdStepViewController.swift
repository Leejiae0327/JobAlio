//
//  ThirdStepViewController.swift
//  How to Create an Onboarding Screen in Your App
//
//  Created by Can Balkaya on 12/3/20.
//

import UIKit

class ThirdStepViewController: UIViewController {

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func actionBtnStart(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnCheckShowBox(_ sender: UIButton) {
        LandscapeManager.shared.isFirstLaunch = true
        dismiss(animated: false, completion: nil)
    }
}


