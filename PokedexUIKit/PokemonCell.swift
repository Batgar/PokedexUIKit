//
//  PokemonCell.swift
//  PokedexUIKit
//
//  Created by Dan Edgar on 10/20/21.
//

import UIKit

class PokemonCell: UICollectionViewCell {
    static let reuseIdentifier = "PokemonCell"
    
    lazy var pokemonView: PokemonView = {
        let pokemonView = PokemonView()
        pokemonView.translatesAutoresizingMaskIntoConstraints = false
        return pokemonView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(pokemonView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            pokemonView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pokemonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pokemonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            pokemonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    var onReuse: () -> Void = {}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        pokemonView.imageView.image = nil
    }
}
