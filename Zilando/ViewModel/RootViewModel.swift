//
//  RootViewModel.swift
//  Zilando
//
//  Created by Le, Triet on 30.12.2020
//

import UIKit
import Foundation
import Combine
import CoreLocation

enum State {
    case starting
    case fetching
    case error(String)
    case fetched([ZilandoItemTableViewCell.UIModel])
    case categoryFetched([String])
    case empty(String)
}

class RootViewModel {
    // MARK: - Observables
    @Published public private(set) var state: State

    public var canGoBack: Bool {
        currentZilandoItems?.prev != nil
    }

    public var canGoForward: Bool {
        currentZilandoItems?.next != nil
    }

    // MARK: - Public properties
    private var bag = Set<AnyCancellable>()
    private var timer: Timer?

    // MARK: - Private properties
    private let networkManager: NetworkManager
    private let userDefaultsManager: UserDefaultsManager

    private var currentBaseUrl = AppPantry.baseUrlString
    private var categoryBaseUrl = AppPantry.categoryBaseUrlString

    private var favoriteIds: [String] {
        userDefaultsManager.getFavoriteIds()
    }

    private var currentZilandoItems: ZilandoItem?
    private var currentCategories = [String]()
    private var currentCategory: String?

    // MARK: - Init
    init(networkManager: NetworkManager, userDefaultsManager: UserDefaultsManager) {
        self.state = .starting
        self.networkManager = networkManager
        self.userDefaultsManager = userDefaultsManager
        fetchItems()
        fetchCategory()
    }

    // MARK: - Public methods
    func remove(id: String) {
        userDefaultsManager.remove(id: id)
        transformData(currentZilandoItems?.items ?? [])
    }

    func add(id: String) {
        userDefaultsManager.add(id: id)
        transformData(currentZilandoItems?.items ?? [])
    }

    func handleNewChosenCategory(_ chosenCategory: String?) {
        currentCategory = chosenCategory
        transformData(currentZilandoItems?.items ?? [])
    }

    func goForward() {
        guard let currentItem = currentZilandoItems else { return }
        currentBaseUrl = currentItem.next!
        fetchItems()
    }

    func goBack() {
        guard let currentItem = currentZilandoItems else { return }
        currentBaseUrl = currentItem.prev!
        fetchItems()
    }

    // MARK: - Private methods
    private func fetchCategory() {
        networkManager
            .getCategory(with: categoryBaseUrl)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.handleError(error)
                default:
                    break
                }
            } receiveValue: { [weak self] response in
                self?.handleCategoryResponse(response)
            }
            .store(in: &bag)
    }

    private func fetchItems() {
        state = .fetching

        networkManager
            .getItems(with: currentBaseUrl)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.handleError(error)
                default:
                    break
                }
            } receiveValue: { [weak self] response in
                self?.handleResponse(response)
            }
            .store(in: &bag)
    }

    private func handleCategoryResponse(_ category: Category?) {
        guard let category = category else { return }
        currentCategories = category.categories
        state = .categoryFetched(currentCategories)
    }

    private func handleResponse(_ response: ZilandoItem?) {
        guard let response = response else {
            state = .empty("Oops! Something went wrong!")
            return
        }

        currentZilandoItems = response
        transformData(response.items)
    }

    private func transformData(_ items: [Item]) {
        var toRet = [ZilandoItemTableViewCell.UIModel]()
        items.forEach { item in
            toRet.append(
                ZilandoItemTableViewCell.UIModel(item: item,
                               isFavorite: favoriteIds.contains(item.itemID)))
        }

        if let currentCategory = currentCategory {
            toRet = toRet.filter({ $0.item.category == currentCategory })
        }

        state = .fetched(toRet)
    }

    private func handleError(_ error: Error) {
        state = .error(error.localizedDescription)
    }
}
