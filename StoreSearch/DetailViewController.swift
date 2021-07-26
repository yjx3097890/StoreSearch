//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by yanjixian on 2021/7/26.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var downloadTask: URLSessionDownloadTask?
    var result: SearchResult!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 添加圆角
        popUpView.layer.cornerRadius = 10
        
        // 点击背景消失当前页面
        let gestureRecongnizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecongnizer.cancelsTouchesInView = true // 如果这个手势触发了，是否取消别的手势事件
        gestureRecongnizer.delegate = self
        view.addGestureRecognizer(gestureRecongnizer)
        
        setValues()
    }
    
    deinit {
        downloadTask?.cancel()
        downloadTask = nil
        print("disappear")
    }
    
    // MARK: - Actions
    @objc @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func linkToAppStore(_ sender: Any) {
        if let url = URL(string: result.storeURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
    }
    
    // MARK: - Helper Methods
    func setValues() {
        if let url = URL(string: result.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: url)
        }
        
        nameLabel.text = result.name
        typeLabel.text = result.type
        if result.artist.isEmpty {
            artistNameLabel.text = "Unknown"
          } else {
            artistNameLabel.text = result.artist
          }
        genreLabel.text = result.genre
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = result.currency
        
        let priceText: String
        if result.price == 0 {
          priceText = "Free"
        } else if let text = formatter.string(from: result.price as NSNumber) {
          priceText = text
        } else {
          priceText = ""
        }
        
        priceButton.setTitle( priceText, for: .normal)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
