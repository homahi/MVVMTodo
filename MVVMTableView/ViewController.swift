//
//  ViewController.swift
//  MVVMTableView
//
//  Created by 原野誉大 on 2018/05/18.
//  Copyright © 2018年 原野誉大. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol TodoView: class {
}

class ViewController: UIViewController {
    
    @IBOutlet weak var textFieldNewItem: UITextField!
    @IBOutlet weak var tableViewItems: UITableView!
    
    private let disposeBag = DisposeBag()
    var viewModel: TodoViewModel?
    
    var identifier = "Item"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableViewItems.register(UINib(nibName: String(describing: TodoItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: identifier)
        
        viewModel = TodoViewModel()
        
        viewModel?.items.asObservable().bind(to: tableViewItems.rx.items(cellIdentifier: identifier, cellType: TodoItemTableViewCell.self)) { index, item, cell in
            cell.configure(with: item)
        }
        .disposed(by: disposeBag)
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

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemViewModel = viewModel?.items.value[indexPath.row]
        (itemViewModel as? TodoItemViewDelegate)?.onItemSelected()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var menuActions: [UIContextualAction] = []
        
        let itemViewModel = viewModel?.items.value[indexPath.row]
        
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

