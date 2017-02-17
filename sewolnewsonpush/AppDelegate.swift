//
//  AppDelegate.swift
//  sewolnewson
//
//  Created by Daeho on 2017. 1. 14..
//  Copyright © 2017년 Daeho. All rights reserved.
//
import UserNotifications
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        let hub : SBNotificationHub = SBNotificationHub(connectionString: HUBLISTENACCESS, notificationHubPath: HUBNAME)
        
        hub.registerNative(withDeviceToken: deviceToken, tags: nil, completion: {(error) in
            if error != nil {
                print("is error")
                
            }else {
                print("done")
                //Device Regi Just Once
                let hasLaunchedKey = "HasLaunched"
                let defaults = UserDefaults.standard
                let hasLaunched = defaults.bool(forKey: hasLaunchedKey)
                
                if !hasLaunched {
                    DataTag.DEVICE_TOKEN = deviceTokenString
                    SessionLogin().deviceRegister(deviceID: UIDevice.current.identifierForVendor!.uuidString.replacingOccurrences(of: "-", with: ""), completionHandler: {(isSuccess) -> Void in
                        if isSuccess {
                            print("done Device Regi")
                            defaults.set(true, forKey: hasLaunchedKey)
                        }else {
                            print("Fail Device Regi")
                        }
                    })
                    
                }

                
            }
        })
        //Azure..
        
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
        
        // Persist it in your backend in case it's new
    }
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        
//        let path = getFileName(fileName: "/notisetting.plist")
//        let fileManager = FileManager.default
//        if(!fileManager.fileExists(atPath: path)){
//            let orgPath = Bundle.main.path(forResource: "notisetting", ofType: "plist")
//            do {
//                try fileManager.copyItem(atPath: orgPath!, toPath: path)
//            } catch _ {
//
//            }
//        }
//        let settingDataAry : NSMutableArray = NSMutableArray(contentsOfFile: path)!
//
//        if (settingDataAry.count) >= 1 {
//
//            let Dic = settingDataAry.object(at: 0) as! NSMutableDictionary
//            switch generateBinary(sound: Dic.value(forKey: "soundNotiSwitch") as! Bool, badge: Dic.value(forKey: "vibrationNotiSwitch") as! Bool, distrub: Dic.value(forKey: "disturbNotiSwitch") as! Bool) {
//            case 0:
//                //SOUND : false, BADGE : false, DISTRUB : false
//                break
//            case 1:
//                //SOUND : false, BADGE : false, DISTRUB : ture
//                break
//            case 2:
//                //SOUND : false, BADGE : ture, DISTRUB : false
//                print("SOUND : false, BADGE : ture, DISTRUB : false")
//                if #available(iOS 10, *) {
//                    UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert]){ (granted, error) in }
//                    application.registerForRemoteNotifications()
//                }
//                    // iOS 9 support
//                else if #available(iOS 9, *) {
//                    UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .alert], categories: nil))
//                    UIApplication.shared.registerForRemoteNotifications()
//                }
//                    // iOS 8 support
//                else if #available(iOS 8, *) {
//                    UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .alert], categories: nil))
//                    UIApplication.shared.registerForRemoteNotifications()
//                }
//                    // iOS 7 support
//                else {
//                    application.registerForRemoteNotifications(matching: [.badge, .alert])
//                }
//                break
//            case 3:
//                //SOUND : false, BADGE : ture, DISTRUB : ture
//                break
//            case 4:
//                //SOUND : ture, BADGE : false, DISTRUB : false
//                break
//            case 5:
//                //SOUND : ture, BADGE : false, DISTRUB : ture
//                break
//            case 6:
//                //SOUND : ture, BADGE : ture, DISTRUB : false
//                break
//            case 7:
//                //SOUND : ture, BADGE : ture, DISTRUB : ture
//                break
//            default:
//                break
//            }
//        }
//        print("hi")
//    }
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        print("Push notification received: \(data)")
        UIApplication.shared.applicationIconBadgeNumber = 0
        
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initPlist()
        // Override point for customization after application launch.
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }

        
        return true
    }
    func initPlist(){
        let fileManager = FileManager()
        //var error = NSError()
        var path = NSString()
        path = getPlistPath() as NSString
        
        let success = fileManager.fileExists(atPath: path as String)
        
        if(!success){
            let defalutPath = Bundle.main.resourcePath?.appending("/notisetting.plist")
            
            do {
                try fileManager.copyItem(atPath: defalutPath!, toPath: path as String)
            } catch _ {
            }
        }
        
    }
    
    func getPlistPath() -> String {
        var docsDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docPath = docsDir[0]
        let fullName = docPath.appending("/notisetting.plist")
        return fullName
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    private func getFileName(fileName:String) -> String {
        let docsDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docPath = docsDir[0]
        let fullName = docPath.appending(fileName)
        return fullName
    }
    private func generateBinary(sound : Bool, badge : Bool, distrub : Bool) -> Int{
        var returnData = 0;
        if sound { returnData = returnData + 4 }
        if badge { returnData = returnData + 2 }
        if distrub { returnData = returnData + 1 }
        print(returnData)
        return returnData
    }
    
}

