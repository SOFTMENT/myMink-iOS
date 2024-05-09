//
//  AddProductDelegate.swift
//  my MINK
//
//  Created by Vijay Rathore on 16/04/24.
//

import UIKit

protocol ProductDelegate {
    
    func addProduct(productModel : MarketplaceModel)
    func removeProduct(productModel : MarketplaceModel)
    func updateProduct(productModel : MarketplaceModel, position : Int)
    
}
