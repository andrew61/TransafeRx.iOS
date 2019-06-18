//
//  PopoverPresentationController.swift
//  BounceBackNow
//
//  Created by Jonathan on 3/20/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

class PopoverPresentationController: UIPresentationController, UIAdaptivePresentationControllerDelegate {
    
    var chromeView: UIView = UIView()
    var closeButton: UIButton = UIButton()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        self.chromeView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        self.chromeView.alpha = 0.0
        
        self.presentedViewController.view.layer.cornerRadius = 5
        self.presentedViewController.view.layer.masksToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chromeViewTapped(gesture:)))
        self.chromeView.addGestureRecognizer(tapGesture)
        
        closeButton = UIButton(frame: CGRect(x: 15, y: 15, width: 40, height: 40))
        closeButton.setImage(UIImage(named: "ic_clear_36pt"), for: .normal)
        closeButton.addTarget(self, action: #selector(self.dismiss), for: .touchUpInside)
        closeButton.layer.cornerRadius = 20
        closeButton.layer.borderWidth = 2
        closeButton.layer.borderColor = UIColor(displayP3Red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0).cgColor
        closeButton.tintColor = .darkGray
        closeButton.backgroundColor = .white
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var presentedViewFrame = CGRect.zero
        let containerBounds = self.containerView?.bounds
        presentedViewFrame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: (containerBounds?.size)!)
        presentedViewFrame.origin = CGPoint(x: (containerBounds?.size.width)! / 2.0, y: (containerBounds?.size.height)! / 2.0)
        presentedViewFrame.origin.x -= presentedViewFrame.size.width / 2.0
        presentedViewFrame.origin.y -= presentedViewFrame.size.height / 2.0
        
        return presentedViewFrame
    }
    
    override var shouldPresentInFullscreen: Bool {
        return false
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width - 65.0, height: parentSize.height - 65.0)
    }
    
    override func presentationTransitionWillBegin() {
        self.chromeView.frame = (self.containerView?.bounds)!
        self.chromeView.alpha = 0.0
        self.containerView?.insertSubview(self.chromeView, at: 0)
        let coordinator = presentedViewController.transitionCoordinator
        if coordinator != nil {
            coordinator!.animate(alongsideTransition: {
                (context:UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.chromeView.alpha = 1.0
            }, completion:nil)
        }
        else {
            self.chromeView.alpha = 1.0
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        self.containerView?.window?.addSubview(self.closeButton)
        UIView.animate(withDuration: 0.25, animations: {
            self.closeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (finished) in
            UIView.animate(withDuration: 0.25, animations: {
                self.closeButton.transform = CGAffineTransform.identity
            })
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let coordinator = presentedViewController.transitionCoordinator
        if coordinator != nil {
            coordinator!.animate(alongsideTransition: {
                (context:UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.chromeView.alpha = 0.0
                self.closeButton.alpha = 0.0
            }, completion:nil)
        }
        else {
            self.chromeView.alpha = 0.0
            self.closeButton.alpha = 0.0
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        self.chromeView.frame = (self.containerView?.bounds)!
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        self.containerView?.window?.bringSubviewToFront(self.closeButton)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    @objc func chromeViewTapped(gesture: UIGestureRecognizer) {
        if (gesture.state == .ended) {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func dismiss() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}

class PopoverAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresentation : Bool = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let fromView = fromVC?.view
        let toView = toVC?.view
        let containerView = transitionContext.containerView
        
        if isPresentation {
            containerView.addSubview(toView!)
        }
        
        let animatingVC = isPresentation ? toVC : fromVC
        let animatingView = animatingVC?.view
        
        let finalFrameForVC = transitionContext.finalFrame(for: animatingVC!)
        var initialFrameForVC = finalFrameForVC
        initialFrameForVC.origin.x += initialFrameForVC.size.width;
        
        let initialFrame = isPresentation ? initialFrameForVC : finalFrameForVC
        let finalFrame = isPresentation ? finalFrameForVC : initialFrameForVC
        
        animatingView?.frame = initialFrame
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 300.0, initialSpringVelocity: 5.0, options: .allowUserInteraction, animations: {
            animatingView?.frame = finalFrame
        }) { (finished) in
            if !self.isPresentation {
                fromView?.removeFromSuperview()
            }
            
            transitionContext.completeTransition(true)
        }
    }
}

class PopoverTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopoverPresentationController(presentedViewController: presented, presenting: presenting)
        
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = PopoverAnimatedTransitioning()
        animationController.isPresentation = true
        return animationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = PopoverAnimatedTransitioning()
        animationController.isPresentation = false
        return animationController
    }
}
