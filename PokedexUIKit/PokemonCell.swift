//
//  PokemonCell.swift
//  PokedexUIKit
//
//  Created by Dan Edgar on 10/20/21.
//

import UIKit

class PokemonCell: UICollectionViewCell {
    static let reuseIdentifier = "PokemonCell"
    
    let pokedexNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.numberOfLines = 1
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.numberOfLines = 1
        return label
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let type1ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let type2ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var typeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            type1ImageView,
            type2ImageView,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
        return stackView
    }()
    
    private lazy var pokemonIdentifierStackView: UIStackView = {
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        let stackView = UIStackView(arrangedSubviews: [
            pokedexNumberLabel,
            nameLabel,
            spacerView,
        ])
        stackView.spacing = 16
        return stackView
    }()
    
    lazy var stackBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10.0
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            pokemonIdentifierStackView,
            imageView,
        ])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        stackView.addSubview(typeStackView)
        stackView.insertSubview(stackBackgroundView, at: 0)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            imageView.widthAnchor.constraint(equalToConstant: 256),
            imageView.heightAnchor.constraint(equalToConstant: 256),
            
            typeStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            typeStackView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            
            type1ImageView.widthAnchor.constraint(equalToConstant: 48),
            type1ImageView.heightAnchor.constraint(equalToConstant: 48),
            
            type2ImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 48),
            type2ImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 48),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            stackBackgroundView.topAnchor.constraint(equalTo: stackView.topAnchor),
            stackBackgroundView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            stackBackgroundView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            stackBackgroundView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    var onReuse: () -> Void = {}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        imageView.image = nil
    }
}
