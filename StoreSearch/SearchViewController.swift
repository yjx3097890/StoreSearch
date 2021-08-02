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
    
        
        searchBar.becomeFirstResponder()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        performSearch()
    }
    
    // trait collection for the view controller changes
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.willTransition(to: newCollection, with: coordinator)
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        @unknown default:
            break
        }
        
    }
    
    // MARK: - Helper Methods
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store. Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func performSearch() {
        
        search.performSearch(for: searchBar.text!, category: Search.Category(rawValue: segmentedControl.selectedSegmentIndex)!) { success in
            if success {
                self.tableView.reloadData()
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
            }, completion: {_ in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.landscapeVC = nil
            })
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "ShowDetail" {
            let controller = segue.destination as! DetailViewController
            let result = search.searchResults[(sender as! IndexPath).row]
            controller.result = result
        }
    }
  
}

// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        performSearch()
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        // 和状态栏成为一体
        return .topAttached
    }
}

// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (search.isLoading || search.hasSearched) && search.searchResults.count == 0 {
            return 1
        }
        return search.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if search.isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingViewCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if search.searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = search.searchResults[indexPath.row]
            cell.configure(for: searchResult)
           return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if search.searchResults.count == 0 || search.isLoading {
            return nil
        }
        return indexPath
    }
    
}
