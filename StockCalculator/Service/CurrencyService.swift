//
//  CurrencyService.swift
//  Paint Calculator
//
//  Created by Phan Đăng on 5/25/20.
//  Copyright © 2020 Phan Đăng. All rights reserved.
//

import Foundation

class CurrencyService {
    static func changeToCurrency(moneyStr:String) ->String? {
        let number:Double? = Double(moneyStr)
        if let number = number {
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.decimal
            return formatter.string(from: NSNumber(value: number))
        }
        return ""
    }
    
    static func replaceSpace(string:String) -> String {
        let newString = string.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        return newString
    }
    
    static func removeDolar(string:String) -> String {
        let newString = string.replacingOccurrences(of: "$", with: "", options: .literal, range: nil)
        return newString
    }
//
}
