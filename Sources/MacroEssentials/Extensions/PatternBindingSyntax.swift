import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics


extension PatternBindingSyntax {
    
    /// Returns the type of the `variable`.
    ///
    /// - Parameters:
    ///   - decl: The second field of `memberwiseMap`. This is the declaration containing the variable.
    public func inferredType(in decl: VariableDeclSyntax) throws -> any TypeSyntaxProtocol {
        do {
            return try self.analysis.inferredType
        } catch {
            // additional info: what if it is an initializer?
            var replacementNote = decl
            let lastBinding = decl.bindings.last!
            
            let name = self.pattern
            
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
                           message: .diagnostic(message: "Type of `\(name.trimmed)` cannot be inferred, please declare explicitly",
                                                diagnosticID: "\(Self.self).cannotInferType.\(name)"),
                           highlights: [Syntax(decl)],
                           notes: [Note(node: Syntax(self), message: .diagnostic(message: error.description, diagnosticID: "\(Self.self).cannotInferType.\(name)"))],
                           fixIt: .replace(message: .diagnostic(message: "Declare Type for `\(name.trimmed)`", diagnosticID: "\(Self.self).cannotInferType.\(name)"),
                                           oldNode: decl,
                                           newNode: replacementNote))
            ])
        }
    }
    
}
