//
//  RJBottomSheet.swift
//  RJBottomSheet
//
//  Created by Raja Harahap on 09/07/25.
//

import UIKit

public protocol RJBottomSheetDelegate: AnyObject {
    func bottomSheet(viewDidDismissed view: RJBottomSheet, content: UIViewController)
}

public class RJBottomSheet: UIViewController {
    
    // MARK: - Private Properties
    private weak var delegate: RJBottomSheetDelegate?
    private var topPadding: CGFloat = 16
    
    public private(set) var contentViewController: UIViewController
    private let fullscreenOffsetConstraint: CGFloat = 44
    private let closeButtonHeight: CGFloat = 40
    private let closeButtonBottomConstraintHeight: CGFloat = 16
    private let notificationCenterName = UIResponder.keyboardWillShowNotification
    
    private var sheetContainerHeightConstraint: NSLayoutConstraint?
    private var height: RJBottomSheetHeight
    private var isSwipeToDismissEnable: Bool = true
    private var keyboardIsShowing: Bool = false
    
    private var isSwipeIndicatorEnable: Bool = false {
        didSet {
            swipeIndicatorView.isHidden = !isSwipeIndicatorEnable
            isSwipeToDismissEnable = isSwipeIndicatorEnable
        }
    }
    
    private var isCloseButtonEnable: Bool = true {
        didSet {
            closeButton.isHidden = !isCloseButtonEnable
            closeButton.isUserInteractionEnabled = isCloseButtonEnable
        }
    }
    
    private var sheetHeight: CGFloat {
        switch height {
        case .quart: return view.frame.height * height.value
        case .half: return view.frame.height * height.value
        case .threeQuart: return view.frame.height * height.value
        case .full: return view.safeAreaLayoutGuide.layoutFrame.height
        case .dynamic: return height.value
        }
    }
    
    // MARK: - UI Layout Composer
    
    private let swipeIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 4 / 2
        return view
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // Container view for close button and content view
    private let sheetContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // Container view for content view
    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = CGFloat(16)
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var closeButton: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 40 / 2
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var closeButtonImageView: UIImageView = {
        let closeIcon = UIImageView()
        closeIcon.contentMode = .scaleAspectFit
        closeIcon.image = UIImage(named: "close")
        return closeIcon
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    // MARK: - Initializer
    
    /// Default initializer for `BottomSheetViewController`
    /// - Parameters:
    ///   - contentViewController: UIViewController for destinated view controller
    ///   - height: `BottomSheetHeight` for bottom sheet height type. Default value is `dynamic`
    ///   - topPadding: The top padding between the content and the top. Default value is 16
    public init(
        for contentViewController: UIViewController,
        height: RJBottomSheetHeight = .dynamic,
        topPadding: CGFloat = 16
    ) {
        self.contentViewController = contentViewController
        self.height = height
        self.topPadding = topPadding
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestureRecognizer()
        setupBottomSheetHeight()
        setupNotificationCenter()
    }
    
    override public func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        /// We only change preferredContentSize when height is dynamic
        if (container as? UIViewController) != nil && height == .dynamic {
            changeSheetContainerHeight(to: container.preferredContentSize.height)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    @discardableResult
    public func isShowCloseButton(_ status: Bool) -> RJBottomSheet {
        self.isCloseButtonEnable = status
        return self
    }
    
    @discardableResult
    public func isShowSwipeIndicatorView(_ status: Bool) -> RJBottomSheet {
        self.isSwipeIndicatorEnable = status
        return self
    }
    
    @discardableResult
    public func isSwipeToDismissEnable(_ status: Bool) -> RJBottomSheet {
        self.isSwipeToDismissEnable = status
        return self
    }
    
    @discardableResult
    public func setupDelegate(_ delegate: RJBottomSheetDelegate?) -> RJBottomSheet {
        self.delegate = delegate
        return self
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        sheetContainerView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButtonImageView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        swipeIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.addSubview(sheetContainerView)
        NSLayoutConstraint.activate([
            sheetContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheetContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        sheetContainerView.addSubview(contentContainerView)
        NSLayoutConstraint.activate([
            contentContainerView.topAnchor.constraint(equalTo: sheetContainerView.topAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: sheetContainerView.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: sheetContainerView.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: sheetContainerView.bottomAnchor)
        ])
        
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let leftLabelStack = UIStackView(arrangedSubviews: [titleLabel])
        leftLabelStack.axis = .horizontal
        leftLabelStack.spacing = 4
        leftLabelStack.alignment = .center
        
        headerStackView.addArrangedSubview(leftLabelStack)
        headerStackView.addArrangedSubview(closeButton)
        
        contentContainerView.addSubview(headerStackView)
        
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 16),
            headerStackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 16),
            headerStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -16),
            headerStackView.heightAnchor.constraint(equalToConstant: 40),
            
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        closeButton.addSubview(closeButtonImageView)
        NSLayoutConstraint.activate([
            closeButtonImageView.centerXAnchor.constraint(equalTo: closeButton.centerXAnchor),
            closeButtonImageView.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            closeButtonImageView.widthAnchor.constraint(equalToConstant: 24),
            closeButtonImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        contentContainerView.addSubview(swipeIndicatorView)
        NSLayoutConstraint.activate([
            swipeIndicatorView.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 6),
            swipeIndicatorView.centerXAnchor.constraint(equalTo: contentContainerView.centerXAnchor),
            swipeIndicatorView.heightAnchor.constraint(equalToConstant: 4),
            swipeIndicatorView.widthAnchor.constraint(equalToConstant: 36)
        ])
        
        addChild(contentViewController)
        contentContainerView.addSubview(contentViewController.view)
        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 8),
            contentViewController.view.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
        contentViewController.didMove(toParent: self)
    }
    
    /// Set the height of the bottom sheet separately after setting up the view.
    /// Different height types are handled with distinct approaches.
    private func setupBottomSheetHeight() {
        switch height {
        case .dynamic:
            /// The height is not set manually to allow it to adapt to its content size
            return
        case .full:
            /// For full display, consider the notch by adding navigation height if present. Otherwise, add height with safe area size only.
            var height = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.height ?? view.frame.height
            height = UIDevice.current.hasNotch ? height + fullscreenOffsetConstraint : height
            
            sheetContainerHeightConstraint = sheetContainerView.heightAnchor.constraint(equalToConstant: height)
        default:
            /// Set height based on the maximum view size multiplied by the specified height type, with added space for the close button.
            let additionalHeight = closeButtonHeight + closeButtonBottomConstraintHeight
            
            sheetContainerHeightConstraint = sheetContainerView
                .heightAnchor
                .constraint(
                    equalTo: view.heightAnchor,
                    multiplier: height.value,
                    constant: additionalHeight
                )
        }
        
        sheetContainerHeightConstraint?.isActive = true
    }
    
    private func setupGestureRecognizer() {
        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        backgroundTapGesture.cancelsTouchesInView = false
        backgroundView.addGestureRecognizer(backgroundTapGesture)
        
        let swipePanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipePan(_:)))
        contentContainerView.addGestureRecognizer(swipePanGesture)
        
        let closeTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCloseTap(_:)))
        closeButton.addGestureRecognizer(closeTapGesture)
    }
    
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    public func dismissSheet() {
        let sourceVC = contentViewController
        contentViewController.dismiss(animated: true) {
            sourceVC.view.endEditing(true)
            self.delegate?.bottomSheet(viewDidDismissed: self, content: sourceVC)
        }
    }
    
    private func resetSheetPosition() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            switch height {
            case .dynamic:
                sheetContainerView.frame.origin.y = view.frame.height - sheetContainerView.frame.height
            case .full:
                let additionalHeight = UIDevice.current.hasNotch ? fullscreenOffsetConstraint : 0
                sheetContainerView.frame.origin.y = view.frame.height - sheetHeight - additionalHeight
            default:
                let additionalHeight = closeButtonHeight + closeButtonBottomConstraintHeight
                sheetContainerView.frame.origin.y = view.frame.height - sheetHeight - additionalHeight
            }
        }
    }
    
    /// This function will call multiple times
    /// following contentSize of children change
    private func changeSheetContainerHeight(to newHeight: CGFloat) {
        let additionalHeight = closeButtonHeight + closeButtonBottomConstraintHeight
        let deviceHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.height ?? view.frame.height
        
        var constantHeight = newHeight + additionalHeight
        if newHeight >= deviceHeight {
            constantHeight = deviceHeight
            
            if UIDevice.current.hasNotch {
                constantHeight += fullscreenOffsetConstraint
            }
        }
        
        /// First we deactivate all the constraint with attribute .height
        if let constraint = sheetContainerView
            .constraints
            .first(where: { $0.firstAttribute == .height && $0.isActive == true }) {
            constraint.isActive = false
        }
        
        /// Insert new height constraint based on preferredContentSizeChange
        sheetContainerHeightConstraint = sheetContainerView.heightAnchor.constraint(equalToConstant: constantHeight)
        sheetContainerHeightConstraint?.isActive = true
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleBackgroundTap(_ gesture: UIPanGestureRecognizer) {
        guard isSwipeToDismissEnable == true else { return }
        dismissSheet()
    }
    
    @objc private func handleCloseTap(_ gesture: UITapGestureRecognizer) {
        dismissSheet()
    }
    
    public func setHeaderTitle(_ title: String) {
        titleLabel.text = title
    }
    
    /// Handles Swipe/Pan Gesture for the bottom sheet view container.
    /// Observes `changed` and `ended` states from the gesture.
    /// Adjusts the `y` frame position during each gesture movement (changed).
    /// After the gesture finishes, it either dismisses or resets the sheet position.
    /// - Parameter gesture: gesture of UIPanGestureRecognizer
    @objc private func handleSwipePan(_ gesture: UIPanGestureRecognizer) {
        guard isSwipeToDismissEnable else { return }
        let translation = gesture.translation(in: view)
        let yTranslation = max(translation.y, 0)
        
        switch gesture.state {
        case .changed:
            switch height {
            case .dynamic:
                sheetContainerView.frame.origin.y = view.frame.height - sheetContainerView.frame.height + yTranslation
            case .full:
                /// Adjustment for presented view: navigation height is not included in safe area for notch devices.
                /// For `full` sheet height types, the notch size is added.
                let additionalHeight = UIDevice.current.hasNotch ? fullscreenOffsetConstraint : 0
                sheetContainerView.frame.origin.y = view.frame.height - sheetHeight + yTranslation - additionalHeight
            default:
                /// Adjusts the position calculation for the sheet height type percentage to exclude the close button view.
                let additionalHeight = closeButtonHeight + closeButtonBottomConstraintHeight
                sheetContainerView.frame.origin.y = view.frame.height - sheetHeight + yTranslation - additionalHeight
            }
        case .ended:
            /// If the y position has moved more than 75% of the sheet height, dismiss the sheet; otherwise, reset it to the initial position.
            let maxLowestPan = contentContainerView.frame.height / 3
            if yTranslation > maxLowestPan {
                dismissSheet()
            } else {
                resetSheetPosition()
            }
        default:
            break
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard height != .full && height != .threeQuart && !keyboardIsShowing else { return }
        
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let offsetY = keyboardFrame.height
            
            let finalOffset = view.frame.height - sheetContainerView.frame.height - offsetY
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.sheetContainerView.frame.origin.y = finalOffset + 16
            }
            
        }
        
        self.keyboardIsShowing = true
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if !keyboardIsShowing {
            return
        }
        
        let bottomSheetFrameHeight = view.frame.height
        let sheetFrameHeight = sheetContainerView.frame.height
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            self.sheetContainerView.frame.origin.y = bottomSheetFrameHeight - sheetFrameHeight
        }
        
        self.keyboardIsShowing = false
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard self.keyboardIsShowing else { return }
        
        guard let userInfo = notification.userInfo,
              let keyboardFrameBegin = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue,
              let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let frameBeginHeight = keyboardFrameBegin.cgRectValue.height
        let frameEndHeight = keyboardFrameEnd.cgRectValue.height
        
        if frameBeginHeight == frameEndHeight {
            return
        }
        
        let sortedFrameHeights = [view.frame.height, sheetContainerView.frame.height, frameEndHeight].sorted(by: >)
        
        let finalOffset = sortedFrameHeights.dropFirst().reduce(sortedFrameHeights[0]) { $0 - $1 }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.sheetContainerView.frame.origin.y = abs(finalOffset) + 16
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension RJBottomSheet: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return RJBottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

