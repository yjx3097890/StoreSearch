//
//  Search.swift
//  StoreSearch
//
//  Created by yanjixian on 2021/8/2.
//

import Foundation

typealias SearchComplete = (Bool) -> Void

class Search {
    private(set) var state: State = .notSearchYet
    
    enum State {
        case notSearchYet
        case loading
        case noResults
        case results([SearchResult])
    }
    
    enum Category: Int {
        case all
        case music
        case software
        case ebooks
        
        var type: String {
            switch self {
                case .all:
                    return ""
                case .music:
                    return "musicTrack"
                case .software:
                    return "software"
                case .ebooks:
                    return "ebook"
            }
        }
    }
    
    private var dataTask: URLSessionDataTask?
    
    private func iTurnsURL(searchText: String, category: Category) -> URL {
        let kind = category.type
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

    private func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
    
    
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
        
        if text.isEmpty {
            return
        }
        dataTask?.cancel()
        state = .loading
        
        let url = iTurnsURL(searchText: text, category: category)
        
        let session = URLSession.shared
        
        dataTask = session.dataTask(with: url) { [self] data, response, error in
          //  print("On main thread? " + (Thread.current.isMainThread ? "Yes" : "No"))
            var newState = State.notSearchYet

            var success = false
            
            if let error = error as NSError?, error.code == -999 {
                print("Failure! \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data {
                    var searchResults = parse(data: data)
                    if searchResults.isEmpty {
                        newState = .noResults
                    } else {
                        searchResults.sort(by: <)
                        newState = .results(searchResults)
                    }
                    success = true
                }
            }
            
            DispatchQueue.main.async {
                self.state = newState
                completion(success)
            }
            
        }
        
        dataTask?.resume()
        
    }
   
    
    
    
}
