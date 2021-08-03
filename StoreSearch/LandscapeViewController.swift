//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by yan jixian on 2021/7/28.
//

import UIKit

class LandscapeViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    
    private var firstTime = true
    var search: Search!
    private var downloadTasks = [URLSessionDownloadTask]()
    private var spinner: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove constraints from main view
          view.removeConstraints(view.constraints)
          view.translatesAutoresizingMaskIntoConstraints = true
          // Remove constraints for page control
          pageControl.removeConstraints(pageControl.constraints)
          pageControl.translatesAutoresizingMaskIntoConstraints = true
          // Remove constraints for scroll view
          scrollView.removeConstraints(scrollView.constraints)
          scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
         
        pageControl.numberOfPages = 0
        
        scrollView.delegate = self
        
    }
    
    deinit { 
        for task in downloadTasks {
            task.cancel()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        scrollView.frame = safeFrame
        pageControl.frame = CGRect(x: safeFrame.origin.x, y: safeFrame.size.height - pageControl.frame.size.height,
                                   width: safeFrame.size.width, height: pageControl.frame.size.height)
        
        if firstTime {
          firstTime = false
            switch search.state {
            case .results(let results):
                tileButtons(results)
            case .loading:
                showSpinner()
            case .noResults:
                showNothingFoundLabel()
            default:
                break
            }
            
        }
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
    
    // MARK: - Actions
    @IBAction func pageChanged(_ sender: UIPageControl) {
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentOffset = CGPoint(
                x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
              y: 0)
        }
     
    }

    
    // MARK: - help methods
    private func tileButtons(_ searchResults: [SearchResult]) {
    
          let itemWidth: CGFloat = 94
          let itemHeight: CGFloat = 88
          var columnsPerPage = 0
          var rowsPerPage = 0
          var marginX: CGFloat = 0
          var marginY: CGFloat = 0
          let viewWidth = scrollView.bounds.size.width
          let viewHeight = scrollView.bounds.size.height
          // 1
          columnsPerPage = Int(viewWidth / itemWidth)
          rowsPerPage = Int(viewHeight / itemHeight)
          // 2
          marginX = (viewWidth - (CGFloat(columnsPerPage) * itemWidth)) * 0.5
          marginY = (viewHeight - (CGFloat(rowsPerPage) * itemHeight)) * 0.5
          
        // Button size
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth) / 2
        let paddingVert = (itemHeight - buttonHeight) / 2
        
        // Add the buttons
        var row = 0
        var column = 0
        var x = marginX
        for (index, result) in searchResults.enumerated() {
          // 1
          let button = UIButton(type: .system)
            button.backgroundColor = UIColor.init(patternImage: UIImage(named: "LandscapeButton")!)
            downloadImage(for: result, placeOn: button)
            button.tag = 2000+index
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
          // 2
          button.frame = CGRect(
            x: x + paddingHorz,
            y: marginY + CGFloat(row) * (itemHeight  ) + paddingVert,
            width: buttonWidth,
            height: buttonHeight)
          // 3
          scrollView.addSubview(button)
          // 4
          row += 1
          if row == rowsPerPage {
            row = 0
            x += itemWidth
            column += 1
            if column == columnsPerPage {
              column = 0
              x += marginX * 2
            }
          }
        }
        
        // Set scroll view content size
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = ceil(Double(searchResults.count) / Double(buttonsPerPage))
        scrollView.contentSize = CGSize(
              width: CGFloat(numPages) * viewWidth,
              height: scrollView.bounds.size.height)
        
        pageControl.numberOfPages = Int(numPages)
        pageControl.currentPage = 0
        print("Number of pages: \(numPages)")
    }
    
    private func downloadImage(for result: SearchResult, placeOn button: UIButton) {
        if let url = URL(string: result.imageSmall){
            let task = URLSession.shared.downloadTask(with:  url) {[weak button] url, response, error in
                if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        button?.setBackgroundImage(image, for: .normal)
                    }
                }
            }
            self.downloadTasks.append(task)
            task.resume()
        }
    }
    
    private func showSpinner() {
        spinner = UIActivityIndicatorView(style: .large)
        spinner!.center = CGPoint(x: scrollView.frame.midX + 0.5, y: scrollView.frame.midY + 0.5)
       // print(scrollView.frame)
       // print(scrollView.bounds)
        spinner!.tag = 1000
        view.addSubview(spinner!)
        spinner!.startAnimating()
    }
    
    private func showNothingFoundLabel() {
      let label = UILabel(frame: CGRect.zero)
        label.text = NSLocalizedString("Nothing Found", comment: "no results found")
      label.textColor = UIColor.label
      label.backgroundColor = UIColor.clear
      
      label.sizeToFit()
      
//      var rect = label.frame
//      rect.size.width = ceil(rect.size.width / 2) * 2    // make even why?
//      rect.size.height = ceil(rect.size.height / 2) * 2  // make even
//      label.frame = rect
      
      label.center = CGPoint(
        x: scrollView.bounds.midX,
        y: scrollView.bounds.midY)
      view.addSubview(label)
    }
    
    func searchResultsReceived() {
        spinner?.removeFromSuperview()
        
        switch search.state {
        case .results(let results):
            tileButtons(results)
        case .noResults:
            showNothingFoundLabel()
        default:
            break
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case let .results(results) = search.state {
                let controller = segue.destination as! DetailViewController
                controller.result = results[(sender as! UIButton).tag - 2000]
            }
           
        }
    }
    

}

// MARK: - UIScrollViewDelegate
extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = floor(scrollView.contentOffset.x / width)
        pageControl.currentPage = Int(page)
    }
}
