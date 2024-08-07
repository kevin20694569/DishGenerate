
import UIKit

class UserProfileViewController : UIViewController, EditUserNameViewControllerDelegate {
    func reloadRecipe(recipe: Recipe) {
      /*  guard let index = historyDishes.firstIndex(of: recipe) else {
            return
        }
        let indexPath = IndexPath(row: index, section: 1)
        if let cell = collectionView.cellForItem(at: indexPath) as? DishDelegate  {
            cell.reloadDish(recipe: recipe)
        }*/
    }
    
    var isLoadingNewDishes : Bool = false
    
    func reloadUserName() {
        
        self.collectionView.reloadSections([0])
        
    }
    
    var user_id : String = Environment.user_id
    
    
    var collectionView : UICollectionView! = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    var historyDishes : [Recipe] = Recipe.examples
    
    var user : User! = User.example
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadDishNotification(_:)), name: .reloadDishNotification, object: nil)
        registerCell()
        registerReuseHeaderView()
        viewSetup()
        collectionViewFlowSetup()
        navItemSetup()
        initLayout()
        collectionViewSetup()
        Task {
            await reloadCollectionView()
        }
    }
    
    func reloadCollectionView() async {
        defer {
            collectionView.refreshControl?.endRefreshing()
        }
       /* do {
            let newDishes = try await RecipeManager.shared.getDishesOrderByCreatedTime(user_id: self.user_id, beforeTime: "")
            self.historyDishes.removeAll()
            self.historyDishes.append(contentsOf: newDishes)
            collectionView.performBatchUpdates ({

                self.collectionView.reloadSections([1])
            }) { bool in
 
            }
        } catch {
            print("reloadCollectionViewError", error)
        }*/
    }
    
    func insertNewDishes(newDishes : [Recipe], insertFunc: insertFuncToArray ) {
        
        let newIndexPaths = (historyDishes.count...historyDishes.count + newDishes.count - 1).compactMap { index in
            return IndexPath(row: index, section: 1)
        }
        collectionView.performBatchUpdates {
            if insertFunc == .unshift {
                self.historyDishes.insert(contentsOf: newDishes, at: 0)
            } else {
                self.historyDishes.insert(contentsOf: newDishes, at: self.historyDishes.count)
            }
            collectionView.insertItems(at: newIndexPaths)
        }
    }
        
    
    
    @objc func handleReloadDishNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo, let dish = userInfo["recipe"] as? Recipe  {
            reloadRecipe(recipe: dish)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navBarSetup()
    }
    
    func navBarSetup() {
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        self.navigationController?.navigationBar.scrollEdgeAppearance?.configureWithTransparentBackground()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func collectionViewSetup() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.delaysContentTouches = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: MainTabBarViewController.bottomBarFrame.height + 16, right: 0)
        collectionView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: MainTabBarViewController.bottomBarFrame.height, right: 0)
    }
    
    func collectionViewFlowSetup() {
        let flow = UICollectionViewFlowLayout()
        self.collectionView.collectionViewLayout = flow
    }
    func registerCell() {
        self.collectionView.register(UserDetailCollectionCell.self, forCellWithReuseIdentifier: "UserDetailCollectionCell")
        self.collectionView.register(SavedDishCell.self, forCellWithReuseIdentifier: "SavedDishCell")
        
        self.collectionView.register(UserProfileDishDateCell.self, forCellWithReuseIdentifier: "UserProfileDishDateCell")
    }
    
    func registerReuseHeaderView() {
        collectionView.register(LeadingLogoHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "LeadingLogoHeaderView")
    }
    
    func viewSetup() {
        self.view.backgroundColor = .primaryBackground
    }
    
    func navItemSetup() {
        self.navigationItem.title = "個人檔案"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
    
    func initLayout() {
        
        [collectionView].forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    
}

extension UserProfileViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ShowRecipeViewControllerDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return historyDishes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserDetailCollectionCell", for: indexPath) as! UserDetailCollectionCell
            
            cell.userProfileCellDelegate = self
            cell.configure(user: user)
            return cell
        }
        let dish = historyDishes[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SavedDishCell", for: indexPath) as!  SavedDishCell
    
        cell.configure(dish: dish)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LeadingLogoHeaderView", for: indexPath) as! LeadingLogoHeaderView
        if indexPath.section == 1 {
            headerView.configure(logoImage: UIImage(systemName: "clock")!, title: "瀏覽紀錄")
        }
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let bounds = view.bounds
        if section == 0 {
            return UIEdgeInsets(top: bounds.height * 0.02, left: 0, bottom: bounds.height * 0.04, right: 0)
        }
        return UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = view.bounds
        if indexPath.section == 0 {
            return CGSize(width: bounds.width, height: bounds.height * 0.15)
        }
        return CGSize(width: (bounds.width - 6)  / 3, height: bounds.height * 0.2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let bounds = view.bounds
        if section == 0 {
           
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: bounds.width, height: bounds.height * 0.04)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.section != 1 {
            return false
        }
    
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.visibleCells.forEach() {
            $0.isSelected = false
        }
        guard indexPath.section == 1 else {
            return
        }
        let dish = historyDishes[indexPath.row]
       /* if recipe.status == .already {
            self.showDishDetailViewController(recipe: recipe)
        } else {
            showDishSummaryDisplayController(dishes: [recipe])
        }*/
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !isLoadingNewDishes else {
            return
        }
       /* guard let created_time = self.historyDishes.last?.created_Time else {
            return
        }
        if self.historyDishes.count - indexPath.row == 5 {
            isLoadingNewDishes = true
            
            Task {
                let newDishes = try await RecipeManager.shared.getDishesOrderByCreatedTime(user_id: self.user_id, beforeTime: created_time)
                
                insertNewDishes(newDishes: newDishes, insertFunc: .push)
                isLoadingNewDishes = false
            }
        }*/
    }
}

extension UserProfileViewController : UserProfileCellDelegate {
    
}











