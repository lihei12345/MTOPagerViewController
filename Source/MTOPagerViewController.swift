//
//  MTOPagerViewController.swift
//  MTOPagerViewController
//
//  Created by jason on 6/25/16.
//  Copyright © 2016 mtoteam. All rights reserved.
//

import UIKit

// MARK: - MTOPagerMenuView -

public protocol MTOPagerMenuView: NSObjectProtocol {
    var selectIndex: Int { get set }
    weak var pagerViewController: MTOPagerViewController? { get set }
    
    func pagerDidScroll(scrollView: UIScrollView)
    func pagerDidEndDecelerating(scrollView: UIScrollView)
    func pagerDidEndDragging(scrollView: UIScrollView)
    func pager(scrollView: UIScrollView, didSelectIndex index: Int)
}

// MARK: - MTOPagerDelegate -

public protocol MTOPagerDelegate: NSObjectProtocol {
    func mto(pager: MTOPagerViewController, childControllerAtIndex index: Int) -> UIViewController;
    func mtoNumOfChildControllers(pager: MTOPagerViewController) -> Int;
    func mto(pager: MTOPagerViewController, didSelectChildController index: Int);
}

// MARK: - MTOPagerViewController -

open class MTOPagerViewController: UIViewController {
    
    // MARK: - Life Cycle
    
    weak fileprivate var delegate: MTOPagerDelegate?
    fileprivate let menuView: MTOPagerMenuView
    private var controllersArray: [UIViewController] = []
    private var firstSelectedIndex: Int
    
    public init(delegate: MTOPagerDelegate, menu: MTOPagerMenuView, selectedIndex: Int = 0) {
        assert(menu.isKind(of: UIView.self), "MTOPagerMenuView must be subclass of UIView")
        
        self.firstSelectedIndex = selectedIndex
        self.delegate = delegate
        pageSpace = 15
        scrollable = true
        menuView = menu
        super.init(nibName: nil, bundle: nil)
        
        menu.pagerViewController = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(contentScrollView)
        reload()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = self.view.bounds.size.width
        contentScrollView.frame = CGRect(x: -pageSpace/2.0, y: 0, width: width + pageSpace, height: self.view.bounds.size.height)
        contentScrollView.contentSize = CGSize(width: CGFloat(controllerCount) * contentScrollView.bounds.size.width, height: 0)
        updateControllerFrame(animated: false)
    }
    
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let vc = currentViewController() {
            vc.beginAppearanceTransition(true, animated: animated)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let vc = currentViewController() {
            vc.endAppearanceTransition()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let vc = currentViewController() {
            vc.beginAppearanceTransition(false, animated: animated)
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let vc = currentViewController() {
            vc.endAppearanceTransition()
        }
    }
    
    // MARK: - Public
    
    open var pageSpace: CGFloat {
        didSet {
            self.view.setNeedsLayout()
        }
    }
    
    open var scrollable: Bool {
        willSet {
            contentScrollView.isScrollEnabled = newValue
        }
    }
    
    open var selectIndex: Int {
        set(value) {
            if self.isViewLoaded {
                update(newIndex: value)
            } else {
                currentSelectedIndex = value
            }
        }
        get {
            return currentSelectedIndex
        }
    }
    
    private var controllerCount:Int {
        get {
            return controllersArray.count
        }
    }
    
    open func reload() {
        /// clean up
        for controller in self.childViewControllers {
            controller.removeFromParentViewController()
        }
        controllersArray.removeAll()
        contentScrollView.mto_pager_removeAllSubviews()
        
        guard let count = self.delegate?.mtoNumOfChildControllers(pager: self) else {
            fatalError("must return a count in func mtoNumOfChildControllers")
            return
        }
        guard count > 0 else {
            return
        }
        for index in 0...(count - 1) {
            if let controller = self.delegate?.mto(pager: self, childControllerAtIndex: index) {
                controllersArray.append(controller)
            } else {
                fatalError("must return a controller in func mtoPager(pager: MTOPagerViewController, childControllerAtIndex index: Int)")
            }
        }
        contentScrollView.contentSize = CGSize(width: CGFloat(count) * contentScrollView.bounds.size.width, height: 0)
        
        currentSelectedIndex = firstSelectedIndex
        if currentSelectedIndex >= count || currentSelectedIndex < 0 {
            currentSelectedIndex = 0
        }
        previousSelectIndex = 0
        update(newIndex: currentSelectedIndex, animated: false)
    }
    
    // MARK: - Private
    
    private lazy var contentScrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView(frame: CGRect.zero)
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = UIColor.clear
        scrollView.isScrollEnabled = self.scrollable
        return scrollView
    }()
    
    private var currentSelectedIndex: Int = 0
    private var previousSelectIndex: Int = 0
    
    private func update(newIndex: Int, animated: Bool = true) {
        let count = controllerCount
        if newIndex >= count || newIndex < 0 {
            return
        }
        previousSelectIndex = currentSelectedIndex
        currentSelectedIndex = newIndex
        
        let controller: UIViewController = controllersArray[currentSelectedIndex]
        var shouldTransition = true
        if controller.parent == nil {
            shouldTransition = false
            self.addChildViewController(controller)
            contentScrollView.addSubview(controller.view)
            controller.didMove(toParentViewController: self)
        }
        updateControllerFrame(animated: animated)
        
        if let delegate = self.delegate {
            delegate.mto(pager: self, didSelectChildController: currentSelectedIndex)
        }
        menuView.pager(scrollView: contentScrollView, didSelectIndex: currentSelectedIndex)
        
        if previousSelectIndex != currentSelectedIndex && self.view.window != nil {
            let fromVC = controllersArray[previousSelectIndex]
            fromVC.beginAppearanceTransition(false, animated: false)
            fromVC.endAppearanceTransition()
            
            if shouldTransition {
                controller.beginAppearanceTransition(true, animated: false)
                controller.endAppearanceTransition()
            }
        }
    }
    
    private func updateControllerFrame(animated: Bool = true) {
        if currentSelectedIndex >= controllerCount || currentSelectedIndex < 0 {
            return
        }
        
        let width: CGFloat = contentScrollView.bounds.size.width
        let controller: UIViewController = controllersArray[currentSelectedIndex]
        let x:CGFloat = CGFloat(currentSelectedIndex) * width + pageSpace/2.0
        controller.view.frame = CGRect(x: x, y: 0, width: width - pageSpace, height: contentScrollView.bounds.size.height)
        
        let targetOffset: CGFloat = width * CGFloat(currentSelectedIndex)
        if fabs(targetOffset - contentScrollView.contentOffset.x) < 0.1 {
            // do nothing
        } else {
            contentScrollView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: animated)
        }
    }
    
    private func currentViewController() -> UIViewController? {
        if currentSelectedIndex >= controllerCount || currentSelectedIndex < 0 {
            return nil
        }
        return controllersArray[currentSelectedIndex]
    }
    
    fileprivate func refreshIndexWhenEndScrolling() {
        let offsetX = contentScrollView.contentOffset.x
        let width = contentScrollView.bounds.size.width
        let index: Int = Int(round(offsetX/width))
        if index >= controllerCount || index < 0 {
            return
        }
        if currentSelectedIndex == index {
            return
        }
        update(newIndex: index)
    }
}

// MARK: - MTOPagerViewController+UIScrollViewDelegate -

extension MTOPagerViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuView.pagerDidScroll(scrollView: scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        refreshIndexWhenEndScrolling()
        menuView.pagerDidEndDecelerating(scrollView: scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshIndexWhenEndScrolling()
        menuView.pagerDidEndDragging(scrollView: scrollView)
    }
}

// MARK: - UIViewController+Extension -

public extension UIViewController {
    public var mto_pagerViewController: MTOPagerViewController? {
        get {
            var pager: MTOPagerViewController?
            var viewController: UIViewController? = self
            while viewController != nil {
                if let _ = viewController!.parent?.isKind(of: MTOPagerViewController.self) {
                    pager = viewController?.parent as? MTOPagerViewController
                    break
                } else {
                    viewController = viewController?.parent
                }
            }
            return pager
        }
    }
}

// MARK: - UIView+Extension -

extension UIView {
    func mto_pager_removeAllSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
}
