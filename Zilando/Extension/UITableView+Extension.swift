//
//  UITableView+Extension.swift
//  Zilando
//
//  Created by Le, Triet on 30.12.2020
//

import UIKit

extension UITableView {
    func reloadDataAnimated() {
        UIView.transition(
            with: self,
            duration: 0.4,
            options: .transitionCrossDissolve,
            animations: { self.reloadData() },
            completion: nil
        )
    }

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(
            frame:
                CGRect(
                    x: 0,
                    y: 0,
                    width: bounds.size.width,
                    height: bounds.size.height
                )
        )

        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        messageLabel.sizeToFit()

        backgroundView = messageLabel
    }

    func restore() {
        backgroundView = nil
    }
}
