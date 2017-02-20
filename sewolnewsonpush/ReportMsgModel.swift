//
//  ReportMsgModel.swift
//  sewolnewsonpush
//
//  Created by Daeho on 2017. 2. 20..
//  Copyright © 2017년 Daeho. All rights reserved.
//

import Foundation
import UIKit

class ReportMsgModel {
    var chattingRoomId = "NULL"
    func uploadImageToServer(mImage : UIImage, completionHandler : @escaping ((_ jsonData : [String : AnyObject]?) -> Void)){
        let myUrl = URL(string: DataTag.URL_IMAGE)
        let jar = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie": "key=value"] // Or ["Set-Cookie": "key=value, key2=value2"] for multiple cookies
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: myUrl!)
        jar.setCookies(cookies, for: myUrl, mainDocumentURL: myUrl)
        
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "POST";
        
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //이미지 데이터
        //let imageData = UIImageJPEGRepresentation(self.thumbNailImage.image!,1)
        let imageData = resizeImage(image: mImage)
        
        if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(imageDataKey: imageData!, boundary: boundary) as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return completionHandler(nil)
            }
            
            // You can print out response object
            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            
            let responseData = String(data: data!, encoding: .utf8)?.data(using: .utf8)
            
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
    }
    func createBodyWithParameters(imageDataKey: NSData, boundary: String) -> NSData {
        var body = Data();
        var parameters : [String : String]?
        
        if self.chattingRoomId == "NULL" {
            parameters = ["msg":"사진","msg_type":"2","user_id": String.init(format: "%d", DataTag.USERID),"name":"image1"]
        }else {
            parameters = ["msg":"사진","msg_type":"2","user_id": String.init(format: "%d", DataTag.USERID),"name":"image1","chatting_room_id":self.chattingRoomId]
        }
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append(string:"--\(boundary)\r\n")
                body.append(string:"Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append(string:"\(value)\r\n")
            }
        }
        let diceRoll = String(arc4random_uniform(100000) + 1)
        let filename = diceRoll+"image.png"
        print("image file Name : ",filename)
        let mimetype = "image/png"
        
        body.append(string: "--\(boundary)\r\n")
        body.append(string:"Content-Disposition: form-data; name=\"image1\";filename=\"\(filename)\"\r\n")
        body.append(string:"Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.append(string:"\r\n")
        body.append(string:"--\(boundary)--\r\n")
        
        //print(body)
        return body as NSData
    }
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    func resizeImage(image : UIImage) -> NSData? {
        
        var actualHeight : CGFloat = image.size.height
        var actualWidth : CGFloat = image.size.width
        let maxHeight : CGFloat = 400.0
        let maxWidth : CGFloat = 300.0
        var imgRatio : CGFloat = actualWidth/actualHeight
        let maxRatio : CGFloat = maxWidth/maxHeight
        //let compressionQuality : CGFloat = 0.5
        
        if (actualHeight > maxHeight || actualWidth > maxWidth)
        {
            if(imgRatio < maxRatio)
            {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio)
            {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else
            {
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }
        
        let rect = CGRect(x: 0, y: 0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImagePNGRepresentation(img!)
        UIGraphicsEndImageContext()
        return imageData as NSData?
        
    }
    
    
    func uploadTextMsgToServer(msg : String, completionHandler : @escaping ((_ jsonData : [String : AnyObject]?) -> Void)){
        
        let url = URL(string: DataTag.URL_IMAGE)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let jar = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie": "key=value"] // Or ["Set-Cookie": "key=value, key2=value2"] for multiple cookies
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url!)
        jar.setCookies(cookies, for: url, mainDocumentURL: url!)
        
        var body = Data();
        let parameters : [String : String]? = ["msg":msg,"msg_type":"1","user_id": String.init(format: "%d", DataTag.USERID),"name":"image1","chatting_room_id":self.chattingRoomId]
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if parameters != nil {
            for (key, value) in parameters! {
                body.append(string:"--\(boundary)\r\n")
                body.append(string:"Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append(string:"\(value)\r\n")
            }
        }
        body.append(string:"\r\n")
        body.append(string: "--\(boundary)\r\n")
        request.httpBody = body
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return completionHandler(nil)
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           //
                //연결은됬는데 다른쪽에서 에러가 났을 경우
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print("****** response data = \(responseString!)")
                
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
    

}
