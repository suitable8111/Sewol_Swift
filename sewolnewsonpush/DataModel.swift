//
//  DataModel.swift
//  sewolnewson
//
//  Created by Daeho on 2017. 1. 24..
//  Copyright © 2017년 Daeho. All rights reserved.

import Foundation

///// 예제를 위한 임의의 JSON 데이터
//let text = "{ \"id\": 123, \"name\": \"Jordan G\", \"age\": 17 }"
//let data = text.data(using: .utf8)
/////

class DataModel {
    func parseUrlJson(urlString : String, completionHandler : @escaping ((_ jsonData : [String : AnyObject]?) -> Void)){
        let url = URL(string: DataTag.URL_LINK)
        let request = URLRequest(url: url!)
        var postString : String = ""
        postString.append("url="+urlString)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return completionHandler(nil)
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           //
                //연결은됬는데 다른쪽에서 에러가 났을 경우
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                return completionHandler(nil)
            }
            
            let responseData = String(data: data, encoding: .utf8)?.data(using: .utf8)
            
            do {
                if let data = responseData,
                    let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String: AnyObject] {
                    return completionHandler(json)
                } else {
                    print("No Data :/")
                }
            } catch {
                // 실패한 경우, 오류 메시지를 출력합니다.
                print("Error, Could not parse the JSON request")
                return completionHandler(nil)
            }
            
        }
        task.resume()
        return completionHandler(nil)
        
    }
    func parseJSONResults(completionHandler : @escaping ((_ jsonData : [String : AnyObject]?) -> Void)){
        //데이터를 파싱한다
        let url = URL(string: DataTag.URL_MSG)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        var postString : String = ""
        
//        postString.append("del_fl=N")
//        postString.append("&room_type=2")
//        postString.append("&chatting_room_id=1")
        //postString.append("&order_by=A.id DESC")
//        postString.append("&mac_address=test")
//        postString.append("&limit=10")
//        postString.append("&offset=0")
//        postString.append("&first_id=1")
//        postString.append("&last_id=1")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return completionHandler(nil)
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           //
                //연결은됬는데 다른쪽에서 에러가 났을 경우
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                return completionHandler(nil)
            }
            
            let responseData = String(data: data, encoding: .utf8)?.data(using: .utf8)
            
            do {
                if let data = responseData,
                    let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String: AnyObject] {
                    return completionHandler(json)
                } else {
                    print("No Data :/")
                }
            } catch {
                // 실패한 경우, 오류 메시지를 출력합니다.
                print("Error, Could not parse the JSON request")
                return completionHandler(nil)
            }
        
        }
        task.resume()
        return completionHandler(nil)
    }
    func parseJSONTotalCount(completionHandler : @escaping ((_ jsonData : [String : AnyObject]?) -> Void)){
        let url = URL(string: DataTag.URL_NOTICE_COUNT)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return completionHandler(nil)
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           //
                //연결은됬는데 다른쪽에서 에러가 났을 경우
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                return completionHandler(nil)
            }
            
            let responseData = String(data: data, encoding: .utf8)?.data(using: .utf8)
            
            do {
                if let data = responseData,
                    let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String: AnyObject] {
                    return completionHandler(json)
                } else {
                    print("No Data :/")
                }
            } catch {
                // 실패한 경우, 오류 메시지를 출력합니다.
                print("Error, Could not parse the JSON request")
                return completionHandler(nil)
            }
            
        }
        task.resume()
        return completionHandler(nil)
    }
    func parseJSONNotice(completionHandler : @escaping ((_ jsonData : [String : AnyObject]?) -> Void)){
        
        let url = URL(string: DataTag.URL_NOTICE)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        var postString : String = ""
        
        postString.append("del_fl=N")
        postString.append("&room_type=2")
        postString.append("&chatting_room_id=1")
        postString.append("&limit=1")
        postString.append("&offset=0")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return completionHandler(nil)
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           //
                //연결은됬는데 다른쪽에서 에러가 났을 경우
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                return completionHandler(nil)
            }
            
            let responseData = String(data: data, encoding: .utf8)?.data(using: .utf8)
            
            do {
                if let data = responseData,
                    let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String: AnyObject] {
                    return completionHandler(json)
                } else {
                    print("No Data :/")
                }
            } catch {
                // 실패한 경우, 오류 메시지를 출력합니다.
                print("Error, Could not parse the JSON request")
                return completionHandler(nil)
            }
            
        }
        task.resume()
        return completionHandler(nil)
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
}


