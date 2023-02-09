//
//  TestData.swift
//  HLToolKit-Swift_Example
//
//  Created by Liang on 2019/6/4.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

struct HomeData :Codable {
    var groups:[Data_groups]?
    var bann:[Data_banners]?
    var topItems:[Data_topItems]?
    
    private enum CodingKeys:String,CodingKey {
        case groups
        case bann = "banners"
        case topItems
    }
}

struct Data_groups:Codable {
    var showType:Int?
    var name:String?
    var id:Int?
    var ImgCover:String?
    var itemList:[group_itemList]?
    
//    private enum CodingKeys:String,CodingKey {
//        case showType
//        case name
//        case id
//        case ImgCover
//        case itemList
//    }
}

struct group_itemList:Codable {
    var id:Int?
    var subTitle:String?
    var itemNo:String?
    var price:Int?
    var itemCode:String?
    var imgCover:String?
    var name:String?
    var sellNum:Int?
    
//    private enum CodingKeys:String,CodingKey {
//        case id
//        case subTitle
//        case itemNo
//        case price
//        case itemCode
//        case imgCover
//        case name
//        case sellNum
//    }
}

struct Data_banners:Codable {
    var bannerType:Int?
    var wapUrl:String?
    var objectId:Int?
    var id:Int?
    var imgCover:String?
    var title:String?
    
//    private enum CodingKeys:String,CodingKey {
//        case bannerType
//        case wapUrl
//        case objectId
//        case id
//        case imgCover
//        case title
//    }
}

struct Data_topItems:Codable {
    var name:String?
    var id:Int?
    var imgCover:String?
    var sellNum:Int?
    var itemCode:String?
    var subTitle:String?
    var price:Int?
    var itemNo:String?
    
//    private enum CodingKeys:String,CodingKey {
//        case name
//        case id
//        case imgCover
//        case sellNum
//        case itemCode
//        case subTitle
//        case price
//        case itemNo
//    }
}
