//
//  AlertService.swift
//  MulchCalculator
//
//  Created by Phan Đăng on 5/4/20.
//  Copyright © 2020 Phan Đăng. All rights reserved.
//

import Foundation
import UIKit

class AlertService {
    
    
    //MARK: - Comfirm purchase IAP
    static func showInfoAlertAndComfirm(in vc: UIViewController, message:String, completion: @escaping (_ okOrRestore: Bool)->Void)  {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in
            completion(true)
        }
        
        let restore = UIAlertAction(title: "Restore", style: .default) { (_) in
            completion(false)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(restore)
        alert.addAction(ok)
        alert.addAction(cancel)
        vc.present(alert,animated: true )
    }
    
    //MARK: - Comfirm Restore IAP
    static func showInfoRestoreAlert(in vc: UIViewController, message: String , completion: @escaping (_ okOrRestore: Bool)->Void)  {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let restore = UIAlertAction(title: "Restore", style: .default) { (_) in
            completion(true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(restore)
        alert.addAction(cancel)
        vc.present(alert,animated: true )
    }
    
    static func showInfoAlert(in vc: UIViewController, title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(ok)
        vc.present(alert,animated: true )
    }

}
