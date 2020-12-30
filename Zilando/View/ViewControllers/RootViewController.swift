//
//  ViewController.swift
//  Zilando
//
//  Created by Le, Triet on 30.12.2020
//

import UIKit
import Combine
import SnapKit

class RootViewController: UIViewController {

    // MARK: - Init
    init(viewModel: RootViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private properties
    private let viewModel: RootViewModel
    private var bag = Set<AnyCancellable>()

    private var items = [ZilandoItemTableViewCell.UIModel]()
    private var categories = [String]()
    private var currentCategory: String?
    private var currentErrorMessage = ""

    // MARK: - UI Properties
    lazy var tableView: UITableView = {
        let tableView = UITableView()

        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        tableView.register(ZilandoItemTableViewCell.self, forCellReuseIdentifier: "ZilandoItemTableViewCell")

        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension

        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }()

    private lazy var loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)

        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .white
        loadingIndicator.tintColor = .white
        loadingIndicator.startAnimating()

        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Previous"), for: .normal)
        button.setTitle(nil, for: .normal)
        button.addTarget(self, action: #selector(handleGoBackTapped), for: .touchUpInside)
        button.tintColor = .orange
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()

    private lazy var forwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Next"), for: .normal)
        button.setTitle(nil, for: .normal)
        button.addTarget(self, action: #selector(handleGoForwardTapped), for: .touchUpInside)
        button.tintColor = .orange
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()

    private lazy var divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        return view
    }()

    private lazy var bottonView: UIView = {
        let view = UIView()
        view.backgroundColor = .white

        view.addSubview(backButton)
        view.addSubview(forwardButton)
        view.addSubview(divider)

        backButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(50)
            make.leading.equalToSuperview().offset(20)
        }

        forwardButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(50)
            make.trailing.equalToSuperview().offset(-20)
        }

        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.trailing.leading.equalToSuperview()
            make.top.equalToSuperview()
        }

        return view
    }()

    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        binding()
    }

    // MARK: - Private methods
    private func setupView() {
        view.addSubview(tableView)
        view.addSubview(bottonView)
        view.addSubview(loadingView)

        configNavigationBar()
        setConstraints()
    }

    private func configNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(filterTapped))
    }

    private func updateNavBar() {
        title = currentCategory != nil ? currentCategory : "All Items"
        navigationController?.navigationBar.tintColor = currentCategory != nil ? .orange : .black
    }

    private func updateBottomView() {
        backButton.isHidden = !viewModel.canGoBack
        forwardButton.isHidden = !viewModel.canGoForward
    }

    private func setConstraints() {
        bottonView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }

        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottonView.snp.top)
        }

        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func binding() {
        viewModel
            .$state
            .sink(receiveValue: { [weak self] state in
                self?.handleNewState(state)
            })
            .store(in: &bag)
    }

    private func handleNewState(_ state: State) {
        if case State.fetching = state {
            loadingView.isHidden = false
        } else {
            loadingView.isHidden = true
        }

        switch state {
        case let .fetched(items):
            self.items = items
            tableView.reloadDataAnimated()
            updateBottomView()
        case let .empty(message):
            items = []
            currentErrorMessage = message
            tableView.reloadDataAnimated()
            updateBottomView()
        case let .error(errorMessage):
            items = []
            currentErrorMessage = errorMessage
            tableView.reloadDataAnimated()
            updateBottomView()
        case let .categoryFetched(categories):
            self.categories = categories
            updateNavBar()
        default:
            return
        }
    }

    private func handleFavoriteButtonCallback(item: ZilandoItemTableViewCell.UIModel) {
        item.isFavorite ? viewModel.add(id: item.item.itemID) : viewModel.remove(id: item.item.itemID)
    }

    @objc private func filterTapped() {
        let filterVC = FilterViewController(categories: categories, currentCategory: currentCategory)

        filterVC.filterItemCallback
            .sink(receiveValue: { [weak self] currentCategory in
                self?.currentCategory = currentCategory
                self?.viewModel.handleNewChosenCategory(currentCategory)
                self?.updateNavBar()
            })
            .store(in: &bag)

        present(filterVC, animated: true, completion: nil)
    }

    @objc private func handleGoBackTapped() {
        viewModel.goBack()
    }

    @objc private func handleGoForwardTapped() {
        viewModel.goForward()
    }

}

extension RootViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count == 0 {
            self.tableView.setEmptyMessage(currentErrorMessage)
        } else {
            self.tableView.restore()
        }
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ZilandoItemTableViewCell", for: indexPath) as! ZilandoItemTableViewCell

        cell.item = items[indexPath.row]
        cell.favoriteButtonCallback
            .sink(receiveValue: { [weak self] item in
                self?.handleFavoriteButtonCallback(item: item)
            })
            .store(in: &bag)

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ZilandoItemTableViewCell else { return }
        cell.configUI()
    }
}
