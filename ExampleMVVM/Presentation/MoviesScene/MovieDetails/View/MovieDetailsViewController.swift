//
//  MovieDetailsViewController.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 04.08.19.
//  Copyright (c) 2019 All rights reserved.
//

import UIKit

final class MovieDetailsViewController: UIViewController, StoryboardInstantiable {

    @IBOutlet private var posterImageView: UIImageView!
    @IBOutlet private var overviewTextView: UITextView!

    // MARK: - Lifecycle

    private var viewModel: MovieDetailsViewModel!
    
    static func create(with viewModel: MovieDetailsViewModel) -> MovieDetailsViewController {
        let view = MovieDetailsViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: viewModel)
    }

    private func bind(to viewModel: MovieDetailsViewModel) {
        viewModel.posterImage.observe(on: self) { [weak self] in self?.posterImageView.image = $0.flatMap(UIImage.init) }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.updatePosterImage(width: Int(posterImageView.imageSizeAfterAspectFit.scaledSize.width))
    }

    // MARK: - Private

    private func setupViews() {
        title = viewModel.title
        overviewTextView.text = viewModel.overview
        posterImageView.isHidden = viewModel.isPosterImageHidden
        view.accessibilityIdentifier = AccessibilityIdentifier.movieDetailsView
    }
}
