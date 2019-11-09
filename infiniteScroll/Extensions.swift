//
//  Extensions.swift
//  infiniteScroll
//
//  Created by Jonathan Morin on 10/22/19.
//  Copyright © 2019 Jonathan Morin. All rights reserved.
//

import UIKit

// MARK: -

extension CGFloat {

    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }

}

// MARK: -

extension UIColor {

    static func random() -> UIColor {
        return UIColor(red: .random(),
                       green: .random(),
                       blue: .random(),
                       alpha: 1.0)
    }

}

// MARK: -

extension Date {
    
    static func currentTimeInMilliSeconds() -> Int {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
}

// MARK: -

extension DispatchTimeInterval {

    func toCGFloat() -> CGFloat? {
        var result: CGFloat? = 0.0

        switch self {
        case .seconds(let value):
            result = CGFloat(value)
        case .milliseconds(let value):
            result = CGFloat(value) * 0.001
        case .microseconds(let value):
            result = CGFloat(value) * 0.000001
        case .nanoseconds(let value):
            result = CGFloat(value) * 0.000000001
        case .never:
            result = nil
        @unknown default:
            result = nil
        }

        return result
    }

}

// MARK: -

@IBDesignable extension UIView {

    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }

    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }

}
