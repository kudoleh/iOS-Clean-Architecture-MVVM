//
//  MoviesListItemCell.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import UIKit

final class MoviesListItemCell: UITableViewCell {

    static let reuseIdentifier = String(describing: MoviesListItemCell.self)
    static let height = CGFloat(130)

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var overviewLabel: UILabel!
    @IBOutlet private var posterImageView: UIImageView!

    private var viewModel: MoviesListItemViewModel!
    private var posterImagesRepository: PosterImagesRepository?
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }

    func fill(with viewModel: MoviesListItemViewModel, posterImagesRepository: PosterImagesRepository?) {
        self.viewModel = viewModel
        self.posterImagesRepository = posterImagesRepository

        titleLabel.text = viewModel.title
        dateLabel.text = viewModel.releaseDate
        overviewLabel.text = viewModel.overview
        updatePosterImage(width: Int(posterImageView.frame.size.width * UIScreen.main.scale))
    }

    private func updatePosterImage(width: Int) {
        posterImageView.image = nil
        guard let posterImagePath = viewModel.posterImagePath else { return }

        imageLoadTask = posterImagesRepository?.fetchImage(with: posterImagePath, width: width) { [weak self] result in
            guard self?.viewModel.posterImagePath == posterImagePath else { return }
            switch result {
            case .success(let data):
                self?.posterImageView.image =  UIImage(data: data)
            case .failure: break
            }
            self?.imageLoadTask = nil
        }
    }
}
