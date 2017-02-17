//
//  SessionLogin.swift
//  sewolnewson
//
//  Created by Daeho on 2017. 1. 24..
//  Copyright © 2017년 Daeho. All rights reserved.
//

import UIKit
//처음에 로그인을 시도하고 사용자가 없을 경우 기기를 등록함

//Login Parameters

//company_id=1
//phone=?      (폰번호 못가져오면 device_id 넣으면 됨)
//device_id=?   (디바이스 고유값)

class SessionLogin {
    
    
    func doLogin(deviceID : String ,completionHandler : @escaping ((_ isSussess : Bool) -> Void)){
        
        //let json : [String : Any] = ["company_id" : "1" , "phone" : deviceID, "device_id" : deviceID]
        
        let url = URL(string: "http://1.234.70.19:8080/SEWOL/mobile/user/loginByPhone.do")
//        var request = URLRequest(url: url!)
        
        let jar = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie": "key=value"] // Or ["Set-Cookie": "key=value, key2=value2"] for multiple cookies
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url!)
        jar.setCookies(cookies, for: url, mainDocumentURL: url)

        var request  = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        let postString = "company_id=1&phone="+deviceID+"&device_id="+deviceID
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return completionHandler(false)
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                //연결은됬는데 다른쪽에서 에러가 났을 경우
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                return completionHandler(false)
            }else {
                let responseData = String(data: data!, encoding: .utf8)?.data(using: .utf8)
                
                do {
                    if let data = responseData,
                        let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String: AnyObject],
                        let list = json["list"] as? NSArray {
                        
                        DataTag.USERID = ((list[0] as! NSDictionary)["id"] as? Int)!
                    } else {
                        print("No Data :/")
                    }
                } catch {
                    // 실패한 경우, 오류 메시지를 출력합니다.
                    print("Error, Could not parse the JSON request")
                    
                }
            }
            
            
            if let httpResponse = response as? HTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: (response?.url)!)
                HTTPCookieStorage.shared.setCookies(cookies, for: response?.url, mainDocumentURL: nil)
                
                for cookie in cookies {
                    var cookiProperties = [HTTPCookiePropertyKey:Any]()
                    cookiProperties[HTTPCookiePropertyKey.name] = cookie.name
                    cookiProperties[HTTPCookiePropertyKey.path] = cookie.path
                    cookiProperties[HTTPCookiePropertyKey.value] = cookie.value
                    cookiProperties[HTTPCookiePropertyKey.domain] = cookie.domain
                    cookiProperties[HTTPCookiePropertyKey.version] = NSNumber(integerLiteral: cookie.version)
                    cookiProperties[HTTPCookiePropertyKey.expires] = NSDate().addingTimeInterval(31536000)
                    
                    let newCookie = HTTPCookie(properties: cookiProperties)
                    HTTPCookieStorage.shared.setCookie(newCookie!)
                    
                    print("cookie name: \(cookie.name) cookie value: \(cookie.value)")
                    
                    //DataTag.COOKIE = cookie.value
                }
                //print("response = \(response)")
                return completionHandler(true)
            }
            
           //let responseString = String(data: data, encoding: .utf8)
            return completionHandler(false)
        }
        task.resume()
    }

    func deviceRegister(deviceID : String, completionHandler : @escaping ((_ isSussess : Bool) -> Void)){
        
        let url = URL(string: "http://1.234.70.19:8080/SEWOL/mobile/device/save.do")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        
        var postString : String = ""
        
        postString.append("device_type=apn")
        postString.append("&reg_id="+DataTag.DEVICE_TOKEN)
        postString.append("&assist_reg_id="+DataTag.DEVICE_TOKEN)
        postString.append("&device_id="+deviceID)
        postString.append("&mac_address=iphoneMAC")
        postString.append("&model="+UIDevice.current.model)
        postString.append("&os_nm="+UIDevice.current.systemName)
        postString.append("&os_version="+UIDevice.current.systemVersion)
        postString.append("&version_name=1.0"+String(DataTag.VERSION_NAME))
        postString.append("&version_code=1"+String(DataTag.VERSION_CODE))
        
        //print(postString)
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return completionHandler(false)
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                //연결은됬는데 다른쪽에서 에러가 났을 경우
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                return completionHandler(false)
            }
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            return completionHandler(true)
        }
        
        task.resume()
    }
}
