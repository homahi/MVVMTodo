//
//  TodoVIewModel.swift
//  MVVMTableView
//
//  Created by 原野誉大 on 2018/05/18.
//  Copyright © 2018年 原野誉大. All rights reserved.
//

import RxSwift

protocol TodoMenuItemViewPresentable {
    var title: String? { get set }
    var backColor: String? { get }
}

protocol TodoMenuItemViewDelegate {
    func onMenuItemSelected() -> ()
}

class TodoMenuItemViewModel: TodoMenuItemViewPresentable, TodoMenuItemViewDelegate {
    var title: String?
    var backColor: String?
    
    weak var parent: TodoItemViewDelegate?
    
    init(parentViewModel: TodoItemViewDelegate) {
        self.parent = parentViewModel
    }
    
    func onMenuItemSelected() {
        // Base class does not require an implemention
    }
}

class RemoveMenuItemViewModel: TodoMenuItemViewModel {
    override func onMenuItemSelected() {
        print("Remove menu item selected")
        parent?.onRemoveSelected()
    }
}

class DoneMenuItemViewModel: TodoMenuItemViewModel {
    override func onMenuItemSelected() {
        print("Done menu item selected ")
        parent?.onDoneSelected()
    }
}

protocol TodoItemViewDelegate: class {
    func onItemSelected() -> (Void)
    func onRemoveSelected() -> (Void)
    func onDoneSelected() -> (Void)
}

protocol TodoItemPresentable {
    var id: String? { get }
    var textValue: String? { get }
    var isDone: Bool? { get set }
    var menuItems: [TodoMenuItemViewPresentable]? { get set }
}

class TodoItemViewModel: TodoItemPresentable {
    var id: String? = "0"
    var textValue: String?
    var isDone: Bool? = false
    var menuItems: [TodoMenuItemViewPresentable]? = []
    weak var parent: TodoViewDelegate?
    
    init(id: String, textValue: String, parentViewModel: TodoViewDelegate) {
        self.id = id
        self.textValue = textValue
        self.parent = parentViewModel
        
        let removeMenuItem = RemoveMenuItemViewModel(parentViewModel: self)
        removeMenuItem.title = "Remove"
        removeMenuItem.backColor = "ff0000"
        
        let doneMenuItem = DoneMenuItemViewModel(parentViewModel: self)
        doneMenuItem.title = isDone! ? "Undone" : "Done"
        doneMenuItem.backColor = "000000"
        menuItems?.append(contentsOf: [removeMenuItem, doneMenuItem])
    }
    
}

protocol TodoViewDelegate: class {
    func onAddTodoItem() -> ()
    func onTodoDeleteItem(todoId: String) -> ()
    func onTodoDoneItem(todoId: String) -> ()
}

protocol TodoViewPresentable {
    var newTodoValue: String? { get }
}

import RealmSwift

class TodoViewModel: TodoViewPresentable {
    var newTodoValue: String?
    var items: Variable<[TodoItemPresentable]> = Variable([])
    var database: Database?
    var notificationToken: NotificationToken? = nil
    
    init() {
        database = Database.singletone
        let todoItemResults = database?.fetch()
        
        notificationToken = todoItemResults?.observe({ [weak self] (changes: RealmCollectionChange) in
            switch(changes) {
            case .initial:
                todoItemResults?.forEach({ (todoItemEntity) in
                    let todoItemEntity = todoItemEntity
                    let itemIndex = todoItemEntity.todoId
                    let newValue = todoItemEntity.todoValue
                    let newItem = TodoItemViewModel(id: "\(itemIndex)", textValue: newValue, parentViewModel: self!)
                    self?.items.value.append(newItem)
                    
                })
                break
            case .update(_, let deletions, let insertions, let modifications):

                insertions.forEach({ (index) in
                    let todoItemEntity = todoItemResults![index]
                    let itemIndex = todoItemEntity.todoId
                    let newValue = todoItemEntity.todoValue
                    let newItem = TodoItemViewModel(id: "\(itemIndex)", textValue: newValue, parentViewModel: self!)
                    self?.items.value.append(newItem)
                    
                    self?.newTodoValue = ""
                })
                
                modifications.forEach({ (index) in
                    
                    let todoItemEntity = todoItemResults![index]
                    
                    guard let index = self?.items.value.index(where: { Int($0.id!) == todoItemEntity.todoId }) else {
                        print("item for the index does not exist")
                        return
                    }
                    
                    var todoItemVm = self?.items.value[index]

                    todoItemVm?.isDone = todoItemEntity.isDone
                    
                    if var doneMenuItem = todoItemVm?.menuItems?.filter({ (todoMenuItem) -> Bool in
                        todoMenuItem is DoneMenuItemViewModel
                    }).first {
                        doneMenuItem.title = todoItemEntity.isDone ? "Undone" : "Done"
                    }
                })
                
            case .error(let error):
                break
            }
            self?.items.value.sort(by: {
                if !($0.isDone!) && !($1.isDone!) {
                    return $0.id! < $01.id!
                }
                if $0.isDone! && $1.isDone! {
                    return $0.id! < $01.id!
                }
                return !($0.isDone!) && $1.isDone!
            })
        })
    }
    
    deinit {
        notificationToken?.invalidate()
    }
}

extension TodoViewModel: TodoViewDelegate {
    func onTodoDoneItem(todoId: String) {
        print("Todo item done with id = \(todoId)")
        guard let index = self.items.value.index(where: { $0.id! == todoId }) else {
            print("item for the index does not exist")
            return
        }
        
        database?.isDone(primaryKey: Int(todoId)!)
    }
    
    func onAddTodoItem() {
        
        guard let newValue = newTodoValue else {
            print("New value is empty")
            return
        }
        print("New todo value received in view model: \(newValue)")
        
        database?.creteOrUpdate(todoItemValue: newValue)
        self.newTodoValue = ""
        
    }
    
    func onTodoDeleteItem (todoId: String) {
        guard let index = self.items.value.index(where: { $0.id! == todoId }) else {
            print("item for the index does not exist")
            return
        }
        self.items.value.remove(at: index)
        
    }
}

extension TodoItemViewModel: TodoItemViewDelegate {
    func onRemoveSelected() {
        parent?.onTodoDeleteItem(todoId: id!)
    }
    
    func onDoneSelected() {
        parent?.onTodoDoneItem(todoId: id!)
    }
    
    func onItemSelected() {
        print("Did select row at received for item with id = \(id!)")
    }
}
