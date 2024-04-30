//
//  CreateUserViewController.swift
//  Tripzo -Travel Planner Application
//
//  Created by Tanzim Islam Khan on 25/4/2024.
//

import UIKit
import Firebase

class CreateUserViewController: UIViewController, DatabaseListener {
    
    
    
    func onSignIn() {
        //
    }
    
    func onNewUser(userDetails: Users?) {
        if let userDetails = userDetails {
               // Pre-fill the form fields with userDetails
               nameField.text = userDetails.name
               emailField.text = userDetails.email
               // Additional fields can be pre-filled similarly
           }
           // Navigate to the CreateUserViewController if not already there
           performSegue(withIdentifier: "showCreateUser", sender: self)
    }
    
    
    
    
    let countryPicker = UIPickerView()
    
    let countries = [
        "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina",
        "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh",
        "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia",
        "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso",
        "Burundi", "Côte d'Ivoire", "Cabo Verde", "Cambodia", "Cameroon", "Canada", "Central African Republic",
        "Chad", "Chile", "China", "Colombia", "Comoros", "Congo (Congo-Brazzaville)",
        "Costa Rica", "Croatia", "Cuba", "Cyprus", "Czechia (Czech Republic)", "Democratic Republic of the Congo",
        "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador",
        "Equatorial Guinea", "Eritrea", "Estonia", "Eswatini (fmr. Swaziland)", "Ethiopia",
        "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece",
        "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Holy See",
        "Honduras", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland",
        "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati",
        "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya",
        "Liechtenstein", "Lithuania", "Luxembourg", "Madagascar", "Malawi", "Malaysia",
        "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico",
        "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique",
        "Myanmar (formerly Burma)", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand",
        "Nicaragua", "Niger", "Nigeria", "North Korea", "North Macedonia", "Norway", "Oman",
        "Pakistan", "Palau", "Palestine State", "Panama", "Papua New Guinea", "Paraguay",
        "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda",
        "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa",
        "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles",
        "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa",
        "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden",
        "Switzerland", "Syria", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo",
        "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu",
        "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States of America",
        "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"
    ]

    
    let genderPicker = UIPickerView()
    let genders = ["Male", "Female", "Other"]
    
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    
    @IBOutlet weak var countryField: UITextField!
    
    
    @IBOutlet weak var genderField: UITextField!
    
    
    @IBOutlet weak var passwordField: UITextField!
    
    var listenerType = ListenerType.all
    
    
    func onAccountCreated() {
        //
    }
    
    func onError(_ error: Error) {
        let message = error.localizedDescription
        DispatchQueue.main.async {
                self.displayMessage(title: "Sign Up Error", message: message)
            }
    }
    
    func onSignOut() {
        //
    }
    
    weak var databaseController: DatabaseProtocol?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
        
        countryPicker.delegate = self
        countryPicker.dataSource = self
                
                // Set the input view of the text field to the country picker
        countryField.inputView = countryPicker
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderField.inputView = genderPicker

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    @IBAction func createAccountPressed(_ sender: Any) {
        
        print("Adding user")

            guard let name = nameField.text, !name.isEmpty else {
                displayMessage(title: "Error", message: "Missing name")
                return
            }

            guard let country = countryField.text, !country.isEmpty else {
                displayMessage(title: "Error", message: "Missing country")
                return
            }

            guard let gender = genderField.text, !gender.isEmpty else {
                displayMessage(title: "Error", message: "Please select gender")
                return
            }

            // Check if user is already signed in through Google/Facebook
            databaseController?.getCurrentUser { [weak self] user in
                DispatchQueue.main.async {
                    if let user = user {
                        // User is already signed in, just update additional info
                        self?.databaseController?.addUser(name: name, phoneNumber: "0333333", country: country, gender: gender, email: user.email)
                        self?.performSegue(withIdentifier: "success", sender: self)
                    } else {
                        // No user is signed in, create new account with email and password
                        guard let email = self?.emailField.text, !email.isEmpty, self?.isValidEmail(email) ?? false else {
                            self?.displayMessage(title: "Error", message: "Invalid Email")
                            return
                        }

                        guard let password = self?.passwordField.text, !password.isEmpty else {
                            self?.displayMessage(title: "Error", message: "Missing password")
                            return
                        }

                        self?.databaseController?.createAccountWithEmail(email: email, password: password) { success, error in
                            DispatchQueue.main.async {
                                if success {
                                    // User was created, now add additional details
                                    self?.databaseController?.addUser(name: name, phoneNumber: "0333333", country: country, gender: gender, email: email)
                                    self?.performSegue(withIdentifier: "success", sender: self)
                                } else if let error = error {
                                    self?.displayMessage(title: "Error", message: error.localizedDescription)
                                }
                            }
                        }
                    }
                }
            }
        
    }
    
    func isValidEmail(_ email: String) -> Bool {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
            return emailTest.evaluate(with: email)
    }
    
    func displayMessage(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CreateUserViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == countryPicker {
            return countries.count
        } else if pickerView == genderPicker {
            return genders.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == countryPicker {
            return countries[row]
        } else if pickerView == genderPicker {
            return genders[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == countryPicker {
            countryField.text = countries[row]
        } else if pickerView == genderPicker {
            genderField.text = genders[row]
        }
    }
}

