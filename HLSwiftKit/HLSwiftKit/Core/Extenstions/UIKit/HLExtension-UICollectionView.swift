//
//  HLExtension-UICollectionView.swift
//  CloudStore
//
//  Created by Liang on 2021/5/18.
//  Copyright © 2021 HangZhouMYQ. All rights reserved.
//


typealias UICollectionViewElementKind = UICollectionView.ElementKind

extension UICollectionView {
    
    public static let elementKindDecorationSection:String    = "elementKindDecorationSection"
    
    public static let elementKindDecorationItem:String       = "elementKindDecorationItem"
        
    enum ElementKind:String {
        case header
        case footer
        case decorateSection
        case decorateItem
        
        var rawValue:String {
            switch self {
            case .header:
                return UICollectionView.elementKindSectionHeader
            case .footer:
                return UICollectionView.elementKindSectionFooter
            case .decorateSection:
                return UICollectionView.elementKindDecorationSection
            case .decorateItem:
                return UICollectionView.elementKindDecorationItem
            }
        }
    }
    
    
    final func customRegisterCell(with classes:[UICollectionViewCell.Type]) {
        classes.forEach {
            register($0.self, forCellWithReuseIdentifier: NSStringFromClass($0))
        }
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(UICollectionViewCell.self))
    }
    
    final func customDequeueCell<T>(for indexPath:IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: NSStringFromClass(T.self as! AnyClass), for: indexPath) as! T
    }
    
    final func customDequeueBaseCell(for indexPath:IndexPath) -> UICollectionViewCell {
//        let cell:UICollectionViewCell = customDequeueCell(for: indexPath)
//        return cell
        dequeueReusableCell(withReuseIdentifier: NSStringFromClass(UICollectionViewCell.self), for: indexPath) as UICollectionViewCell
    }
    
    final func customRegisterSupplementaryView(with classes:[ElementKind:UICollectionReusableView.Type]) {
        classes.forEach {
            register($0.value.self,
                     forSupplementaryViewOfKind: $0.key.rawValue,
                     withReuseIdentifier: NSStringFromClass($0.value))
        }
        register(UICollectionReusableView.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self))
    }
    
    final func customDequeueSupplementaryView<T>(with kind:ElementKind,for indexPath:IndexPath) -> T {
        dequeueReusableSupplementaryView(ofKind: kind.rawValue, withReuseIdentifier: NSStringFromClass(T.self as! AnyClass), for: indexPath) as! T
    }
    
    final func customDequeueBaseSupplementaryView(with kind:ElementKind = .header, for indexPath:IndexPath) -> UICollectionReusableView {
        dequeueReusableSupplementaryView(ofKind: kind.rawValue,
                                         withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self),
                                         for: indexPath) as UICollectionReusableView
    }
    
}
