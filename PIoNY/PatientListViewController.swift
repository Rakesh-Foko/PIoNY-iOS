//
//  PatientListViewController.swift
//  PloNY
//
//  Created by Rakesh Tripathi on 2020-01-23.
//  Copyright © 2020 Rakesh Tripathi. All rights reserved.
//

import UIKit

class PatientListViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var table: UITableView!
    var patientList = [PatientModel]()
    var searchedPatient: PatientModel?
    var searchModeOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getPatientsList(isSearchOn: false)

    }
    
    func setupUI() {
        self.searchBar.delegate = self
        self.table.delegate = self
        self.table.dataSource = self
        
    }
    
    func showLoader(view: UIView) -> UIActivityIndicatorView {

              //Customize as per your need
              let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height:40))
              spinner.backgroundColor = UIColor.black.withAlphaComponent(0.7)
              spinner.layer.cornerRadius = 3.0
              spinner.clipsToBounds = true
              spinner.hidesWhenStopped = true
        spinner.style = UIActivityIndicatorView.Style.white;
              spinner.center = view.center
              view.addSubview(spinner)
              spinner.startAnimating()
              UIApplication.shared.beginIgnoringInteractionEvents()

              return spinner
          }
    
    func getPatientsList(isSearchOn: Bool){
        var baseUrl = URL.init(string: "")
        if isSearchOn == true {
             baseUrl = URL(string: "https://virtserver.swaggerhub.com/TactioHealth/piony/1.0.2/patients/\(searchBar.text ?? "0")")!
        }else {
             baseUrl = URL(string: "https://virtserver.swaggerhub.com/TactioHealth/piony/1.0.2/patients")!
        }
        let spinner = showLoader(view: self.view)

        guard let url = baseUrl else { return }
        
        let task = URLSession.shared.dataTask(with: url ) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                return
            }
            if self.searchModeOn == true {
                guard let patient = jsonString.toJSON() as? [String:Any] else { return }
                let patientObj = PatientModel.init(json: patient)
                self.searchedPatient = patientObj
            }else {
            guard let jsonPatientList = jsonString.toJSON() as? [[String:Any]] else { return }
            self.patientList.removeAll()
            for patient in jsonPatientList {
                let patientObj = PatientModel.init(json: patient)
                self.patientList.append(patientObj)
            }
            debugPrint("foo")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
                   spinner.dismissLoader()
                }
                
            DispatchQueue.main.async {
                self.table.reloadData()
            }
            }
        }

        task.resume()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let addPatientScreen = segue.destination as? AddPatientViewController else { return }
        if sender == nil {
            //Add a new patient
            addPatientScreen.isAddNewPatient = true
        }else {
            //Edit or view patient
            guard let selectedPatientObj = sender as? PatientModel else { return }
            addPatientScreen.patientInfoObj = selectedPatientObj
            addPatientScreen.isAddNewPatient = false
        }
    }
    
    @IBAction func addClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "to_details", sender: nil)
    }
    

}
extension PatientListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchModeOn == true {
            guard self.searchedPatient != nil else { return 0 }
            return 1
        }else {
            return min (25, self.patientList.count)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "patient_info_cell", for: indexPath) as! PatientInfoCell
        cell.name.text = "\(patientList[indexPath.row].firstName) \(patientList[indexPath.row].lastName)"
        cell.addr.text = "\(patientList[indexPath.row].city) \(patientList[indexPath.row].state)"
        cell.phone.text = patientList[indexPath.row].mobilePhone
        cell.conditions.text = patientList[indexPath.row].conditions.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "to_details", sender: patientList[indexPath.row])
    }
    
}

extension PatientListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard self.searchedPatient != nil else { return }
        self.view.endEditing(true)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchModeOn = true
        // call search Api
        getPatientsList(isSearchOn: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchModeOn = false
        self.view.endEditing(true)
        self.table.reloadData()
    }
}

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

extension UIActivityIndicatorView {
    func dismissLoader() {
           self.stopAnimating()
           UIApplication.shared.endIgnoringInteractionEvents()
       }
}
