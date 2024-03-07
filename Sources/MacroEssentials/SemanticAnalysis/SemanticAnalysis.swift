//
//  SemanticAnalysis.swift
//
//
//  Created by Vaida on 2024/3/7.
//

import Foundation
import SwiftSyntax


/// A set of semantic analysis methods. Used to distinguish from the literal syntax.
///
/// Do not use this struct directly, use the ``SyntaxProtocol/analysis`` attribute.
public struct SemanticAnalysis<Syntax: SyntaxProtocol> {
    
    internal let syntax: Syntax
    
    internal init(syntax: Syntax) {
        self.syntax = syntax
    }
    
}


extension SyntaxProtocol {
    
    /// A set of semantic analysis methods. Used to distinguish from the literal syntax.
    public var analysis: SemanticAnalysis<Self> {
        SemanticAnalysis(syntax: self)
    }
    
}
