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
    
    private var viewModel: MovieDetailsViewModel!
    
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
        title = viewModel.title
        overviewTextView.text = viewModel.overview
        viewModel.posterImage.observe(on: self) { [weak self] in self?.posterImageView.image = $0.flatMap(UIImage.init) }
        posterImageView.isHidden = viewModel.isPosterImageHidden
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.updatePosterImage(width: Int(posterImageView.imageSizeAfterAspectFit.scaledSize.width))
    }
}
