////
////  MainPageViewController.swift
////  How to Create an Onboarding Screen in Your App
////
////  Created by Can Balkaya on 12/3/20.
////
//
//import UIKit
//
//class PageViewController: UIPageViewController {
//
//    lazy var vcArray: [UIViewController] = {
//        return [self.vcInstance(name: "FirstStepVC"),
//        self.vcInstance(name: "SecondStepVC")]
//    }()
//
//    private func vcInstance(name:String) -> UIViewController{
//        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.dataSource = self
//        self.delegate = self
//        if let firstVC = vcArray.first{
//            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
//        }
//
////        LandscapeManager.shared.isFirstLaunch = true
////        self.setViewControllers([viewControllerList[0]], direction: .forward, animated: false, completion: nil)
//    }
//
//
//    func pageViewController(_ pagViwController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
//
//        guard let vcIndex = vcArray.firstIndex(of: viewController) else{
//            return nil
//        }
//
//        let prevIndex = vcIndex-1
//
//        guard prevIndex >= 0 else{
//            return nil
//        }
//
//        guard vcArray.count > prevIndex else {
//            return nil
//        }
//
//        return vcArray[prevIndex]
//    }
//
//}
//
//extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate{
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
//
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
//
//    }
//}
