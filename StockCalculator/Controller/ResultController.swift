//
//  ResultController.swift
//  StockCalculator
//
//  Created by Phan Đăng on 12/10/20.
//

import UIKit
import GoogleMobileAds

class ResultController: UIViewController,GADBannerViewDelegate  {

    @IBOutlet weak var numberOfSharesLabel: UILabel!
    @IBOutlet weak var buyingPriceLabel: UILabel!
    @IBOutlet weak var sellPriceLabel: UILabel!
    @IBOutlet weak var buyCommissionLabel: UILabel!
    @IBOutlet weak var sellCommissionLabel: UILabel!
    @IBOutlet weak var netBuyPriceLabel: UILabel!
    @IBOutlet weak var buyCommissionResultLabel: UILabel!
    @IBOutlet weak var netSellPriceLabel: UILabel!
    @IBOutlet weak var sellCommissionResultLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var roiLabel: UILabel!
    @IBOutlet weak var breakEvenSharePriceLabel: UILabel!
    
    
    @IBOutlet weak var resultShadowView: UIView!
    @IBOutlet weak var inputShadowView: UIView!
    
    @IBOutlet weak var bannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var heightFromInputToResultContraint: NSLayoutConstraint!
    
    
    var buyingSegment = 0
    var sellingSegment = 0
    
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
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !defaults.bool(forKey: "isRemoveAds"){
            bannerView.delegate = self
            //bannerView.adUnitID = ""
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //Test
            bannerView.rootViewController = self
        }
        
        resultShadowView.layer.shadowColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        resultShadowView.layer.shadowOpacity = 0.5
        resultShadowView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        resultShadowView.layer.shadowRadius = 6
        
        inputShadowView.layer.shadowColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        inputShadowView.layer.shadowOpacity = 0.5
        inputShadowView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        inputShadowView.layer.shadowRadius = 6

        
        netBuyingPriceToShowResult = (netBuyingPriceToShowResult*100).rounded()/100
        buyingCommissionResultToShowResult = (buyingCommissionResultToShowResult*100).rounded()/100
        netSellingPriceToShowResult = (netSellingPriceToShowResult*100).rounded()/100
        sellingCommissionResultToShowResult = (sellingCommissionResultToShowResult*100).rounded()/100
        profitToShowResult = (profitToShowResult*100).rounded()/100
        roiToShowResult = roiToShowResult * 100
        roiToShowResult = (roiToShowResult*100).rounded()/100
        breakEvenSharePriceToShowResult = (breakEvenSharePriceToShowResult*100).rounded()/100
        
        numberOfSharesLabel.text = "\(Tools.changeToCurrency(moneyStr: numberOfSharesToShowResult)!)"
        buyingPriceLabel.text = "$ \(Tools.changeToCurrency(moneyStr: buyingPriceToShowResult)!)"
        sellPriceLabel.text = "$ \(Tools.changeToCurrency(moneyStr: sellingPriceToShowResult)!)"
        
        
        netBuyPriceLabel.text = "$ \(Tools.changeToCurrency(moneyStr: netBuyingPriceToShowResult)!)"
        netSellPriceLabel.text = "$ \(Tools.changeToCurrency(moneyStr: netSellingPriceToShowResult)!)"
        profitLabel.text = "$ \(Tools.changeToCurrency(moneyStr: profitToShowResult)!)"
        if profitToShowResult >= 0 {
            profitLabel.textColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        }else {
            profitLabel.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        }
        roiLabel.text = "\(Tools.changeToCurrency(moneyStr: roiToShowResult)!)%"
        breakEvenSharePriceLabel.text = "$ \(Tools.changeToCurrency(moneyStr: breakEvenSharePriceToShowResult)!)"
        
        if buyingSegment == 0 {
            //%
            buyCommissionResultLabel.text = "$ \(Tools.changeToCurrency(moneyStr: buyingCommissionResultToShowResult)!)"
            buyCommissionLabel.text = "\(Tools.changeToCurrency(moneyStr: buyingCommissionInputToShowResult)!)%"
        }else {
            //$
            buyCommissionResultLabel.text = "\(Tools.changeToCurrency(moneyStr: buyingCommissionResultToShowResult)!)%"
            buyCommissionLabel.text = "$ \(Tools.changeToCurrency(moneyStr: buyingCommissionInputToShowResult)!)"
        }
        
        if sellingSegment == 0 {
            //%
            sellCommissionResultLabel.text = "$ \(Tools.changeToCurrency(moneyStr: sellingCommissionResultToShowResult)!)"
            sellCommissionLabel.text = "\(Tools.changeToCurrency(moneyStr: sellingCommissionInputToShowResult)!)%"
        }else {
            //$
            sellCommissionResultLabel.text = "\(Tools.changeToCurrency(moneyStr: sellingCommissionResultToShowResult)!)%"
            sellCommissionLabel.text = "$ \(Tools.changeToCurrency(moneyStr: sellingCommissionInputToShowResult)!)"
        }
        
        AppStoreReviewManager.requestReviewIfAppropriate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
    }
    
    @objc func reload() {
        if !defaults.bool(forKey: "isRemoveAds"){
            loadBannerAd()
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
}
