//
//  ComBduyngTiathmovilCheckoutButton.swift
//  ComBduyngTiathmovil
//
//  Created by Duy Bao Nguyen on 10/24/19.
//

import Foundation
import TitaniumKit
import athmovil_checkout

@objc(ComBduyngTiathmovilButton)
class ComBduyngTiathmovilCheckoutButton: TiUIView {
    var checkoutButton: ATHMCheckoutButton?
    
    public override func initializeState() {
        super.initializeState()
        
        checkoutButton = ATHMCheckout.shared.getCheckoutButton(withTarget: self, action: #selector(payWithATHMButtonPressed))
        checkoutButton?.style = .original
        
        self.addSubview(checkoutButton!)
    }
    
    public override func frameSizeChanged(_ frame: CGRect, bounds: CGRect) {
        for child in checkoutButton!.subviews {
            TiUtils.setView(child, positionRect: bounds)
        }
        
        super.frameSizeChanged(frame, bounds: bounds)
    }
    
    @objc func payWithATHMButtonPressed() {
        proxy.fireEvent("click")
    }
    
}
