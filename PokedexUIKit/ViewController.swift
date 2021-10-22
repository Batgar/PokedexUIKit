//
//  ViewController.swift
//  PokedexUIKit
//
//  Created by Dan Edgar on 10/20/21.
//

import Combine
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
            Pokemon.PokemonType.displayableTypes.compactMap { pokemonType in
                guard
                    let title = pokemonType.title,
                    pokemonType.isDisplayable
                else { return nil }
                return .normal(pokemonType: pokemonType)
            }
        ].flatMap { $0 }
        
        let segmentedControl = UISegmentedControl(
            frame: .zero,
            actions: segmentActions.compactMap { segmentAction in
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
                    guard
                        let title = pokemonType.title
                    else { return nil }
                    
                    return UIAction(title: title) { [weak self] _ in
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
            Pokemon.PokemonType.displayableTypes.indices.contains(pokemonTypeIndex)
        else { return }
        
        let nextType = Pokemon.PokemonType.displayableTypes[pokemonTypeIndex]
        
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
        collectionView.register(PokemonCell.self, forCellWithReuseIdentifier: PokemonCell.reuseIdentifier)
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
                receiveCompletion: { _ in },
                receiveValue: { [weak self] pokemon in
                    self?.pokemonToShow = pokemon
                }
            ).store(in: &cancellables)
    }

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
        
        if let imageURL = pokemon.imageURL {
            let task = URLSession.shared.dataTask(with: imageURL) { data, _ , _ in
                guard
                    let data = data
                else {
                    // Load a placeholder image into the imageView
                    return
                }
                
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: data)
                }
            }
            
            task.resume()
            
            cell.onReuse = {
                task.cancel()
            }
        }
        
        return cell
    }

}

private extension Pokemon.PokemonType {
    var title: String? {
        switch self {
        case .unknown:
            return nil
        case .notApplicable:
            return nil
        default:
            return rawValue.capitalized
        }
    }
    
    var isDisplayable: Bool {
        switch self {
        case .unknown:
            return false
        case .notApplicable:
            return false
        default:
            return true
        }
    }
    
    static var displayableTypes: [Pokemon.PokemonType] {
        Pokemon.PokemonType.allCases.compactMap { pokemonType in
            pokemonType.isDisplayable ? pokemonType : nil
        }
    }
}

