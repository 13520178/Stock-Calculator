//
//  Tools.swift
//  MulchCalculator
//
//  Created by Phan Đăng on 5/4/20.
//  Copyright © 2020 Phan Đăng. All rights reserved.
//

import Foundation
class Tools {
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    static func addDotToCurrencyString(money:String,cha:Character) -> String {
        var newMoney = money
        if newMoney.count == 4 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 1))
        }else if newMoney.count == 5 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 2))
        }else if newMoney.count == 6 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 3))
        }else if newMoney.count == 7 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 4))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 1))
        }else if newMoney.count == 8 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 5))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 2))
        }else if newMoney.count == 9 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 6))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 3))
        }else if newMoney.count == 10 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 7))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 4))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 1))
        }else if newMoney.count == 11 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 8))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 5))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 2))
        }else if newMoney.count == 12 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 9))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 6))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 3))
        }else if newMoney.count == 13 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 10))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 7))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 4))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 1))
        }else if newMoney.count == 14 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 11))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 8))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 5))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 2))
        }else if newMoney.count == 15 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 12))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 9))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 6))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 3))
        }else if newMoney.count == 16 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 13))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 10))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 7))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 4))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 1))
        }else if newMoney.count == 17 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 14))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 11))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 8))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 5))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 2))
        }
        return newMoney
    }
    
    static func fixCurrencyTextInTextfield(moneyStr:String) ->String? {
        
        var afterFixString = moneyStr
        
        afterFixString = afterFixString.replacingOccurrences(of: ",", with: "", options: .literal, range: nil)
        
        let numOfDot = moneyStr.components(separatedBy:".").count - 1
        if numOfDot > 1 {
            afterFixString = String(afterFixString.dropLast())
        }
        
        let commaStringArray = afterFixString.components(separatedBy: ".")
        var beforeCommaString = commaStringArray[0]
        if beforeCommaString.count >= 15 {
            beforeCommaString = String(beforeCommaString.dropLast())
        }
        beforeCommaString = Tools.addDotToCurrencyString(money: beforeCommaString, cha: ",")
        
        print(beforeCommaString)
        
        if commaStringArray.count == 2 {
            var afterCommaString = commaStringArray[1]
            if afterCommaString.count > 2 {
                afterCommaString = String(afterCommaString.dropLast())
            }
            print(afterCommaString)
            return beforeCommaString + "." + afterCommaString
        }
        return beforeCommaString
        
    }
    
    static func changeToCurrency(moneyStr:Double) ->String? {
        let number = moneyStr
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        return formatter.string(from: NSNumber(value: number))
    }
    
}

extension String {
    var stringByRemovingWhitespaces: String {
        return components(separatedBy: .whitespaces).joined()
    }
}

extension Decimal {
    mutating func round(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) {
        var localCopy = self
        NSDecimalRound(&self, &localCopy, scale, roundingMode)
    }
    
    func rounded(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) -> Decimal {
        var result = Decimal()
        var localCopy = self
        NSDecimalRound(&result, &localCopy, scale, roundingMode)
        return result
    }
}
