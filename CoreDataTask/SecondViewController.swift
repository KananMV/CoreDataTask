
//  SecondViewController.swift
//  CoreDataTask
//
//  Created by Kenan Memmedov on 20.09.24.
//

import UIKit
import SnapKit
protocol SecondViewControllerDelegate: AnyObject {
    func didSaveItem(_ item: ListEntity)
    func didUpdateItem(_ item: ListEntity)
    func didDeleteItem(_ item: ListEntity)
}

class SecondViewController: UIViewController{
    weak var delegate: SecondViewControllerDelegate?
    var itemToEdit: ListEntity?
    var currentItem: ListEntity?
    
    private let titleLabel:UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14,weight: .medium)
        label.text = "Title"
        return label
        
    }()
    private let titleTextView: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = .systemGray6
        textField.font = .systemFont(ofSize: 20,weight: .semibold)
        textField.layer.cornerRadius = 12
        return textField
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14,weight: .medium)
        label.text = "Description"
        return label
    }()
    public let saveButton:UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 12
        return button
    }()
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .systemGray6
        textView.font = .systemFont(ofSize: 20,weight: .semibold)
        textView.layer.cornerRadius = 12
        return textView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let item = itemToEdit {
            titleTextView.text = item.title
            descriptionTextView.text = item.desc
        }
        setup()
        setupConstraints()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    func setup(){
        view.backgroundColor = .white
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "trash.fill"), style: .plain, target: self, action: #selector(rightButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
        rightButton.tintColor = .red
        view.addSubview(titleLabel)
        view.addSubview(titleTextView)
        view.addSubview(descriptionLabel)
        view.addSubview(saveButton)
        view.addSubview(descriptionTextView)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    @objc func rightButtonTapped() {
        guard let itemToDelete = currentItem else { return }
        delegate?.didDeleteItem(itemToDelete)
        navigationController?.popViewController(animated: true)
    }
    @objc func saveButtonTapped() {
        guard let title = titleTextView.text, !title.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty else {
            return
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let item = itemToEdit {
            item.title = title
            item.desc = description
            item.date = Date()
            
            do {
                try context.save()
                delegate?.didUpdateItem(item)
            } catch {
                print("Failed to save item: \(error)")
            }
        } else {
            let newItem = ListEntity(context: context)
            newItem.id = UUID()
            newItem.title = title
            newItem.desc = description
            newItem.date = Date()
            
            do {
                try context.save()
                delegate?.didSaveItem(newItem)
            } catch {
                print("Failed to save item: \(error)")
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    func setupConstraints(){
        titleLabel.snp.makeConstraints{make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalTo(view.snp.leading).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
        }
        titleTextView.snp.makeConstraints{make in
            make.height.equalTo(100)
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
        }
        descriptionLabel.snp.makeConstraints{make in
            make.top.equalTo(titleTextView.snp.bottom).offset(16)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
        }
        saveButton.snp.makeConstraints{make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            make.height.equalTo(40)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
        }
        descriptionTextView.snp.makeConstraints{make in
            make.top.equalTo(descriptionLabel.snp.bottom)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
            make.bottom.equalTo(saveButton.snp.top).offset(-10)
        }
    }
}
