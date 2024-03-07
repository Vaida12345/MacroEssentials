//
//  MacroDerived.swift
//  MacroEssentials
//
//  Created by Vaida on 2024/3/7.
//


import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics


extension Macro {
    
    /// Applies map to every member, ie, properties to a Data Type.
    ///
    /// - Parameters:
    ///   - declaration: The data type declaration.
    ///   - handler: The handler for building the return value.
    ///
    /// ## handler parameters
    ///
    /// - term variable: Each property, *binding* itself.
    /// - term decl: The declaration in which the `variable` is defined.
    /// - term name: The shorthand for `variable` name.
    /// - term type: The property type
    public static func _memberwiseMap<T>(for declaration: some SwiftSyntax.DeclGroupSyntax,
                                        handler: (_ variable: PatternBindingListSyntax.Element, _ decl: VariableDeclSyntax, _ name: String, _ type: PropertyType) throws -> T?
    ) rethrows -> [T] {
        let lines: [[T]] = try declaration.memberBlock.members.map { member in
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
    
    
    /// Returns the type of the `variable`.
    ///
    /// - Parameters:
    ///   - variable: The first field of `memberwiseMap`
    ///   - decl: The second field of `memberwiseMap`
    ///   - name: The third field of `memberwiseMap`
    ///   - declaration: The main declaration
    public static func _getType(for variable: PatternBindingSyntax, decl: VariableDeclSyntax, name: String, of declaration: some SyntaxProtocol) throws -> any TypeSyntaxProtocol {
        do {
            return try variable.analysis.inferredType
        } catch let error as SemanticAnalysis<ExprSyntax>.InferTypeError {
            // additional info: what if it is an initializer?
            var replacementNote = decl
            let lastBinding = decl.bindings.last!
            
            var typeName: String?
            if let initializer = lastBinding.initializer,
               let value = initializer.value.as(FunctionCallExprSyntax.self),
               let baseName = value.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName,
               baseName.text.first?.isUppercase ?? false {
                typeName = baseName.text
            }
            
            
            let replacementPattern = lastBinding.pattern.with(\.trailingTrivia, [])
            let replacementBinding = PatternBindingSyntax(pattern: replacementPattern,
                                                          typeAnnotation: TypeAnnotationSyntax(colon: .colonToken(trailingTrivia: .space),
                                                                                               type: MissingTypeSyntax(placeholder: .identifier(typeName ?? "<#type#>"),
                                                                                                                       trailingTrivia: .space)),
                                                          initializer: lastBinding.initializer
            )
            
            replacementNote.bindings[replacementNote.bindings.index(before: replacementNote.bindings.endIndex)] = replacementBinding
            
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: decl,
                           message: .diagnostic(message: "Type of `\(name)` cannot be inferred, please declare explicitly",
                                                diagnosticID: "\(Self.self).cannotInferType.\(name)"),
                           highlights: [decl.cast(Syntax.self)],
                           notes: [Note(node: variable.cast(Syntax.self), message: .diagnostic(message: error.description, diagnosticID: "\(Self.self).cannotInferType.\(name)"))],
                           fixIt: .replace(message: .diagnostic(message: "Declare Type for `\(name)`", diagnosticID: "\(Self.self).cannotInferType.\(name)"),
                                           oldNode: decl,
                                           newNode: replacementNote))
            ])
        }
    }
    
    
    /// returns whether the declaration has the attribute (ie, macro) of the given name.
    ///
    /// ```swift
    /// @codable
    /// class Model { }
    /// ```
    /// has the attribute of `codable`.
    public static func _has(attribute: String, declaration: some SwiftSyntax.DeclGroupSyntax) -> Bool {
        declaration.attributes.contains(where: { $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == attribute })
    }
    
    /// returns whether the declaration has the inheritance of the given name.
    ///
    /// ```swift
    /// class Model: Codable { }
    /// ```
    /// has the inheritance of `Codable`.
    public static func _has(inheritance: String, declaration: some SwiftSyntax.DeclGroupSyntax) -> Bool {
        if let inheritedTypes = declaration.inheritanceClause?.inheritedTypes {
            return inheritedTypes.contains(where: { $0.type.as(IdentifierTypeSyntax.self)?.name.text == inheritance })
        } else {
            return false
        }
    }
    
}
