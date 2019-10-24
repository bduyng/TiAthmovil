//
//  ComBduyngTiathmovilCheckoutButton.swift
//  ComBduyngTiathmovil
//
//  Created by Duy Bao Nguyen on 10/24/19.
//

import Foundation
import TitaniumKit
import athmovil_checkout

@objc(ComBduyngTiathmovilCheckoutButton)
class ComBduyngTiathmovilCheckoutButton: TiUIView {
    var checkoutButton: ATHMCheckoutButton
    
    override init(frame: CGRect) {
      checkoutButton = ATHMCheckoutButton()
      super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
      checkoutButton = ATHMCheckoutButton()
      super.init(coder: aDecoder)
    }
    
    override func initializeState() {
        NSLog("[DEBUG] in initializeState... ")
        super.initializeState()
        checkoutButton = ATHMCheckout.shared.getCheckoutButton(withTarget: self, action: #selector(payWithATHMButtonPressed))
        checkoutButton.frame = self.bounds
        checkoutButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        checkoutButton.style = .original

        self.addSubview(checkoutButton)
    }
    
    public override func frameSizeChanged(_ frame: CGRect, bounds: CGRect) {
        super.frameSizeChanged(frame, bounds: bounds)
        
        TiUtils.setView(checkoutButton, positionRect: bounds)
    }
    
    @objc func payWithATHMButtonPressed() {
        if (proxy._hasListeners("click")) {
            proxy.fireEvent("click")
        }
    }
    
}
