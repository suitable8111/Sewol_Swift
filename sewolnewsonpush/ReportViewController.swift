//
//  ReportViewController.swift
//  sewolnewson
//
//  Created by Daeho on 2017. 1. 16..
//  Copyright © 2017년 Daeho. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var mScrollView: UIScrollView!
    @IBOutlet weak var mTextView: UITextView!
    
    @IBOutlet weak var rimg0: UIImageView!
    @IBOutlet weak var rimg1: UIImageView!
    @IBOutlet weak var rimg2: UIImageView!
    @IBOutlet weak var rimg3: UIImageView!
    @IBOutlet weak var rimg4: UIImageView!
    @IBOutlet weak var rimg5: UIImageView!
    @IBOutlet weak var rimg6: UIImageView!
    @IBOutlet weak var rimg7: UIImageView!
    @IBOutlet weak var rimg8: UIImageView!
    @IBOutlet weak var rimg9: UIImageView!
    
    
    
    let imageStack = NSMutableArray()
    var onEditing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.successAlert()
        self.mTextView.text = "제보된 내용은 '공개'를 원칙으로 합니다.\n 공개를 원치 않으시는 경우, 글에 적어주세요 \n 예) 제보한 사진은 비공개를 원합니다."
        self.mTextView.textColor = UIColor.lightGray
        self.mTextView.delegate = self
        self.mScrollView.contentSize = CGSize(width: self.view.frame.width*3.5, height: self.mScrollView.frame.height)
    }
    //MARK : TEXTVIEW DELEGAGTE
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.transform = CGAffineTransform(translationX: 0.0 , y: -self.view.frame.height * 0.3);
        }, completion: nil)
        
        onEditing = true
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "제보된 내용은 '공개'를 원칙으로 합니다.\n 공개를 원치 않으시는 경우, 글에 적어주세요 \n 예) 제보한 사진은 비공개를 원합니다."
            textView.textColor = UIColor.lightGray
        }
    }
    
    //MARK : IBACTION
    @IBAction func actSwipe(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actAddPhoto(_ sender: Any) {
        let alert = UIAlertController(title: "사진가져오기", message: "선택하시오.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        let action1 = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler: nil)
        let action2 = UIAlertAction(title: "사진찍기", style: UIAlertActionStyle.default, handler: action2Handler)
        let action3 = UIAlertAction(title: "앨범에서 가져오기", style: UIAlertActionStyle.default, handler: action3Handler)
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        present(alert, animated: true, completion: nil)

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if onEditing {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.transform = CGAffineTransform(translationX: 0.0 , y: 0.0);
            })
            onEditing = false
            self.view.endEditing(true)
        }
    }
    @IBAction func actSendReport(_ sender: Any) {
        if onEditing {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.transform = CGAffineTransform(translationX: 0.0 , y: 0.0);
            })
            onEditing = false
            self.view.endEditing(true)
            
        }
        self.successAlert()
//        uploadToServer()
    }
    
    //MARK : IMAGE HANDLER
    
    func action2Handler(alert:UIAlertAction?){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func action3Handler(alert:UIAlertAction?){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.imageStack.add(image)
        setReportImg(img: image)
        picker.dismiss(animated: true, completion: nil)
    }
    func setReportImg(img : UIImage)  {
        switch self.imageStack.count {
        case 1:
            self.rimg0.image = img
            break
        case 2:
            self.rimg1.image = img
            break
        case 3:
            self.rimg2.image = img
            break
        case 4:
            self.rimg3.image = img
            break
        case 5:
            self.rimg4.image = img
            break
        case 6:
            self.rimg5.image = img
            break
        case 7:
            self.rimg6.image = img
            break
        case 8:
            self.rimg7.image = img
            break
        case 9:
            self.rimg8.image = img
            break
        case 10:
            self.rimg9.image = img
            break
        default:
            print("사진은 10개 이하로 제한합니다.")
            break
        }
    }
    
    
    //SEND IMAGE FUNC
    func uploadToServer() {
        let myUrl = URL(string: "http://1.234.70.19:8080/SEWOL/mobile/chatting/saveConsultMsg.do")
        let jar = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie": "key=value"] // Or ["Set-Cookie": "key=value, key2=value2"] for multiple cookies
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: myUrl!)
        jar.setCookies(cookies, for: myUrl, mainDocumentURL: myUrl)
        
        //var request  = URLRequest(url: url!)
        
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "POST";
        //        let param = [
        //            "firstName"  : "Sergey",
        //            "lastName"    : "Kargopolov",
        //            "userId"    : "9"
        //        ]
        
        
        
        let boundary = generateBoundaryString()
        
        //request.httpBody = postString.data(using: .utf8)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //이미지 데이터
        //let imageData = UIImageJPEGRepresentation(self.thumbNailImage.image!,1)
        let imageData = resizeImage(image: self.imageStack.object(at: 0) as! UIImage)
        
        if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(imageDataKey: imageData!, boundary: boundary) as Data
        
        
        
        //myActivityIndicator.startAnimating();
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            // You can print out response object
            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            
            
        }
        
        task.resume()
    }
    func createBodyWithParameters(imageDataKey: NSData, boundary: String) -> NSData {
        var body = Data();
        //msg=\"사진\"; msg_type=\"2\"; user_id=\"\(userid)\";
        let parameters : [String : String]? = ["msg":"사진","msg_type":"2","user_id": String.init(format: "%d", DataTag.USERID),"name":"file1"]
        if parameters != nil {
            for (key, value) in parameters! {
                body.append(string:"--\(boundary)\r\n")
                body.append(string:"Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append(string:"\(value)\r\n")
            }
        }
        //
        let filename = (UIDevice.current.identifierForVendor!.uuidString.replacingOccurrences(of: "-", with: ""))+".png"
        //
        let mimetype = "image/png"
        //
        //var postString : String = ""
        
        //body.append(string:"&user_id="+)
        
        body.append(string: "--\(boundary)\r\n")
        body.append(string:"Content-Disposition: form-data; name=\"image\";filename=\"\(filename)\"\r\n")
        body.append(string:"Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.append(string:"\r\n")
        
        body.append(string:"--\(boundary)--\r\n")
        //
        
        print(body)
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
    
    func successAlert() {
        let alertController = UIAlertController (title: "준비중입니다.", message: "제보하기 서비스가 현재 운영중이지 않습니다. 불편을 드려서 죄송합니다.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
extension Data {
    mutating func append(string: String) {
        let data = string.data(
            using: String.Encoding.utf8,
            allowLossyConversion: true)
        append(data!)
    }
}

