//
//  PatternBindingSyntax.swift
//  MacroEssentials
//
//  Created by Vaida on 2023/12/15.
//

import Foundation
import SwiftSyntax
import SwiftDiagnostics


extension SemanticAnalysis where Syntax == PatternBindingSyntax {
    
    /// Returns the type associated with the variable.
    public var inferredType: any TypeSyntaxProtocol {
        get throws {
            // The base case, where the type is explicitly declared.
            if let type = syntax.typeAnnotation?.type {
                return type
            } else if let initializer = syntax.initializer {
                return try initializer.value.analysis.inferredType
            } else {
                throw SemanticAnalysis<ExprSyntax>.InferTypeError.cannotInferBindingWithoutTypeOrInitializer
            }
        }
    }
    
}
