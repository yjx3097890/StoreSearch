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
    var result: SearchResult? {
        didSet {
            if isViewLoaded {
                // iphone 的isViewLoaded 可能为 false
                setValues()
            }
        }
    }
    var isPopUp = false
    
    enum AnimationStyle {
        case slide
        case fade
    }
    
    var dismissStyle = AnimationStyle.fade
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        transitioningDelegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isPopUp {
            
            // 添加圆角
            popUpView.layer.cornerRadius = 10
            
            // 点击背景消失当前页面
            let gestureRecongnizer = UITapGestureRecognizer(target: self, action: #selector(close))
            gestureRecongnizer.cancelsTouchesInView = true // 如果这个手势触发了，是否取消别的手势事件
            gestureRecongnizer.delegate = self
            view.addGestureRecognizer(gestureRecongnizer)
            // Gradient view
            view.backgroundColor = .clear
            let dimmingView = GradientView(frame: view.bounds)
            view.insertSubview(dimmingView, at: 0)
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
            popUpView.isHidden = true
            if let displayName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
                title = displayName
            }
        }
        
        if result != nil {
            setValues()

        }
    }
    
    deinit {
        downloadTask?.cancel()
        downloadTask = nil
        print("disappear")
    }
//    
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.willTransition(to: newCollection, with: coordinator)
//        switch newCollection.verticalSizeClass {
//            case .compact, .regular, .unspecified:
//                dismiss(animated: true, completion: nil)
//            default:
//                break
//        }
//    }
    
    // MARK: - Actions
    @objc @IBAction func close() {
        dismissStyle = .slide
        dismiss(animated: true, completion: nil)
    }

    @IBAction func linkToAppStore(_ sender: Any) {
        if let r = result, let url = URL(string: r.storeURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
    }
    
    // MARK: - Helper Methods
    func setValues() {
        if let r = result, let url = URL(string: r.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: url)
        }
        
        nameLabel.text = result?.name
        typeLabel.text = result?.type
        if let r = result, r.artist.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "Unknown artist")
          } else {
            artistNameLabel.text = result?.artist
          }
        genreLabel.text = result?.genre
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = result?.currency
        
        let priceText: String
        if let r = result, r.price == 0 {
          priceText = NSLocalizedString("Free", comment: "price 0")
        } else if let r = result, let text = formatter.string(from: r.price as NSNumber) {
          priceText = text
        } else {
          priceText = ""
        }
        
        priceButton.setTitle( priceText, for: .normal)
        
        popUpView.isHidden = false
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


extension DetailViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return BounceAnimationController()
  }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissStyle == .slide ? SlideOutAnimationController(): FadeOutAnimationController()
    }
}
