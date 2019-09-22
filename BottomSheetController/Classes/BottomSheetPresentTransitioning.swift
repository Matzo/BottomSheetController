//
//  BottomSheetController.swift
//  MiniPlayer
//
//  Created by Matsuo Keisuke on 9/20/19.
//  Copyright © 2019 Matsuo Keisuke. All rights reserved.
//

import UIKit
class BottomSheetPresentTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        toVC.view.frame = containerView.bounds
        toVC.view.transform = CGAffineTransform(translationX: 0, y: toVC.view.frame.height)

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseOut,
                       animations: {
                        toVC.view.transform = .identity
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
