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
    
    @IBOutlet weak private var posterImageView: UIImageView!
    @IBOutlet weak private var overviewTextView: UITextView!
    
    var viewModel: MovieDetailsViewModel!
    
    final class func create(with viewModel: MovieDetailsViewModel) -> MovieDetailsViewController {
        let view = MovieDetailsViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind(to: viewModel)
        view.accessibilityLabel = NSLocalizedString("Movie details view", comment: "")
    }
    
    func bind(to viewModel: MovieDetailsViewModel) {
        viewModel.title.observe(on: self) { [weak self] title in
            self?.title = title
        }
        viewModel.posterImage.observe(on: self) { [weak self] image in
            self?.posterImageView.image = image.flatMap { UIImage(data: $0) }
        }
        viewModel.overview.observe(on: self) { [weak self] text in
            self?.overviewTextView.setTextWithFadeTransition(text: text, withFadeTransitionDuration: MovieDetailsViewController.fadeTransitionDuration)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.updatePosterImage(width: Int(self.posterImageView.bounds.width))
    }
}

fileprivate extension UITextView {
    
    func setTextWithFadeTransition(text: String, withFadeTransitionDuration fadeTransitionDuration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = fadeTransitionDuration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
        self.text = text
    }
}
