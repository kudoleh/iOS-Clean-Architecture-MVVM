//
//  MoviesListItemCell.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation
import UIKit

final class MoviesListItemCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: MoviesListItemCell.self)
    static let height = CGFloat(130)
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var overviewLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    
    private var viewModel: MoviesListItemViewModel! { didSet { unbind(from: oldValue) } }
    
    func fill(with viewModel: MoviesListItemViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        dateLabel.text = "\(NSLocalizedString("Release Date", comment: "")): \(viewModel.releaseDate)"
        overviewLabel.text = viewModel.overview
        viewModel.updatePosterImage(width: Int(posterImageView.frame.size.width * UIScreen.main.scale))
        
        bind(to: viewModel)
    }
    
    func bind(to viewModel: MoviesListItemViewModel) {
        viewModel.posterImage.observe(on: self) { [weak self] (data: Data?) in
            self?.posterImageView.image = data.flatMap { UIImage(data: $0) }
        }
    }
    
    private func unbind(from item: MoviesListItemViewModel?) {
        item?.posterImage.remove(observer: self)
    }
}
