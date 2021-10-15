//
//  DetailsViewController.swift
//  NYSEStock
//
//  Created by Ashish Ashish on 10/14/21.
//

import UIKit

class DetailsViewController: UIViewController {

    var companyInfo : CompanyInfo?
    
    @IBOutlet weak var lblSymbol: UILabel!
    
    
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblVolume: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let companyInfo = companyInfo else {return}
        lblSymbol.text = companyInfo.symbol
        lblCompanyName.text = companyInfo.companyName
        lblPrice.text = "\(companyInfo.price)"

        lblVolume.text = "\(companyInfo.volAvg)"


    }
    

}
