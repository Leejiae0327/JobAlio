
import UIKit
import UserNotifications
import FirebaseAnalytics
import Firebase  //UIApplicationDelegate에서 firebase 모듈 가져오기
import Alamofire
import AuthenticationServices


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    let gcmMessageIDKey = "gcm.message_id"
    var paramPushToken:String?
    
    func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Use Firebase library to configure APIs
        
        
        FirebaseApp.configure() //앱실행 완료 시 firebase 서비스 시작
        FirebaseConfiguration .shared.setLoggerLevel(.min) //디버거에 표시되는 데이터의 양이 줄어듬
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications() //apple 푸시 알림 서비스에 등록

        //UIApplication.shared.applicationIconBadgeNumber = 1]
        

        
        // [END register_for_notifications]
        
        
        //앱 실행 중 [설정 앱] - [Apple ID] - [암호 및 보안] - [내 Apple ID를 사용하는 앱] 에서 'Apple ID 사용 중단' 했을 경우 앱으로 돌아왔을때
//        NotificationCenter.default.addObserver(forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil, queue: nil) { (Notification) in
//            print("Revoked Notification")
//            // 로그인 페이지로 이동
//        }
        
//        if #available(iOS 13.0, *) {
//            let provider = ASAuthorizationAppleIDProvider()
//            provider.getCredentialState(forUserID: "", completion: <#T##(ASAuthorizationAppleIDProvider.CredentialState, Error?) -> Void#>)
//        } else {
//            // Fallback on earlier versions
//        }
        

        return true
    }
    
    @available(iOS 13.0, *)
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }


    //사용자가 알림을 수신 할 때 호출됨
    func application(_ application: UIApplication,didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)
    }

    // [START receive_message] /앱에서 원격 알림 수신 시 호출됨
    func application(_ application: UIApplication,didReceiveRemoteNotification userInfo: [AnyHashable: Any],fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                     -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }

    //Apple 푸시 알림 서비스(APN)가 등록 프로세스를 성공적으로 완료할 수 없을 때 호출 (APNS 등록 실패)
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    //앱이 Apple 푸시 알림 서비스(APN)에 성공적으로 등록되었을 때 호출 (APNS 등록 성공)
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
         //With swizzling disabled you must set the APNs token here.
         Messaging.messaging().apnsToken = deviceToken
    }
    
    //앱 실행 시 푸시 배지 초기화
    //뱃지 초기화 시키는 방법 IOS 13 이상
    //if #available(iOS 13.0, *) {
//    @available(iOS 13.0, *)
//    func sceneDidBecomeActive(_ scene: UIScene) {
//            // Called when the scene has moved from an inactive state to an active state.
//            // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
//            
//            UIApplication.shared.applicationIconBadgeNumber = 0;
//        }
//    //}else{
//    //뱃지 초기화 시키는 방법 IOS 13 이하
//        func applicationDidBecomeActive(_ application: UIApplication) {
//            UIApplication.shared.applicationIconBadgeNumber = 0;
//        }
    //}

    
    

}

// [START ios_10_message_handling] / firebase console에서 테스트 눌렀을 때 제일 먼서 실행되는 부분
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
  // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,willPresent notification: UNNotification,withCompletionHandler   completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // [START_EXCLUDE]
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }
        // [END_EXCLUDE]
        // Print full message.
        print(userInfo)

        // Change this to your preferred presentation option
        completionHandler([[.alert, .sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // [START_EXCLUDE]
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }
        // [END_EXCLUDE]
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print full message.
        print(userInfo)

        completionHandler()
    }
    
}


// TODO: If necessary send token to application server.
// Note: 앱이 시작될 때 또는 새 토큰이 생성될 때 실행하는 콜백
extension AppDelegate: MessagingDelegate {
  // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
        if fcmToken != nil{
            paramPushToken = (String(describing: fcmToken!))
        }
    }
    
    // [END refresh_token]
}



