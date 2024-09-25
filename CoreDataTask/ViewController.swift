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
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupConstraints()
        fetchToDoItems()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    var toDoItems: [ListEntity] = []
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
        let secondVC = SecondViewController()
        secondVC.delegate = self
        navigationController?.pushViewController(secondVC, animated: true)
    }
    func fetchToDoItems() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()

        do {
            toDoItems = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
    func updateToDoItem(_ item: ListEntity) {
        if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
            toDoItems[index] = item
            tableView.reloadData()
        }
    }
    func deleteToDoItem(_ item: ListEntity) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.delete(item)
        do {
            try context.save()
            if let index = toDoItems.firstIndex(of: item) {
                toDoItems.remove(at: index)
                tableView.reloadData()
            }
        } catch {
            print("Failed to delete item: \(error)")
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
        return toDoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        let item = toDoItems[indexPath.row]
        cell.configure(with: item)
        
        return cell
    }
    func didSaveItem(_ item: ListEntity) {
        toDoItems.append(item)
        tableView.reloadData()
    }
    func didUpdateItem(_ item: ListEntity) {
        updateToDoItem(item)
    }
    func didDeleteItem(_ item: ListEntity) {
        deleteToDoItem(item)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = toDoItems[indexPath.row]
        let secondVC = SecondViewController()
        secondVC.saveButton.setTitle("Update", for: .normal)
        secondVC.delegate = self
        secondVC.currentItem = selectedItem
        secondVC.itemToEdit = selectedItem
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(secondVC, animated: true)
    }
    
}

