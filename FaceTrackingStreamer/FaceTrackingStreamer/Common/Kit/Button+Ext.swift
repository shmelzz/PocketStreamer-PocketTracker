//
//  Button+Ext.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 07.04.2024.
//

import UIKit

extension UIButton {
    
    static func tinted(title: String, font: UIFont, textColor: UIColor = .white) -> UIButton {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: textColor
            ])
        )
        let button = UIButton(configuration: configuration)
        button.tintColor = .black
        return button
    }
}
