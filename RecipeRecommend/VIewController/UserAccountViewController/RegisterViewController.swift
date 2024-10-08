import UIKit
import PhotosUI

class RegisterViewController : UIViewController, UITextFieldDelegate, EditUserProfileCellDelegate {
    var user: User!
    
    var mainView : UIView = UIView()

    
    var registerButton : ZoomAnimatedButton = ZoomAnimatedButton()


    var buttonAttributedTitleContainer : AttributeContainer = AttributeContainer([.font : UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .medium)])
    
    var registering : Bool = false
    
    var userImage : UIImage? = nil
    
    var tableView : UITableView = UITableView()
    
    var registerStatus : Bool = false { didSet {
        registerButton.isEnabled = registerStatus
    }}
    
    var tableCellTextTuples : [(String, String?)] = [("名稱", nil), ("電子郵件", nil), ("密碼", nil), ("確認密碼", nil)] { didSet {
        guard !registering else {
            registerButton.isEnabled = false
            return
        }
        guard let name = tableCellTextTuples[0].1,
              let email = tableCellTextTuples[1].1,
              let password = tableCellTextTuples[2].1,
              let checkPassword = tableCellTextTuples[3].1,
              password == checkPassword
        else {
            registerButton.isEnabled = false
            return
        }
        registerStatus = true
        
    }}
    
    func tableViewSetup() {
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.rowHeight = UIScreen.main.bounds.height * 0.2
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        viewSetup()
        tableViewSetup()
        mainViewSetup()
        buttonSetup()
        
        initLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TapGestureHelper.shared.shouldAddTapGestureInWindow(view: self.view)
        
    }

    
    func buttonSetup() {
        [registerButton].forEach() {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 14
        }

        var config = UIButton.Configuration.filled()

        let registerAttributedString = AttributedString("註冊", attributes: self.buttonAttributedTitleContainer)
        config.attributedTitle = registerAttributedString
        config.baseBackgroundColor = .orangeTheme
        config.baseForegroundColor = .white
        registerButton.configuration = config
        registerButton.addTarget(self, action: #selector(registerButtonTapped ( _ :)), for: .touchUpInside)
        registerButton.isEnabled = false

        
        
    }

    @objc func registerButtonTapped(_ button : UIButton) {
         guard !registering else {
             return
         }
        guard let name = tableCellTextTuples[0].1,
              let email = tableCellTextTuples[1].1,
              let password = tableCellTextTuples[2].1 else {
            return
        }
        Task {
            var config = registerButton.configuration
            registerButton.configuration?.showsActivityIndicator = true
            registerButton.configuration?.title = nil
            do {
                registerButton.configuration?.showsActivityIndicator = false
                config?.title = "成功註冊"
                config?.attributedTitle = AttributedString("成功註冊！", attributes: self.buttonAttributedTitleContainer)
                config?.baseBackgroundColor = .systemGreen
                registerButton.configuration = config
                //try? await UserManager.shared.register(name: name, email: email, password: password, image: self.userImage)

                try await Task.sleep(nanoseconds: 1000000000)
                if let loginViewController = navigationController?.viewControllers.first as?  LoginViewController {
                    loginViewController.emailTextField.text = email
                    loginViewController.passwordTextField.text = password
                }
                self.navigationController?.popViewController(animated: true)
                
            } catch {
                registerButton.configuration = config
                registerButton.configuration?.showsActivityIndicator = false
                print(error)
            }
        }

     }
    
    
    
    func buttonLayout() {
        NSLayoutConstraint.activate([
            registerButton.widthAnchor.constraint(equalTo: view.widthAnchor,multiplier: 0.7),
            registerButton.heightAnchor.constraint(equalTo:  view.heightAnchor,multiplier: 0.06),
            registerButton.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -24),
            registerButton.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
        ])
    }

    
    
    
    func mainViewSetup() {
        mainView.clipsToBounds = true
        mainView.backgroundColor = .backgroundPrimary
        mainView.layer.cornerRadius = 32
    }
    
    func initLayout() {
        [mainView].forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
       /* [emailTextField, passwordTextField, emailLabel, warningLabel, passwordLabel, registerButton, , checkPasswordLabel, checkPasswordTextField].forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
            mainView.addSubview($0)
        }*/
        [tableView, registerButton].forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
            mainView.addSubview($0)
        }

        mainViewLayout()
       // labelLayout()
       // textFieldLayout()
        buttonLayout()
        tableViewLayout()
    }
    
    func mainViewLayout() {
        NSLayoutConstraint.activate([
            mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            mainView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75)
        ])
    }
    
    func tableViewLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: mainView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: -24),

            tableView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor)

        ])
    }
    
    func registerCell() {
        tableView.register(RegisterUserImageViewTableCell.self, forCellReuseIdentifier: "RegisterUserImageViewTableCell")
        tableView.register(TextFieldWithWarningLabelTableCell.self, forCellReuseIdentifier: "TextFieldWithWarningLabelTableCell")
        
    }
    
    func viewSetup() {
        self.view.backgroundColor = .accent
    }
    
}

extension RegisterViewController : PHPickerViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        var isSecureEntry = false
        if row >= 2 {
            isSecureEntry = true
        }
        
        
        if section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterUserImageViewTableCell", for: indexPath) as! RegisterUserImageViewTableCell
            cell.editUserProfileCellDelegate = self
            cell.configure(image: self.userImage ?? UIImage())
            return cell
        }
        let tuple = tableCellTextTuples[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldWithWarningLabelTableCell", for: indexPath) as! TextFieldWithWarningLabelTableCell
        cell.textFieldDelegate = self
        cell.textField.tag = row
        cell.configure(title: tuple.0, value: tuple.1, isSecureEntry: isSecureEntry)
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    
    func showImagePicker() {
        
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .automatic
        let phppicker = PHPickerViewController(configuration: configuration)
        phppicker.delegate = self
        
        present(phppicker, animated: true)
        
    }
    
    
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        
        picker.dismiss(animated: true, completion: nil)
        if results.isEmpty {
            return
        }
        let result = results[0]
        
        
        Task {
            do {
                let image = try await withCheckedThrowingContinuation { (continuation : CheckedContinuation<UIImage, Error>) in
                    
                    result.itemProvider.loadObject(ofClass: UIImage.self)   { (data, error) in
                        if let error = error {
                            continuation.resume(throwing: error)
                        }
                        
                        if let image = data as? UIImage {
                            continuation.resume(returning: image)

                        } else {
                            let error = NSError(domain: "ImageErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"])
                            continuation.resume(throwing: error)
                        }
                    }
                }
                self.userImage = image
                for cell in tableView.visibleCells {
                    if let cell = cell as? RegisterUserImageViewTableCell {
                        cell.configure(image: image)
                    }
                }
               
            } catch {
                print(error)
            }
            

            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return UIView(frame: .zero)
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        if section == 0 {
            return view.bounds.height * 0.1
        }
        return view.bounds.height * 0.18
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text as NSString? {

            let updatedText = text.replacingCharacters(in: range, with: string)

            for cell in tableView.visibleCells {
                if let cell = cell as? TextFieldWithWarningLabelTableCell {
                    
                    if cell.textField == textField {
                        let index = cell.textField.tag

                        tableCellTextTuples[index].1 = updatedText
                        
                        if let inValidStr = textFieldIsInValid(textField: textField, updatedText: updatedText, tag: index) {

                            cell.warningLabel.isHidden = false
                            cell.warningLabel.text = inValidStr
                        } else {
                            cell.warningLabel.isHidden = true
                        }
                        if index == 2 {
                            
                        }
                        break
                    }
                }
            }
        }
        
        return true
    }
    
    func textFieldIsInValid(textField : UITextField, updatedText : String, tag : Int) -> String? {

        let text = textField.text
        
        switch tag {
        case 0 :
            return nil
        case 1 :
            if let cell = tableView.cellForRow(at: IndexPath(row: tag, section: 0)) as? TextFieldWithWarningLabelTableCell
            {
                
            }
            return nil
        case 2 :
            if let passwordCell = tableView.cellForRow(at: IndexPath(row: tag, section: 0)) as? TextFieldWithWarningLabelTableCell,
               let checkCell = tableView.cellForRow(at: IndexPath(row: tag + 1, section: 0)) as? TextFieldWithWarningLabelTableCell
            {
              
            }
            return nil
        case 3 :
            if let checkCell = tableView.cellForRow(at: IndexPath(row: tag, section: 0)) as? TextFieldWithWarningLabelTableCell,
               let passwordCell = tableView.cellForRow(at: IndexPath(row: tag - 1, section: 0)) as? TextFieldWithWarningLabelTableCell
            {
                return passwordCell.textField.text == updatedText ? nil : "不相符"
            }
            return nil
        default :
            return nil
        }
    }
    


    
}

