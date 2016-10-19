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
    
    public init(delegate: MTOPagerDelegate, menu: MTOPagerMenuView) {
        assert(menu.isKind(of: UIView.self), "MTOPagerMenuView must be subclass of UIView")
        
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
        updateSelectedController()
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
                let count = controllerCount
                if value >= count || value < 0 {
                    _selectedIndex = 0
                } else {
                    _selectedIndex = value
                }
                updateSelectIndex()
            } else {
                _selectedIndex = value
            }
        }
        get {
            return _selectedIndex
        }
    }
    
    open func reload() {
        for controller in self.childViewControllers {
            controller.removeFromParentViewController()
        }
        controllersMap.removeAll()
        contentScrollView.mto_pager_removeAllSubviews()
        
        let count = controllerCount
        if count == 0 {
            return
        }
        
        let width = contentScrollView.bounds.size.width
        contentScrollView.contentSize = CGSize(width: CGFloat(count) * width, height: 0)
        if _selectedIndex >= count || _selectedIndex < 0 {
            _selectedIndex = 0
        }
        updateSelectIndex()
    }
    
    // MARK: - Private
    
    private var controllersMap: [Int : UIViewController] = [:]
    
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
    
    private var controllerCount:Int {
        get {
            var count:Int = 0
            if let c = self.delegate?.mtoNumOfChildControllers(pager: self) {
                count = c
            }
            return count
        }
    }
    
    private func controllerAtIndex(at index:Int) -> UIViewController {
        var controller: UIViewController? = controllersMap[index]
        if controller == nil {
            if let c = self.delegate?.mto(pager: self, childControllerAtIndex: index) {
                controller = c
                controllersMap[index] = c
                addChildViewController(c)
            } else {
                fatalError("must return a controller in func mtoPager(pager: MTOPagerViewController, childControllerAtIndex index: Int)")
            }
        }
        return controller!
    }
    
    private var _selectedIndex: Int = 0
    
    private func updateSelectIndex() {
        let count = controllerCount
        if _selectedIndex >= count || _selectedIndex < 0 {
            return
        }
        updateSelectedController()
        if let delegate = self.delegate {
            delegate.mto(pager: self, didSelectChildController: _selectedIndex)
        }
        menuView.pager(scrollView: contentScrollView, didSelectIndex: _selectedIndex)
    }
    
    private func updateSelectedController() {
        let count = controllerCount
        if _selectedIndex >= count || _selectedIndex < 0 {
            return
        }
        let width: CGFloat = contentScrollView.bounds.size.width
        let controller: UIViewController = controllerAtIndex(at: _selectedIndex)
        let x:CGFloat = CGFloat(_selectedIndex) * width + pageSpace/2.0
        controller.view.frame = CGRect(x: x, y: 0, width: width, height: contentScrollView.bounds.size.height)
        contentScrollView.addSubview(controller.view)
        
        let targetOffset: CGFloat = width * CGFloat(_selectedIndex)
        if fabs(targetOffset - contentScrollView.contentOffset.x) < 0.1 {
            // do nothing
        } else {
            contentScrollView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: true)
        }
    }
    
    fileprivate func refreshIndexWhenEndScrolling() {
        let offsetX = contentScrollView.contentOffset.x
        let width = contentScrollView.bounds.size.width
        let index: Int = Int(round(offsetX/width))
        let count: Int = controllerCount
        if index >= count || index < 0 {
            return
        }
        if _selectedIndex == index {
            return
        }
        _selectedIndex = index
        updateSelectIndex()
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
