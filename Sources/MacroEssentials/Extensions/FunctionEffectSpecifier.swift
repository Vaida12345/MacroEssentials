//
//  FunctionSyntaxSpecifier.swift
//  MacroEssentials
//
//  Created by Vaida on 2025-06-27.
//

import SwiftSyntax


extension FunctionEffectSpecifiersSyntax {
    
    /// Indicates the synchronous throws clause without a type.
    public static var `throws`: FunctionEffectSpecifiersSyntax {
        FunctionEffectSpecifiersSyntax(throwsClause: ThrowsClauseSyntax(throwsSpecifier: .keyword(.throws)))
    }
    
    /// Indicates the function is asynchronous.
    public static var async: FunctionEffectSpecifiersSyntax {
        FunctionEffectSpecifiersSyntax(asyncSpecifier: .keyword(.async))
    }
    
    /// Indicates an asynchronous throws clause without a type.
    public static var asyncThrows: FunctionEffectSpecifiersSyntax {
        FunctionEffectSpecifiersSyntax(asyncSpecifier: .keyword(.async), throwsClause: ThrowsClauseSyntax(throwsSpecifier: .keyword(.throws)))
    }
    
}
