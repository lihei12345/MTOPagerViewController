//
//  PagerMenuView.swift
//  MTOPagerViewController
//
//  Created by jason on 6/25/16.
//  Copyright © 2016 mtoteam. All rights reserved.
//

import UIKit

// MARK: - PagerMenuView -

open class PagerMenuView: UIView, MTOPagerMenuView, UIScrollViewDelegate {
    
    // MARK: - Init
    
    fileprivate let titles: [String]
    
    public init(titles: [String]) {
        assert(titles.count > 0)
        
        self.titles = titles
        self.selectIndex = 0
        
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor.clear
        addSubview(contentScrollView)
        addSubview(selectedImageView)
        selectedImageView.backgroundColor = highlightColor
        addSubview(bottomLine)
        bottomLine.backgroundColor = separatorLineColor
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.titles.count > 0 {
            let max = min(self.titles.count, 5)
            perButtonWidth = self.bounds.size.width/CGFloat(max)
        } else {
            perButtonWidth = nil
        }
        updateTitles()
    }
    
    fileprivate lazy var contentScrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView(frame: self.bounds)
        scrollView.backgroundColor = UIColor.clear
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    fileprivate lazy var selectedImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect.zero)
        return imageView
    }()
    
    fileprivate lazy var bottomLine: UIView = {
        let bottomLine: UIView = UIView(frame: CGRect(x: 0.0, y: self.bounds.size.height - 1, width: self.bounds.size.width, height: 0.5))
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        return bottomLine
    }()
    
    // MARK: - Public 
    
    open func selectButton(_ index: Int) {
        selectIndex = index
        pagerViewController?.selectIndex = index
    }
    
    open var showSeparatorLine = true {
        didSet {
            bottomLine.isHidden = !showSeparatorLine
        }
    }
    
    open var separatorLineColor = UIColor(red: 0xC7/255, green: 0xC4/255, blue: 0xBE/255, alpha: 1) {
        didSet {
            bottomLine.backgroundColor = separatorLineColor
        }
    }
    
    open var highlightColor = UIColor(red: 0x19/255, green: 0xb9/255, blue: 0x55/155, alpha: 1) {
        didSet {
            selectedImageView.backgroundColor = highlightColor
        }
    }
    
    open var normalTextColor = UIColor(red: 0x54/255, green: 0x54/255, blue: 0x54/255, alpha: 1)  {
        didSet {
            for button in buttons {
                button.setTitleColor(normalTextColor, for: .selected)
            }
        }
    }
    
    open var highlightTextColor = UIColor(red: 0x19/255, green: 0xb9/255, blue: 0x55/155, alpha: 1) {
        didSet {
            for button in buttons {
                button.setTitleColor(highlightTextColor, for: .selected)
            }
        }
    }
    
    open var showHighlightImage = true {
        didSet {
            updateHighlightImage()
        }
    }
    
    open var highlightImageWidth: CGFloat? {
        didSet {
            updateHighlightImage()
        }
    }
    
    open var perButtonWidth: CGFloat? {
        didSet {
            updateTitles()
        }
    }
    
    open var scaleFactor: CGFloat = 1 {
        didSet {
            updateTitles()
        }
    }
    
    open var titleFont: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            updateTitles()
        }
    }
    
    // MARK: - Helper
    
    fileprivate var buttons: [UIButton] = []
    
    fileprivate func updateTitles() {
        guard let perButtonWidth = perButtonWidth else { return }
        
        let height = self.bounds.size.height
        if self.buttons.count == 0 {
            for i in 0...(titles.count - 1) {
                let title = titles[i]
                let button = createButton(title)
                button.tag = 1000 + i
                button.addTarget(self, action: #selector(didTapTitleButton(_:)), for: .touchUpInside)
                contentScrollView.addSubview(button)
                buttons.append(button)
            }
        }
        for i in 0...(buttons.count - 1) {
            buttons[i].titleLabel?.font = self.titleFont
            buttons[i].frame = CGRect(x: CGFloat(i)*perButtonWidth, y: 0, width: perButtonWidth, height: height)
            buttons[i].isHighlighted = false
        }
        contentScrollView.contentSize = CGSize(width: perButtonWidth * CGFloat(buttons.count), height: 0)
        updateHighlightButton()
        updateHighlightImage()
    }
    
    fileprivate func updateHighlightButton() {
        guard selectIndex < buttons.count else { return }
        
        for i in 0...(buttons.count - 1) {
            let button = buttons[i]
            button.isSelected = (i == Int(selectIndex)) ? true : false
            var factor: CGFloat = (i == Int(selectIndex)) ? scaleFactor : 1
            UIView.animate(withDuration: 0.2, animations: {
                button.transform = CGAffineTransform(scaleX: factor, y: factor)
            })
        }
    }
    
    fileprivate func updateHighlightImage() {
        guard let perButtonWidth = perButtonWidth , selectIndex < buttons.count else { return }
        
        if !showHighlightImage {
            selectedImageView.isHidden = true
            return
        } else {
            selectedImageView.isHidden = false
        }
        
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
    
    func didTapTitleButton(_ button: UIButton) {
        let index = button.tag - 1000
        selectButton(index)
    }
    
    fileprivate func createButton(_ title: String) -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setTitleColor(normalTextColor, for: UIControlState())
        button.setTitleColor(highlightTextColor, for: .selected)
        button.setTitle(title, for: UIControlState())
        return button
    }
    
    // MARK: - MTOPagerMenuView
    
    open weak var pagerViewController: MTOPagerViewController?
    
    open var selectIndex: Int {
        didSet {
            updateHighlightButton()
        }
    }
    
    open func pagerDidScroll(scrollView: UIScrollView) {
        guard let perButtonWidth = perButtonWidth, let highlightImageWidth = highlightImageWidth else { return }
        
        let scrollPercentage: CGFloat = scrollView.contentOffset.x / scrollView.contentSize.width
        let offsetX: CGFloat = contentScrollView.contentSize.width * scrollPercentage + (perButtonWidth - highlightImageWidth)/2
        var frame = selectedImageView.frame
        frame.origin.x = offsetX
        selectedImageView.frame = frame
    }
    
    open func pagerDidEndDragging(scrollView: UIScrollView) {
        // do nothing
    }
    
    open func pagerDidEndDecelerating(scrollView: UIScrollView) {
        // do nothing
    }
    
    open func pager(scrollView: UIScrollView, didSelectIndex index: Int) {
        selectIndex = index
    }
}
