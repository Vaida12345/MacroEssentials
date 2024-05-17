//
//  TokenSyntax.swift
//
//
//  Created by Vaida on 5/17/24.
//

import Foundation
import SwiftSyntax


extension TokenSyntax {
    
    /// Determines if the token is an identifier of name `identifier`.
    ///
    /// For example, this structure,
    /// ```swift
    /// struct Model {
    ///     ...
    /// }
    /// ```
    ///
    /// whose syntax tree is,
    /// ```
    /// - StructDeclSyntax
    /// ├─attributes: AttributeListSyntax
    /// ├─modifiers: DeclModifierListSyntax
    /// ├─structKeyword: keyword(SwiftSyntax.Keyword.struct)
    /// ├─name: identifier("Model")
    /// ╰─memberBlock: MemberBlockSyntax
    /// ```
    ///
    /// The following is `true`,
    /// ```swift
    /// syntax.as(StructDeclSyntax.self)!.name.isEqual(to: "Model")
    /// ```
    public func isEqual(to identifier: String) -> Bool {
        self.text == identifier
    }
    
}
