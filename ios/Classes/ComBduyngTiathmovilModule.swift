//
//  ComBduyngTiathmovilModule.swift
//  TiAthmovil
//
//  Created by Your Name
//  Copyright (c) 2019 Your Company. All rights reserved.
//

import UIKit
import TitaniumKit
import athmovil_checkout

/**
 
 Titanium Swift Module Requirements
 ---
 
 1. Use the @objc annotation to expose your class to Objective-C (used by the Titanium core)
 2. Use the @objc annotation to expose your method to Objective-C as well.
 3. Method arguments always have the "[Any]" type, specifying a various number of arguments.
 Unwrap them like you would do in Swift, e.g. "guard let arguments = arguments, let message = arguments.first"
 4. You can use any public Titanium API like before, e.g. TiUtils. Remember the type safety of Swift, like Int vs Int32
 and NSString vs. String.
 
 */

@objc(ComBduyngTiathmovilModule)
class ComBduyngTiathmovilModule: TiModule, UIApplicationDelegate {
  
  // MARK: Public constants
  
  @objc let ENV_DEV = AMEnvironment.development.rawValue
  
  @objc let ENV_PROD = AMEnvironment.production.rawValue
  
  func moduleGUID() -> String {
    return "6badf05c-034d-4d24-9a82-f436c7800883"
  }
  
  override func moduleId() -> String! {
    return "com.bduyng.tiathmovil"
  }
  
  override func startup() {
    super.startup()
    debugPrint("[DEBUG] \(self) loaded")
  }
  
  @objc func handleIncomingURLWithUrl(notification: NSNotification) {
    guard let urlString = notification.userInfo?["url"] as? String else {
      return
    }
    
//    let alert = UIAlertController(title: "DEBUG", message: urlString, preferredStyle: UIAlertController.Style.alert)
//    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//    TiApp.controller().topPresentedController().present(alert, animated: true, completion: nil)
    
    do {
      try ATHMCheckout.shared.handleIncomingURL(url: URL(string: urlString)!)
    } catch let error {
      if (self._hasListeners("error")) {
        fireEvent("error", with: ["error": true, "method": "handleIncomingURLWithUrl", "message": error.localizedDescription ])
      }
    }
  }
  
  @objc(configure:)
  func configure(arguments: Array<Any>?) {
    NSLog("[DEBUG] in configure... ")
    guard let params = arguments?.first as? [String: Any],
      let publicToken = params["publicToken"] as? String,
      let callbackURL = params["callbackURL"] as? String,
      let environment = (params["environment"] as? String)
      else {
        if (self._hasListeners("error")) {
          fireEvent("error", with: ["error": true, "method": "configure", "arguments": arguments! ])
        }
        return
    }
    
    
    do {
      try ATHMCheckout.shared.configure(for: environment == "dev" ? AMEnvironment.development : AMEnvironment.production,
                                        with: publicToken,
                                        and: callbackURL)
      ATHMCheckout.shared.publicToken = publicToken
      ATHMCheckout.shared.callbackURL = callbackURL
      ATHMCheckout.shared.timeout = 60
      ATHMCheckout.shared.delegate = self
      let nc = NotificationCenter.default
      nc.addObserver(self, selector: #selector(self.handleIncomingURLWithUrl), name: NSNotification.Name(rawValue: kTiApplicationLaunchedFromURL), object: nil)
      
    } catch {
      if (self._hasListeners("error")) {
        fireEvent("error", with: ["error": true, "method": "configure", "message": error.localizedDescription ])
      }
    }
  }
  
  @objc(checkoutWithPayment:)
  func checkoutWithPayment(arguments: Array<Any>?) {
    guard let params = arguments?.first as? [String: Any],
      let total = params["total"] as? NSNumber
      else {
        if (self._hasListeners("error")) {
          fireEvent("error", with: ["error": true, "method": "checkoutWithPayment", "arguments": arguments! ])
        }
        return
    }
    
    let itemsParams = params["items"] as? [[String: Any]]
    let subtotal = params["subtotal"] as? NSNumber
    let tax = params["tax"] as? NSNumber
    
    // create items
    var items: [ATHMPaymentItem] = []
    if (itemsParams != nil) {
      for itemParam in itemsParams! {
        guard let item = try? ATHMPaymentItem(desc: itemParam["desc"] as! String,
                                              name: itemParam["name"] as! String,
                                              priceNumber: itemParam["price"] as! NSNumber,
                                              quantity: itemParam["quantity"] as! Int
          ) else {
            if (self._hasListeners("error")) {
              fireEvent("error", with: ["error": true, "method": "checkoutWithPayment", "itemParam": itemParam ])
            }
            return
        }
        items.append(item)
      }
    }
    
    guard let payment = try? ATHMPayment(
      total: total,
      subtotal: subtotal,
      tax: tax,
      items: items
      ) else { return }
    
    do {
      try ATHMCheckout.shared.checkout(with: payment)
    } catch {
      if (self._hasListeners("error")) {
        fireEvent("error", with: [
          "error": true,
          "method": "checkoutWithPayment",
          "message": error.localizedDescription
        ])
      }
    }
    
  }
}

extension ComBduyngTiathmovilModule: AMCheckoutDelegate {
  public func onCompletedPayment(referenceNumber: String?, total: NSNumber, tax: NSNumber?, subtotal: NSNumber?, metadata1: String?, metadata2: String?, items: [ATHMPaymentItem]?) {
    if (self._hasListeners("success")) {
      fireEvent("success", with: ["success": true])
    }
  }
  
  public func onCancelledPayment(referenceNumber: String?, total: NSNumber, tax: NSNumber?, subtotal: NSNumber?, metadata1: String?, metadata2: String?, items: [ATHMPaymentItem]?) {
    if (self._hasListeners("cancelled")) {
      fireEvent("cancelled", with: ["cancelled": true])
    }
  }
  
  public func onExpiredPayment(referenceNumber: String?, total: NSNumber, tax: NSNumber?, subtotal: NSNumber?, metadata1: String?, metadata2: String?, items: [ATHMPaymentItem]?) {
    if (self._hasListeners("error")) {
      fireEvent("error", with: ["error": true, "expired": true])
    }
  }
  
  
}
