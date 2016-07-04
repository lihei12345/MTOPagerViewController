//
//  ViewController.swift
//  MTOPagerViewControllerDemo
//
//  Created by jason on 7/4/16.
//  Copyright © 2016 mtoteam. All rights reserved.
//

import UIKit
import MTOPagerViewController

class ViewController: UIViewController, MTOPagerDelegate {
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "MTOPagerViewController"
        
        self.edgesForExtendedLayout = .None
        self.view.addSubview(pagerMenuView)
        
        addChildViewController(pagerVC)
        self.view.addSubview(pagerVC.view)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pagerMenuView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 42)
        let bottom: CGFloat = pagerMenuView.frame.origin.y + pagerMenuView.bounds.size.height
        pagerVC.view.frame = CGRect(x: 0, y: bottom, width: self.view.bounds.size.width, height: self.view.bounds.size.height - bottom)
    }
    
    // MARK: - Pager
    
    private lazy var pagerMenuView: PagerMenuView = {
        let view = PagerMenuView(titles: ["History", "Favor"])
        return view
    }()
    
    private lazy var pagerVC: MTOPagerViewController = {
        let pager = MTOPagerViewController(delegate: self, menu: self.pagerMenuView)
        return pager
    }()
    
    private lazy var favorVC: UIViewController = {
        let vc: UIViewController = UIViewController()
        vc.view.backgroundColor = UIColor.yellowColor()
        return vc
    }()
    
    private lazy var historyVC: UIViewController = {
        let vc: UIViewController = UIViewController()
        vc.view.backgroundColor = UIColor.blueColor()
        return vc
    }()
    
    // MARK: - MTOPagerDelegate
    
    func mtoPagerNumOfChildControllers(pager: MTOPagerViewController) -> Int {
        return 2
    }
    
    func mtoPager(pager: MTOPagerViewController, didSelectChildController index: Int) {
        // do nothing
    }
    
    func mtoPager(pager: MTOPagerViewController, childControllerAtIndex index: Int) -> UIViewController {
        if index == 0 {
            return historyVC
        } else {
            return favorVC
        }
    }
}

