//
//  FadeOutAnimationController.swift
//  StoreSearch
//
//  Created by yan jixian on 2021/7/31.
//

import UIKit

class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: .from) {
            let time = transitionDuration(using: transitionContext)
            UIView.animate(withDuration: time, animations: {fromView.alpha = 0}) { finish in
                transitionContext.completeTransition(finish)
            }
        }
    }
}
