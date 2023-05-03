//
//  SecondStepViewController.swift
//  How to Create an Onboarding Screen in Your App
//
//  Created by Can Balkaya on 12/3/20.
//

import UIKit

class SecondStepViewController: UIViewController {

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func actionBtnStart(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnCheckShowBox(_ sender: UIButton) {
        LandscapeManager.shared.isSkipOnboard = true
        dismiss(animated: false, completion: nil)
    }
    
    
}
