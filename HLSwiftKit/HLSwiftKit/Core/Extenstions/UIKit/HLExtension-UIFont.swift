//
//  HLExtension-UIFont.swift
//  CloudStore
//
//  Created by Liang on 2021/9/30.
//  Copyright © 2021 HangZhouMYQ. All rights reserved.
//


import CoreText

private let UndefinedFontSize = CGFloat(1)

let FontDidBecomeAvailableNotification = "com.hoppenichu.FontDownloader.FontDidBecomeAvailableNotification"
let FontNameInfoKey = "FontNameInfoKey"

extension UIFont {
    typealias DownloadProgressHandler = (Int, Int, Int) -> Void
    typealias DownloadCompletionHandler = (UIFont?) -> Void
    
    class func downloadableFontNames() -> [String] {
        let downloadableDescriptor = CTFontDescriptorCreateWithAttributes([
            (kCTFontDownloadableAttribute as NSString): kCFBooleanTrue
        ] as CFDictionary)
        guard let cfMatchedDescriptors = CTFontDescriptorCreateMatchingFontDescriptors(downloadableDescriptor, nil),
              let matchedDescriptors = (cfMatchedDescriptors as NSArray) as? [CTFontDescriptor] else {
            return []
        }
        return matchedDescriptors.compactMap { (descriptor) -> String? in
            let attributes = CTFontDescriptorCopyAttributes(descriptor) as NSDictionary
            return attributes[kCTFontNameAttribute as String] as? String
        }
    }
    
    class func fontExists(name: String,size:CGFloat = UndefinedFontSize) -> Bool {
        return UIFont(name: name, size: size) != nil
    }
    
    class func preloadFontWithName(name: String) {
        if fontExists(name: name) {
            return
        }
        downloadFontWithName(name: name, size: UndefinedFontSize)
    }
    
    class func downloadFontWithName(name: String, size: CGFloat, progress: DownloadProgressHandler? = nil, completion: DownloadCompletionHandler? = nil) {
        let wrappedCompletionHandler = { (postNotification: Bool) -> Void in
            DispatchQueue.main.async {
                let font = UIFont(name: name, size: size)
                if postNotification && font != nil {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: FontDidBecomeAvailableNotification),
                                                    object: nil,
                                                    userInfo: [FontNameInfoKey: name])
                }
                completion?(font)
            }
        }
        if fontExists(name: name) {
            wrappedCompletionHandler(false)
            return
        }
        let wrappedProgressHandler = { (param: NSDictionary) -> Void in
            DispatchQueue.main.async {
                let downloadedSize = param[kCTFontDescriptorMatchingTotalDownloadedSize as String] as? Int ?? 0
                let totalSize = param[kCTFontDescriptorMatchingTotalAssetSize as String] as? Int ?? 0
                let percentage = param[kCTFontDescriptorMatchingPercentage as String] as? Int ?? 0
                progress?(downloadedSize, totalSize, percentage)
            }
        }
        CTFontDescriptorMatchFontDescriptorsWithProgressHandler([
            CTFontDescriptorCreateWithNameAndSize(name as CFString, size)
        ] as CFArray, nil) { (state, param) -> Bool in
            switch state {
            case .willBeginDownloading, .stalled, .downloading, .didFinishDownloading:
                wrappedProgressHandler(param)
            case .didFinish:
                wrappedCompletionHandler(true)
            default:
                break
            }
            return true
        }
    }
}
