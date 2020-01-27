//
//  AddPatientViewController.swift
//  PloNY
//
//  Created by Rakesh Tripathi on 2020-01-23.
//  Copyright © 2020 Rakesh Tripathi. All rights reserved.
//

import UIKit

class AddPatientViewController: UIViewController {
    
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var postalCode: UITextField!
    @IBOutlet weak var conditions: UITextField!
    @IBOutlet weak var airQualityLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var showAirQualityLabel: UILabel!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var patientInfoObj: PatientModel?
    var isAddNewPatient = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        // Get polution level
        if !isAddNewPatient {
            guard let patientInfo = self.patientInfoObj else { return }
            self.getPatientLocationAirQuality(postalCode: patientInfo.postalCode)
        }
    }
    
    func setupUI() {
        if isAddNewPatient {
            self.airQualityLabel.isHidden = true
            self.showAirQualityLabel.isHidden = true
            self.deleteButton.isEnabled = false
        }else{
            self.deleteButton.isEnabled = true

            guard let patientInfo = patientInfoObj else { return }
            self.id.text = "\(patientInfo.id)"
            self.phoneNumber.text = patientInfo.mobilePhone
            self.firstName.text = patientInfo.firstName
            self.lastName.text = patientInfo.lastName
            self.city.text = patientInfo.city
            self.postalCode.text = "\(patientInfo.postalCode)"
            self.conditions.text = patientInfo.conditions.name
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        if !isAddNewPatient {
            deleteAPatient()
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if isAddNewPatient {
            //Add New
            sendNewPatientData(isUpdate: false)
        }else {
            // Update
            sendNewPatientData(isUpdate: true)
        }
    }
    
    func makeNewPatientObj() -> PatientModel {
        return PatientModel.init(id: Int(self.id.text ?? "0") ?? 0, mobilePhone: self.phoneNumber.text ?? "", firstName: self.firstName.text ?? "", lastName: self.lastName.text ?? "", streerAdress:"", city: self.city.text ?? "", state:"", postalCode: Int(self.postalCode.text ?? "") ?? 0, conditions: ConditionsModel.init(id: 0, name: self.conditions.text ?? "", desc: ""), status: true)
    }
    
    func getPatientJson() -> [String:Any] {
        return
        [ "id": "\(self.id.text ?? "0")",
        "mobilePhone" : "\(self.phoneNumber.text ?? "0")",
        "firstName" : "\(self.firstName.text ?? "")",
        "lastName" : "\(self.lastName.text ?? "")",
        "streerAdress" : "",
        "city" : "\(self.city.text ?? "")",
        "state" : "",
        "postalCode" : "\(self.postalCode.text ?? "")",
        "conditions" : [
        "id" : "1",
        "name" : "\(self.conditions.text ?? "")",
          "description" : ""
        ],
        "status" : "active"
        ]
    }
    
    
    func sendNewPatientData(isUpdate: Bool) {
        // prepare json data
        let json = self.getPatientJson()

        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        // create post request
        let url = URL(string: "https://virtserver.swaggerhub.com/TactioHealth/piony/1.0.2/patients")!
        var request = URLRequest(url: url)
        if isUpdate {
            request.httpMethod = "PUT"
        }else{
            request.httpMethod = "POST"
        }
        // insert json data to the request
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
            //call successful
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }

        task.resume()
    }
    
    func deleteAPatient(){
        
        // create Delete request
        let url = URL(string: "https://virtserver.swaggerhub.com/TactioHealth/piony/1.0.2/patients\(self.id.text ?? "")")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        deleteButton.isEnabled = false
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
            //call successfull
            DispatchQueue.main.async {
                self.deleteButton.isEnabled = true
                self.navigationController?.popViewController(animated: true)
            }
        }

        task.resume()
        
    }
    
    func getPatientLocationAirQuality(postalCode: Int) {
        let url = URL(string: "https://open.propellerhealth.com/prod/forecast?postalCode=\(postalCode)")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                return
            }
            guard let jsonPatientAirInfo = jsonString.toJSON() as? [String:Any] else { return }
            guard let airQualityJson = jsonPatientAirInfo["properties"] as? [String:Any] else { return }
            guard let airQualityStr = airQualityJson["code"] as? String else { return }
            debugPrint("foo")
            DispatchQueue.main.async {
                // Update Air Quality
                self.airQualityLabel.text = airQualityStr
            }
        }

        task.resume()
    }
    
    
    
}
