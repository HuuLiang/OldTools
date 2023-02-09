//
//  HLExtension-JSONDecoder.swift
//  CloudStore
//
//  Created by Liang on 2021/7/5.
//  Copyright © 2021 HangZhouMYQ. All rights reserved.
//

import CoreData

extension JSONDecoder {
    convenience init(context: NSManagedObjectContext?) {
        self.init()
        if context != nil {
            self.userInfo[.context!] = context!
        }
    }
}
