//
//  ViewController.swift
//  HLToolKit-Swift
//
//  Created by 757437150@qq.com on 05/21/2019.
//  Copyright (c) 2019 757437150@qq.com. All rights reserved.
//

import UIKit
import HLToolKit_Swift

class ViewController: UIViewController {
    
    var btn:UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        self.btn = UIButton(type: .custom)
        self.btn.frame = CGRect.init(x: 100, y: 100, width: 200, height: 50)
        self.btn.backgroundColor = UIColor.init("#efefef")
        self.btn.setTitleColor(UIColor.init("#000000"), for: UIControl.State.normal)
        self.btn.setTitle("button", for: .normal)
        
        //        self.btn.forceRoundCorner = true
        self.btn.rectCornerRadius = 20;
        let corners: UIRectCorner = [.bottomLeft,.bottomRight]
        self.btn.rectCorner = corners
        
        self.view.addSubview(self.btn)
        
        self.btn.addEvent { [weak self] in
//            self?.timeTest()
            self?.reqTest()
//            self?.getImage()
        }
        
        
        
        
        //        let start:CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        //        for index in 1...1 {
        //            let color = UIColor.hex("#efefef")
        //        }
        //        let end: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        //        print(end - start)
        //
        //
        //        let start1:CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        //        for index in 1...1 {
        //            let color = UIColor("#efefef")
        //        }
        //        let end1: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        //        print(end1 - start1)
        
    }
    
//    func getImage() {
//        HLImagePicker.defaultPicker().getImage(from: self) { [weak self] obj in
//
//        }
//    }

    
    
    func timeTest() {
        let xx =  kTimeTest {
            for _ in 1...100 {
                _ = UIColor.init("ffffff")
            }
        }
        print(xx);
    }
    
    func reqTest() {
        HLReq.fetchPurchaseCateList {  (obj, error) in
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

