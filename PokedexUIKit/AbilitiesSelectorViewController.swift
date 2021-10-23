/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The application's primary table view controller showing a list of products.
*/

import UIKit

class AbilitiesSelectorViewController: UIViewController {
    private lazy var dataSource: UITableViewDiffableDataSource<Section, Ability> = {
        UITableViewDiffableDataSource<Section, Ability>(
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
        return tableView
    }()
    
    // MARK: - Constants
    
    /// State restoration values.
    private enum RestorationKeys: String {
        case searchControllerIsActive
        case searchBarText
        case searchBarIsFirstResponder
        case searchBarToken
    }
    
    // MARK: - Properties
    
    /// Search controller to help us with filtering.
    var searchController: UISearchController!
    
    // MARK: - View Life Cycle
    
    private let allAbilities: [Ability]
    
    init(
        allAbilities: [Ability]
    ) {
        self.allAbilities = allAbilities
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
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction() { [weak self] _ in
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction() { [weak self] _ in
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        )
        
        refresh()
    
        //setupDataModel()
        
        //resultsTableController = ResultsTableController()
        //resultsTableController.suggestedSearchDelegate = self // So we can be notified when a suggested search token is selected.
        
        searchController = UISearchController(searchResultsController: UITableViewController())
        //searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.searchTextField.placeholder = NSLocalizedString("Enter a search term", comment: "")
        searchController.searchBar.returnKeyType = .done

        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController
            
        // Make the search bar always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
     
        // Monitor when the search controller is presented and dismissed.
        searchController.delegate = self

        // Monitor when the search button is tapped, and start/end editing.
        searchController.searchBar.delegate = self
        
        /** Specify that this view controller determines how the search controller is presented.
            The search controller should be presented modally and match the physical size of this view controller.
        */
        definesPresentationContext = true
    }
    
    private struct Section: Hashable {
        let index: Int
    }
    
    private func refresh() {
        let sections = [Section(index: 1)]
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Ability>()
        snapshot.appendSections(sections)
        
        sections.forEach { section in
            snapshot.appendItems(allAbilities, toSection: section)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        userActivity = self.view.window?.windowScene?.userActivity
        if userActivity != nil {
            // Restore the active state.
            searchController.isActive = userActivity!.userInfo?[RestorationKeys.searchControllerIsActive.rawValue] as? Bool ?? false
         
            // Restore the first responder status.
            if let wasFirstResponder = userActivity!.userInfo?[RestorationKeys.searchBarIsFirstResponder.rawValue] as? Bool {
                if wasFirstResponder {
                    searchController.searchBar.becomeFirstResponder()
                }
            }

            // Restore the text in the search field.
            if let searchBarText = userActivity!.userInfo?[RestorationKeys.searchBarText.rawValue] as? String {
                searchController.searchBar.text = searchBarText
            }
        
            if let token = userActivity!.userInfo?[RestorationKeys.searchBarToken.rawValue] as? NSNumber {
                //searchController.searchBar.searchTextField.tokens = [ResultsTableController.searchToken(tokenValue: token.intValue)]
            }
            
            //resultsTableController.showSuggestedSearches = false
        } else {
            // No current acivity, so create one.
            //userActivity = NSUserActivity(activityType: MainTableViewController.viewControllerActivityType())
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // No longer interested in the current activity.
        view.window?.windowScene?.userActivity = nil
    }
    
    private func cellProvider(
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
                let imageView = UIImageView(image: pokemonType.smallerImage)
                imageView.contentMode = .scaleAspectFit
                cell.typeStackView.addArrangedSubview(
                    imageView
                )
            }
        
        return cell
    }

}

// MARK: - UISearchBarDelegate

extension AbilitiesSelectorViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        /*if searchBar.text!.isEmpty {
            // Text is empty, show suggested searches again.
            setToSuggestedSearches()
        } else {
            resultsTableController.showSuggestedSearches = false
         }*/
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // User tapped the Done button in the keyboard.
        searchController.dismiss(animated: true, completion: nil)
        searchBar.text = ""
    }

}

// MARK: - UISearchControllerDelegate

// Use these delegate functions for additional control over the search controller.

extension AbilitiesSelectorViewController: UISearchControllerDelegate {
    
    // We are being asked to present the search controller, so from the start - show suggested searches.
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
        //setToSuggestedSearches()
    }
}

// MARK: - State Restoration

extension AbilitiesSelectorViewController {
    
    /** Returns the activity object you can use to restore the previous contents of your scene's interface.
        Before disconnecting a scene, the system asks your delegate for an NSUserActivity object containing state information for that scene.
        If you provide that object, the system puts a copy of it in this property.
        Use the information in the user activity object to restore the scene to its previous state.
    */
    override func updateUserActivityState(_ activity: NSUserActivity) {

        super.updateUserActivityState(activity)

        // Update the user activity with the state of the search controller.
        activity.userInfo = [RestorationKeys.searchControllerIsActive.rawValue: searchController.isActive,
                             RestorationKeys.searchBarIsFirstResponder.rawValue: searchController.searchBar.isFirstResponder,
                             RestorationKeys.searchBarText.rawValue: searchController.searchBar.text!]
        
        // Add the search token if it exists in the search field.
        if !searchController.searchBar.searchTextField.tokens.isEmpty {
            let searchToken = searchController.searchBar.searchTextField.tokens[0]
            if let searchTokenRep = searchToken.representedObject as? NSNumber {
                activity.addUserInfoEntries(from: [RestorationKeys.searchBarToken.rawValue: searchTokenRep])
            }
        }
    }

    /** Restores the state needed to continue the given user activity.
        Subclasses override this method to restore the responder’s state with the given user activity.
        The override should use the state data contained in the userInfo dictionary of the given user activity to restore the object.
     */
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        super.restoreUserActivityState(activity)
    }

}

extension AbilitiesSelectorViewController: UICollectionViewDelegate {}

extension AbilitiesSelectorViewController: UICollectionViewDelegateFlowLayout {}

// MARK: - Table View

/*extension UITableViewController {
    
    static let productCellIdentifier = "cellID"
    
    // Used by both MainTableViewController and ResultsTableController to define its table cells.
    func configureCell(_ cell: UITableViewCell, forProduct product: Product) {
        let textTitle = NSMutableAttributedString(string: product.title)
        let textColor = ResultsTableController.suggestedColor(fromIndex: product.color)
        
        textTitle.addAttribute(NSAttributedString.Key.foregroundColor,
                               value: textColor,
                               range: NSRange(location: 0, length: textTitle.length))
        cell.textLabel?.attributedText = textTitle
        
        // Build the price and year as the detail right string.
        let priceString = product.formattedPrice()
        let yearString = product.formattedDate()
        cell.detailTextLabel?.text = "\(priceString!) | \(yearString!)"
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = nil
    }
    
}*/
