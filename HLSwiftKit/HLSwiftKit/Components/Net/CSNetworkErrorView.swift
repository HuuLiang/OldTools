//
//  CSNetworkErrorView.swift
//  CloudStore
//
//  Created by Liang on 2020/9/8.
//  Copyright © 2020 HangZhouMYQ. All rights reserved.
//

class CSNetworkErrorView:UIView {
    
    var touchAction:ConfirmAction?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = kColor("F5F5F5")
        titleLabel.isHidden = false
        
        addEvent { [weak self] in
            self?.touchAction?()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var imageView:UIImageView = { [unowned self] in
        let imageView = UIImageView.init()
        imageView.image = kImage("network_error")
        self.addSubview(imageView)
        imageView.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-kWidth(50))
            make.size.equalTo(kWidth(90))
        })
        return imageView
        }()
    
    private lazy var titleLabel:UILabel = { [unowned self] in
        let label = UILabel()
        label.textColor = kColor("999999")
        label.font = kFont(15)
        label.textAlignment = .center
        label.text = "网络走丢了,请稍后再试 戳我-_-👇"
        self.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.imageView.snp.bottom).offset(kWidth(24))
        })
        return label
        }()

}
