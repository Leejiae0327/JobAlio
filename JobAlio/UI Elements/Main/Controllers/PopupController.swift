//
//  ViewController.swift
//  JobAlio
//
//  Created by jiea on 2021/06/23.
//

import UIKit
import WebKit
import Alamofire

class PopupController: UIViewController, WKNavigationDelegate, WKUIDelegate{


    @IBOutlet weak var closeImg: UIImageView!
    @IBOutlet weak var popupWebView: WKWebView!
    
    var url: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.popupWebView.uiDelegate = self
        popupWebView?.navigationDelegate = self
        //self.popupWebView?.allowsLinkPreview = false
        
        //userAgent 변경
        popupWebView.evaluateJavaScript("navigator.userAgent"){(result, error) in
            let originUserAgent = result as! String
            let agent = originUserAgent + " JOBALIO_APP_IOS"
            self.popupWebView.customUserAgent = agent
        }
        
        let settingTap = UITapGestureRecognizer(target: self, action: #selector(closeBtn))
        closeImg.isUserInteractionEnabled = true
        closeImg.addGestureRecognizer(settingTap)
        
        let contentController = popupWebView.configuration.userContentController
        contentController.add(self, name: "webViewClose")
        contentController.add(self, name: "getVersion")
        
        openPage()
    }
    
    //WKWebView URL Loading 요청 시(탐색 시) 호출되는 딜리게이트 함수
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let strUrl = navigationAction.request.url!.absoluteString
        
        print("now url : ", strUrl)
        decisionHandler(.allow)
        
    }
    
    //javascript window.close()호출 시 실행
    func webViewDidClose(_ webView: WKWebView) {
        //UIApplication.shared.open(url!, options: [:])
        dismiss(animated: true, completion: nil)
       
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        let strUrl = navigationAction.request.url!.absoluteString
        let url = navigationAction.request.url!
        
        print("now url : ", strUrl)
        
       
        //if !strUrl.contains("job.alio.go.kr"){ //외부 링크 Safari에서 열기
        if !strUrl.contains("localhost"){ //외부 링크 Safari에서 열기
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

             guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopupController") as? PopupController else { return nil}
             vc.setUrl(strUrl: strUrl)
//                 vc.modalPresentationStyle = .pageSheet
             vc.modalPresentationStyle = .fullScreen
             self.present(vc, animated: true, completion: nil)
             return nil
        }

        return nil
    }
    
    //javascript에서 alert 열릴때 실행
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
    
    
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //indicator.isHidden = false
        //indicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';", completionHandler: nil)
        //webView.evaluateJavaScript("document.body.style.webkitUserSelect='none';", completionHandler: nil)
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
                    let alert = UIAlertController(title: "", message: "네트워크 상태가 원활하지 않습니다.", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                                
                            }
                    alert.addAction(okAction)
                    present(alert, animated: false, completion: nil)
                    
                case .resourceUnavailable:
                    print("error code: " + String(describing: err) + "  :: resourceUnavailable")

                case .timedOut:
                    print("error code: " + String(describing: err) + "  :: timedOut")

                default:
                  print("error code: " + String(describing: err) + "  :: does not fall under known failures")
                }
        }
      
    }
    
    private func openPage(){
        let requestUrl = URLRequest(url : self.url!)
        popupWebView.load(requestUrl)
    }
    
    func setUrl(strUrl: String){
        self.url = URL(string: strUrl)
    }
    
    @objc func closeBtn(){
        dismiss(animated: true, completion: nil)
    }
    
    private func webViewClose(_ messageBody: String) {
        
        if(messageBody == "main"){
            //let url = URL(string: "https://job.alio.go.kr/mobile2021/home.do")
            let url = URL(string: "http://localhost:8080/mobile2021/home.do")
            //let url = URL(string: urlStr)
            let request = URLRequest(url: url!)
            popupWebView.load(request)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5){
                self.dismiss(animated: true, completion: nil)
            }
            
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
}

extension PopupController: WKScriptMessageHandler { //javascript -> wkwebview 데이터 전달
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "webViewClose"{
            webViewClose(message.body as! String)
        }else if message.name == "getVersion"{
            
        }
    }
}
  
