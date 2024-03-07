//
//  TypeSyntaxProtocol.swift
//  MacroEssentials
//
//  Created by Vaida on 2023/12/15.
//

import Foundation
import SwiftSyntax


extension TypeSyntaxProtocol {
    
    /// Whether it is an optional class.
    public var isOptional: Bool {
        if self.is(OptionalTypeSyntax.self) { return true }
        if let syntax = self.as(IdentifierTypeSyntax.self), syntax.name.text == "Optional" { return true }
        
        return false
    }
    
}
