//
//  PagerMenuView.swift
//  MTOPagerViewController
//
//  Created by jason on 6/25/16.
//  Copyright © 2016 mtoteam. All rights reserved.
//

import UIKit

// MARK: - PagerMenuView -

public class PagerMenuView: UIView, MTOPagerMenuView, UIScrollViewDelegate {
    
    // MARK: - Init
    
    private let titles: [String]
    
    public init(titles: [String]) {
        assert(titles.count > 0)
        
        self.titles = titles
        self.selectIndex = 0
        
        super.init(frame: CGRectZero)
        
        self.backgroundColor = UIColor.clearColor()
        addSubview(contentScrollView)
        addSubview(selectedImageView)
        selectedImageView.backgroundColor = highlightColor
        addSubview(bottomLine)
        bottomLine.backgroundColor = separatorLineColor
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if perButtonWidth == nil && self.titles.count > 0 {
            let max = min(self.titles.count, 5)
            perButtonWidth = self.bounds.size.width/CGFloat(max)
        }
        updateTitles()
    }
    
    private lazy var contentScrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView(frame: self.bounds)
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private lazy var selectedImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRectZero)
        return imageView
    }()
    
    private lazy var bottomLine: UIView = {
        let bottomLine: UIView = UIView(frame: CGRect(x: 0.0, y: self.bounds.size.height - 1, width: self.bounds.size.width, height: 0.5))
        bottomLine.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
        return bottomLine
    }()
    
    // MARK: - Public 
    
    public func selectButton(index: Int) {
        selectIndex = index
        pagerViewController?.selectIndex = index
    }
    
    public var separatorLineColor = UIColor(red: 0xC7/255, green: 0xC4/255, blue: 0xBE/255, alpha: 1) {
        didSet {
            bottomLine.backgroundColor = separatorLineColor
        }
    }
    
    public var highlightColor = UIColor(red: 0x19/255, green: 0xb9/255, blue: 0x55/155, alpha: 1) {
        didSet {
            selectedImageView.backgroundColor = highlightColor
            for button in buttons {
                button.setTitleColor(highlightColor, forState: .Selected)
            }
        }
    }
    
    public var normalTextColor = UIColor(red: 0x54/255, green: 0x54/255, blue: 0x54/255, alpha: 1)  {
        didSet {
            for button in buttons {
                button.setTitleColor(normalTextColor, forState: .Selected)
            }
        }
    }
    
    public var highlightImageWidth: CGFloat? {
        didSet {
            updateHighlightImage()
        }
    }
    
    public var perButtonWidth: CGFloat? {
        didSet {
            updateTitles()
        }
    }
    
    // MARK: - Helper
    
    private var buttons: [UIButton] = []
    
    private func updateTitles() {
        guard let perButtonWidth = perButtonWidth else { return }
        
        let height = self.bounds.size.height
        if self.buttons.count == 0 {
            for i in 0...(titles.count - 1) {
                let title = titles[i]
                let button = createButton(title)
                button.tag = 1000 + i
                button.addTarget(self, action: #selector(didTapTitleButton(_:)), forControlEvents: .TouchUpInside)
                contentScrollView.addSubview(button)
                buttons.append(button)
            }
        }
        for i in 0...(buttons.count - 1) {
            buttons[i].frame = CGRect(x: CGFloat(i)*perButtonWidth, y: 0, width: perButtonWidth, height: height)
            buttons[i].highlighted = false
        }
        contentScrollView.contentSize = CGSize(width: perButtonWidth * CGFloat(buttons.count), height: 0)
        updateHighlightButton()
        updateHighlightImage()
    }
    
    private func updateHighlightButton() {
        guard selectIndex < buttons.count else { return }
        
        for i in 0...(buttons.count - 1) {
            buttons[i].selected = (i == Int(selectIndex)) ? true : false
        }
    }
    
    private func updateHighlightImage() {
        guard let perButtonWidth = perButtonWidth where selectIndex < buttons.count else { return }
        
        if highlightImageWidth == nil {
            highlightImageWidth = perButtonWidth
        }
        selectedImageView.frame = CGRect(
            x: perButtonWidth * CGFloat(selectIndex) + (perButtonWidth - highlightImageWidth!)/2.0,
            y: self.bounds.size.height - 2 - 1,
            width: highlightImageWidth!,
            height: 2
        )
    }
    
    func didTapTitleButton(button: UIButton) {
        let index = button.tag - 1000
        selectButton(index)
    }
    
    private func createButton(title: String) -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.clearColor()
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        button.setTitleColor(normalTextColor, forState: .Normal)
        button.setTitleColor(highlightColor, forState: .Selected)
        button.setTitle(title, forState: .Normal)
        return button
    }
    
    // MARK: - MTOPagerMenuView
    
    public weak var pagerViewController: MTOPagerViewController?
    
    public var selectIndex: Int {
        didSet {
            updateHighlightButton()
        }
    }
    
    public func pagerDidScroll(scrollView: UIScrollView) {
        guard let perButtonWidth = perButtonWidth, let highlightImageWidth = highlightImageWidth else { return }
        
        let scrollPercentage: CGFloat = scrollView.contentOffset.x / scrollView.contentSize.width
        let offsetX: CGFloat = contentScrollView.contentSize.width * scrollPercentage + (perButtonWidth - highlightImageWidth)/2
        var frame = selectedImageView.frame
        frame.origin.x = offsetX
        selectedImageView.frame = frame
    }
    
    public func pagerDidEndDragging(scrollView: UIScrollView) {
        // do nothing
    }
    
    public func pagerDidEndDecelerating(scrollView: UIScrollView) {
        // do nothing
    }
    
    public func pager(scrollView: UIScrollView, didSelectIndex index: Int) {
        selectIndex = index
    }
}
