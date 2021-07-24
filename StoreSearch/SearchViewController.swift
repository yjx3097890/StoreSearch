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
    
    
    var hasSearched = false
    var isLoading = false
    var dataTask: URLSessionDataTask?
    
    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingViewCell = "LoadingViewCell"
        }
    }

    var searchResults = [SearchResult]()
    
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
    
    // MARK: - Helper Methods
    func iTurnsURL(searchText: String, category: Int) -> URL {
        let kind: String
        switch category {
        case 1:
            kind = "musicTrack"
        case 2:
            kind = "software"
        case 3:
            kind = "ebook"
        default:
            kind = ""
        }
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", encodedText, kind)
        let url = URL(string: urlString)
        return url!
    }

//    func performStoreRequest(with url: URL) -> String? {
//        do {
//            return try String(contentsOf: url, encoding: .utf8)
//        } catch {
//            print("Download Error: '\(error.localizedDescription)'")
//        }
//        return nil
//    }
    
//    func performStoreRequest(with url: URL) -> Data? {
//        do {
//            let data = try Data(contentsOf: url)
//             return data
//        } catch {
//            print("Download Error: '\(error.localizedDescription)'")
//            isLoading = false
//            showNetworkError()
//            return nil
//        }
//    }

    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store. Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func performSearch() {
        
        if searchBar.text!.isEmpty {
            return
        }
        searchBar.resignFirstResponder()
        dataTask?.cancel()
        hasSearched = true
        searchResults = []
        isLoading = true
        tableView.reloadData()

        
        let url = iTurnsURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
        
        let session = URLSession.shared
        
        dataTask = session.dataTask(with: url) { [self]
            data, response, error in
            print("On main thread? " + (Thread.current.isMainThread ? "Yes" : "No"))
            if let error = error as NSError?, error.code == -999 {
                print("Failure! \(error.localizedDescription)")
                return
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data {
                    searchResults = parse(data: data)
                    searchResults.sort(by: <)
                    DispatchQueue.main.async {
                        isLoading = false
                        tableView.reloadData()
                    }
                    return
                }
            } else {
                print("Failure! \(response!)")
            }
            DispatchQueue.main.async {
                hasSearched = false
                isLoading = false
                tableView.reloadData()
                showNetworkError()
            }
        }
        
        dataTask?.resume()
        
        
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
        if (isLoading || hasSearched) && searchResults.count == 0 {
            return 1
        }
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingViewCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLable.text = searchResult.name
            
            if searchResult.artist.isEmpty {
                cell.artistNameLable.text = "Unknown"
            } else {
                cell.artistNameLable.text = "\(searchResult.artist) (\(searchResult.type))"
            }
           return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        }
        return indexPath
    }
    
}
