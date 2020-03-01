//
//  MoviesQueriesItemCell.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import UIKit

final class MoviesQueriesItemCell: UITableViewCell {
    static let height = CGFloat(50)
    static let reuseIdentifier = String(describing: MoviesQueriesItemCell.self)

    @IBOutlet private var titleLabel: UILabel!
    
    func fill(with suggestion: MoviesQueryListItemViewModel) {
        self.titleLabel.text = suggestion.query
    }
}
