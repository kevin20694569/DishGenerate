import UIKit

class MainTabBarViewController : UIViewController, UITabBarDelegate {
    
    static var shared : MainTabBarViewController! = MainTabBarViewController()
    
    var mainNavViewController : MainNavgationController!
    
    var userProfileNavViewController : UserProfileNavViewController!
    
   // var savedDishesNavViewController : UINavigationController!
    
    var preferenceNavViewController : UINavigationController!
    
    static var bottomBarFrame : CGRect! = .zero
    
    var currentIndex : Int! = 0
    
    var tabBar : UITabBar! = UITabBar()
    
    var bottomBarView : UIView! = UIView()
    
    lazy var viewControllers : [UINavigationController] = [preferenceNavViewController, mainNavViewController , userProfileNavViewController]
    
    var itemImages : [UIImage] = [ UIImage(systemName: "rectangle.and.pencil.and.ellipsis.rtl")!  ,UIImage(systemName: "house")!, UIImage(systemName: "person.circle.fill")!]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        childViewControllersSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarSetup()
        tabBarLayout()
        layoutSetup()
        self.view.backgroundColor = .primaryBackground
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        MainTabBarViewController.bottomBarFrame = self.view.convert(bottomBarView.frame, to: nil)
    }
    
    
    lazy var bottomBarViews : [UIView] = [bottomBarView, tabBar]
    
    func childViewControllersSetup() {
        let mainTableViewController = RecipeTableViewController()

        self.mainNavViewController = MainNavgationController(rootViewController: mainTableViewController)
        mainNavViewController.mainDishViewController = mainTableViewController
        
        let userProfileViewController = UserProfileViewController()
        let userProfileNavViewController = UserProfileNavViewController(rootViewController: userProfileViewController)
        self.userProfileNavViewController = userProfileNavViewController
        
    //    let savedDishesViewController = SavedRecipesViewController()
        
     //   let savedDishesNavViewController = UINavigationController(rootViewController: savedDishesViewController)
       // self.savedDishesNavViewController = savedDishesNavViewController
        
        self.preferenceNavViewController = UINavigationController(rootViewController: DisplayPreferenceViewController())
       
    }
    
    func tabBarLayout() {
        self.view.addSubview(bottomBarView)
        self.view.addSubview(tabBar)
        self.view.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            bottomBarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            bottomBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)

        ])
        self.view.layoutIfNeeded()
        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            bottomBarView.topAnchor.constraint(equalTo: tabBar.topAnchor)
        ])
        self.view.layoutIfNeeded()
        
        bottomBarView.backgroundColor = .themeColor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //MainTabBarViewController.bottomBarFrame = self.view.convert(bottomBarView.frame, to: nil)
    }
    
    func layoutSetup() {
        showViewController(at: 1)
        self.view.addSubview(bottomBarView)
        self.view.addSubview(tabBar)
    }
    
    func tabBarSetup() {
        tabBar.isTranslucent = false
        tabBar.standardAppearance.configureWithOpaqueBackground()
        tabBar.scrollEdgeAppearance?.configureWithOpaqueBackground()
        tabBar.selectedItem?.isEnabled = true
        tabBar.barStyle = .default
        tabBar.barTintColor = .themeColor
        //tabBar.barTintColor = .clear
        let normalConfig = UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .title2, weight: .medium))
        let selectedConfig = UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .title2, weight: .medium))
        
        let items = viewControllers.enumerated().compactMap { (index, nav) in
            let image = itemImages[index]
            let item = UITabBarItem(title: nil, image: image.withConfiguration(normalConfig).withTintColor(.secondaryLabelColor, renderingMode: .alwaysOriginal), selectedImage: image.withConfiguration(selectedConfig).withTintColor(.white, renderingMode: .alwaysOriginal))
            item.tag = index
            return item
        } 
        tabBar.setItems(items, animated: false)
        tabBar.selectedItem = tabBar.items?[1]
        tabBar.delegate = self
    }
    
    func showViewController(at index: Int) {
        let selectedViewController = viewControllers[index]
        if currentIndex == index {
            selectedViewController.popToRootViewController(animated: true)
            return
        }
        currentIndex = index
        view.addSubview(selectedViewController.view)
        selectedViewController.didMove(toParent: self)
        for (i, viewController) in viewControllers.enumerated() {
            if i != index {
                viewController.view.removeFromSuperview()
                viewController.removeFromParent()
            }
        }
        bottomBarViews.forEach() {
            view.addSubview($0)
        }
        self.tabBar.selectedItem = tabBar.items?[index]
    }
    
    func getTopViewController() -> UIViewController? {
        var topController : UIViewController = viewControllers[self.currentIndex]

        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }

        return topController
    }
}


extension MainTabBarViewController  {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        showViewController(at: item.tag)
    }
}


