//
//  ViewController.swift
//  MTOPagerViewControllerDemo
//
//  Created by jason on 7/4/16.
//  Copyright © 2016 mtoteam. All rights reserved.
//

import UIKit
import MTOPagerViewController

class BaseViewController: UIViewController {
    
    static var counter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(describing: BaseViewController.self) + " : " + #function)
        
        if BaseViewController.counter%2 == 0 {
            self.view.backgroundColor = UIColor.yellow
        } else {
            self.view.backgroundColor = UIColor.gray
        }
        BaseViewController.counter = BaseViewController.counter + 1;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(String(describing: BaseViewController.self) + " : " + #function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(String(describing: BaseViewController.self) + " : " + #function)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(String(describing: BaseViewController.self) + " : " + #function)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(String(describing: BaseViewController.self) + " : " + #function)
    }
}

class ViewController: UIViewController, MTOPagerDelegate {
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "MTOPagerViewController"
        
        self.edgesForExtendedLayout = UIRectEdge()
        self.view.addSubview(pagerMenuView)
        
        addChildViewController(pagerVC)
        self.view.addSubview(pagerVC.view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pagerMenuView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 42)
        let bottom: CGFloat = pagerMenuView.frame.origin.y + pagerMenuView.bounds.size.height
        pagerVC.view.frame = CGRect(x: 0, y: bottom, width: self.view.bounds.size.width, height: self.view.bounds.size.height - bottom)
    }
    
    // MARK: - Pager
    
    fileprivate lazy var pagerMenuView: PagerMenuView = {
        let view = PagerMenuView(titles: ["History", "Favor"])
        view.highlightImageWidth = 65
        return view
    }()
    
    fileprivate lazy var pagerVC: MTOPagerViewController = {
        let pager = MTOPagerViewController(delegate: self, menu: self.pagerMenuView)
        return pager
    }()
    
    fileprivate lazy var favorVC: UIViewController = {
        let vc: UIViewController = BaseViewController()
        return vc
    }()
    
    fileprivate lazy var historyVC: UIViewController = {
        let vc: UIViewController = BaseViewController()
        return vc
    }()
    
    // MARK: - MTOPagerDelegate
    
    func mtoNumOfChildControllers(pager: MTOPagerViewController) -> Int {
        return 2
    }
    
    func mto(pager: MTOPagerViewController, didSelectChildController index: Int) {
        
    }
    
    func mto(pager: MTOPagerViewController, childControllerAtIndex index: Int) -> UIViewController {
        if index == 0 {
            return historyVC
        } else {
            return favorVC
        }
    }
}

