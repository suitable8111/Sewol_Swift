//
//  ImageViewController.swift
//  sewolnewson
//
//  Created by Daeho on 2017. 1. 26..
//  Copyright © 2017년 Daeho. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        
        let dataImgModel = DataModel()
        dataImgModel.getDataFromUrl(url: URL(string: url)!) { (data, response, error) in
            
            print("Download Finished")
            if data != nil {
                DispatchQueue.main.async {
                    self.imgView.image = UIImage(data: data!)
                }
            }
        }
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    @IBAction func swipeBack(_ sender: Any) {
         _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}
