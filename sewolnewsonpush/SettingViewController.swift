//
//  SettingViewController.swift
//  sewolnewson
//
//  Created by Daeho on 2017. 1. 17..
//  Copyright © 2017년 Daeho. All rights reserved.
//

import UIKit
import UserNotifications

//Setting 관련 ViewController push noti의 소리, 배지, 알람을 설정할 수 있다.

class SettingViewController: UIViewController {
    
    var settingDataAry:                     NSMutableArray? //ROAD Plist Array
    var seSwitch:                           Bool = true     //Start, End Switch Start : TRUE, END : FALSE
    @IBOutlet weak var settingEtcBtn:       UIButton!       //세팅하기 버튼
    @IBOutlet weak var settingEtcSwitch:    UISwitch!       //기타 세팅 스위치
    @IBOutlet weak var allNotiSwitch:       UISwitch!       //노드 전체 세팅 스위치
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = getFileName(fileName: "/notisetting.plist")
        let fileManager = FileManager.default
        if(!fileManager.fileExists(atPath: path)){
            let orgPath = Bundle.main.path(forResource: "notisetting", ofType: "plist")
            do {
                try fileManager.copyItem(atPath: orgPath!, toPath: path)
            } catch _ {
                
            }
        }
        settingDataAry = NSMutableArray(contentsOfFile: path)
        if (settingDataAry?.count)! >= 1 {
            print("Data 존재")
            //print(self.settingDataAry)
            let Dic = self.settingDataAry?.object(at: 0) as! NSMutableDictionary
            self.allNotiSwitch.setOn(Dic.value(forKey: "allNotiSwitch") as! Bool, animated: false)
            
            self.controllAllSwitch()
        }else {
            print("저장된 부분 없음")
        }
    }
    //MARK : IBAction Picker
    
    
    
    //MARK : IBAction Btns
    //뒤로가기와 저장을 동시에
    @IBAction func actSwipe(_ sender: Any) {
        self.saveSetting()
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    @IBAction func actBackASave(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
//        self.saveSetting()
    }

    //MARK : IBAction Switchs
    //모든 알림을 제어하는 스위치
    @IBAction func goSettingChange(_ sender: Any) {
        goSettingFromApp(sender)
        self.settingEtcSwitch.setOn(true, animated: false)
    }
    @IBAction func goSettingFromApp(_ sender: Any) {
        let alertController = UIAlertController (title: "알림 세팅", message: "알림 세팅을 위해 앱 설정으로 이동합니다.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "이동하기", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                } else  if #available(iOS 8.0, *) {
                    let url = NSURL(string: UIApplicationOpenSettingsURLString)
                    UIApplication.shared.openURL(url as! URL)
                } else  if #available(iOS 9.0, *) {
                    let url = NSURL(string: UIApplicationOpenSettingsURLString)
                    UIApplication.shared.openURL(url as! URL)
                }
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func actAllNoti(_ sender: Any) {
        controllAllSwitch()
        if !allNotiSwitch.isOn {
            setNotiOff()
        }else {
            setNotiOn()
        }
        self.saveSetting()
    }
    //MARK : FUNC..
    //알림제어 해제
    private func setNotiOff() {
        print("노티를 해제합니다.")
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    private func setNotiOn() {
        print("노티를 실행합니다..")
        //Swith On
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            UIApplication.shared.registerForRemoteNotifications()
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
            UIApplication.shared.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
    }
    //Plist 경로 들고오기
    private func getFileName(fileName:String) -> String {
        let docsDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docPath = docsDir[0]
        let fullName = docPath.appending(fileName)
        return fullName
    }
    private func saveSetting(){
        if (self.settingDataAry?.count)! >= 1 {
            //덮어쓰기
            self.settingDataAry?.removeAllObjects()
        }
        let saveDic = NSMutableDictionary()

        
        saveDic.setValue(self.allNotiSwitch.isOn , forKey: "allNotiSwitch" )
        
        self.settingDataAry?.add(saveDic)
        let path = getFileName(fileName: "/notisetting.plist")
        self.settingDataAry?.write(toFile: path, atomically: true)

    }
    private func controllAllSwitch() {
        if !allNotiSwitch.isOn {
            self.settingEtcSwitch.isEnabled = false
            
            self.settingEtcBtn.isEnabled = false
            
        }else {
            self.settingEtcSwitch.isEnabled = true
            
            self.settingEtcBtn.isEnabled = true
        }
    }
}
extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
}
