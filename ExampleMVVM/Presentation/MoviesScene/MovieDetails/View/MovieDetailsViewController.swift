//
//  MovieDetailsViewController.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 04.08.19.
//  Copyright (c) 2019 All rights reserved.
//

import UIKit

final class MovieDetailsViewController: UIViewController, StoryboardInstantiable {
    
    private static let fadeTransitionDuration: CFTimeInterval = 0.4
    
    @IBOutlet private var posterImageView: UIImageView!
    @IBOutlet private var overviewTextView: UITextView!
    
    var viewModel: MovieDetailsViewModel!
    
    static func create(with viewModel: MovieDetailsViewModel) -> MovieDetailsViewController {
        let view = MovieDetailsViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind(to: viewModel)
        view.accessibilityIdentifier = AccessibilityIdentifier.movieDetailsView
    }
    
    private func bind(to viewModel: MovieDetailsViewModel) {
        viewModel.title.observe(on: self) { [weak self] in self?.title = $0 }
        viewModel.posterImage.observe(on: self) { [weak self] in self?.posterImageView.image = $0.flatMap { UIImage(data: $0) } }
        viewModel.overview.observe(on: self) { [weak self] in self?.overviewTextView.text = $0 }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.updatePosterImage(width: Int(self.posterImageView.bounds.width))
    }
}
