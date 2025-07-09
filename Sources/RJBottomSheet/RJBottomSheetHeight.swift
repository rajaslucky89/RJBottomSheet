//
//  RJBottomSheetHeight.swift
//  RJBottomSheet
//
//  Created by Raja Harahap on 09/07/25.
//

import UIKit

public enum RJBottomSheetHeight {
    case quart
    case half
    case threeQuart
    case full
    case dynamic
    
    var value: CGFloat {
        switch self {
        case .quart: return 0.25
        case .half: return 0.5
        case .threeQuart: return 0.75
        case .full: return 1
        case .dynamic: return 0
        }
    }
}
