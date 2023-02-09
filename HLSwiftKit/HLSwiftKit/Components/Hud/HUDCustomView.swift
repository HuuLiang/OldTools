//
//  HUDCustomView.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/8/13.
//  Copyright © 2019 Liang. All rights reserved.
//

class HUDCustomView: UIView {
    
    static func success(_ message:String?) -> HUDCustomView {
        return HUDCustomView.show("success", message)
    }
    
    static func error(_ message:String?) -> HUDCustomView {
        return HUDCustomView.show("error", message)
    }
    
    static func notice(_ message:String?) -> HUDCustomView {
        return HUDCustomView.show("warning", message)
    }
    
    static func hint(_ simpleMessage:String?) -> HUDCustomView {
        return HUDCustomView.show(simpleMessage)
    }
    
    private static func show(_ image:String,_ message:String?) -> HUDCustomView {
        let customView = HUDCustomView.init(frame: CGRect.init(x: 0, y: 0, width: 120, height: 120))
        customView.imgName = image
        customView.title = message
        return customView
    }
    
    private static func show(_ message:String?) -> HUDCustomView {
        let height = (message?.height(width: kWidth(210), font: kFont(14)))! + kWidth(20)
        let customView = HUDCustomView.init(frame: CGRect.init(x: 0, y: 0, width: kWidth(270), height: height))
        customView.hint = message
        return customView
    }
    
    fileprivate var imgName:String? {
        willSet {
            if newValue != nil {
                imageView.image = UIImage.init(named: newValue!)
            }
        }
    }
    
    fileprivate var title:String? {
        willSet {
            if newValue != nil {
                titleLabel.text = newValue
            }
        }
    }
    
    fileprivate var hint:String? {
        willSet {
            if newValue != nil {
                simpleLabel.text = newValue!
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = kColor("3a3a3a", 0.9)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var imageView:UIImageView = { [unowned self] in
        let imageView = UIImageView.init()
        self.addSubview(imageView)
        imageView.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(kWidth(28))
            make.size.equalTo(kWidth(36))
        })
        return imageView
    }()
    
    private lazy var titleLabel:UILabel = { [unowned self] in
        let label = UILabel()
        label.textColor = .white 
        label.font = kFont(15)
        label.numberOfLines = 0
        label.textAlignment = .center
        self.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(kWidth(100))
            make.top.equalTo(self.imageView.snp.bottom).offset(kWidth(8))
        })
        return label
    }()
    
    private lazy var simpleLabel:UILabel = { [unowned self] in
        let label = UILabel()
        label.textColor = .white 
        label.font = kFont(14)
        label.numberOfLines = 0
        label.textAlignment = .center
        self.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.width.equalTo(kWidth(210))
            make.center.equalToSuperview()
        })
        return label
    }()
    
}
