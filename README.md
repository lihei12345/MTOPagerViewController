# MTOPagerViewController
MTORefresher is a iOS Container View Controller.

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

