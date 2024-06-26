//
//  CategoriesViewModel.swift
//  Meals
//
//  Created by Dipen Panchasara on 01/02/2024.
//

import SwiftUI
import Combine

class CategoriesViewModel: ObservableObject {
  struct ViewModel: Equatable {
    var categories: [CategoryModel]
  }

  private let useCase: CategoriesUseCaseProtocol
  private(set) var categoryRouter: CategoryRouterProtocol
  private(set) var categoryViewModelFactory: CategoryViewModelFactoryProtocol
  @Published var loadingState: ViewState<ViewModel> = .idle
  private var subscriptions = Set<AnyCancellable>()
  
  init(
    useCase: CategoriesUseCaseProtocol,
    categoryRouter: CategoryRouterProtocol,
    categoryViewModelFactory: CategoryViewModelFactoryProtocol
  ) {
    self.useCase = useCase
    self.categoryRouter = categoryRouter
    self.categoryViewModelFactory = categoryViewModelFactory
    self.subscribe()
  }

  private func subscribe() {
    useCase.publisher
      .receive(on: DispatchQueue.main)
      .sink { completion in
        print(completion)
        switch completion {
          case .finished:
            print("\(#function) Category stream finished")
          case .failure(let error):
            print("Error: \(error)")
        }
      } receiveValue: { [weak self] result in
        guard let self = self else { return }
        switch result {
          case .success(let categories):
            self.loadingState = .loaded(model: ViewModel(categories: categories))
          case .failure(let error):
            print("Error: \(error)")
            self.loadingState = .failed(model: ErrorModel(message: "Unable to load categories."))
        }
      }
      .store(in: &subscriptions)
  }

  func loadData() {
    guard loadingState.canReload else { return }
    loadingState = .loading(model: ViewModel(categories: .mock))
    useCase.fetchCategories()
  }

  
  @MainActor
  func fetchData() async {
    guard loadingState.canReload else { return }
    loadingState = .loading(model: ViewModel(categories: .mock))

    let result = await self.useCase.fetchCategories()
    switch result {
      case .success(let categories):
        self.loadingState = .loaded(model: .init(categories: categories))
      case .failure:
        self.loadingState = .failed(model: ErrorModel(message: "Unable to load categories."))
    }
  }

  func onRetryTap() async {
    await fetchData()
  }

  @MainActor
  func onSelect(category: CategoryModel) {
    categoryRouter.push(
      destination: .foodItems(categoryName: category.name)
    )
  }
}
