//
//  ViewController.swift
//  MVVMTableView
//
//  Created by 原野誉大 on 2018/05/18.
//  Copyright © 2018年 原野誉大. All rights reserved.
//

import UIKit

protocol TodoView: class {
    func insertTodoItem() -> ()
    func removeTodoItem(at index: Int) -> ()
    func updateTodoItem(at index: Int) -> ()
    func reloadItems() -> Void
}

class ViewController: UIViewController {
    
    @IBOutlet weak var textFieldNewItem: UITextField!
    @IBOutlet weak var tableViewItems: UITableView!
    
    var viewModel: TodoViewModel?
    
    var identifier = "Item"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableViewItems.register(UINib(nibName: String(describing: TodoItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: identifier)
        
        viewModel = TodoViewModel(view: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onAddItem(_ sender: UIButton) {
        guard let newTodoValue = textFieldNewItem.text, !newTodoValue.isEmpty else {
            print("No value enterd")
            return
        }
        viewModel?.newTodoValue = newTodoValue
        DispatchQueue.global(qos: .background).async {
            self.viewModel?.onAddTodoItem()
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let casted = cell as? TodoItemTableViewCell, let vm = self.viewModel {
            casted.configure(with: vm.items[indexPath.row])
        }
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemViewModel = viewModel?.items[indexPath.row]
        (itemViewModel as? TodoItemViewDelegate)?.onItemSelected()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var menuActions: [UIContextualAction] = []
        
        let itemViewModel = viewModel?.items[indexPath.row]
        
        _ = itemViewModel?.menuItems?.map( { item in
            let menuAction = UIContextualAction(style: .normal, title: item.title!) { (action, sourceView, success: (Bool) -> (Void)) in

                if let delegate = item as? TodoMenuItemViewDelegate {
                    DispatchQueue.global(qos: .background).async {
                            delegate.onMenuItemSelected()
                    }
                    
                }
                
                success(true)
            }
            
            menuAction.backgroundColor = item.backColor!.hexColor
            menuActions.append(menuAction)
            
        })

        return UISwipeActionsConfiguration(actions: menuActions)
    }
}

extension ViewController: TodoView {
    func insertTodoItem() {
        guard let items = viewModel?.items else {
            print("Items object is empty")
            return
        }
        DispatchQueue.main.async(execute: { () -> Void in
            self.textFieldNewItem.text = self.viewModel?.newTodoValue
            self.tableViewItems.beginUpdates()
            self.tableViewItems.insertRows(at: [IndexPath(row: items.count - 1, section: 0)], with: .automatic)
            self.tableViewItems.endUpdates()
        })
    }
    
    func removeTodoItem(at index: Int) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableViewItems.beginUpdates()
            self.tableViewItems.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.tableViewItems.endUpdates()
        })
    }
    
    func updateTodoItem(at index: Int) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableViewItems.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        })
    }
    
    func reloadItems() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableViewItems.reloadData()
        })
        
    }
}


