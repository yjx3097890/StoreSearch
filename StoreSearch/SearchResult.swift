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

private let typeForKind = [
"album": NSLocalizedString(
     "Album",
     comment: "Localized kind: Album"),
    "audiobook":
   NSLocalizedString(
     "Audio Book",
     comment: "Localized kind: Audio Book"),
   "book":
     NSLocalizedString(
     "Book",
     comment: "Localized kind: Book"),
   "ebook":
     NSLocalizedString(
     "E-Book",
     comment: "Localized kind: E-Book"),
   "feature-movie":
     NSLocalizedString(
     "Movie",
     comment: "Localized kind: Feature Movie"),
   "music-video":
     NSLocalizedString(
     "Music Video",
       comment: "Localized kind: Music Video"),
   "podcast":
     NSLocalizedString(
     "Podcast",
     comment: "Localized kind: Podcast"),
   "software":
     NSLocalizedString(
     "App",
     comment: "Localized kind: Software"),
   "song":
     NSLocalizedString(
     "Song",
     comment: "Localized kind: Song"),
   "tv-episode":
     NSLocalizedString(
     "TV Episode",
     comment: "Localized kind: TV Episode")
]

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
        return typeForKind[kind] ?? kind
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
