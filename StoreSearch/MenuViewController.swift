//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by yanjixian on 2021/8/5.
//

import UIKit
import MessageUI

class MenuViewController: UITableViewController {
    
    weak var delegate: MenuViewControllerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()

     }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            delegate?.menuViewControllerSendEmail(self)
        }
    }
  
  
}

protocol MenuViewControllerDelegate: AnyObject {
    func menuViewControllerSendEmail(_ controller: MenuViewController)
}
