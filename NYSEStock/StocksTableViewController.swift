//
//  StocksTableViewController.swift
//  NYSEStock
//
//  Created by Ashish Ashish on 10/7/21.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit

class StocksTableViewController: UITableViewController {
    
    var arr = ["ABCD","EFGH"]
    
    let stockQuoteURL = "https://financialmodelingprep.com/api/v3/quote-short/"
    let companyProfileURL = "https://financialmodelingprep.com/api/v3/profile/"
    let apiKey = "65a61eae62f70d8bbaa99f9c0729ab08"
    
    @IBOutlet var tblView: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadStockValues()
       
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = arr[indexPath.row]

        return cell
    }
    
    
    
    @IBAction func addStockAction(_ sender: Any) {
        var globalTextField: UITextField?
        
        let actionController = UIAlertController(title: "Add Stock Symbol", message: "", preferredStyle: .alert)
        
        let OKButton = UIAlertAction(title: "OK", style: .default) { action in
            guard let symbol = globalTextField?.text else {return}
            
            if symbol == "" {
                return
            }
            self.storeValuesInDB(symbol.uppercased())
    
            
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print(" I am in cancel")
        }
        actionController.addAction(OKButton)
        actionController.addAction(cancelButton)
        
        actionController.addTextField { stockTextField in
            stockTextField.placeholder = "Stock Symbol"
            globalTextField = stockTextField
        }
        
        self.present(actionController, animated: true, completion: nil)
        
    }
    
    func storeValuesInDB(_ symbol : String ){
        
        getCompanyInfo(symbol)
            .done { companyJSON in
                
                if companyJSON.count == 0 {
                    return
                }
                                
                let companyInfo = CompanyInfo()
                companyInfo.symbol = companyJSON["symbol"].stringValue
                companyInfo.price = companyJSON["price"].floatValue
                companyInfo.volAvg = companyJSON["volAvg"].intValue
                companyInfo.companyName = companyJSON["companyName"].stringValue
                companyInfo.exchangeShortName = companyJSON["exchangeShortName"].stringValue
                companyInfo.website = companyJSON["website"].stringValue
                companyInfo.desc = companyJSON["description"].stringValue
                companyInfo.image = companyJSON["image"].stringValue
                
                self.addStockinDB(companyInfo)
                
            }
            .catch{ (error) in
                print(error)
            }
    }
    
    
    func addStockinDB(_ companyInfo : CompanyInfo){
        do{
            let realm = try Realm()
            try realm.write {
                realm.add(companyInfo, update: .modified)
            }
        }catch{
            print("Error in getting values from DB \(error)")
        }
    }
    
    
    
    func doesStockExistInDB(_ symbol : String) -> Bool {
        do{
            let realm = try Realm()
            if realm.object(ofType: CompanyInfo.self, forPrimaryKey: symbol) != nil { return true }
        
        }catch{
            print("Error in getting values from DB \(error)")
        }
        return false
    }
    
    func getCompanyInfo(_ symbol : String) -> Promise <JSON> {
        
        return Promise< JSON > { seal -> Void in
            
            let url = companyProfileURL + symbol + "?apikey=" + apiKey
                        
            AF.request(url).responseJSON { response in
        
                if response.error != nil {
                    seal.reject(response.error!)
                }
                
                let stocks = JSON( response.data!).array
            
                guard let firstStock = stocks!.first else { seal.fulfill(JSON())
                    return
                }
                
                seal.fulfill(firstStock)
                
            }// AF Response JSON
        }// Promise return
    }// End of function
    
    
    func loadStockValues(){
        
        do{
            let realm = try Realm()
            let companies = realm.objects(CompanyInfo.self)
            
            arr.removeAll()
            
            for company in companies{
                arr.append( "\(company.symbol) \(company.companyName)" )
            }
            
            tblView.reloadData()
            
            
            
        }catch{
            print("Error in reading Daatabase \(error)")
        }
        
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */


}
