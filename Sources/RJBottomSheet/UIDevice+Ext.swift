//
//	UIDevice+Ext.swift
//	CoreUI
//	
//	Created by PT. Bank Negara Indonesia (BNI).
// 

import UIKit

public extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
