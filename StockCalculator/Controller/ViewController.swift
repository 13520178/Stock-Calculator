//
//  ViewController.swift
//  StockCalculator
//
//  Created by Phan Đăng on 12/10/20.
//

import UIKit
import StoreKit
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

class ViewController: UIViewController,GADBannerViewDelegate,GADInterstitialDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var bannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var heightFromInputToResultContraint: NSLayoutConstraint!
    @IBOutlet weak var heightFromCalculateButtonToInputViewBottomConstraint: NSLayoutConstraint!
    var interstitial: GADInterstitial!
    

    @IBOutlet weak var numberOfSharesTextfield: UITextField!
    @IBOutlet weak var buyingPriceTextfield: UITextField!
    @IBOutlet weak var sellingPriceTextfield: UITextField!
    @IBOutlet weak var buyCommissionTextfield: UITextField!
    @IBOutlet weak var sellCommissionTextfield: UITextField!
    @IBOutlet weak var buyCommissionSegment: UISegmentedControl!
    @IBOutlet weak var sellCommissionSegment: UISegmentedControl!
    
    @IBOutlet weak var inputShadowView: UIView!
    @IBOutlet weak var removeAdsButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //input value
    var numberOfSharesToShowResult = 0.0
    var buyingPriceToShowResult = 0.0
    var sellingPriceToShowResult = 0.0
    var buyingCommissionInputToShowResult = 0.0
    var sellingCommissionInputToShowResult = 0.0
    
    //result value
    var netBuyingPriceToShowResult = 0.0
    var buyingCommissionResultToShowResult = 0.0
    var netSellingPriceToShowResult = 0.0
    var sellingCommissionResultToShowResult = 0.0
    var profitToShowResult = 0.0
    var roiToShowResult = 0.0
    var breakEvenSharePriceToShowResult = 0.0

    
    var products: [SKProduct] = []
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IAPProduct.store.delegate = self
        if !defaults.bool(forKey: "isRemoveAds"){
            bannerView.delegate = self
            bannerView.adUnitID = "ca-app-pub-9626752563546060/7242960380"
            //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //Test
            bannerView.rootViewController = self
            
            //interstitial
            interstitial = createAndLoadInterstitial()
        }
        
        numberOfSharesTextfield.setBottomBorder()
        buyingPriceTextfield.setBottomBorder()
        sellingPriceTextfield.setBottomBorder()
        buyCommissionTextfield.setBottomBorder()
        sellCommissionTextfield.setBottomBorder()
        
        numberOfSharesTextfield.delegate = self
        buyingPriceTextfield.delegate = self
        sellingPriceTextfield.delegate = self
        buyCommissionTextfield.delegate = self
        sellCommissionTextfield.delegate = self
        
        numberOfSharesTextfield.backgroundColor = UIColor(named: "Textfield Color")
        buyingPriceTextfield.backgroundColor = UIColor(named: "Textfield Color")
        sellingPriceTextfield.backgroundColor = UIColor(named: "Textfield Color")
        buyCommissionTextfield.backgroundColor = UIColor(named: "Textfield Color")
        sellCommissionTextfield.backgroundColor = UIColor(named: "Textfield Color")
        
        inputShadowView.layer.shadowColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        inputShadowView.layer.shadowOpacity = 0.5
        inputShadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        inputShadowView.layer.shadowRadius = 6
        
        scrollView.backgroundColor = UIColor(named: "Background Color")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        //Input format
        numberOfSharesTextfield.addTarget(self, action: #selector(numberOfSharesTextfieldDidChange), for: .editingChanged)
        buyingPriceTextfield.addTarget(self, action: #selector(buyingPriceTextfieldDidChange), for: .editingChanged)
        sellingPriceTextfield.addTarget(self, action: #selector(sellingPriceTextfieldDidChange), for: .editingChanged)
        buyCommissionTextfield.addTarget(self, action: #selector(buyCommissionTextfieldDidChange), for: .editingChanged)
        sellCommissionTextfield.addTarget(self, action: #selector(sellCommissionTextfieldDidChange), for: .editingChanged)
        
    }
    
    func requestIDFA() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                self.bannerView.load(GADRequest())
                self.interstitial = self.createAndLoadInterstitial()
            })
        } else {
            self.bannerView.load(GADRequest())
            interstitial = createAndLoadInterstitial()
        }
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
        if !defaults.bool(forKey: "isRemoveAds"){
            removeAdsButton.isHidden = false
            loadBannerAd()
            requestIDFA()
            self.heightFromCalculateButtonToInputViewBottomConstraint.constant = 70
        }else {
            removeAdsButton.isHidden = true
            self.bannerView.isHidden = true
            self.heightFromInputToResultContraint.constant = 0
            self.heightFromCalculateButtonToInputViewBottomConstraint.constant = 25
        }
    }
    
    
    // BANNER MAKING
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.loadBannerAd()
        })
    }
    
    func loadBannerAd() {
        // Step 2 - Determine the view width to use for the ad width.
        let frame = { () -> CGRect in
            // Here safe area is taken into account, hence the view frame is used
            // after the view has been laid out.
            if #available(iOS 11.0, *) {
                return view.frame.inset(by: view.safeAreaInsets)
            } else {
                return view.frame
            }
        }()
        let viewWidth = frame.size.width
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        
        bannerHeightConstraint.constant = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth).size.height
        print( bannerHeightConstraint.constant )
        bannerView.load(GADRequest())
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        UIView.animate(withDuration: 1, animations: {
            self.heightFromInputToResultContraint.constant = bannerView.frame.height
        })
    }
    
    // INTERSTITIAL MAKING
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-9626752563546060/4616797041")
        //let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910") //Test
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        if !defaults.bool(forKey: "isRemoveAds"){
            interstitial = createAndLoadInterstitial()
        }
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        numberOfSharesTextfield.resignFirstResponder()
        buyingPriceTextfield.resignFirstResponder()
        sellingPriceTextfield.resignFirstResponder()
        buyCommissionTextfield.resignFirstResponder()
        sellCommissionTextfield.resignFirstResponder()
    }
    
    @objc func numberOfSharesTextfieldDidChange(_ textField: UITextField) {
        numberOfSharesTextfield.text = Tools.fixCurrencyTextInTextfield(moneyStr: numberOfSharesTextfield.text ?? "" )
    }
    
    @objc func buyingPriceTextfieldDidChange(_ textField: UITextField) {
        buyingPriceTextfield.text = Tools.fixCurrencyTextInTextfield(moneyStr: buyingPriceTextfield.text ?? "" )
    }
    
    @objc func sellingPriceTextfieldDidChange(_ textField: UITextField) {
        sellingPriceTextfield.text = Tools.fixCurrencyTextInTextfield(moneyStr: sellingPriceTextfield.text ?? "" )
    }
    
    @objc func buyCommissionTextfieldDidChange(_ textField: UITextField) {
        buyCommissionTextfield.text = Tools.fixCurrencyTextInTextfield(moneyStr: buyCommissionTextfield.text ?? "" )
    }
    
    @objc func sellCommissionTextfieldDidChange(_ textField: UITextField) {
        sellCommissionTextfield.text = Tools.fixCurrencyTextInTextfield(moneyStr: sellCommissionTextfield.text ?? "" )
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "," {
            textField.text = textField.text! + "."
            return false
        }
        return true     // Could also filter on numbers only
    }
    
    
    
    @IBAction func calculateButtonPressed(_ sender: UIButton) {
        
        self.view.endEditing(true)

        
        var numberOfSharesString = numberOfSharesTextfield.text!
        var buyingPriceString = buyingPriceTextfield.text!
        var sellingPriceString = sellingPriceTextfield.text!
        var buyCommissionString = buyCommissionTextfield.text!
        var sellCommissionString = sellCommissionTextfield.text!
        
        if numberOfSharesString == "" {
            numberOfSharesString = "0"
        }
        
        if buyingPriceString == "" {
            buyingPriceString = "0"
        }
        
        if sellingPriceString == "" {
            sellingPriceString = "0"
        }
        
        if buyCommissionString == "" {
            buyCommissionString = "0"
        }
        
        if sellCommissionString == "" {
            sellCommissionString = "0"
        }
        
        var numberOfShares = 0.0
        var buyingPrice = 0.0
        var sellingPrice = 0.0
        var buyingCommission = 0.0
        var sellingCommission = 0.0
        
        let numberOfSharesRemoveDot = numberOfSharesString.stringByRemovingWhitespaces
        let buyingPriceRemoveDot = buyingPriceString.stringByRemovingWhitespaces
        let sellingPriceRemoveDot = sellingPriceString.stringByRemovingWhitespaces
        let buyCommissionRemoveDot = buyCommissionString.stringByRemovingWhitespaces
        let sellCommissionRemoveDot = sellCommissionString.stringByRemovingWhitespaces
        
        if Double(numberOfSharesRemoveDot.replacingOccurrences(of: ",", with: "")) != nil {
            numberOfShares = Double(numberOfSharesRemoveDot.replacingOccurrences(of: ",", with: ""))!
        }else {
            AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.thereWasAnError)
            return
        }
        
        if Double(buyingPriceRemoveDot.replacingOccurrences(of: ",", with: "")) != nil {
            buyingPrice = Double(buyingPriceRemoveDot.replacingOccurrences(of: ",", with: ""))!
        }else {
            AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.thereWasAnError)
            return
        }
        
        if Double(sellingPriceRemoveDot.replacingOccurrences(of: ",", with: "")) != nil {
            sellingPrice = Double(sellingPriceRemoveDot.replacingOccurrences(of: ",", with: ""))!
        }else {
            AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.thereWasAnError)
            return
        }
        
        if Double(buyCommissionRemoveDot.replacingOccurrences(of: ",", with: "")) != nil {
            buyingCommission = Double(buyCommissionRemoveDot.replacingOccurrences(of: ",", with: ""))!
        }else {
            AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.thereWasAnError)
            return
        }
        
        if Double(sellCommissionRemoveDot.replacingOccurrences(of: ",", with: "")) != nil {
            sellingCommission = Double(sellCommissionRemoveDot.replacingOccurrences(of: ",", with: ""))!
        }else {
            AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.thereWasAnError)
            return
        }
        
        if numberOfShares < 0 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.numberOfSharesIsNotNegative)
            return
        }
        
        numberOfSharesToShowResult = numberOfShares
        buyingPriceToShowResult = buyingPrice
        sellingPriceToShowResult = sellingPrice
        buyingCommissionInputToShowResult = buyingCommission
        sellingCommissionInputToShowResult = sellingCommission

        if buyCommissionSegment.selectedSegmentIndex == 0 {
            buyingCommissionResultToShowResult = numberOfShares * buyingPrice * (buyingCommission / 100)
            netBuyingPriceToShowResult = numberOfShares * buyingPrice + buyingCommissionResultToShowResult
        }else {
            buyingCommissionResultToShowResult = (buyingCommission / (numberOfShares * buyingPrice)) * 100
            netBuyingPriceToShowResult = numberOfShares * buyingPrice + buyingCommissionInputToShowResult
        }
        
        if sellCommissionSegment.selectedSegmentIndex == 0 {
            sellingCommissionResultToShowResult = numberOfShares * sellingPrice * (sellingCommission / 100)
            netSellingPriceToShowResult = numberOfShares * sellingPrice - sellingCommissionResultToShowResult
        }else {
            sellingCommissionResultToShowResult = (sellingCommission / (numberOfShares * sellingPrice)) * 100
            netSellingPriceToShowResult = numberOfShares * sellingPrice - sellingCommissionInputToShowResult
        }
        
        profitToShowResult = netSellingPriceToShowResult - netBuyingPriceToShowResult
        roiToShowResult = profitToShowResult / netBuyingPriceToShowResult
        if sellCommissionSegment.selectedSegmentIndex == 0 {
            breakEvenSharePriceToShowResult = netBuyingPriceToShowResult / (numberOfShares * (1 - (sellingCommissionInputToShowResult / 100)))
            
        }else {
            breakEvenSharePriceToShowResult = netBuyingPriceToShowResult / (numberOfShares * (1 - (sellingCommissionResultToShowResult / 100)))
        }

        if !defaults.bool(forKey: "isRemoveAds"){
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
        }
        performSegue(withIdentifier: "result", sender: nil)
    }
    
    @IBAction func upgradeAndRemoveAdsButtonPressed(_ sender: UIButton) {
        if products.count >= 1 {
            AlertService.showInfoAlertAndComfirm(in: self, message: "\(StringForLocal.upgradeAndRemoveAds) \(Tools.priceFormatter.string(from: products[0].price)!)") {isOK in
                if isOK {
                    //Purchase
                    if IAPHelper.canMakePayments(){
                        IAPProduct.store.buyProduct(self.products[0])
                    }
                }else {
                    IAPProduct.store.restorePurchases()
                }
            }
        }
    }
    
    @IBAction func buySegmentChanged(_ sender: UISegmentedControl) {
        if !defaults.bool(forKey: "isRemoveAds") {
            buyCommissionSegment.selectedSegmentIndex = 0
            if products.count >= 1 {
                AlertService.showInfoAlertAndComfirm(in: self, message: "\(StringForLocal.defaultValueIsPercent) \(Tools.priceFormatter.string(from: products[0].price)!)") {isOK in
                    if isOK {
                        //Purchase
                        if IAPHelper.canMakePayments(){
                            IAPProduct.store.buyProduct(self.products[0])
                        }
                    }else {
                        IAPProduct.store.restorePurchases()
                    }
                }
            }
        }else {
            
        }
    }
    
    @IBAction func sellSegmentChanged(_ sender: UISegmentedControl) {
        if !defaults.bool(forKey: "isRemoveAds") {
            sellCommissionSegment.selectedSegmentIndex = 0
            if products.count >= 1 {
                AlertService.showInfoAlertAndComfirm(in: self, message: "\(StringForLocal.defaultValueIsPercent) \(Tools.priceFormatter.string(from: products[0].price)!)") {isOK in
                    if isOK {
                        //Purchase
                        if IAPHelper.canMakePayments(){
                            IAPProduct.store.buyProduct(self.products[0])
                        }
                    }else {
                        IAPProduct.store.restorePurchases()
                    }
                }
            }
        }else {
            
        }
    }
    
    @IBAction func clearButtonPressed(_ sender: UIBarButtonItem) {
        numberOfSharesTextfield.text = ""
        buyingPriceTextfield.text = ""
        sellingPriceTextfield.text = ""
        buyCommissionTextfield.text = ""
        sellCommissionTextfield.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "result" {
            if let resultController = segue.destination as? ResultController {
                resultController.numberOfSharesToShowResult = numberOfSharesToShowResult
                resultController.buyingPriceToShowResult = buyingPriceToShowResult
                resultController.buyingCommissionInputToShowResult = buyingCommissionInputToShowResult
                resultController.sellingPriceToShowResult = sellingPriceToShowResult
                resultController.sellingCommissionInputToShowResult = sellingCommissionInputToShowResult
                
                resultController.buyingCommissionResultToShowResult = buyingCommissionResultToShowResult
                resultController.sellingCommissionResultToShowResult = sellingCommissionResultToShowResult
                resultController.netBuyingPriceToShowResult = netBuyingPriceToShowResult
                resultController.netSellingPriceToShowResult = netSellingPriceToShowResult
                resultController.profitToShowResult = profitToShowResult
                resultController.roiToShowResult = roiToShowResult
                resultController.breakEvenSharePriceToShowResult = breakEvenSharePriceToShowResult
                resultController.sellingSegment = sellCommissionSegment.selectedSegmentIndex
                resultController.buyingSegment = buyCommissionSegment.selectedSegmentIndex
            }
        }
    }
    

}

extension ViewController: IAPDoneMaking {
    func purchase(){
        reload()
    }
}

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.masksToBounds = false
        self.layer.shadowColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

