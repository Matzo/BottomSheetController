//
//  BottomSheetController.swift
//  MiniPlayer
//
//  Created by Matsuo Keisuke on 9/20/19.
//  Copyright © 2019 Matsuo Keisuke. All rights reserved.
//

import UIKit

public protocol BottomSheetPresentable: UIViewController {
    var bottomSheetController: BottomSheetController? { get set }
    var scrollView: UIScrollView? { get }
    var preferredContentSize: CGSize { get }
}

public class BottomSheetController: NSObject {

    // MARK: - Private Methods
    private var style: SheetStyle
    private let interactiveDismissTransition: UIPercentDrivenInteractiveTransition = {
        let transitioning = UIPercentDrivenInteractiveTransition()
        transitioning.wantsInteractiveStart = false
        return transitioning
    }()

    // MARK: - Initialize
    public init(height: HeightType) {
        self.style = SheetStyle(height: height)
    }
    public init(style: SheetStyle) {
        self.style = style
    }

    // MARK: - Public Methods
    public static func present(_ viewController: BottomSheetPresentable, from: UIViewController, style: BottomSheetController.SheetStyle, animated: Bool, completion: (() -> Void)? = nil) {
        let sheet = BottomSheetController(style: style)
        viewController.bottomSheetController = sheet
        viewController.transitioningDelegate = sheet
        viewController.modalPresentationStyle = .custom
        from.present(viewController, animated: animated, completion: completion)
    }

    public static func present(_ viewController: BottomSheetPresentable, from: UIViewController, height: BottomSheetController.HeightType, animated: Bool, completion: (() -> Void)? = nil) {
        let style = BottomSheetController.SheetStyle(height: height)
        present(viewController, from: from, style: style, animated: animated, completion: completion)
    }

    public static func dismissStackedBottomSheets(frontSheet: UIViewController, alsoParent: Bool, animated: Bool = true, completion: (() -> Void)? = nil) {
        var target: UIViewController = frontSheet
        while target.presentationController is BottomSheetPresentationController {
            if let presenting = target.presentingViewController {
                target = presenting
            }
        }
        if let presenting = target.presentingViewController, alsoParent {
            target = presenting
        }
        target.dismiss(animated: animated, completion: completion)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension BottomSheetController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomSheetPresentTransitioning()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomSheetDismissTransitioning()
    }

    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactiveDismissTransition.wantsInteractiveStart {
            return interactiveDismissTransition
        }
        return nil
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.style = style
        presentationController.interactiveDismissTransition = interactiveDismissTransition
        return presentationController
    }
}

// MARK: - Options
extension BottomSheetController {

    public struct SheetStyle {
        public var height: HeightType
        public var overlayAlpha: CGFloat
        public var sheetRadius: CGFloat
        public var closeThreshold: CGFloat
        public init(height: HeightType,
             overlayAlpha: CGFloat = 0.3,
             sheetRadius: CGFloat = 0,
             closeThreshold: CGFloat = 0.3) {
            self.height = height
            self.overlayAlpha = overlayAlpha
            self.sheetRadius = sheetRadius
            self.closeThreshold = closeThreshold
        }
    }

    public enum HeightType {
        case fixed(CGFloat)
        case half
        case preferred
    }
}
