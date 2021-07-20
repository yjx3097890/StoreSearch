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

}
