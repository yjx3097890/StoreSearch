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
    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
        }
    }

    var searchResults = [SearchResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 45, left: 0, bottom: 0, right: 0)
        
        let cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        let nothingCellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(nothingCellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Helper Methods
    func iTurnsURL(searchText: String) -> URL {
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", encodedText)
        let url = URL(string: urlString)
        return url!
    }

    func performStoreRequest(with url: URL) -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("Download Error: '\(error.localizedDescription)'")
        }
        return nil
    }

}

// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text!.isEmpty {
            return
        }
        
        searchResults = []
        hasSearched = true
        searchBar.resignFirstResponder()
        
        let url = iTurnsURL(searchText: searchBar.text!)
        print("URL: '\(url)'")
        if let jsonString = performStoreRequest(with: url) {
            print("Received JSON string '\(jsonString)'")
        }
        
        
        tableView.reloadData()
        
       
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        // 和状态栏成为一体
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
        
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLable.text = searchResult.name
            cell.artistNameLable.text = searchResult.artistName
           return cell
        }
        
        
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
