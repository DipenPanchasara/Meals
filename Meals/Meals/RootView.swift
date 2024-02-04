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
    NavigationStack(path: $viewModel.path) {
      CategoriesView(
        viewModel: CategoriesViewModel(
          useCase: CategoriesUseCase(
            networkManager: NetworkManager(baseURL: viewModel.baseURL)
          )
        )
      )
    }
  }
}

#if DEBUG
struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(viewModel: RootViewModel())
    .previewDisplayName("RootView")
  }
}
#endif