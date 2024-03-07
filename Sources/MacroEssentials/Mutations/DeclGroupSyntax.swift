//
//  DeclGroupSyntax.swift
//  MacroEssentials
//
//  Created by Vaida on 2023/12/20.
//


import Foundation
import SwiftSyntax


extension DeclGroupSyntax {
    
    public mutating func appendInheritedTypes(identifier: String) {
        if self.inheritanceClause == nil {
            self.inheritanceClause = InheritanceClauseSyntax(colon: .colonToken(leadingTrivia: [], trailingTrivia: .space),
                                                             inheritedTypes: [InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier(identifier)))],
                                                             trailingTrivia: .space)
        } else {
            self.inheritanceClause!.inheritedTypes[self.inheritanceClause!.inheritedTypes.index(before: self.inheritanceClause!.inheritedTypes.endIndex)].trailingComma = .commaToken(leadingTrivia: [], trailingTrivia: .space)
            self.inheritanceClause!.inheritedTypes.append(InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier(identifier)),
                                                                              trailingTrivia: .space))
        }
    }
    
}
