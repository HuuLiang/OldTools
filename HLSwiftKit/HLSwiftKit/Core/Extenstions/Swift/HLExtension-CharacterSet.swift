//
//  HLExtension-CharacterSet.swift
//  CloudStore
//
//  Created by 胡亮亮 on 2021/12/29.
//  Copyright © 2021 HangZhouMYQ. All rights reserved.
//

extension CharacterSet {
        
    ///合法字符集合
    static var legalPunctuationCharacterSet:CharacterSet = {
        return .init(charactersIn: ",.·，。•、")
    }()
        
    ///中文字符合集
    static var chineseCharacterSet:CharacterSet = {
        let start =  Unicode.Scalar.init(0x4e00)!
        let end = Unicode.Scalar.init(0x9fa5)!
        return CharacterSet.init(charactersIn: start...end)
    }()
    
    ///合法字符  英文和数字字符 中文字符 并集的集合
    static var allLegalCharacterSet:CharacterSet = {
        var set:CharacterSet = CharacterSet()
        set.formUnion(.legalPunctuationCharacterSet)
        set.formUnion(.chineseCharacterSet)
        set.formUnion(.alphanumerics)
        set.formUnion(.punctuationCharacters)
        set.formUnion(.whitespacesAndNewlines)
        return set
    }()
    
    ///除去合法字符  英文和数字字符 中文字符 并集的集合的补集
    static var invertedAllLegalCharacterSet:CharacterSet = {
        return allLegalCharacterSet.inverted
    }()
    
    
    
}
