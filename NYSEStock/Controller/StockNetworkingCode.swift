//
//  StockRealmCode.swift
//  NYSEStock
//
//  Created by Ashish Ashish on 10/14/21.
//


import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit


extension StocksTableViewController{
    
    func doesStockExistInDB(_ symbol : String) -> Bool {
        do{
            let realm = try Realm()
            if realm.object(ofType: CompanyInfo.self, forPrimaryKey: symbol) != nil { return true }
            
        }catch{
            print("Error in getting values from DB \(error)")
        }
        return false
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
    
    func storeValuesInDB(_ symbol : String ){
        
        getCompanyInfo(symbol)
            .done { company in
                self.addStockinDB(company)
            }
            .catch{ (error) in
                print(error)
            }
    }
    
//    func removeStockFromDB(_ companyInfo : CompanyInfo){
//        do{
//            let realm = try Realm()
//            let object = realm.objects(CompanyInfo.self)
//            try realm.write({
//                realm.delete(companyInfo)
//            })
//        }catch{
//            print("Error in deleting values from DB \(error)")
//        }
//    }
    
    
    func getAllCompanyInfo(_ companies: [CompanyInfo] ) -> Promise<[CompanyInfo]> {
        
        var promises: [Promise< CompanyInfo >] = []
        
        for i in 0 ... companies.count - 1 {
            promises.append( getCompanyInfo(companies[i].symbol) )
        }
        
        return when(fulfilled: promises)
        
    }
    
    func getCompanyInfo(_ symbol : String) -> Promise<CompanyInfo>{
        return Promise<CompanyInfo> { seal -> Void in
            let url = companyProfileURL + symbol + "?apikey=" + apiKey
            
            AF.request(url).responseJSON { response in
                
                if response.error != nil {
                    seal.reject(response.error!)
                }
                
                let stocks = JSON( response.data!).array
                
                guard let firstStock = stocks!.first else { seal.fulfill(CompanyInfo())
                    return
                }
                
                let companyInfo = CompanyInfo()
                companyInfo.symbol = firstStock["symbol"].stringValue
                companyInfo.price = firstStock["price"].floatValue
                companyInfo.volAvg = firstStock["volAvg"].intValue
                companyInfo.companyName = firstStock["companyName"].stringValue
                companyInfo.exchangeShortName = firstStock["exchangeShortName"].stringValue
                companyInfo.website = firstStock["website"].stringValue
                companyInfo.desc = firstStock["description"].stringValue
                companyInfo.image = firstStock["image"].stringValue
                
                seal.fulfill(companyInfo)
                
            }
        }
    }// End of getCompanyInfo
}
