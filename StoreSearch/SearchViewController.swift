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
    
    var hasSearched = false
    
    var searchResults = [SearchResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.contentInset = UIEdgeInsets(top: 45, left: 0, bottom: 0, right: 0)
    }


}

// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchResults = []
        if ( searchBar.text != "j") {
        for i in stride(from: 0, through: 2, by: 1) {
            let searchResult = SearchResult()
            searchResult.name = String(format: "Faake Result %d for '%@'", i, searchBar.text!)
            searchResult.artistName = searchBar.text!
            searchResults.append(searchResult)
        }
        }
        hasSearched = true
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasSearched && searchResults.count == 0 {
            return 1
        }
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "SearchResultCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }
        if searchResults.count == 0 {
            cell?.textLabel?.text = "(Nothing Found)"
            cell?.detailTextLabel?.text = ""
        } else {
            let searchResult = searchResults[indexPath.row]
            cell?.textLabel!.text = searchResult.name
            cell?.detailTextLabel?.text = searchResult.artistName
           
        }
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 {
            return nil
        }
        return indexPath
    }
    
}
