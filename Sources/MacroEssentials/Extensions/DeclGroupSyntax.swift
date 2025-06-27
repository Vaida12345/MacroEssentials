//
//  DeclGroupSyntax.swift
//  MacroEssentials
//
//  Created by Vaida on 2025-06-27.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics


extension SwiftSyntax.DeclGroupSyntax {
    
    /// Applies map to every member, ie, properties to a Data Type.
    ///
    /// - Parameters:
    ///   - handler: The handler for building the return value.
    ///
    /// ## handler parameters
    ///
    /// - term variable: Each property, *binding* itself.
    /// - term decl: The declaration in which the `variable` is defined.
    /// - term name: The shorthand for `variable` name.
    /// - term type: The property type
    public func mapProperties<T>(
        handler: (_ variable: PatternBindingListSyntax.Element, _ decl: VariableDeclSyntax, _ name: String, _ type: PropertyType) throws -> T?
    ) rethrows -> [T] {
        let lines: [[T]] = try self.memberBlock.members.map { member in
            guard let variables = member.decl.as(VariableDeclSyntax.self) else { return [] }
            
            // there may be multiple identifiers associated with the same member declaration, ie, `let a, b = 1`
            return try variables.bindings.compactMap { variable -> T? in
                guard let name = variable.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed.text else { return nil }
                let type = PropertyType(of: variables)
                
                return try handler(variable, variables, name, type)
            }
        }
        return lines.flatMap({ $0 })
    }
    
    /// Returns a list of protocols that `self` conforms.
    public var conformances: [String] {
        self.inheritanceClause?.inheritedTypes.compactMap { $0.type.as(IdentifierTypeSyntax.self)?.name.text } ?? []
    }
    
    /// Returns a list of macros attached to `self`
    public var attachedMacros: [String] {
        self.attributes.compactMap { $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text }
    }
    
}


extension DeclGroupSyntax {
    
    public mutating func appendInheritedTypes(identifier: String) {
        if self.inheritanceClause == nil {
            self.inheritanceClause = InheritanceClauseSyntax(colon: .colonToken(leadingTrivia: [], trailingTrivia: .space),
                                                             inheritedTypes: [InheritedTypeSyntax(type: .identifier(identifier))],
                                                             trailingTrivia: .space)
        } else {
            self.inheritanceClause!.inheritedTypes[self.inheritanceClause!.inheritedTypes.index(before: self.inheritanceClause!.inheritedTypes.endIndex)].trailingComma = .commaToken(leadingTrivia: [], trailingTrivia: .space)
            self.inheritanceClause!.inheritedTypes.append(InheritedTypeSyntax(type: .identifier(identifier),
                                                                              trailingTrivia: .space))
        }
    }
    
}
