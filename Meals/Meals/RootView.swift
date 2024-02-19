//
//  RootView.swift
//  Meals
//
//  Created by Dipen Panchasara on 04/02/2024.
//

import SwiftUI

struct RootView: View {
  @ObservedObject var viewModel: RootViewModel
  
  var body: some View {
    NavigationStack(path: viewModel.$router.path) {
      CategoriesView(
        viewModel: CategoriesViewModel(
          useCase: CategoriesUseCase(
            categoryRepository: CategoryRepository(
              networkManager: NetworkManager(
                scheme: viewModel.scheme,
                baseURLString: viewModel.baseURLString,
                session: viewModel.session
              ),
              decoder: ResponseDecoder()
            )
          ),
          router: CategoryRouter(router: viewModel.router)
        )
      )
    }
  }
}

#if DEBUG
struct RootView_Previews: PreviewProvider {
  static let router = Router(path: NavigationPath())
  
  static var previews: some View {
    RootView(
      viewModel: RootViewModel(
        scheme: "https",
        baseURLString: "www.test.com",
        router: router
      )
    )
    .previewDisplayName("RootView")
  }
}
#endif
