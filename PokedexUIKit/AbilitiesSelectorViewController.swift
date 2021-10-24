/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The application's primary table view controller showing a list of products.
*/

import UIKit

class AbilitiesSelectorViewController: UIViewController, AbilitiesCellProvider {
    private var selectedAbilities: [Ability] = []
    private let completion: ([Ability]) -> Void
    
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
        tableView.allowsMultipleSelection = true
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var typeAheadViewController: AbilitiesTypeAheadViewController = {
        let viewController = AbilitiesTypeAheadViewController() { [weak self] selectedAbility in
            self?.addSelectedAbility(selectedAbility)
        }
        return viewController
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
    
    let allAbilities: [Ability]
    
    init(
        allAbilities: [Ability],
        completion: @escaping ([Ability]) -> Void
    ) {
        self.allAbilities = allAbilities
        self.completion = completion
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
                self?.selectedAbilities = []
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        )
        
        refresh()
       
        searchController = UISearchController(
            searchResultsController: typeAheadViewController
        )
        searchController.searchResultsUpdater = self
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
        
        if isBeingDismissed || (navigationController?.isBeingDismissed ?? false) {
            completion(selectedAbilities)
        }
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
    // We are being asked to present the search controller, so from the
    // start - show suggested searches.
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
        setToSuggestedSearches()
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

extension AbilitiesSelectorViewController: UISearchResultsUpdating {
    func setToSuggestedSearches() {
        // Show suggested searches only if we don't have a search token in the search field.
        if searchController.searchBar.searchTextField.tokens.isEmpty {
            //resultsTableController.showSuggestedSearches = true
            
            // We are no longer interested in cell navigating, since we are now showing the suggested searches.
            //resultsTableController.tableView.delegate = resultsTableController
        }
    }
    
    // Called when the search bar's text has changed or when the search bar becomes first responder.
    func updateSearchResults(for searchController: UISearchController) {
        guard
            let userEnteredSearchTerm = searchController.searchBar.text
        else { return }
        
        let strippedString = userEnteredSearchTerm.trimmingCharacters(
            in: CharacterSet.whitespaces
        ).lowercased()
        
        let filteredAbilities = allAbilities.filter {
            $0.ability.lowercased().hasPrefix(strippedString)
        }
        
        // We now have the abilities we want to show in the
        // filtered view, so show them.
        typeAheadViewController.allAbilities = filteredAbilities
    }
}

extension AbilitiesSelectorViewController: UITableViewDelegate {
    func addSelectedAbility(_ selectedAbility: Ability) {
        guard
            !selectedAbilities.contains(where: {
                $0 == selectedAbility
            })
        else { return }
        
        selectedAbilities.append(selectedAbility)
        
        selectedAbilities = selectedAbilities.sorted(by: { $0 < $1 })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            allAbilities.indices.contains(indexPath.item)
        else { return }
        
        let selectedAbility = allAbilities[indexPath.item]
        
        addSelectedAbility(selectedAbility)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard
            allAbilities.indices.contains(indexPath.item)
        else { return }
        
        let selectedAbility = allAbilities[indexPath.item]
        
        guard
            let indexToRemove = selectedAbilities.firstIndex(where: {
                $0 == selectedAbility
            })
        else { return }
        
        selectedAbilities.remove(at: indexToRemove)
        
        selectedAbilities = selectedAbilities.sorted(by: { $0 < $1 })
    }
}

