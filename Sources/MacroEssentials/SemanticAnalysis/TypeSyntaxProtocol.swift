//
//  TypeSyntaxProtocol.swift
//  MacroEssentials
//
//  Created by Vaida on 2023/12/15.
//

import Foundation
import SwiftSyntax


extension SemanticAnalysis where Syntax: TypeSyntaxProtocol {
    
    /// Whether it is an optional class.
    public var isOptional: Bool {
        if syntax.is(OptionalTypeSyntax.self) { return true }
        if let syntax = syntax.as(IdentifierTypeSyntax.self), syntax.name.text == "Optional" { return true }
        
        return false
    }
    
}
