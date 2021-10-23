//
//  ViewController.swift
//  PokedexUIKit
//
//  Created by Dan Edgar on 10/20/21.
//

import Combine
import Kingfisher
import SwiftUI
import UIKit

class ViewController: UIViewController {
    
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            segmentedControl,
            collectionView,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        enum SegmentAction {
            case normal(pokemonType: Pokemon.PokemonType)
            case all
        }
        
        let segmentActions: [SegmentAction] = [
            [.all],
            Pokemon.PokemonType.allCases.map {
                .normal(pokemonType: $0)
            }
        ].flatMap { $0 }
        
        let segmentedControl = UISegmentedControl(
            frame: .zero,
            actions: segmentActions.map { segmentAction in
                switch segmentAction {
                case .all:
                    return UIAction(title: "All") { [weak self] _ in
                        guard let self = self else { return }
                        Pokemon.decodeAllPokemon()
                            .receive(on: DispatchQueue.main)
                            .sink(
                                receiveCompletion: { _ in },
                                receiveValue: { [weak self] pokemon in
                                    self?.pokemonToShow = pokemon
                                }
                            ).store(in: &self.cancellables)
                    }
                case .normal(let pokemonType):
                   return UIAction(title: pokemonType.title) { [weak self] _ in
                        guard let self = self else { return }
                        Pokemon.pokemonOfType(type: pokemonType)
                            .receive(on: DispatchQueue.main)
                            .sink(
                                receiveCompletion: { _ in },
                                receiveValue: { [weak self] pokemon in
                                    self?.pokemonToShow = pokemon
                                }
                            ).store(in: &self.cancellables)
                    }
                }
            }
        )
        return segmentedControl
    }()
    
    @objc func pokemonTypeValueChanged(_ sender: Any) {
        let pokemonTypeIndex = segmentedControl.selectedSegmentIndex
        
        guard
            Pokemon.PokemonType.allCases.indices.contains(pokemonTypeIndex)
        else { return }
        
        let nextType = Pokemon.PokemonType.allCases[pokemonTypeIndex]
        
        Pokemon.pokemonOfType(type: nextType)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] pokemon in
                    self?.pokemonToShow = pokemon
                }
            ).store(in: &cancellables)
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            PokemonCell.self,
            forCellWithReuseIdentifier: PokemonCell.reuseIdentifier
        )
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Pokemon> = {
        UICollectionViewDiffableDataSource<Section, Pokemon>(
            collectionView: collectionView,
            cellProvider: cellProvider
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                primaryAction: UIAction(
                    title: "Abilities",
                    handler: showAbilitiesSelector
                )
            ),
        ]
        
        view.addSubview(stackView)
        
        collectionView.dataSource = dataSource
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        Pokemon.decodeAllPokemon()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error): print("Error \(error)")
                    case .finished: print("Publisher is finished")
                    }
                },
                receiveValue: { [weak self] pokemon in
                    self?.allPokemon = pokemon
                    self?.pokemonToShow = pokemon
                }
            )
            .store(in: &cancellables)
    }
    
    var allPokemon: [Pokemon] = []

    private struct Section: Hashable {
        let index: Int
    }
    
    private var pokemonToShow: [Pokemon] = [] {
        didSet {
            let sections = [Section(index: 1)]
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, Pokemon>()
            snapshot.appendSections(sections)
            
            sections.forEach { section in
                snapshot.appendItems(pokemonToShow, toSection: section)
            }
            
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func cellProvider(
        _ collectionView: UICollectionView,
        _ indexPath: IndexPath,
        _ itemIdentifier: Pokemon
    ) -> UICollectionViewCell? {
        print("pokemon - \(indexPath.item)")
        guard
            pokemonToShow.indices.contains(indexPath.item),
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PokemonCell.reuseIdentifier,
                for: indexPath
            ) as? PokemonCell
        else { return nil }
        
        let pokemon = pokemonToShow[indexPath.item]
        cell.nameLabel.text = pokemon.name
        cell.type1ImageView.image = pokemon.type1.image
        cell.type2ImageView.image = pokemon.type2?.image
        
        if let imageURL = pokemon.imageURL {
            let task = cell.imageView.kf
                .setImage(
                    with: imageURL,
                    placeholder: UIImage(named: "International_Pokemon_logo")
                )
            
            cell.onReuse = {
                task?.cancel()
            }
        }
        
        return cell
    }

}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            pokemonToShow.indices.contains(indexPath.item)
        else { return }
        
        let selectedPokemon = pokemonToShow[indexPath.item]
        
        navigationController?.pushViewController(
            PokemonDetailViewController(
                allPokemon: allPokemon,
                selectedPokemon: selectedPokemon
            ),
            animated: true
        )
    }
}

extension ViewController {
    func showAbilitiesSelector(_ action: UIAction) {
        guard let sender = action.sender as? UIBarButtonItem else { return }
        
        Pokemon.decodeAllAbilities()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error): print("Error \(error)")
                    case .finished: print("Publisher is finished")
                    }
                },
                receiveValue: { [weak self] allAbilities in
                    let abilitiesSelectorViewController = UINavigationController(
                        rootViewController: AbilitiesSelectorViewController(
                            allAbilities: allAbilities
                        )
                    )
                    abilitiesSelectorViewController.modalPresentationStyle = .popover
                    abilitiesSelectorViewController.popoverPresentationController?.barButtonItem = sender
                    abilitiesSelectorViewController.preferredContentSize = CGSize(width: 550, height: 680)
                    self?.present(abilitiesSelectorViewController, animated: true)
                }
            )
            .store(in: &cancellables)
        
       
    }
}

