//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by yan jixian on 2021/7/25.
//

import UIKit

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        
        let downloadTask = session.downloadTask(with:  url) { [weak self] fileUrl, _, error in
            if error == nil, let file = fileUrl, let data =  try? Data(contentsOf: file), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    // the user might have navigated away to a different part of the app now.
                    self?.image = image
                }
            }
        }
        
        downloadTask.resume()
        return downloadTask
    }
}
