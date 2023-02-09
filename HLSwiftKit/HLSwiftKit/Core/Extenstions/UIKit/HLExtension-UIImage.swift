//
//  HLExtension-UIImage.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/10.
//  Copyright © 2019 Liang. All rights reserved.
//

import CoreServices
import Kingfisher

//MARK: CSGIFImage
final class CSGIFImage {
    let images: [UIImage]
    let duration: TimeInterval
    
    init?(from fileName: String,
          for info: [String: Any] = [kCGImageSourceShouldCache as String: NSNumber(value: true),
                                     kCGImageSourceTypeIdentifierHint as String: kUTTypeGIF],
          options: ImageCreatingOptions) {
        guard let imageSource = UIImage.getGifSource(with: fileName) else {
            return nil
        }
        
        let frameCount = CGImageSourceGetCount(imageSource)
        var images = [UIImage]()
        var gifDuration = 0.0
        
        for i in 0 ..< frameCount {
            guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, info as CFDictionary) else {
                return nil
            }
            
            if frameCount == 1 {
                gifDuration = .infinity
            } else {
                // Get current animated GIF frame duration
                gifDuration += CSGIFImage.getFrameDuration(from: imageSource, at: i)
            }
            images.append(KFCrossPlatformImage(cgImage: imageRef, scale: options.scale, orientation:.up))
        }
        self.images = images
        self.duration = gifDuration
    }
    
    // Calculates frame duration for a gif frame out of the kCGImagePropertyGIFDictionary dictionary.
    static func getFrameDuration(from gifInfo: [String: Any]?) -> TimeInterval {
        let defaultFrameDuration = 0.1
        guard let gifInfo = gifInfo else { return defaultFrameDuration }
        
        let unclampedDelayTime = gifInfo[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber
        let delayTime = gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber
        let duration = unclampedDelayTime ?? delayTime
        
        guard let frameDuration = duration else { return defaultFrameDuration }
        return frameDuration.doubleValue > 0.011 ? frameDuration.doubleValue : defaultFrameDuration
    }

    // Calculates frame duration at a specific index for a gif from an `imageSource`.
    static func getFrameDuration(from imageSource: CGImageSource, at index: Int) -> TimeInterval {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil)
            as? [String: Any] else { return 0.0 }

        let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any]
        return getFrameDuration(from: gifInfo)
    }
}

extension UIImage {
    
    /// 创建图片对象
    /// - Parameters:
    ///   - fileName: 文件路径
    ///   - fileType: 文件类型
    convenience init?(_ fileName:String, _ fileType:String) {
        let filePath = Bundle.main.path(forResource: fileName, ofType: fileType) ?? ""
        self.init(contentsOfFile:filePath)
    }
    
    static func getGifSource(with fileName:String) -> CGImageSource? {
        let path = Bundle.main.path(forResource: fileName, ofType: "gif")
        let data = NSData(contentsOfFile: path!)
        let options: NSDictionary = [kCGImageSourceShouldCache as String: NSNumber(value: true),
                                     kCGImageSourceTypeIdentifierHint as String: kUTTypeGIF]
        guard let imageSource = CGImageSourceCreateWithData(data!, options) else {
            return nil
        }
        return imageSource
    }
    
    /// 生成图片对象
    /// - Parameters:
    ///   - colorHex: 颜色值
    ///   - alpha: 透明度
    @objc static func color(_ colorHex:String,_ alpha:CGFloat = 1) -> UIImage? {
        return color(kColor(colorHex, alpha))
    }
    
    static func color(_ color:UIColor, size:CGSize = .init(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }

}

// MARK:渐变色图片
extension UIImage {
    
    /// 生成渐变图片
    /// - Parameters:
    ///   - size: 图片大小
    ///   - colors: 渐变色
    ///   - locations: 渐变位置
    ///   - direct: 渐变方向
    static func gradient(size:CGSize,colors:[UIColor],locations:[CGFloat] = [0,1],direct:CSGradientDirection) -> UIImage? {
        guard let gradient = CGGradient.`init`(colors: colors, locations: locations) else {
            return nil
        }
        
        let directPoint = direct.directPoint(rect: .init(x: 0, y: 0, width: size.width, height: size.height))
        UIGraphicsBeginImageContext(size)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.drawLinearGradient(gradient, start: directPoint.startPoint, end: directPoint.endPoint, options: [.drawsBeforeStartLocation,.drawsAfterEndLocation])
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }

}

//MARK: 图片压缩
extension UIImage {
    
    /// 压缩图片到指定大小
    /// - Parameter maxByte: 指定压缩后的图片的数据最大值
    /// - Returns: 压缩结果 新的图片
    func compress(to maxByte:Int) -> (Bool,UIImage) {
        guard let data = self.jpegData(compressionQuality: 1.0) else {
            return (false,self)
        }
        guard let newImageData = ImageCompress.compressImageData(data, limitDataSize: maxByte),
              let newImage = UIImage(data: newImageData) else {
            return (false,self)
        }
        return (true,newImage)
    }
    
}

//MARK: 图片合成类型
enum CSComplexType {
    //文字内容 尺寸 字体 颜色  自定义属性文字
    case text(String = "",
              UIFont? = nil,
              UIColor? = nil,
              rect:CGRect = .zero,
              attri:NSAttributedString? = nil)
    ///图片 尺寸 裁剪圆角
    case image(UIImage,
               CGRect,
               cornerRadius:CGFloat = 0)
}

final class CSComplexInfo {
    ///类型
    var type:CSComplexType
    
//    ///文字内容
//    var text:String?
//    ///文字字体
//    var font:UIFont?
//    ///文字颜色
//    var color:UIColor?
//    ///
////    var origin:CGPoint = .zero
//    var style:NSParagraphStyle?
//
//    var img:UIImage?
//    var rect:CGRect = .zero
//    var cornerRadius:CGFloat = 0.0
    
    init(_ type:CSComplexType) {
        self.type = type
    }
}

extension UIImage {
    
    /// 图片裁剪圆角
    /// - Parameters:
    ///   - rect: 图片尺寸
    ///   - cornerRadius: 圆角值
    func clip(size:CGSize, cornerRadius:CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIBezierPath.init(roundedRect: .init(x: 0, y: 0, width: size.width, height: size.height), cornerRadius: cornerRadius).addClip()
        draw(in: .init(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    /// 图片合成
    /// - Parameters:
    ///   - size: 画布尺寸
    ///   - complexInfo: 待合成信息
    static func complexImage(size:CGSize,with complexInfo:[CSComplexInfo]) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        for item in complexInfo {
            switch item.type {
            case .image(let img, let rect, let cornerRadius):
                if cornerRadius != 0.0 {
                    img.clip(size: rect.size, cornerRadius: cornerRadius)?.draw(in: rect)
                } else {
                    img.draw(in: rect)
                }
            case .text(let content, let font, let color,let rect,let attri):
                let newAttri:NSAttributedString = attri ?? .init(string: content,
                                                                 attributes: [.foregroundColor:color!,
                                                                              .font:font!])
                let size = rect.size != .zero ? rect.size : newAttri.size()
                newAttri.draw(in: .init(x: rect.minX,
                                        y: rect.minY,
                                        width:size.width,
                                        height: size.height))
            }
            
//            switch item.type {
//            case .image:
//                if item.cornerRadius != 0.0 {
//                    item.img?.clip(size: item.rect.size, cornerRadius: item.cornerRadius)?.draw(in: item.rect)
//                } else {
//                    item.img?.draw(in: item.rect)
//                }
//            case .text:
//                var attributes = [NSAttributedString.Key.foregroundColor:item.color!,
//                                  NSAttributedString.Key.font:item.font!]
//                if item.style != nil {
//                    attributes.updateValue(item.style!, forKey: NSAttributedString.Key.paragraphStyle)
//                }
//                let attri = NSAttributedString.init(string: item.text!,
//                                                    attributes: attributes)
//
//                // 文字属性
//                let size = item.rect.size != .zero ? item.rect.size : attri.size()
//
//                // 绘制文字
//                attri.draw(in: CGRect(x: item.rect.minX,
//                                      y: item.rect.minY,
//                                      width: size.width,
//                                      height: size.height))
//            default:break
//            }
        }

        // 从当前上下文获取图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    ///图片的二进制数据
    var data:Data? {
        get {
            if let jpgData = self.kf.data(format: .JPEG) {
                return jpgData
            } else if let pngData = self.kf.data(format: .PNG) {
                return pngData
            } else {
                return nil
            }
        }
    }
}

//MARK: 图片裁剪
extension UIImage {
     
    //将图片裁剪成指定比例（多余部分自动删除）
    func crop(ratio: CGFloat) -> UIImage {
        //计算最终尺寸
        var newSize:CGSize!
        if size.width/size.height > ratio {
            newSize = CGSize(width: size.height * ratio, height: size.height)
        }else{
            newSize = CGSize(width: size.width, height: size.width / ratio)
        }
     
        ////图片绘制区域
        var rect = CGRect.zero
        rect.size.width  = size.width
        rect.size.height = size.height
        rect.origin.x    = (newSize.width - size.width ) / 2.0
        rect.origin.y    = (newSize.height - size.height ) / 2.0
         
        //绘制并获取最终图片
        UIGraphicsBeginImageContext(newSize)
        draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
         
        return scaledImage!
    }
    
}

//MARK: 高斯模糊
extension UIImage {
    
    func createGaussianBlurImage(with value:CGFloat) -> UIImage {
        guard let ciImage = CIImage(image: self) else { return self }
        // 创建高斯模糊滤镜类
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return self }
        
        // key 可以在控制台打印 po blurFilter.inputKeys
        // 设置图片
        blurFilter.setValue(ciImage, forKey: "inputImage")
        // 设置模糊值
        blurFilter.setValue(value, forKey: "inputRadius")
        // 从滤镜中 取出图片
        guard let outputImage = blurFilter.outputImage else { return self }

        // 创建上下文
        let context = CIContext(options: nil)
        // 根据滤镜中的图片 创建CGImage
        guard let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else { return self }
        
        return UIImage(cgImage: cgImage)
    }
}
