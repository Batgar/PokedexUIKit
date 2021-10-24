//
//  AbilitiesCellProvider.swift
//  PokedexUIKit
//
//  Created by Dan Edgar on 10/24/21.
//

import UIKit

struct AbilitiesSection: Hashable {
    let index: Int
}

protocol AbilitiesCellProvider {
    var allAbilities: [Ability] { get }
    var dataSource: UITableViewDiffableDataSource<AbilitiesSection, Ability> { get }
}

extension AbilitiesCellProvider {
    func cellProvider(
        _ tableView: UITableView,
        _ indexPath: IndexPath,
        _ itemIdentifier: Ability
    ) -> UITableViewCell? {
        guard
            allAbilities.indices.contains(indexPath.item),
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AbilityTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? AbilityTableViewCell
        else { return nil }
        
        let ability = allAbilities[indexPath.item]
        cell.nameLabel.text = "\(ability.ability) - \(ability.pokemon.count)"
        
        let uniqueTypes = Set<Pokemon.PokemonType>(ability.pokemon.map { $0.type1 })
        
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        let arrangedSubviews = cell.typeStackView.arrangedSubviews
        
        arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        cell.typeStackView.addArrangedSubview(spacerView)
        
        Array(uniqueTypes)
            .sorted(by: { $0.rawValue < $1.rawValue})
            .forEach { pokemonType in
                let imageView = UIImageView(image: pokemonType.smallestImage)
                imageView.contentMode = .scaleAspectFit
                cell.typeStackView.addArrangedSubview(
                    imageView
                )
            }
        
        return cell
    }
    
    func refresh() {
        let sections = [AbilitiesSection(index: 1)]
        
        var snapshot = NSDiffableDataSourceSnapshot<AbilitiesSection, Ability>()
        snapshot.appendSections(sections)
        
        sections.forEach { section in
            snapshot.appendItems(allAbilities, toSection: section)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
