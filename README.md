# MTOPagerViewController
MTORefresher is a iOS Container View Controller, like View Pager in Android.

![Screenshot](https://cloud.githubusercontent.com/assets/1996801/16556049/5f254a34-420a-11e6-9a35-402da6fd4660.png)

## Demo

### 1.create MTOPagerViewController

```Swift

private lazy var pagerMenuView: PagerMenuView = {
    let view = PagerMenuView(titles: ["History", "Favor"])
    view.highlightImageWidth = 65
    return view
}()
    
private lazy var pagerVC: MTOPagerViewController = {
    let pager = MTOPagerViewController(delegate: self, menu: self.pagerMenuView)
    return pager
}()
```

### 2.MTOPagerDelegate

```Swift
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
```

### 3.add to parent view controller

```Swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "MTOPagerViewController"
    
    self.edgesForExtendedLayout = .None
    self.view.addSubview(pagerMenuView)
    
    addChildViewController(pagerVC)
    self.view.addSubview(pagerVC.view)
}
```
