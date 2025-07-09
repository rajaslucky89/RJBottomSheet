//
//  RJBottomSheetPresentationController.swift
//  RJBottomSheet
//
//  Created by Raja Harahap on 09/07/25.
//

import UIKit

public class RJBottomSheetPresentationController: UIPresentationController {
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        return view
    }()
    
    // MARK: - Initializer
    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    public override func presentationTransitionWillBegin() {
        setupViews()
        
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.backgroundView.alpha = 1
        })
    }
    
    public override func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.backgroundView.alpha = 0.0
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        })
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        let yOrigin = (keyWindow?.bounds.height ?? UIScreen.main.bounds.height) - preferredContentSize.height
        return CGRect(origin: CGPoint(x: 0, y: yOrigin), size: preferredContentSize)
    }
    
    public override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        presentedView?.layer.cornerRadius = .zero
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.backgroundView.frame.size = size
        })
    }

    private func setupViews() {
        guard let containerView = containerView else { return }
        containerView.insertSubview(backgroundView, at: 0)
        backgroundView.frame = containerView.bounds
    }
}
