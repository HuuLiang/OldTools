//
//  HLExtension-String.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/10.
//  Copyright © 2019 Liang. All rights reserved.
//

import CommonCrypto

extension String {
    /// 使用下标截取字符串 例: "示例字符串"[0..<2] 结果是 "示例"
    subscript (r: Swift.Range<Int>) -> String {
        get {
            if (r.lowerBound > count) || (r.upperBound > count) { return "截取超出范围" }
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            return String(self[startIndex..<endIndex])
        }
    }
    
    subscript (i:Int)->String{
        let startIndex = self.index(self.startIndex, offsetBy: i)
        let endIndex = self.index(startIndex, offsetBy: 1)
        return String(self[startIndex..<endIndex])
    }
    
    ///转floatValue
    var floatValue:CGFloat {
        get {
            let strDouble = Double(self)
            let strFloat = CGFloat(strDouble ?? 0.0)
            return strFloat
        }
    }
    
    ///转md5
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        free(result)
        return String(format: hash as String)
    }
    
    //转换为字符串数组
    func toStringArray() -> [String] {
        var arr = [String]()
        if let data = self.data(using: .utf8) {
            if let strArr = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String] {
                arr.append(contentsOf: strArr)
            }
        }
        return arr
    }
    
    /// 阿里云图片大小设置
    func custom(_ w:Int) -> String {
        return self+"&x-oss-process=image/resize,m_lfit,w_\(w)"
    }
    
    func bankCardNoStyle() -> String {
        return (self as NSString).replacingCharacters(in: .init(location: 0, length: self.count - 4), with: "****") as String
//        var newString = ""
//        for index in 0..<self.count {
//            if index <= 3 || index >= self.count - 4 {
//                newString.append(self[index])
//            } else {
//                newString.append("*")
//            }
//        }
//        return newString
    }
    
    var urlEncoding:String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
    }
    
    var urlLegal:Bool {
        return hasPrefix("http")
    }
    
    var urlParaming:String {
        contains("?") ? appending("&") : appending("?")
    }
    
    fileprivate var ascii:[UInt32] {
        unicodeScalars.map{$0.value}
    }
    
    var encryptContent:String {
        ascii.encrypt().toString()
    }
    
    var decryptContent:String {
        ascii.encrypt().toString()
    }
    
}

//MARK: Date
extension String {
    
    func toDate(format:String = "yyyy-MM-dd") -> Date {
        return self.toDate(format, region: .local)!.date
    }
    
    func toTimeInterval(format:String = "yyyy-MM-dd HH:mm:ss") -> Int {
        if let date = self.toDate(format, region: .local) {
            return Int(date.timeIntervalSince1970)
        }
        return 0
    }
    
    /// 获取倒计时秒数
    /// - Parameter fullTimeInterval: 完整的倒计时时间
    /// - Returns: 当前剩余倒计时
    func getCountDown(with formatString:String, fullTimeInterval:Int) -> Int? {
        guard let startTime = toDate(formatString, region: .local)?.timeIntervalSince1970 else {
            return nil
        }
        let currentTime:Int = Int(Date().timeIntervalSince1970)
        let completeTime:Int = Int(startTime) + fullTimeInterval
        if completeTime <= currentTime {
            return nil
        }
        return completeTime - currentTime
    }
}

//MARK: Size
extension String {
    ///获取高度
    func height(width: CGFloat, font: UIFont) -> CGFloat {
        return fetchTextSize(with: CGSize(width:width, height: CGFloat.infinity),
                             options: [.usesLineFragmentOrigin,.usesFontLeading],
                             attributes: [NSAttributedString.Key.font: font]).height
    }
    
    ///获取宽度
    func width(height:CGFloat, font:UIFont) -> CGFloat {
        return fetchTextSize(with: CGSize(width: CGFloat.infinity, height: height),
                             options: [.usesLineFragmentOrigin,.usesFontLeading],
                             attributes: [NSAttributedString.Key.font: font]).width
    }
    
    ///获取文字size
    func fetchTextSize(with constraintRect:CGSize,
                       options: NSStringDrawingOptions = [.usesLineFragmentOrigin,.usesFontLeading],
                       attributes: [NSAttributedString.Key : Any]) -> CGSize {
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: options,
                                            attributes: attributes,
                                            context: nil)
        return boundingBox.size
    }

}

//MARK: 字符串过滤 验证
extension String {
    ///是否全是a-z A-Z 0-9
    func isPureNumLetter() -> Bool {
        let reg = "^[a-zA-Z0-9]+$"
        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        return pre.evaluate(with: self)
    }
    
    ///是否全是0-9的数字
    func isPureNum() -> Bool {
        let reg = "^[0-9]*$"
        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        return pre.evaluate(with: self)
    }
    
    ///是否是身份证
    func isIdCard() -> Bool {
        let reg = "^(\\d{17})([0-9xX])$"
        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        return pre.evaluate(with: self)
    }
    
    func isValidYearIdCard() -> Bool {
        let yearDate = Date().year
        if let year =  Int.init(self[6..<10]) {
            let diff = yearDate - year
            if diff >= 18 && diff <= 65 {
                return true
            }
        }
        return false
    }
    
    ///是否全是空格和换行符 的 字符串
    func isBlankText() -> Bool {
        //去掉空格和换行符
        let trueText = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trueText.isEmpty
    }

    
    /// 判断是否为手机号
    ///        * 判断字符串是否符合手机号码格式
    ///       * 移动号段:   134 135 136 137 138 139 147 148 150 151 152 157 158 159  165 172 178 182 183 184 187 188 198
    ///        * 联通号段:   130 131 132 145 146 155 156 166 170 171 175 176 185 186
    ///        * 电信号段:   133 149 153 170 173 174 177 180 181 189  191  199
    ///        * 虚拟运营商:  170
    ///        let mobileRule = "^((13[0-9])|(14[5,6,7,9])|(15[^4])|(16[5,6])|(17[0-9])|(18[0-9])|(19[1,8,9]))\\d{8}$"
    func isPhoneNumber() -> Bool {
        if self.count != 11 {
            return false
        }
        
        let mobileRule = "1\\d{10}$"
        let regexMobile = NSPredicate(format: "SELF MATCHES %@",mobileRule)
        return regexMobile.evaluate(with: self)
    }

    ///过滤表情符号
    var legalString:String {
        return components(separatedBy: .invertedAllLegalCharacterSet).joined()
    }
}


//MARK: Decimal
extension String {
    
    var decimalValue:Decimal {
        return .init(string: self) ?? .zero
    }
    
    var doubleValue:Double {
        return Double(self) ?? .zero
    }
}


//MARK: JSON
extension String {
    
    func toDictionary<T>() -> T? {
        if let data = data(using: .utf8) {
            do {
                let result =  try JSONSerialization.jsonObject(with: data, options: []) as? T
                return result
            } catch let error {
                HLog(error.localizedDescription)
                return nil
            }
        }
        return nil
    }
    
}
