//
//  DiagnosticsError.swift
//  MacroEssentials
//
//  Created by Vaida on 2024/3/6.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax

extension DiagnosticsError {
    
    /// Creates the error with its attributes.
    public init<Node>(_ title: String, highlighting node: some SyntaxProtocol, replacing oldNode: Node, message: String, with handler: (_ replacement: inout Node) -> Void) where Node: SyntaxProtocol {
        let id = UUID().description
        
        var copy = oldNode
        handler(&copy)
        
        self.init(diagnostics: [
            Diagnostic(node: node, 
                       message: .diagnostic(message: title, diagnosticID: id),
                       fixIt: .replace(message: .diagnostic(message: message, diagnosticID: id), oldNode: oldNode, newNode: copy))
        ])
    }
    
    public init(_ title: String, highlighting node: some SyntaxProtocol) {
        self.init(diagnostics: [
            Diagnostic(node: node,
                       message: .diagnostic(message: title, diagnosticID: UUID().description))
        ])
    }
    
    /// Returns the error indicating that the macro should be removed.
    ///
    /// - Parameters:
    ///   - declaration: The main declaration
    ///   - node: The name of the macro, with any attributes. eg, `@codable`.
    ///   - message: The message indicating why it should be removed.
    public static func shouldRemoveMacro(for declaration: some SwiftSyntax.DeclGroupSyntax,
                                         node: SwiftSyntax.AttributeSyntax,
                                         message: String
    ) -> DiagnosticsError {
        if let declarationIndex = declaration.attributes.firstIndex(where: { $0.description == node.description }) {
            return DiagnosticsError(message, highlighting: node, 
                                    replacing: declaration.attributes, message: "Remove `\(node.attributeName)`") { replacement in
                replacement.remove(at: declarationIndex)
            }
        } else {
            return DiagnosticsError(message, highlighting: node)
        }
    }
    
}


