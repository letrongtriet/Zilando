//
//  FilterViewController.swift
//  Zilando
//
//  Created by Le, Triet on 30.12.2020.
//

import Combine
import SnapKit
import UIKit

class FilterViewController: UIViewController {

    // MARK: - Observable
    var filterItemCallback = PassthroughSubject<String?, Never>()

    // MARK: - Init
    init(categories: [String], currentCategory: String?) {
        self.categories = categories
        self.currentCategory = currentCategory
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private properties
    private var categories: [String]
    private var currentCategory: String?

    // MARK: - UI Properties
    lazy var tableView: UITableView = {
        let tableView = UITableView()

        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        tableView.layer.cornerRadius = 8

        tableView.register(FilterItemTableViewCell.self, forCellReuseIdentifier: "FilterItemTableViewCell")

        tableView.rowHeight = 40

        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }()

    private lazy var backgroundButton: UIButton = {
        let button = UIButton()
        button.setTitle(nil, for: .normal)
        button.setImage(nil, for: .normal)
        button.addTarget(self, action: #selector(handleBackgroundTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.addSubview(backgroundButton)
        view.addSubview(tableView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)

        setConstraints()
    }

    private func setConstraints() {
        backgroundButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(CGFloat(40 * categories.count))
        }
    }

    @objc private func handleBackgroundTapped() {
        dismiss(animated: true, completion: nil)
    }

}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterItemTableViewCell", for: indexPath) as! FilterItemTableViewCell
        cell.item = FilterItemTableViewCell.UIModel(item: categories[indexPath.row], isChosen: categories[indexPath.row] == currentCategory)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        currentCategory = currentCategory == category ? nil : category

        dismiss(animated: true, completion: { [weak self] in
            self?.filterItemCallback.send(self?.currentCategory)
        })
    }
}
