//
//  TodoItemTableViewCell.swift
//  MVVMTableView
//
//  Created by 原野誉大 on 2018/05/18.
//  Copyright © 2018年 原野誉大. All rights reserved.
//

import UIKit

class TodoItemTableViewCell: UITableViewCell {

    @IBOutlet weak var txtIndex: UILabel!
    @IBOutlet weak var txtTodoItem: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with viewModel: TodoItemPresentable) -> () {
        txtIndex.text = viewModel.id!
        txtTodoItem.text = viewModel.textValue!
    }
    
}
