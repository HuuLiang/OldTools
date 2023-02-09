//
//  HLImagePicker.swift
//  HLToolKit-Swift
//
//  Created by Liang on 2019/6/28.
//

import Foundation
import SVProgressHUD

public class HLImagePicker :GalleryControllerDelegate,LightboxControllerDismissalDelegate {
    
    var gallery:GalleryController!
    var lightbox:LightboxController!
    
    @objc public final func getImage(from viewController:UIViewController, handler:@escaping (_:[UIImage]) -> Void) {
        
        Config.tabsToShow = [.imageTab,.cameraTab]
        Config.initialTab = .imageTab
        
        gallery = GalleryController()
        gallery.delegate = self
        viewController.present(gallery, animated: true, completion: nil)
    }
    
    func showLightbox(images: [UIImage]) {
        guard images.count > 0 else {
            return
        }
        
        let lightboxImages = images.map({ LightboxImage(image: $0) })
        lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        lightbox.dismissalDelegate = self
        
        gallery.present(lightbox, animated: true, completion: nil)
    }
    
    private static var singlePicker:HLImagePicker = {
        let picker = HLImagePicker.init()
        return picker
    }()
    
    private init() {}

    public static func defaultPicker() ->HLImagePicker {
        return singlePicker
    }
    
    //    MARK: GalleryControllerDelegate
    
    public func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
    }
    
    public func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    public func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        LightboxConfig.DeleteButton.enabled = true
        
        SVProgressHUD.show()
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
            SVProgressHUD.dismiss()
            self?.showLightbox(images: resolvedImages.compactMap({ $0 }))
        })
    }
    
    public func galleryControllerDidCancel(_ controller: GalleryController) {
        gallery.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    //    MARK:LightboxControllerDismissalDelegate
    
    public func lightboxControllerWillDismiss(_ controller: LightboxController) {
        lightbox.dismiss(animated: true, completion: nil)
        lightbox = nil
    }

}
