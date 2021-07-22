//
//  SearchResult.swift
//  StoreSearch
//
//  Created by yan jixian on 2021/7/19.
//

import Foundation

class ResultArray: Codable {
    var resultCount = 0
    var results = [SearchResult]()
}

class SearchResult: Codable, Identifiable, CustomStringConvertible {
    
    var description: String {
        "\nResult - Kind: \(kind ?? "None"), Name: \(name), Artist Name: \(artistName ?? "None")"
    }
    
   
    var name: String {
        trackName ?? ""
    }
    
    var artistName: String? = ""
    var trackName: String? = ""
    var kind: String? = ""
    var trackPrice: Double? = 0.0
    var currency = ""
    var imageSmall = ""
    var imageLarge = ""
    var storeUrl: String? = ""
    var genre = ""

    enum CodingKeys: String, CodingKey {
        case <#case#>
    }
    
    
    
    

}
