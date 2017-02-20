//
//  DataTag.swift
//  sewolnewson
//
//  Created by Daeho on 2017. 1. 24..
//  Copyright © 2017년 Daeho. All rights reserved.
//

import Foundation

class DataTag {
    static let VERSION_NAME = 1.0
    static let VERSION_CODE = 1
    static var USERID : Int = 0
    static var COOKIE : String = ""
    static let APP_URL : String = "http://www.naver.com"
    static var TOTALCOUNT : Int = 0
    static var DEVICE_TOKEN : String = ""
    static var DEVICE_AZURE_TOKEN : String = ""
    
    static let URL_DIVICE_SAVE = "http://1.234.70.19:8080/SEWOL/mobile/device/save.do"
    static let URL_LOGIN = "http://1.234.70.19:8080/SEWOL/mobile/user/loginByPhone.do"
    static let URL_NOTICE : String = "http://1.234.70.19:8080/SEWOL/mobile/chatting/searchNotice.do"
    static let URL_NOTICE_COUNT : String = "http://1.234.70.19:8080/SEWOL/mobile/user/searchCount.do"
    static let URL_MSG : String = "http://1.234.70.19:8080/SEWOL/mobile/chatting/searchMsg.do?del_fl=N&room_type=2&chatting_room_id=1&mac_address=test"
    static let URL_LINK : String = "http://1.234.70.19:8080/SEWOL/mobile/linkUrl/search.do"
    static let URL_IMAGE : String = "http://1.234.70.19:8080/SEWOL/mobile/chatting/saveConsultMsg.do"
    
}
