//
//  Database.swift
//  MVVMTableView
//
//  Created by 原野誉大 on 2018/05/22.
//  Copyright © 2018年 原野誉大. All rights reserved.
//

import Foundation
import RealmSwift

class Database {
    
    static let singletone = Database()
    private init() {
        
    }
    
    func creteOrUpdate(todoItemValue: String) -> (Void) {
        let realm = try! Realm()
        
        var todoId: Int? = 1
        
        if let lastEntity = realm.objects(TodoItem.self).last {
            todoId = lastEntity.todoId + 1
        }

        let todoItemEntity = TodoItem()
        todoItemEntity.todoId = todoId!
        todoItemEntity.todoValue = todoItemValue
        
        try! realm.write {
            realm.add(todoItemEntity, update: true)
        }
    }
    
    func fetch() -> (Results<TodoItem>) {
       let realm = try! Realm()
        
       let todoItemResults = realm.objects(TodoItem.self)
        
       return todoItemResults
    }
    
    func delete(primaryKey: Int) -> (Void) {
        let realm = try! Realm()
        
        if let todoItemEntity = realm.object(ofType: TodoItem.self, forPrimaryKey: primaryKey) {
            try! realm.write {
                realm.delete(todoItemEntity)
            }
        }
    }
    
    func isDone(primaryKey: Int) -> (Void) {
        let realm = try! Realm()
        
        if let todoItemEntity = realm.object(ofType: TodoItem.self, forPrimaryKey: primaryKey) {
            try! realm.write {
                realm.delete(todoItemEntity)
            }
        }
    }
}
