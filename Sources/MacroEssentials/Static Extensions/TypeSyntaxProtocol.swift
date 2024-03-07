//
//  TypeSyntaxProtocol.swift
//
//
//  Created by Vaida on 2024/3/7.
//

import Foundation
import SwiftSyntax


extension TypeSyntaxProtocol {
    
    public static func identifier(_ syntax: TokenSyntax) -> IdentifierTypeSyntax where Self == IdentifierTypeSyntax {
        IdentifierTypeSyntax(name: syntax)
    }
    
    public static func identifier(_ text: String) -> IdentifierTypeSyntax where Self == IdentifierTypeSyntax {
        IdentifierTypeSyntax(name: .identifier(text))
    }
    
}

