Pod::Spec.new do |s|
  s.name		          = "MTOPagerViewController"
  s.version          	= "0.1.0"
  s.summary          	= "MTORefresher is a Swift implementation of View Pager"
  s.description      	= "MTORefresher is a Swift implementation of View Pager. It's completed by iOS Container View Controller. You can custom your own menu view."
  s.homepage         	= "https://github.com/lihei12345/MTOPagerViewController"
  s.license           = 'MIT'
  s.author           	= { "lifuqiang" => "195135955@qq.com" }
  s.source	      	  = { :git => "https://github.com/lihei12345/MTOPagerViewController.git", :tag => s.version.to_s }
  s.platform		      = :ios, '8.0'
  s.requires_arc    	= true
  s.default_subspec   = "Core" 

  s.subspec "Core" do |ss|
    ss.source_files   = "Source/*.swift"
    ss.framework      = "UIKit"
  end

  s.subspec "PagerMenuView" do |ss|
    ss.source_files   = "PagerMenuView/*.swift"
    ss.dependency "MTOPagerViewController/Core"
  end
end