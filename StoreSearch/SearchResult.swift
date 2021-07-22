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
        trackName ?? collectionName ?? ""
    }
    
    var storeURL: String {
      return trackViewUrl ?? collectionViewUrl ?? ""
    }

    var price: Double {
      return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }

    var genre: String {
      if let genre = itemGenre {
        return genre
      } else if let genres = bookGenre {
        return genres.joined(separator: ", ")
      }
      return ""
    }
    
    var type: String {
        let kind = self.kind ?? "audiobook"
        switch kind {
          case "album": return "Album"
          case "audiobook": return "Audio Book"
          case "book": return "Book"
          case "ebook": return "E-Book"
          case "feature-movie": return "Movie"
          case "music-video": return "Music Video"
          case "podcast": return "Podcast"
          case "software": return "App"
          case "song": return "Song"
          case "tv-episode": return "TV Episode"
          default:
            return "Unknown"
        }
    }
    
    var artist: String {
        artistName ?? ""
    }
    
    
    var artistName: String? = ""
    var kind: String? = ""
    var currency = ""
    var imageSmall = ""
    var imageLarge = ""
    var trackName: String? = ""
    var collectionName: String?
    var trackViewUrl: String?
    var collectionViewUrl: String?
    var trackPrice: Double? = 0.0
    var collectionPrice: Double?
    var itemPrice: Double?
    var itemGenre: String?
    var bookGenre: [String]?

    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case kind, artistName, trackName, trackPrice, trackViewUrl, currency, collectionName, collectionViewUrl, collectionPrice
        
    }
    

}

extension SearchResult {
    static func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}
