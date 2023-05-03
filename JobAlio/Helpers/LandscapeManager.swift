//
//  LandscapeManager.swift
//  How to Create an Onboarding Screen in Your App
//
//  Created by Can Balkaya on 12/3/20.
//

import Foundation

class LandscapeManager {
    static let shared = LandscapeManager()
    
    var isSkipOnboard: Bool { //다음부터 온보딩화면 표시하지 않기 체크시 false
        get {
            !UserDefaults.standard.bool(forKey: #function)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: #function)
        }
    }
    
    var isFirst = false
    var isFirstLaunch: Bool { //스플래시 화면 최초 1회만 보이기(앱 최초 실행인지 아닌지 구분)
        get {
            return isFirst
        }
        set(value) {
            isFirst = value
        }
    }
    
    
}
