//
//  CSCircleProgressView.swift
//  CloudStore
//
//  Created by Liang on 2021/12/6.
//  Copyright © 2021 HangZhouMYQ. All rights reserved.
//

final class CSCircleProgressView:UIView {
    
    var progess: CGFloat = 0.0 // 环形进度
    var label: UILabel? // 中心文本显示
    var lineWidth: CGFloat = 0.0 // 环形的宽
    private var foreLayer: CAShapeLayer? // 进度条的layer层（可做私有属性）
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    // 覆写父类构造器后这个方法是必须实现的
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 遍历构造器传入frame，以及进度条宽度
    convenience init(frame: CGRect, lineWidth: CGFloat) {
        self.init(frame: frame)
        self.lineWidth = lineWidth
        seup(rect: frame) // 绘制自定义视图的函数
    }
    
    func seup(rect: CGRect) -> Void {
        // 背景圆环（灰色背景）
        let shapeLayer: CAShapeLayer = CAShapeLayer.init()
        // 设置frame
        shapeLayer.frame = CGRect.init(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        shapeLayer.lineWidth = self.lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.init(red: 50/255, green: 40/255, blue: 50/255, alpha: 1).cgColor
        
        let center: CGPoint = CGPoint.init(x: rect.size.width/2, y: rect.size.height/2)
        // 画出曲线（贝塞尔曲线）
        let bezierPath: UIBezierPath = UIBezierPath.init(arcCenter: center, radius: (rect.size.width - self.lineWidth)/2, startAngle: CGFloat(-0.5 * Double.pi), endAngle: CGFloat(1.5 * Double.pi), clockwise: true)
        shapeLayer.path = bezierPath.cgPath // 将曲线添加到layer层
        
        self.layer.addSublayer(shapeLayer) // 添加蒙版
        
        // 渐变色 加蒙版 显示蒙版区域
        let gradientLayer: CAGradientLayer = CAGradientLayer.init()
        
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [kColor("5F98FC").cgColor,kColor("47BF00").cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 0, y: 1)
        
        self.layer.addSublayer(gradientLayer) // 将渐变色添加带layer的子视图
        
        self.foreLayer = CAShapeLayer.init()
        self.foreLayer?.frame = self.bounds
        self.foreLayer?.fillColor = UIColor.clear.cgColor
        self.foreLayer?.lineWidth = self.lineWidth
        
        self.foreLayer?.strokeColor = UIColor.red.cgColor
        self.foreLayer?.strokeEnd = 0
        /* The cap style used when stroking the path. Options are `butt', `round'
         * and `square'. Defaults to `butt'. */
        self.foreLayer?.lineCap = .round // 设置画笔
        self.foreLayer?.path = bezierPath.cgPath
        // 修改渐变layer层的遮罩, 关键代码
        gradientLayer.mask = self.foreLayer
        
        self.label = UILabel.init(frame: self.bounds)
        self.label?.text = ""
        self .addSubview(self.label!)
        self.label?.font = kMFont(15)
        self.label?.textColor = kColor("999999")
        self.label?.textAlignment = NSTextAlignment.center
    }
    
    func setProgress(value: CGFloat) -> Void {
        progess = value // 设置当前属性的值
        self.label?.text = String.init(format: "%.f%%", progess * 100) // 设置内部Label显示的值(注意字符的格式化)
        self.foreLayer?.strokeEnd = progess // 视图改变的关键代码
    }
}
