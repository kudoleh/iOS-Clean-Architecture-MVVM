//
//  MoviesQueryListView.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
extension MoviesQueryListItemViewModel: Identifiable { }

@available(iOS 13.0, *)
struct MoviesQueryListView: View {
    @ObservedObject var viewModelWrapper: MoviesQueryListViewModelWrapper
    
    var body: some View {
        List(viewModelWrapper.items) { item in
            Button(action: {
                self.viewModelWrapper.viewModel?.didSelect(item: item)
            }) {
                Text(item.query)
            }
        }
        .onAppear {
            self.viewModelWrapper.viewModel?.viewWillAppear()
        }
    }
}

@available(iOS 13.0, *)
final class MoviesQueryListViewModelWrapper: ObservableObject {
    var viewModel: MoviesQueryListViewModel?
    @Published var items: [MoviesQueryListItemViewModel] = []
    
    init(viewModel: MoviesQueryListViewModel?) {
        self.viewModel = viewModel
        viewModel?.items.observe(on: self) { [weak self] values in self?.items = values }
    }
}

#if DEBUG
@available(iOS 13.0, *)
struct MoviesQueryListView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesQueryListView(viewModelWrapper: previewViewModelWrapper)
    }
    
    static var previewViewModelWrapper: MoviesQueryListViewModelWrapper = {
        var viewModel = MoviesQueryListViewModelWrapper(viewModel: nil)
        viewModel.items = [MoviesQueryListItemViewModel(query: "item 1"),
                           MoviesQueryListItemViewModel(query: "item 2")
        ]
        return viewModel
    }()
}
#endif
