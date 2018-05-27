//
//  TodoItem.swift
//  MVVMTableView
//
//  Created by 原野誉大 on 2018/05/22.
//  Copyright © 2018年 原野誉大. All rights reserved.
//

import Foundation
import RealmSwift

class TodoItem: Object {
    @objc dynamic var todoId: Int = 0
    @objc dynamic var todoValue: String = ""
    @objc dynamic var createdAt: Date? = Date()
    @objc dynamic var updatedAt: Date? = Date()
    @objc dynamic var isDone: Bool = false
    
    override static func primaryKey() -> String? {
        return "todoId"
    }
}
