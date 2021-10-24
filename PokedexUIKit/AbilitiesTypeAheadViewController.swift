//
//  AbilitiesTypeAheadViewController.swift
//  PokedexUIKit
//
//  Created by Dan Edgar on 10/24/21.
//

import UIKit

class AbilitiesTypeAheadViewController: UIViewController, AbilitiesCellProvider {
    var allAbilities: [Ability] = [] {
        didSet {
            refresh()
        }
    }
    
    let selectionCompletion: (Ability) -> Void
    
    lazy var dataSource: UITableViewDiffableDataSource<AbilitiesSection, Ability> = {
        UITableViewDiffableDataSource<AbilitiesSection, Ability>(
            tableView: tableView,
            cellProvider: cellProvider
        )
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            AbilityTableViewCell.self,
            forCellReuseIdentifier: AbilityTableViewCell.reuseIdentifier
        )
        tableView.delegate = self
        return tableView
    }()
    
    init(
        selectionCompletion: @escaping (Ability) -> ()
    ) {
        self.selectionCompletion = selectionCompletion
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}

extension AbilitiesTypeAheadViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            allAbilities.indices.contains(indexPath.row)
        else { return }
        
        let selectedAbility = allAbilities[indexPath.row]
        
        selectionCompletion(selectedAbility)
    }
}
