//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by yanjixian on 2021/7/20.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    @IBOutlet var nameLable: UILabel!
    @IBOutlet var artistNameLable: UILabel!
    @IBOutlet var artworkImageView: UIImageView!
    
    var downloadTask: URLSessionDownloadTask?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(named: "SearchBar")?.withAlphaComponent(0.5)
        selectedBackgroundView = selectedView
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    // MARK: - helper method
    func configure(for result: SearchResult) {
        nameLable.text = result.name
        
        if result.artist.isEmpty {
            artistNameLable.text = "unknown"
        } else {
            artistNameLable.text = "\(result.artist) (\(result.type))"
        }
        
        artworkImageView.image = UIImage(systemName: "square")
        if let smallURL = URL(string: result.imageSmall) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }

}
