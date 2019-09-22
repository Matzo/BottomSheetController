//
//  BottomSheetController.swift
//  MiniPlayer
//
//  Created by Matsuo Keisuke on 9/20/19.
//  Copyright © 2019 Matsuo Keisuke. All rights reserved.
//

import UIKit

class BottomSheetPresentationController: UIPresentationController {

    // MARK: - Private Properties
    private let overlayView = UIView()
    private let gestureView = UIView()
    private var observes: [NSKeyValueObservation] = []

    // MARK: - Internal Properties
    internal var style = BottomSheetController.SheetStyle(height: .half)
    internal var interactiveDismissTransition: UIPercentDrivenInteractiveTransition?

    ///
    /// Presentation Transition
    ///
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        overlayView.frame = containerView.bounds
        overlayView.backgroundColor = .black
        overlayView.isUserInteractionEnabled = false
        overlayView.alpha = 0.0
        containerView.insertSubview(overlayView, at: 0)

        let tap = UITapGestureRecognizer(target: self, action: #selector(BottomSheetPresentationController.tapToClose(_:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(BottomSheetPresentationController.panToClose(_:)))
        gestureView.frame = containerView.bounds
        gestureView.isUserInteractionEnabled = true
        gestureView.gestureRecognizers = [tap, pan]
        containerView.insertSubview(gestureView, at: 0)

        if case .preferred = style.height {
            observes.append(presentedViewController.observe(\.preferredContentSize) { [weak self] (viewController, changed) in
                self?.updatePresentedViewFrame()
            })
        }

        let panPresented = UIPanGestureRecognizer(target: self, action: #selector(BottomSheetPresentationController.panToClose(_:)))
        panPresented.delegate = self
        presentedView?.addGestureRecognizer(panPresented)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            self?.overlayView.alpha = self?.style.overlayAlpha ?? 0.0
            }, completion: { (_) in
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
    }

    ///
    /// Dismiss Transition
    ///
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            self?.overlayView.alpha = 0.0
            }, completion:nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            overlayView.removeFromSuperview()
            gestureView.removeFromSuperview()
        }
    }

    ///
    /// Layout
    ///

    // for Contents Size
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let safeAreaBottom = presentedViewController.view.safeAreaInsets.bottom
        let maxWidth: CGFloat = parentSize.width
        let maxHeight: CGFloat
        switch style.height {
        case .fixed(let height):
            maxHeight = height
        case .half:
            maxHeight = parentSize.height * 0.5
        case .preferred:
            let size = presentedViewController.preferredContentSize
            if size != .zero {
                maxHeight = size.height + safeAreaBottom
            } else {
                maxHeight = parentSize.height * 0.5
            }
        }
        return CGSize(width: maxWidth, height: maxHeight)
    }

    // for Contents Frame
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerBounds = containerView?.bounds else { return .zero }

        var presentedViewFrame = CGRect()
        let childContentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        presentedViewFrame.size = childContentSize
        presentedViewFrame.origin.x = 0
        presentedViewFrame.origin.y = containerBounds.height - childContentSize.height

        return presentedViewFrame
    }

    override func containerViewWillLayoutSubviews() {
        updatePresentedViewFrame()
    }

    override func containerViewDidLayoutSubviews() {
    }

    func updatePresentedViewFrame() {
        guard let bounds = containerView?.bounds else { return }
        overlayView.frame = bounds
        gestureView.frame = bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = style.sheetRadius
        presentedView?.clipsToBounds = true
    }

    ///
    /// Tap Background to close
    ///
    @objc func tapToClose(_ tap: UITapGestureRecognizer) {
        guard let transitioning = self.interactiveDismissTransition else { return }
        transitioning.wantsInteractiveStart = false
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    ///
    /// Swipe Background or Contents to close
    ///
    @objc func panToClose(_ pan: UIPanGestureRecognizer) {
        guard let viewController = presentedViewController as? BottomSheetPresentable else { return }
        guard let transitioning = self.interactiveDismissTransition else { return }

        let position = pan.translation(in: gestureView)
        let progress: CGFloat = max(0.0, min(1.0, position.y / gestureView.frame.height))

        switch pan.state {
        case .began:
            transitioning.wantsInteractiveStart = true
            viewController.dismiss(animated: true, completion: nil)
            transitioning.update(progress)

        case .changed:
            transitioning.update(progress)

        case .ended:
            if progress > style.closeThreshold {
                transitioning.finish()
                pan.isEnabled = false
            } else {
                transitioning.cancel()
            }
            transitioning.wantsInteractiveStart = false
            viewController.scrollView?.isScrollEnabled = true

        case .cancelled: fallthrough
        case .failed:
            transitioning.cancel()
            transitioning.wantsInteractiveStart = false
            viewController.scrollView?.isScrollEnabled = true
        case .possible:
            break
        @unknown default:
            break
        }
    }
}

///
/// Swipe UIScrollView of Contents to close
///
extension BottomSheetPresentationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard let pressentable = presentedViewController as? BottomSheetPresentable else { return true }

        if let scrollView = pressentable.scrollView, pan.velocity(in: pressentable.view).y > 0 {
            if (scrollView.contentOffset.y + scrollView.contentInset.top) <= 0 {
                pressentable.scrollView?.isScrollEnabled = false
            } else {
                pressentable.scrollView?.isScrollEnabled = true
            }
        }
        return true
    }
}
