//
//  MoviesQueriesTableViewController.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import UIKit

final class MoviesQueriesTableViewController: UITableViewController, StoryboardInstantiable {
    
    private var viewModel: MoviesQueryListViewModel!
    
    static func create(with viewModel: MoviesQueryListViewModel) -> MoviesQueriesTableViewController {
        let view = MoviesQueriesTableViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = MoviesQueriesItemCell.height
        tableView.rowHeight = UITableView.automaticDimension
        
        bind(to: viewModel)
    }
    
    private func bind(to viewModel: MoviesQueryListViewModel) {
        viewModel.items.observe(on: self) { [weak self] _ in self?.tableView.reloadData() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MoviesQueriesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoviesQueriesItemCell.reuseIdentifier, for: indexPath) as? MoviesQueriesItemCell else {
            fatalError("Cannot dequeue reusable cell \(MoviesQueriesItemCell.self) with reuseIdentifier: \(MoviesQueriesItemCell.reuseIdentifier)")
        }
        cell.fill(with: viewModel.items.value[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        viewModel.didSelect(item: viewModel.items.value[indexPath.row])
    }
}
