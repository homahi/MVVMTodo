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


class TodoViewModel: TodoViewPresentable {
    weak var view: TodoView?
    var newTodoValue: String?
    var items: [TodoItemPresentable] = []
    
    init(view: TodoView) {
        self.view = view
        let item1 = TodoItemViewModel(id: "1", textValue: "Washing Clothes", parentViewModel:self)
        let item2 = TodoItemViewModel(id: "2", textValue: "Buy Groceries", parentViewModel:self)
        let item3 = TodoItemViewModel(id: "3", textValue: "Wash Car", parentViewModel:self)
        items.append(contentsOf: [item1, item2, item3])
    }
}

extension TodoViewModel: TodoViewDelegate {
    func onTodoDoneItem(todoId: String) {
        print("Todo item done with id = \(todoId)")
        guard let index = self.items.index(where: { $0.id! == todoId }) else {
            print("item for the index does not exist")
            return
        }
        
        var todoItem = self.items[index]
        let nextStatus = !(todoItem.isDone)!
        todoItem.isDone = nextStatus
        if var doneMenuItem = todoItem.menuItems?.filter({ (todoMenuItem) -> Bool in
            todoMenuItem is DoneMenuItemViewModel
        }).first {
            doneMenuItem.title = nextStatus ? "Undone" : "Done"
        }
        
        self.items.sort(by: {
            if !($0.isDone!) && !($1.isDone!) {
                return $0.id! < $01.id!
            }
            if $0.isDone! && $1.isDone! {
                return $0.id! < $01.id!
            }
            return !($0.isDone!) && $1.isDone!
        })

        
        self.view?.reloadItems()
    }
    
    func onAddTodoItem() {
        guard let newValue = newTodoValue else {
            print("New value is empty")
            return
        }
        print("New todo value received in view model: \(newValue)")
        
        let itemIndex = items.count + 1
        
        let newItem = TodoItemViewModel(id: "\(itemIndex)", textValue: newValue, parentViewModel: self)
        self.items.append(newItem)
        
        self.newTodoValue = ""
        
        self.view?.insertTodoItem()
    }
    
    func onTodoDeleteItem (todoId: String) {
        guard let index = self.items.index(where: { $0.id! == todoId }) else {
            print("item for the index does not exist")
            return
        }
        self.items.remove(at: index)
        
        self.view?.removeTodoItem(at: index)
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
