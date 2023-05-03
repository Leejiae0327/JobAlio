
//
//  ConciergeViewController.swift
//  How to Create an Onboarding Screen in Your App
//
//  Created by Can Balkaya on 12/3/20.
//

import UIKit
import WebKit
import SwiftyGif
import AuthenticationServices
import Alamofire
import SafariServices

class ConciergeViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    
    @IBOutlet weak var webView: WKWebView!
    //@IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var url: URL!
    var popupView : WKWebView!
    let logoAnimationView = LogoAnimationViewController()
    
    //closeBtn
    let closeImage: UIImage = UIImage(named: "btn_close.png")!
    var imageView: UIImageView!
    
    //cookie
    var plainId = ""
    var cipherId = ""
    
    //appVersion
    var version: String? {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String else {return nil}
                           
        let versionAndBuild: String = "\(version)"
        return versionAndBuild
    }

    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        //webView.configuration.websiteDataStore = WKWebsiteDataStore.default()
        //webView.configuration.websiteDataStore.accessibilityActivate()
        //print(webView.configuration.websiteDataStore.isPersistent)
        
        if !LandscapeManager.shared.isFirstLaunch { //온보딩 나오기 전에만 실행
            view.addSubview(logoAnimationView)
            logoAnimationView.pinEdgesToSuperView()
            logoAnimationView.logoGifImageView.delegate = self
        }
        
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        
        let contentController = webView.configuration.userContentController
        contentController.add(self, name: "getLogin")
        contentController.add(self, name: "getVersion")

        //userAgent 변경
        webView.evaluateJavaScript("navigator.userAgent"){(result, error) in
            let originUserAgent = result as! String
            let agent = originUserAgent + " JOBALIO_APP_IOS_VERSION_" + self.version!
            self.webView.customUserAgent = agent
        }
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
       
        if !LandscapeManager.shared.isFirstLaunch {
            if LandscapeManager.shared.isSkipOnboard {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.5){
                    self.performSegue(withIdentifier: "toOnboarding", sender: nil)
                    self.openPage("https://job.alio.go.kr/mobile2021/home.do")
                    //self.openPage("http://localhost:8080/mobile2021/home.do")
                    //self.setAppVersion()
                }
            }else{
                openPage("https://job.alio.go.kr/mobile2021/home.do")
                //openPage("http://localhost:8080/mobile2021/home.do")
                //self.setAppVersion()
            }
            
        }
        
    }
    
    func setAppVersion(){
        print("")
        print("===============================")
        print("[ViewController >> sendFunctionOpen() : IOS >> 자바스크립트]")
        print("_send : ", version!)
        print("===============================")
        print("")
//        self.webView!.evaluateJavaScript("setIosAppVersion('\(version!)')", completionHandler: nil)
        self.webView!.evaluateJavaScript("setIosAppVersion('\(version!)')", completionHandler: {
            (any, err) -> Void in
            print(err ?? "[receive_Open] IOS >> 자바스크립트 : SUCCESS")
        })
    }
    
    private func updatePushToken(_ plainId:String){
        //Alamofire POST 요청
        //let url = "http://127.0.0.1:8080/mobile2021/member/getToken.do"
        let url = "https://job.alio.go.kr/api/pushToken.do"
        
        let ad = UIApplication.shared.delegate as? AppDelegate
        let pushToken = ad?.paramPushToken ?? ""
        print("pushToken : ",pushToken)
        let params = ["user_id" : plainId, "push_fcm_token" : pushToken, "device_type" : "I"]
        
        AF.request(url, method: .post, parameters: params, encoding: URLEncoding.httpBody).responseString() { response in
                   switch response.result {
                   case .success:
                    print("push update result :: ",response.result)
                   case .failure(let error):
                       print(error)
                       return
                   }
               }
    }
                   
    private func test(){
        let urlStr = "http://localhost:8080/mobile2021/member/CallbackJoinSns.do?apple_login_key=11111&user_name=ee&user_email=ee"
        //let urlStr = "http://localhost:8080/mobile2021/member/joinSns.do"
        if let encoded = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encoded) {
           print(url)
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    //WKWebView URL Loading 요청 시(탐색 시) 호출되는 딜리게이트 함수
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let strUrl = navigationAction.request.url!.absoluteString
        
        print("now url : ", strUrl)
        decisionHandler(.allow)
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //indicator.isHidden = false
        //indicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //웹뷰를 이용해 로드된 웹페이지의 Javascript 함수 호출
        //webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';", completionHandler: nil) //팝업 메뉴 방지
        webView.evaluateJavaScript("document.body.style.webkitUserSelect='none';", completionHandler: nil) //블럭,복사 방지
            
        //indicator.stopAnimating()
        //indicator.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        //indicator 비활성화
        //indicator.stopAnimating()
        //indicator.isHidden = true
        
        
        if let err = error as? URLError{
            print("error code: " + String(describing: err) + "  :: does not fall under known failures")

            switch(err.code) {  //  Exception occurs on this line
                case .cancelled:
                    print("error code: " + String(describing: err) + "  :: cancelled")
                    if (err.code.rawValue == NSURLErrorCancelled) {
                            return;
                        }
                    return

                case .cannotFindHost:
                    print("error code: " + String(describing: err) + "  :: cannotFindHost")
                    
                case .notConnectedToInternet:
                    print("error code: " + String(describing: err) + "  :: notConnectedToInternet")
                    
                    //네트워크 에러 메세지
                    openAlert("네트워크 상태가 원활하지 않습니다.")
                    
                case .resourceUnavailable:
                    print("error code: " + String(describing: err) + "  :: resourceUnavailable")

                case .timedOut:
                    print("error code: " + String(describing: err) + "  :: timedOut")

                default:
                  print("error code: " + String(describing: err) + "  :: does not fall under known failures")
                }
        }
      
    }
   
    //javascript에서 window.open()이 발생했을 때 실행
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        let strUrl = navigationAction.request.url!.absoluteString
        let url = navigationAction.request.url!
        
        print("now url : ", strUrl)
        
        if !strUrl.contains("job.alio.go.kr"){ //외부 링크 Safari에서 열기
            if navigationAction.targetFrame == nil{
                UIApplication.shared.open(url, options: [:]) //외부에서 열기
    //                let safariViewController = SFSafariViewController(url: url) //웹뷰에서 열기
    //                present(safariViewController, animated: true, completion: nil)
    //                safariViewController.dismissButtonStyle = SFSafariViewController.DismissButtonStyle.close //닫기버튼(default:완료)
            }
            return nil

        //소셜로그인 구분
        }else if strUrl.contains("socialGbn=1"){ //네이버 :: 0, 카카오 :: 1, 애플 :: 2
                 //decisionHandler(.cancel)

//                 guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopupController") as? PopupController else { return nil}
//                 vc.setUrl(strUrl: strUrl)
////                 vc.modalPresentationStyle = .pageSheet
//                 vc.modalPresentationStyle = .fullScreen
//                 self.present(vc, animated: true, completion: nil)
//                 return nil

            popupView = WKWebView(frame: view.bounds, configuration: configuration)
            popupView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            popupView?.navigationDelegate = self
            popupView?.uiDelegate = self
            
            popupView.evaluateJavaScript("navigator.userAgent"){(result, error) in
                let originUserAgent = result as! String
                let agent = originUserAgent + " JOBALIO_APP_IOS"
                self.popupView.customUserAgent = agent
            }
            
            
            let imageWidth: CGFloat = 25.5
            let imageHeight: CGFloat = 25.5
            let reversePosX: CGFloat = (view.bounds.width - 35)
            print(view.bounds.width)
            print(reversePosX)
            let reversePosY: CGFloat = (view.bounds.height)/17
            print(view.bounds.height)
            print(reversePosY)
            
            imageView = UIImageView(frame: CGRect(x: reversePosX, y: reversePosY, width: imageWidth, height: imageHeight))
            
            let settingTap = UITapGestureRecognizer(target: self, action: #selector(self.closeBtn))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(settingTap)

            imageView.image = closeImage
            
            view.addSubview(popupView!)
            view.addSubview(imageView)
            return popupView!
            
        }else if strUrl.contains("socialGbn=0"){ //네이버 :: 0, 카카오 :: 1, 애플 :: 2
            
            popupView = WKWebView(frame: view.bounds, configuration: configuration)
            popupView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            popupView?.navigationDelegate = self
            popupView?.uiDelegate = self
            
            popupView.evaluateJavaScript("navigator.userAgent"){(result, error) in
                let originUserAgent = result as! String
                let agent = originUserAgent + " JOBALIO_APP_IOS"
                self.popupView.customUserAgent = agent
            }
            
            view.addSubview(popupView!)
            
            return popupView!
        }
            
        return nil
    }
    
    //javascript window.close()호출 시 실행
    func webViewDidClose(_ webView: WKWebView) {
        //UIApplication.shared.open(url!, options: [:])
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5){
            self.imageView?.removeFromSuperview()
            self.imageView = nil
            self.popupView?.removeFromSuperview()
            self.popupView = nil
        }
    }
    
    //javascript에서 alert 열릴때 실행f
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alertController = UIAlertController(title: "JOBALIO", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "확인", style: .cancel) { _ in
                completionHandler()
            }
            alertController.addAction(cancelAction)
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
    }
    
    //javascript에서 confirm 열릴때 실행
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
           let alertController = UIAlertController(title: "JOBALIO", message: message, preferredStyle: .alert)
           let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
               completionHandler(false)
           }
           let okAction = UIAlertAction(title: "확인", style: .default) { _ in
               completionHandler(true)
           }
           alertController.addAction(cancelAction)
           alertController.addAction(okAction)
           DispatchQueue.main.async {
               self.present(alertController, animated: true, completion: nil)
           }
       }
    
    func openPage(_ message:String){
        print(message)
        if let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encoded) {
           print(url)
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
   
    @available(iOS 13.0, *)
    @objc func appleLogInButtonTapped(){ //로그인 버튼이 눌렸을 때 실행
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
       
    }
    
//    func getLogin(_ apple_login_key:String){
//        let url = "https://job.alio.go.kr/api/getAppleLogin.do"
//        let params = ["apple_login_key" : apple_login_key]
//
//        AF.request(url, method: .post, parameters: params, encoding: URLEncoding.httpBody).responseString() { response in
//                   switch response.result {
//                   case .success:
//                    let resultValue = response.value!
//                    if resultValue == "SUCC"{ //00 :: 회원, 01 :: 비회원, 02 :: 실패
//                        if #available(iOS 11, *) {
//                            let dataStore = WKWebsiteDataStore.default()
//                            dataStore.httpCookieStore.getAllCookies({ (cookies) in
//                                print(cookies)
//
//                                if self.plainId != ""{
//                                    self.updatePushToken(self.plainId) //푸시토큰 업데이트
//                                }
//                            })
//
//                        }
//
////                        self.webView.reload()
////                        self.openAlert("로그인에 성공했습니다.")
////                        self.openPage("https://job.alio.go.kr/mobile2021/home.do")
//                        //let url = URL(string: "") {
//                         //  print(url)
//                         //   let request = URLRequest(url: url)
//
//
//                    }else{
//                        self.openAlert("서버와의 통신이 원활하지 않습니다. 잡시 후 다시 시도해 주세요.")
//                    }
//                   case .failure(let error):
//                       print(error)
//                       self.openAlert("서버와의 통신이 원활하지 않습니다. 잡시 후 다시 시도해 주세요.")
//                       return
//                   }
//               }
//    }
    
    func openAlert(_ massage:String){
        let alert = UIAlertController(title: "", message: massage, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                    
                }
        alert.addAction(okAction)
        self.present(alert, animated: false, completion: nil)
    }
    
    @objc func closeBtn(){
        self.imageView?.removeFromSuperview()
        self.imageView = nil
        self.popupView?.removeFromSuperview()
        self.popupView = nil
        //dismiss(animated: true, completion: nil)
    }

}

/////////////////////extension///////////////////////////

extension ConciergeViewController: SwiftyGifDelegate {
    func gifDidStop(sender: UIImageView) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5){
            self.logoAnimationView.isHidden = true
            
            //푸시 토큰 저장, 앱 실행시 한번만 실행
                if #available(iOS 11, *) {
                    let dataStore = WKWebsiteDataStore.default()
                    dataStore.httpCookieStore.getAllCookies({ (cookies) in
                        print(cookies)
                        for cookie in cookies{
                            if cookie.name == "plain"{
                                self.plainId = cookie.value
                                print("plainId : " , self.plainId)
                            }else if cookie.name == "ciper"{
                                self.cipherId = cookie.value
                                print("cipherId : " , self.cipherId)
                            }
                        }
                        
                        if self.plainId != ""{
                            self.updatePushToken(self.plainId) //푸시토큰 업데이트
                        }
                    })
                    
                } else {
                    guard let cookies = HTTPCookieStorage.shared.cookies else {
                        return
                    }
                    for cookie in cookies{
                        if cookie.name == "plain"{
                            self.plainId = cookie.value
                            print("plainId : " , self.plainId)
                        }else if cookie.name == "ciper"{
                            self.cipherId = cookie.value
                            print("cipherId : " , self.cipherId)
                        }
                        
                        if self.plainId != "" {
                            self.updatePushToken(self.plainId) //푸시토큰 업데이트
                        }
                    }
                }
            
        }
    }
}

@available(iOS 13.0, *) //Apple login
extension ConciergeViewController: ASAuthorizationControllerDelegate{

     //로그인 성공
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            // Apple ID
            case let appleIDCredential as ASAuthorizationAppleIDCredential:

                // 계정 정보 가져오기
                let apple_login_key = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email

//                print("User ID : \(apple_login_key)")
//                print("User Email : \(email ?? "")")
//                print("User Name : \((fullName?.familyName ?? "") + (fullName?.givenName ?? ""))")

                let url = "https://job.alio.go.kr/api/getAppleUserInfo.do"
                let user_name = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
                let user_email = email ?? ""
                //let url = "https://localhost:8080/mobile2021/member/callbackApple.do"
                let params = ["apple_login_key":apple_login_key]
                
                    AF.request(url, method: .post, parameters: params, encoding: URLEncoding.httpBody).responseString() { response in
                        switch response.result {
                            case .success:
                                print("push update result :: ",response.result)
                                let resultValue = response.value!
                                
                                if resultValue == "00"{ //00 :: 회원, 01 :: 비회원, 02 :: 실패
                                    //self.getLogin(apple_login_key) //애플로 로그인 rest api 호출
                                    self.openPage("https://job.alio.go.kr/mobile2021/member/callbackApple.do?apple_login_key=\(apple_login_key)&rtnCode=\(resultValue)")
                                    
                                }else if resultValue == "01"{
                                    self.openPage("https://job.alio.go.kr/mobile2021/member/callbackApple.do?apple_login_key=\(apple_login_key)&user_name=\(user_name)&user_email=\(user_email)&rtnCode=\(resultValue)")
                                    
                                }else{
                                    self.openAlert("서버와의 통신이 원활하지 않습니다. 잠시 후 다시 시도해 주세요.")
                                }
                            case .failure(let error):
                                print(error)
                                self.openAlert("로그인에 실패했습니다. 잠시 후 다시 시도해 주세요.")
                            }
                    }
            default:
            break
        }
    }

    //로그인 실패
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.openAlert("로그인에 실패했습니다. 잠시 후 다시 시도해 주세요.")
        //print(error)
    }
}

@available(iOS 13.0, *)
extension ConciergeViewController: ASAuthorizationControllerPresentationContextProviding {
    //로그인 버튼 눌렀을 때 Apple로그인을 모달 시트로 표현
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor{
        return self.view.window!
    }
}

extension ConciergeViewController: WKScriptMessageHandler { //javascript -> wkwebview 데이터 전달
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "getLogin" {
            if #available(iOS 13.0, *) {
                appleLogInButtonTapped()
            } else {
                self.openAlert("애플로그인은 iOS 13.0 버전 이상만 지원하고 있습니다.")
            }
        }else if message.name == "getVersion"{
            self.setAppVersion()
        }
    }
}

