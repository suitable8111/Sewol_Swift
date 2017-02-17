//
//  ViewController.swift
//  sewolnewson
//
//  Created by Daeho on 2017. 1. 14..
//  Copyright © 2017년 Daeho. All rights reserved.
//

import UIKit
import StoreKit
//Main ViewController 세월호 소식을 전체적으로 보여주고 다른 ViewController로 이동하게끔 구현되어있다

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextFieldDelegate {

    
    
    // IBOutlets..
    
    @IBOutlet weak var sideView:                UIView!         //알림설정, 웹으로 가기, 제보하기 기능을 보여주는 사이드 뷰
    @IBOutlet weak var noticeView:              UIView!         //상단 공지사항을 알려주는 UIView
    
    @IBOutlet weak var noticeLabel:             UILabel!        //상단 공지사항의 내용이 기입 된 라벨
    @IBOutlet weak var topLb:                   UILabel!        //상단 세월호 표시 라벨
    @IBOutlet weak var totalPeopleLb:           UILabel!        //전체 앱 등록 된 사람수를 보는 라벨
    @IBOutlet weak var sideTotalPeopleLb:       UILabel!        //사이드 뷰에 있는 앱 등록 된 사람수를 보는 라벨
    @IBOutlet weak var progressView:            UILabel!        //서버쪽 데이터가 받아와질때까지 진행하는 UILabel 데이터가 모두 받아와 지면 종료된다.
    
    @IBOutlet weak var hiddenViewBtn:           UIButton!       //사이드 뷰가 켜질때, 데이터를 가져올 때 나타나는 버튼, 모든 처리가 끝나면 사라진다.
    @IBOutlet weak var noticeNeverShowBtn:      UIButton!       //상단 공지사항을 절때 보여주지 않도록하는 버튼
    @IBOutlet weak var noticeHiddenBtn:         UIButton!       //상단 공지사항을 접어두는 버튼
    @IBOutlet weak var searchGoUpBtn:           UIButton!       //검색 자료를 찾은 후 생성되는 버튼, 과거 데이터를 불러온다.
    @IBOutlet weak var searchGoDownBtn:         UIButton!       //검색 자료를 찾은 후 생성되는 버튼, 맨 처음 데이터를 불러온다.
    @IBOutlet weak var tableViewScrollDownBtn:  UIButton!       //테이블 뷰 제일 밑에(최신 화면)으로 내려주는
    @IBOutlet weak var noticeShowBtn:           UIButton!       //상단 공지사항의 전체 내용을 볼수 있도록하는 버튼
    @IBOutlet weak var searchBtn:               UIButton!       //찾기 버튼
    
    @IBOutlet weak var searchTF:                UITextField!    //검색 내용을 기입하는 텍스트필드
    @IBOutlet weak var mTableview:              UITableView!    //메시지 List를 처리하는 UITableview
    
    
    
    // Values..
    var searchPosAry:           NSMutableArray?                 //검색시 데이터를 받아오는 배열
    var datadic:                NSMutableArray?                 //실제 세월호 테이블 뷰에 담겨진 데이터들
    var sectionAry:             NSMutableArray?                 //섹션 (날짜)를 저장하는 배열
    var noticeJson:             [NSDictionary]?                 //상단 공지 관련 데이터
    
    
    var searchText:             String = ""                     //검색 스트링
    var searchCount:            Int = 0                         //검색 카운트 검색된 스트링의 위치값을 찾아주는 역할
    var searchRangeCount:       Int = -1                        //검색 상세 카운트 세션(날짜)별 데이터를 2차원으로 구현하여 필요함
    var isSearchingGoDown:      Bool = false                    //검색을 한후 위아래로 움직여지는 상태
    var onSideView:             Bool = false                    //사이드 뷰가 올라와 졌을때 상태
    var onNoticeView:           Bool = true                     //상단 공지사항이 열려져 있을 상태
    var isReload:               Bool = false                    //데이터가 리로드 될때 상태
    var isSearch:               Bool = false                    //검색 중인 상태
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        self.view.layer.zPosition = 1;
        
        self.mTableview.delegate = self
        self.mTableview.dataSource = self
        self.mTableview.rowHeight = UITableViewAutomaticDimension
        self.mTableview.estimatedRowHeight = 70;
        
        
        
        self.noticeHiddenBtn.layer.borderWidth = 0.5
        self.noticeNeverShowBtn.layer.borderWidth = 0.5
        self.noticeHiddenBtn.layer.borderColor = UIColor.lightGray.cgColor
        self.noticeNeverShowBtn.layer.borderColor = UIColor.lightGray.cgColor
        
        self.searchTF.delegate = self
        self.searchTF.returnKeyType = UIReturnKeyType.done
        
        //self.hiddenViewBtn.isEnabled = false
        //self.hiddenViewBtn.isUserInteractionEnabled = false
        //self.hiddenViewBtn.isHidden = false
        
        
        
        self.hideKeyboardWhenTappedAround()
        let hasLaunchedKey = "isNeverShow"
        let defaults = UserDefaults.standard
        let hasLaunched = defaults.bool(forKey: hasLaunchedKey)
        if hasLaunched {
            self.noticeView.isHidden = true
        }
        //Do ParseData CallBack
        
        
        let session = SessionLogin()
        print("Device UUID to String : ",UIDevice.current.identifierForVendor!.uuidString.replacingOccurrences(of: "-", with: ""))
        session.doLogin(deviceID: UIDevice.current.identifierForVendor!.uuidString.replacingOccurrences(of: "-", with: ""),completionHandler: {(isSuccess) -> Void in
            if isSuccess == true {
                print("Success Login... Get Data")
                let dataModel = DataModel()
                
                dataModel.parseJSONTotalCount{(json) -> Void in
                    if json != nil {
                        if let json = json,
                            let list = json["list"] as? NSArray {
                            DispatchQueue.main.async {
                                self.totalPeopleLb.text = String.init(format: "대화상대 %d명", ((list[0] as! NSDictionary)["count"] as? Int)!)
                                self.sideTotalPeopleLb.text = String.init(format: "대화상대 %d명", ((list[0] as! NSDictionary)["count"] as? Int)!)
                                
                                DataTag.TOTALCOUNT = ((list[0] as! NSDictionary)["count"] as? Int)!
                            }
                        }
                    }
                }
                dataModel.parseJSONNotice{(json) -> Void in
                    if json != nil {
                        print("Access Notice")
                        if let json = json,
                            let list = json["list"] as? NSArray {
                            self.noticeJson = list as? [NSDictionary]
                            DispatchQueue.main.async {
                                self.noticeLabel.text = self.noticeJson?[0]["msg"] as? String
                            }
                        }
                    }else {
                        print("Not Access Notice")
                    }
                }
                
                dataModel.parseJSONResults{(json) -> Void in
                    if json != nil {
                        if let json = json,
                        let list = json["list"] as? NSArray {
                            
                            
                            var ary = NSMutableArray()
                            self.datadic = NSMutableArray()
                            self.sectionAry = NSMutableArray()
                            
                            var preDateText = self.DatetoString(date: Date(timeIntervalSince1970: Double((list[0] as! NSDictionary)["created_time"] as! Int64)))
                            
                            for element in 0..<(list.count-1) {
                                let dateString = self.DatetoString(date: Date(timeIntervalSince1970: Double((list[element] as! NSDictionary)["created_time"] as! Int64)))
                                ary.add(list[element] as! NSDictionary)

                                if preDateText != dateString {
                                    self.datadic?.add(ary)
                                    self.sectionAry?.add(dateString)
                                    ary = NSMutableArray()
                                }
                                preDateText = dateString
                                
                                //print(dateString)
                            }
                            
                            DispatchQueue.main.async {
                                
                                //self.hiddenViewBtn.layer.zPosition = 0
                                //self.mTableview.layer.zPosition = 1
                                self.hiddenViewBtn.alpha = 0.0
                                self.progressView.isHidden = true
                                self.mTableview.reloadData()
                                self.mTableview.tableViewScrollToBottom(animated: false)
                            }
                        }
                    }else {
                        print("데이터 가져오기 실패")
                    }
                }
            }else {
                print("Login Error")
                self.progressView.isHidden = true
            }
        })
    }
    
    // MARK: ScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView {
        case mTableview:
            let offset : CGPoint = mTableview.contentOffset
            let bounds : CGRect = mTableview.bounds
            let size : CGSize = mTableview.contentSize
            let inset : UIEdgeInsets = mTableview.contentInset
            
            let y : CGFloat = offset.y + bounds.size.height - inset.bottom
            let h : CGFloat = size.height
            
            let nextValue : CGFloat = -100
            if (y > h + nextValue) {
                self.tableViewScrollDownBtn.isHidden = true
            }else {
                self.tableViewScrollDownBtn.isHidden = false
            }
            
            if (offset.y < -40){
                self.isReload = true
                print("RELOAD")
            }
            break
        default :
            break
        }
    }
    // MARK: TextField Delgate 
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text!.isEmpty {
            self.searchText = ""
        }else{
            self.isSearch = true
            self.searchPosAry = NSMutableArray()
            self.searchCount = 0;
            self.searchRangeCount = -1
            self.searchText = textField.text!
            self.mTableview.reloadData()
            self.mTableview.tableViewScrollToBottom(animated: false)
            self.searchGoUpBtn.isHidden = false
            self.searchGoDownBtn.isHidden = false
        }
        return true
    }
    
    // MARK: TableView Delgate & DataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //MainNomalCell : 일반적인 채팅 Cell TextView 형식
        //MainShortCell : 글자길이가 15자 이하일 경우 작은 Label로 구성
        //MainImageLinkCell :  msg가 링크로만 구성되어 질경우... 링크와 해당 url 사진을 보여주는 셀..
        //MainImageCell : msg가 "사진"인 경우 사진만 보여주는 cell path를 거쳐 가져옵
        
        let cellString = (((self.datadic?.object(at: indexPath.section) as! NSMutableArray).object(at: indexPath.row) as! NSDictionary)["msg"] as? NSString)!
        
        
        
        if cellString.isEqual(to: "사진") {
            let cell = mTableview.dequeueReusableCell(withIdentifier: "MainImageCell", for: indexPath) as! MainImageCell
            
        
            
            let urlString = String.init(format: "http://1.234.70.19:8080/%@", ((self.datadic?.object(at: indexPath.section) as! NSMutableArray).object(at: indexPath.row) as! NSDictionary)["attachment"] as! String)
            print(urlString.replacingOccurrences(of: "\\", with: "/"))
            
            let dataImgModel = DataModel()
            dataImgModel.getDataFromUrl(url: URL(string: urlString.replacingOccurrences(of: "\\", with: "/"))!) { (data, response, error) in
                
                print("Download Finished")
                if data != nil {
                    DispatchQueue.main.async {
                        cell.imageC.image = UIImage(data: data!)
                    }
                }
            }
            let tagString : String = String.init(format: "%dn%d", indexPath.section,indexPath.row)
            cell.shareBtn.setTitle(tagString, for: UIControlState.normal)
            cell.imageBtn.setTitle(tagString, for: UIControlState.normal)
            
            cell.shareBtn.addTarget(self, action: #selector(ViewController.actShareImg(_:)), for: UIControlEvents.touchUpInside)
            cell.imageBtn.addTarget(self, action: #selector(ViewController.actPushImg(_:)), for: UIControlEvents.touchUpInside)
            
            return cell
        } else if (cellString as String).isAlphanumeric {
            let cell = mTableview.dequeueReusableCell(withIdentifier: "MainLinkImageCell", for: indexPath) as! MainLinkImageCell
            
            cell.LinkUrlLb.text = ((self.datadic?.object(at: indexPath.section) as! NSMutableArray).object(at: indexPath.row) as! NSDictionary)["msg"] as? String
            
            let tagString : String = String.init(format: "%dn%d", indexPath.section,indexPath.row)
            cell.shareBtn.setTitle(tagString, for: UIControlState.normal)
            cell.shareBtn.addTarget(self, action: #selector(ViewController.actShare(_:)), for: UIControlEvents.touchUpInside)
            cell.goUrlBtn.setTitle(tagString, for: UIControlState.normal)
            //print(((self.datadic?.object(at: indexPath.section) as! NSMutableArray).object(at: indexPath.row) as! NSDictionary)["msg"] as? String)
            let dataUrlModel = DataModel()
            
            dataUrlModel.parseUrlJson(urlString: ((self.datadic?.object(at: indexPath.section) as! NSMutableArray).object(at: indexPath.row) as! NSDictionary)["msg"] as! String){(json) -> Void in
                if json != nil {
                    if let json = json,
                        let list = json["list"] as? NSArray {
                           dataUrlModel.getDataFromUrl(url: URL(string: ((list[0] as! NSDictionary)["imgSrc"] as? String)!)!){(data, response, error) in
                                print("Download Finished")
                                print((list[0] as! NSDictionary)["imgSrc"] as? String)
                                DispatchQueue.main.async {
                                    cell.LinkTitleLb.text = (list[0] as! NSDictionary)["title"] as? String
                                    cell.LinkImage.image = UIImage(data: data!)
                                }
                            }
                    }
                }
            }
            
            return cell
        }else if CGFloat(cellString.length) < CGFloat(15.0) {
            let cell = mTableview.dequeueReusableCell(withIdentifier: "MainShortCell", for: indexPath) as! MainShortCell
            //cell.ContentLb.text = (self.dataJson![indexPath.row]["msg"] as? String)!
            
            cell.ContentLb.text = ((self.datadic?.object(at: indexPath.section) as! NSMutableArray).object(at: indexPath.row) as! NSDictionary)["msg"] as? String
            
            let timeInt = ((self.datadic?.object(at: indexPath.section) as! NSMutableArray).object(at: indexPath.row) as! NSDictionary)["created_time"] as? Int64
            cell.timeLb.text = self.DatetoStringAA(date: Date(timeIntervalSince1970: Double(timeInt!)))
            
            let tagString : String = String.init(format: "%dn%d", indexPath.section,indexPath.row)
            cell.shareBtn.setTitle(tagString, for: UIControlState.normal)
            
            cell.shareBtn.addTarget(self, action: #selector(ViewController.actShare(_:)), for: UIControlEvents.touchUpInside)
            
            let viewCount = DataTag.TOTALCOUNT - (((self.datadic?.object(at: indexPath.section) as! NSMutableArray).object(at: indexPath.row) as! NSDictionary)["unread_cnt"] as! Int)
            
            cell.viewCountLb.text = String.init(format: "%d", viewCount)
            return cell
        }else {
            let cell = mTableview.dequeueReusableCell(withIdentifier: "MainNomalCell", for: indexPath) as! MainNomalCell
            
            
            //Attrbute Size
            
            let cellString = ((self.datadic?.object(at: indexPath.section) as! NSMutableArray).object(at: indexPath.row) as! NSDictionary)["msg"] as! String
            // set label Attribute
            if isSearch {
                cell.contextLb.attributedText = changeTint(cellString: cellString as NSString, searchString: self.searchText as NSString, index : indexPath)
            }else {
                self.searchCount = 0;
                self.searchRangeCount = -1;
                cell.contextLb.text = cellString
            }
            let timeInt = ((self.datadic?.object(at: indexPath.section) as! NSMutableArray).object(at: indexPath.row) as! NSDictionary)["created_time"] as? Int64
            cell.timeLb.text = self.DatetoStringAA(date: Date(timeIntervalSince1970: Double(timeInt!)))
            let tagString : String = String.init(format: "%dn%d", indexPath.section,indexPath.row)
            cell.shareBtn.setTitle(tagString, for: UIControlState.normal)
            
            cell.shareBtn.addTarget(self, action: #selector(ViewController.actShare(_:)), for: UIControlEvents.touchUpInside)
            
            let viewCount = DataTag.TOTALCOUNT - (((self.datadic?.object(at: indexPath.section) as! NSMutableArray).object(at: indexPath.row) as! NSDictionary)["unread_cnt"] as! Int)
            
            cell.viewCountLb.text = String.init(format: "%d", viewCount)
            return cell
        }
   
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.datadic != nil {
            return (self.datadic?.object(at: section) as! NSMutableArray).count
        }else {
            return  0
        }
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()

        
        if self.sectionAry != nil {
            label.text = sectionAry![section] as? String
        }else {
            label.text = "검색중입니다."
        }
        
        view.addSubview(label)
   
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.darkGray
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: label.font.fontName, size: 13)
        let views = ["label": label, "view": view]
        
        let horizontallayoutContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-30-[label]-30-|", options: .alignAllCenterY, metrics: nil, views: views)
        view.addConstraints(horizontallayoutContraints)
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.sectionAry != nil {
            return (self.sectionAry?.count)!
        }else {
            return 1
        }
        
    }
    // MARK : IBActionㄴ
    
    @IBAction func actSearch(_ sender: Any) {
        if self.isSearch {
            self.isSearchingGoDown = false
            self.isSearch = false
            self.searchBtn.setImage(UIImage(named:"ic_search_white_24dp"), for: UIControlState.normal)
            self.searchTF.isHidden = true
            self.topLb.isHidden = false
            self.totalPeopleLb.isHidden = false
            self.searchGoUpBtn.isHidden = true
            self.searchGoDownBtn.isHidden = true
            self.view.endEditing(true)
            self.mTableview.reloadData()
            self.mTableview.tableViewScrollToBottom(animated: false)
        }else {
            //SEARCH MODE
            self.searchBtn.setImage(UIImage(named:"ic_close_white_24dp"), for: UIControlState.normal)
            self.searchTF.becomeFirstResponder()
            self.isSearch = true
            self.searchTF.isHidden = false
            self.topLb.isHidden = true
            self.totalPeopleLb.isHidden = true
            self.searchText = ""
            self.mTableview.tableViewScrollToBottom(animated: false)
        }
    }
    @IBAction func actShowSwipe(_ sender: Any) {
        self.actShowSideView(sender)
    }
    @IBAction func actTableScroolDown(_ sender: Any) {
        self.mTableview.tableViewScrollToBottom(animated: false)
    }
    @IBAction func actShowSideView(_ sender: Any) {
        if self.onSideView == false {
            //self.hiddenViewBtn.isEnabled = true
            //self.hiddenViewBtn.isUserInteractionEnabled = true
            //self.hiddenViewBtn.isHidden = false;
            UIView.animate(withDuration: 0.7, animations: {
                self.sideView.transform = CGAffineTransform(translationX: self.view.frame.width * 0.85 , y: 0.0);
                self.hiddenViewBtn.alpha = 0.7
                self.onSideView = true
            })
            
        }
        
    }
    @IBAction func actShareApp(_ sender: Any) {
        
        
        let firstActivityItem = DataTag.APP_URL
        let secondActivityItem : NSURL = NSURL(string: DataTag.APP_URL)!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
        
        // This line remove the arrow of the popover to show in iPad
        
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivityType.airDrop,
        ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func actPushImg(_ sender: Any){
        print((sender as! UIButton).tag)
    }
    @IBAction func actShareImg(_ sender: Any){
        print((sender as! UIButton).tag)
        let sectionRow  = (((sender as! UIButton).titleLabel?.text)! as String).returnSectionRow
        if sectionRow != nil {
            let section = sectionRow!.0
            let row = sectionRow!.1
            let urlString = String.init(format: "http://1.234.70.19:8080/%@", ((self.datadic?.object(at: section) as! NSMutableArray).object(at: row) as! NSDictionary)["attachment"] as! String)
            print(urlString.replacingOccurrences(of: "\\", with: "/"))
            
            let dataImgModel = DataModel()
            dataImgModel.getDataFromUrl(url: URL(string: urlString.replacingOccurrences(of: "\\", with: "/"))!) { (data, response, error) in
                
                print("Share Image Data Download Finished")
                if data != nil {
                    let activityViewController : UIActivityViewController = UIActivityViewController(
                        activityItems: [UIImage(data : data!)!], applicationActivities: nil)
                    
                    // This lines is for the popover you need to show in iPad
                    activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
                    
                    // This line remove the arrow of the popover to show in iPad
                    
                    activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
                    
                    activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
                    
                    // Anything you want to exclude
                    activityViewController.excludedActivityTypes = [
                        UIActivityType.airDrop,
                    ]
                    
                    self.present(activityViewController, animated: true, completion: nil)
                }else {
                    print("image data nil")
                }
            }

        }else {
            print("nil Data")
        }
    }
    @IBAction func actShareLink(_ sender: Any){
        print((sender as! UIButton).tag)
    }
    @IBAction func actShare(_ sender: Any){
        print(((sender as! UIButton).titleLabel?.text)! as String)
        let sectionRow  = (((sender as! UIButton).titleLabel?.text)! as String).returnSectionRow
        if sectionRow != nil {
            let section = sectionRow!.0
            let row = sectionRow!.1
            
            let firstActivityItem = ((self.datadic?.object(at: section) as! NSMutableArray).object(at: row) as! NSDictionary)["msg"] as! String
            
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [firstActivityItem], applicationActivities: nil)
            
            // This lines is for the popover you need to show in iPad
            activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
            
            // This line remove the arrow of the popover to show in iPad
            
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
            
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
            
            // Anything you want to exclude
            activityViewController.excludedActivityTypes = [
                UIActivityType.airDrop,
            ]
            
            self.present(activityViewController, animated: true, completion: nil)
            
        }else {
            print("nil Data")
        }
        //print((((sender as! UIButton).titleLabel?.text)! as String).returnSectionRow)
    }
    @IBAction func actSearchDown(_ sender: Any) {
        if searchPosAry != nil && isSearch  {
            
            let set = NSSet(array: searchPosAry?.copy() as! [NSMutableDictionary])
            
            let searchPosArySort = set.allObjects.sorted() { (($0 as! NSMutableDictionary).value(forKey: "index") as! IndexPath).section > (($1 as! NSMutableDictionary).value(forKey: "index") as! IndexPath).section }
            
            let rangeArray = (searchPosArySort[searchCount] as! NSMutableDictionary).value(forKey: "pos") as! [NSRange]
            let indexPath = ((searchPosArySort[searchCount] as! NSMutableDictionary).value(forKey: "index") as! IndexPath)
            print("searchRangeCount : ",searchRangeCount)
            print("searchCount : ",searchCount)
            if self.searchRangeCount > -1 && rangeArray.count != 0{
                if self.searchRangeCount > 0 {
                    self.searchRangeCount = self.searchRangeCount - 1
                }
                let range = rangeArray[searchRangeCount]
                
                self.mTableview.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: false)
                if let cell = self.mTableview.cellForRow(at: indexPath) as? MainNomalCell {
                    DispatchQueue.main.async {
                        cell.contextLb.select(self)
                        cell.contextLb.selectedRange = range
                        let caret = cell.contextLb.caretRect(for: cell.contextLb.selectedTextRange!.start)
                        self.mTableview.contentOffset = CGPoint(x: 0, y: self.mTableview.contentOffset.y+caret.maxY-self.view.frame.height/2)
                    }
                }
                
                
                if self.searchRangeCount == 0 && searchCount > 0 {
                    self.searchRangeCount = ((searchPosArySort[searchCount-1] as! NSMutableDictionary).value(forKey: "pos") as! [NSRange]).count
                    self.searchCount = self.searchCount - 1
                }else {
                    print("NO MOREPAGE")
                }
                
            }else {
                
            }
        }
    }
    @IBAction func actSearchUp(_ sender: Any) {
        
        if searchPosAry != nil && isSearch  {
            
            let set = NSSet(array: searchPosAry?.copy() as! [NSMutableDictionary])
            
            let searchPosArySort = set.allObjects.sorted() { (($0 as! NSMutableDictionary).value(forKey: "index") as! IndexPath).section > (($1 as! NSMutableDictionary).value(forKey: "index") as! IndexPath).section }
            
//            print(searchPosArySort)
            let rangeArray = (searchPosArySort[searchCount] as! NSMutableDictionary).value(forKey: "pos") as! [NSRange]
            let indexPath = ((searchPosArySort[searchCount] as! NSMutableDictionary).value(forKey: "index") as! IndexPath)
            print("searchRangeCount : ",searchRangeCount)
            print("searchCount : ",searchCount)
            if self.searchRangeCount < rangeArray.count && rangeArray.count != 0 {
                if self.searchRangeCount != rangeArray.count - 1  {
                    self.searchRangeCount = self.searchRangeCount + 1
                }
                
                let range = rangeArray[searchRangeCount]
                
                
                
//                print(indexPath)
//                print(range.location)
//                print(range.length)
                self.mTableview.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: false)
                if let cell = self.mTableview.cellForRow(at: indexPath) as? MainNomalCell {
                    DispatchQueue.main.async {
                        cell.contextLb.select(self)
                        cell.contextLb.selectedRange = range
                        let caret = cell.contextLb.caretRect(for: cell.contextLb.selectedTextRange!.start)
                        self.mTableview.contentOffset = CGPoint(x: 0, y: self.mTableview.contentOffset.y+caret.maxY-self.view.frame.height/2)
                    }
                }
                
                
                if self.searchRangeCount == rangeArray.count - 1 && searchCount < (searchPosArySort.count) - 1 {
                        self.searchRangeCount = -1
                        self.searchCount = self.searchCount + 1
                }else {
                    print("NO MOREPAGE")
                }
            
            }else {
                
            }
        }
       
    }
    
    @IBAction func actHiddenOff(_ sender: Any) {
        if self.onSideView {
            UIView.animate(withDuration: 0.7, animations: {
                self.sideView.transform = CGAffineTransform(translationX: 0.0 , y: 0.0);
                self.hiddenViewBtn.alpha = 0.0
                self.onSideView = false
            },completion : { (error) in
                //self.hiddenViewBtn.isHidden = true
                //self.hiddenViewBtn.isEnabled = false
                //self.hiddenViewBtn.isUserInteractionEnabled = false
            })
        }
    }
    
    @IBAction func actNeverShowNotice(_ sender: Any) {
        let hasLaunchedKey = "isNeverShow"
        let defaults = UserDefaults.standard
        let hasLaunched = defaults.bool(forKey: hasLaunchedKey)
        
        if !hasLaunched {
            defaults.set(true, forKey: hasLaunchedKey)
            self.noticeView.isHidden = true
        }
        
    }
    @IBAction func actNoticeHidden(_ sender: Any) {
        self.actNoticeViewOn(sender)
    }
    @IBAction func actNoticeViewOn(_ sender: Any) {
        if self.onNoticeView {
            self.noticeLabel.numberOfLines = 25
            self.onNoticeView = false
            self.noticeHiddenBtn.isHidden = false
            self.noticeNeverShowBtn.isHidden = false
            self.noticeShowBtn.setImage(UIImage(named:"ic_expand_less_black_24dp"), for: UIControlState.normal)
        }else {
            self.noticeLabel.numberOfLines = 2
            self.noticeHiddenBtn.isHidden = true
            self.noticeNeverShowBtn.isHidden = true
            self.onNoticeView = true
            self.noticeShowBtn.setImage(UIImage(named:"ic_expand_more_black_24dp"), for: UIControlState.normal)
        }
        
    }
    // MARK : PREPAREFORSEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "goImage":
            //이미지뷰로 이동 ..관련 파라메터 전달
            let sectionRow  = (((sender as! UIButton).titleLabel?.text)! as String).returnSectionRow
            let section = sectionRow!.0
            let row = sectionRow!.1
            
            let ImgVC = segue.destination as! ImageViewController
            let urlString = String.init(format: "http://1.234.70.19:8080/%@", ((self.datadic?.object(at: (section)) as! NSMutableArray).object(at: (row)) as! NSDictionary)["attachment"] as! String)
            ImgVC.url = urlString.replacingOccurrences(of: "\\", with: "/")
            break
        case "goReport":
            //제보하기뷰로 이동 ..관련 파라메터 전달
            break
        case "goSetting":
            //세팅뷰로 이동 ..관련 파라매터 전달
            break
        default:
            //Daum, Naver ,인터넷뷰로 이동
            let webVC = segue.destination as! WebViewController
            webVC.urlType = segue.identifier!
            
            if segue.identifier == "goUrl" {
                let sectionRow  = (((sender as! UIButton).titleLabel?.text)! as String).returnSectionRow
                let section = sectionRow!.0
                let row = sectionRow!.1
                webVC.url = ((self.datadic?.object(at: section) as! NSMutableArray).object(at: row) as! NSDictionary)["msg"] as! String
            }
            
            break
        }
        
    }
    // MARK : FUNCS
    //검색된 스트링만의 색을 변형시키는 함수
    func changeTint(cellString : NSString, searchString : NSString, index : IndexPath) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(string: cellString as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 15.0)])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        paragraphStyle.firstLineHeadIndent = 5
        attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle,range: NSMakeRange(0, attrString.length))
        
        let fullStringLength = (cellString as String).characters.count
        var searchRange = NSMakeRange(0, fullStringLength)
        let Dic = NSMutableDictionary()
        Dic.setValue(index, forKey: "index")
        let posAry = NSMutableArray()
        while searchRange.location < fullStringLength {
            searchRange.length = fullStringLength - searchRange.location
            let foundRange = cellString.range(of: searchString as String, options: NSString.CompareOptions.caseInsensitive, range: searchRange)
            
            
            if foundRange.location != NSNotFound {
                
                searchRange.location = foundRange.location + 1
                posAry.add(NSMakeRange(searchRange.location-1, foundRange.length))
                attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(searchRange.location - 1, foundRange.length) )
                attrString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.gray, range: NSMakeRange(searchRange.location - 1, foundRange.length) )
                
            } else {
                // no more strings to find
                break
            }
        }
        
        let set = NSSet(array: posAry.copy() as! [NSRange])
        
        let sortPosAry = set.allObjects.sorted() { ($0 as! NSRange).location > ($1 as! NSRange).location }
    
        Dic.setValue(sortPosAry, forKey: "pos")
        
        self.searchPosAry?.add(Dic)
        
        
        return attrString
    }
    func DatetoString(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 EEEE"
        return dateFormatter.string(from: date)
    }
    func DatetoStringAA(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "aa HH:mm"
        return dateFormatter.string(from: date)
    }
    // MARK : TOUCH EVENT
}

// Extensions..
extension UITableView {
    
    func tableViewScrollToBottom(animated: Bool) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            }
        
    }
}

extension String {
    var isAlphanumeric: Bool {
        let rangeString = range(of: "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*)+)+(/)?(\\?.*)?", options: .regularExpression)
        if rangeString != nil {
            if self.distance(from: self.startIndex, to: (rangeString?.lowerBound)!) == 0 {
                return true
            }else {
                return false
            }
        }
        return false
    }
    
    var returnSectionRow : (Int , Int)? {
        let rangeString = range(of: "n", options: .regularExpression)
        if rangeString != nil {
            //print(self.distance(from: self.startIndex, to: (rangeString?.lowerBound)!))
            return (Int(self.substring(to: (rangeString?.lowerBound)!))!,Int(self.substring(from: (rangeString?.upperBound)!))!)
        }
        return nil
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}


