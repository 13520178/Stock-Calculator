//
//  InfoController.swift
//  SalaryCalculator
//
//  Created by Phan Đăng on 10/22/20.
//

import UIKit
import MessageUI
import StoreKit


class InfoController: UIViewController, MFMailComposeViewControllerDelegate {
    
    let defaults = UserDefaults.standard
    var products: [SKProduct] = []

    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var resourceView: UIView!
    @IBOutlet weak var stairCalculatorView: UIView!
    @IBOutlet weak var autoLoanCalculatorView: UIView!
    @IBOutlet weak var restoreView: UIView!
    @IBOutlet weak var shareAppView: UIView!
    @IBOutlet weak var writeAReviewView: UIView!
    
    private let productURL = URL(string: "https://apps.apple.com/app/id1544187060")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IAPProduct.store.delegate = self
        
        let reportTap = UITapGestureRecognizer(target: self, action: #selector(sentMail))
        reportView.addGestureRecognizer(reportTap)
        
        let resourceTap = UITapGestureRecognizer(target: self, action: #selector(showResource))
        resourceView.addGestureRecognizer(resourceTap)
        
        let stairTap = UITapGestureRecognizer(target: self, action: #selector(openStair))
        stairCalculatorView.addGestureRecognizer(stairTap)
        
        let autoLoanTap = UITapGestureRecognizer(target: self, action: #selector(openAuto))
        autoLoanCalculatorView.addGestureRecognizer(autoLoanTap)
        
        let restoreTab = UITapGestureRecognizer(target: self, action: #selector(restoreIAP))
        restoreView.addGestureRecognizer(restoreTab)
        
        let shareAppTab = UITapGestureRecognizer(target: self, action: #selector(shareApp))
        shareAppView.addGestureRecognizer(shareAppTab)
        
        let writeReviewTab = UITapGestureRecognizer(target: self, action: #selector(writeReview))
        writeAReviewView.addGestureRecognizer(writeReviewTab)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    @objc func reload() {
        products = []
        IAPProduct.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                self.products = products!
            }
        }
    }
    
    @objc func shareApp() {
        // 1.
        let activityViewController = UIActivityViewController(
          activityItems: [productURL],
          applicationActivities: nil)
        
        // 2.
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func writeReview() {
        // 1.
        var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)
        
        // 2.
        components?.queryItems = [
          URLQueryItem(name: "action", value: "write-review")
        ]
        
        // 3.
        guard let writeReviewURL = components?.url else {
          return
        }
        
        // 4.
        UIApplication.shared.open(writeReviewURL)
    }
    
    
    @objc func restoreIAP() {
        if products.count >= 1 {
            AlertService.showInfoRestoreAlert(in: self, message: "Do you want to Restore your In App Purchase?", completion: { (isOK) in
                if isOK {
                    IAPProduct.store.restorePurchases()
                }
            })
        }
    }
    
    @objc func showResource() {
        AlertService.showInfoAlert(in: self, title: "Resource", message: "http://nhatdang.freetzi.com/")
        
    }
    
    
    @objc func openStair() {
        if let url = URL(string: "https://apps.apple.com/app/id1531071094"),
            UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc func openAuto() {
        if let url = URL(string: "https://apps.apple.com/app/id1542576418"),
            UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["phannhatd@gmail.com"])
        mailComposerVC.setSubject("Question about Stock Calculator")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Unable to send mail", message: "Your device cannot send mail", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @objc func sentMail() {
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showMailError()
        }
        
    }
    @IBAction func seeAllButtonPressed(_ sender: UIButton) {
    }
    
    func showOKAlert() {
        AlertService.showInfoAlert(in: self, title: "Notification", message: "Restore was successful!")
    }
    
}

extension InfoController: IAPDoneMaking {
    func purchase(){
        showOKAlert()
    }
}
