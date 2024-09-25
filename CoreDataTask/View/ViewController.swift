//
//  ViewController.swift
//  CoreDataTask
//
//  Created by Kenan Memmedov on 20.09.24.
//

import UIKit
import SnapKit
import CoreData
class ViewController: UIViewController {
    let toDoLabel: UILabel = {
        let label = UILabel()
        label.text = "Todo List"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18,weight: .semibold)
        label.textColor = .black
        return label
    }()
    let addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .red
        return button
    }()
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.allowsSelection = true
        return tableView
    }()
    var viewModel = ToDoDataViewModel()
    var viewActionModel = ToDoActionViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupConstraints()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        fetchItems()
    }
    func setup(){
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .white
        view.addSubview(toDoLabel)
        view.addSubview(addButton)
        view.addSubview(tableView)
        addButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        let backButton = UIBarButtonItem()
        backButton.title = "Todo List"
        navigationItem.backBarButtonItem = backButton
        navigationItem.backBarButtonItem?.tintColor = .black
        
    }
    @objc func buttonTapped(){
        viewActionModel.navigateToSecondViewController(navigationController: navigationController!)
    }
    func fetchItems() {
        viewModel.fetchToDoItems { result in
                switch result {
                case .success(let items):
                    self.viewModel.toDoItems = items
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Failed to fetch items: \(error)")
                }
            }
    }
    func setupConstraints(){
        toDoLabel.snp.makeConstraints{make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalTo(view.snp.centerX)
        }
        addButton.snp.makeConstraints{make in
            make.centerY.equalTo(toDoLabel.snp.centerY)
            make.right.equalTo(view.snp.right).offset(-16)
        }
        tableView.snp.makeConstraints{make in
            make.top.equalTo(toDoLabel.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
}
extension ViewController:UITableViewDataSource,UITableViewDelegate,SecondViewControllerDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.toDoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        let item = viewModel.toDoItems[indexPath.row]
        cell.configure(with: item)
        
        return cell
    }
    func didSaveItem(_ item: ListEntity) {
        viewModel.toDoItems.append(item)
        tableView.reloadData()
    }
    func didUpdateItem(_ item: ListEntity) {
        viewModel.updateToDoItem(item: item) { success in
            if success {
                self.tableView.reloadData()
            } else {
                print("Failed to update")
            }
        }
    }
    func didDeleteItem(_ item: ListEntity) {
        viewModel.deleteToDoItem(item: item) { success in
            if success {
                if let index = self.viewModel.toDoItems.firstIndex(of: item) {
                    self.viewModel.toDoItems.remove(at: index)
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                self.tableView.reloadData()
            } else {
                print("Failed to delete")
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
                let itemToDelete = self.viewModel.toDoItems[indexPath.row]
                self.viewModel.deleteToDoItem(item: itemToDelete) { success in
                    if success {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    } else {
                        print("Failed to delete")
                    }
                }
                completionHandler(true)
            }
            deleteAction.backgroundColor = .red
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = viewModel.toDoItems[indexPath.row]
        let secondVC = SecondViewController()
        secondVC.saveButton.setTitle("Update", for: .normal)
        secondVC.delegate = self
        secondVC.currentItem = selectedItem
        secondVC.itemToEdit = selectedItem
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(secondVC, animated: true)
    }
    
}

