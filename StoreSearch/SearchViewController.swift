//
//  ViewController.swift
//  StoreSearch
//
//  Created by yan jixian on 2021/7/19.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    weak var detailVCForSplit: DetailViewController?
    var landscapeVC: LandscapeViewController?
    private let search = Search()
    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingViewCell = "LoadingViewCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 51 + 44, left: 0, bottom: 0, right: 0)
      
        let cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        let nothingCellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(nothingCellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        let loadingCellNib = UINib(nibName: TableView.CellIdentifiers.loadingViewCell, bundle: nil)
        tableView.register(loadingCellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingViewCell)
    
        if UIDevice.current.userInterfaceIdiom != .pad {
            searchBar.becomeFirstResponder()
        }
        
        title = NSLocalizedString("Search", comment: "split view primary button")
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      if UIDevice.current.userInterfaceIdiom == .phone {
        navigationController?.navigationBar.isHidden = true
      }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        performSearch()
    }
    
    // trait collection for the view controller changes
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.willTransition(to: newCollection, with: coordinator)
        switch newCollection.verticalSizeClass {
        case .compact:
            if newCollection.horizontalSizeClass == .compact {
                showLandscape(with: coordinator)
            }
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        @unknown default:
            break
        }
        
    }
    
    // MARK: - Helper Methods
    
    func showNetworkError() {
        let alert = UIAlertController(title: NSLocalizedString("Whoops...", comment: "Error alert: title"),
                                      message: NSLocalizedString("There was an error reading from the iTunes Store. Please try again.", comment: "Error alert: message"), preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: "ok button"), style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func performSearch() {
        
        search.performSearch(for: searchBar.text!, category: Search.Category(rawValue: segmentedControl.selectedSegmentIndex)!) { success in
            if success {
                self.tableView.reloadData()
                self.landscapeVC?.searchResultsReceived()
            } else {
                self.showNetworkError()
            }
        }
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
        
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeVC == nil else {
            return
        }
        
        
        landscapeVC = storyboard?.instantiateViewController(identifier: "LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeVC {
            // You have to be sure to set searchResults before you access the view property which will trigger calling viewDidLoad()
            
            controller.search = search
            
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            // view controller containment
            view.addSubview(controller.view)
            addChild(controller)
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentationController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { _ in
                controller.didMove(toParent: self)
            })
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParent: nil)
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 0
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: {_ in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.landscapeVC = nil
            })
        }
    }
    
    private func hidePrimaryPane() {
        UIView.animate(withDuration: 0.25, animations: {
            self.splitViewController?.preferredDisplayMode = .secondaryOnly
        }) { _ in
            // Otherwise, the primary pane stays hidden even in landscape!
            self.splitViewController?.preferredDisplayMode = .automatic
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "ShowDetail" {
            if case let .results(results)  = search.state {
                let controller = segue.destination as! DetailViewController
                let result = results[(sender as! IndexPath).row]
                controller.result = result
                UIView.animate(withDuration: 0.3, animations: {
                    controller.isPopUp = true
                })
            }
            
        }
    }
  
}

// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        performSearch()
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        // ????????????????????????
        return .topAttached
    }
}

// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
            case .notSearchYet:
                return 0
            case .loading, .noResults:
                return 1
            case .results(let results):
                return results.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch search.state {
            case .loading:
                let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingViewCell, for: indexPath)
                let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                spinner.startAnimating()
                return cell
            case .noResults:
                return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
            case .results(let results):
                let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
                let searchResult = results[indexPath.row]
                cell.configure(for: searchResult)
               return cell
            case .notSearchYet:
                fatalError("Should never get here")
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        
        if view.window!.rootViewController?.traitCollection.horizontalSizeClass == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        } else {
            if case let .results(results) = search.state {
                detailVCForSplit?.result = results[indexPath.row]
            }
            if splitViewController!.displayMode != .oneBesideSecondary {
                hidePrimaryPane()
            }
        }
        
      
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
       
        switch search.state {
        case .loading, .noResults, .notSearchYet :
            return nil
        case .results:
            return indexPath
        }
        
    }
    
}
