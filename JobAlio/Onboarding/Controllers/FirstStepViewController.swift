//
//  FirstStepViewController.swift
//  How to Create an Onboarding Screen in Your App
//
//  Created by Can Balkaya on 12/3/20.
//

import UIKit

class FirstStepViewController: UIViewController {

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func actionBtnTapped(_ sender: UIButton) {
        if let pageController = parent as? MainPageViewController {
            pageController.pushNext()
        }
    }
    
    @IBAction func actionBtnSkip(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
}
