//
//  BottomSheetController.swift
//  MiniPlayer
//
//  Created by Matsuo Keisuke on 9/20/19.
//  Copyright © 2019 Matsuo Keisuke. All rights reserved.
//

import UIKit
class BottomSheetDismissTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(fromVC.view)

        let curve: UIView.AnimationOptions

        if transitionContext.isInteractive {
            curve = .curveLinear
        } else {
            curve = .curveEaseOut
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0,
                       options: curve,
                       animations: {
                        fromVC.view.transform = CGAffineTransform(translationX: 0, y: fromVC.view.frame.height)
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
