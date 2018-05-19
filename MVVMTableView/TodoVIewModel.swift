//
//  TodoVIewModel.swift
//  MVVMTableView
//
//  Created by 原野誉大 on 2018/05/18.
//  Copyright © 2018年 原野誉大. All rights reserved.
//

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
    
    func onMenuItemSelected() {
        // Base class does not require an implemention
    }
}

class RemoveMenuItemViewModel: TodoMenuItemViewModel {
    override func onMenuItemSelected() {
        print("Remove menu item selected")
    }
}

class DoneMenuItemViewModel: TodoMenuItemViewModel {
    override func onMenuItemSelected() {
        print("Done menu item selected ")
    }
}

protocol TodoItemViewDelegate {
    func onItemSelected() -> (Void)
}

protocol TodoItemPresentable {
    var id: String? { get }
    var textValue: String? { get }
    var menuItems: [TodoMenuItemViewPresentable]? { get set }
}

class TodoItemViewModel: TodoItemPresentable {
    var id: String? = "0"
    var textValue: String?
    var menuItems: [TodoMenuItemViewPresentable]? = []
    init(id: String, textValue: String) {
        self.id = id
        self.textValue = textValue
        
        let removeMenuItem = RemoveMenuItemViewModel()
        removeMenuItem.title = "Remove"
        removeMenuItem.backColor = "ff0000"
        
        let doneMenuItem = DoneMenuItemViewModel()
        doneMenuItem.title = "Done"
        doneMenuItem.backColor = "000000"
        menuItems?.append(contentsOf: [removeMenuItem, doneMenuItem])
    }
    
}

protocol TodoViewDelegate {
    func onAddTodoItem() -> ()
    func onDeleteItem(todoId: String) -> ()
}

protocol TodoViewPresentable {
    var newTodoValue: String? { get }
}


class TodoViewModel: TodoViewPresentable {
    weak var view: TodoView?
    var newTodoValue: String?
    var items: [TodoItemPresentable] = []
    
    init(view: TodoView) {
        self.view = view
        let item1 = TodoItemViewModel(id: "1", textValue: "Washing Clothes")
        let item2 = TodoItemViewModel(id: "2", textValue: "Buy Groceries")
        let item3 = TodoItemViewModel(id: "2", textValue: "Wash Car")
        items.append(contentsOf: [item1, item2, item3])
    }
}

extension TodoViewModel: TodoViewDelegate {
    func onAddTodoItem() {
        guard let newValue = newTodoValue else {
            print("New value is empty")
            return
        }
        print("New todo value received in view model: \(newValue)")
        
        let itemIndex = items.count + 1
        
        let newItem = TodoItemViewModel(id: "\(itemIndex)", textValue: newValue)
        self.items.append(newItem)
        
        self.newTodoValue = ""
        
        self.view?.insertTodoItem()
    }
    
    func onDeleteItem(todoId: String) {
        guard let index = self.items.index(where: { $0.id! == todoId }) else {
            print("item for the index does not exist")
            return
        }
        self.items.remove(at: index)
        
        self.view?.removeTodoItem(at: index)
    }
}

extension TodoItemViewModel: TodoItemViewDelegate {
    func onItemSelected() {
        print("Did select row at received for item with id = \(id!)")
    }
}
