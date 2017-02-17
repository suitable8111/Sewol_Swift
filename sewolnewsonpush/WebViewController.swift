//
//  WebViewController.swift
//  sewolnewson
//
//  Created by Daeho on 2017. 1. 16..
//  Copyright © 2017년 Daeho. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    var urlType : String = ""
    var url = ""
    @IBOutlet weak var mWebView: UIWebView!
    
    override func viewDidLoad() {
        
        self.mWebView.delegate = self
        switch urlType {
        case "goDaum":
            url = "http://www.daum.net"
            break
        case "goNaver":
            url = "http://www.naver.com"
            break
        default:
            break
        }
        self.mWebView.loadRequest(URLRequest(url: URL(string: self.url)!))
    }
    @IBAction func actSwipe(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actHome(_ sender: Any) {
        self.mWebView.loadRequest(URLRequest(url: URL(string: self.url)!))
    }
    @IBAction func actGoTop(_ sender: Any) {
        self.mWebView.scrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }
}
