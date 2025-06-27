//
//  Array.swift
//  MacroEssentials
//
//  Created by Vaida on 2025-06-27.
//

import Foundation
import SwiftSyntax


extension Array where Element == DeclSyntax {
    
    public mutating func append(_ syntax: some DeclSyntaxProtocol) {
        self.append(DeclSyntax(syntax))
    }
    
    public mutating func append<E: Error>(_ syntax: () throws(E) -> some DeclSyntaxProtocol) throws(E) {
        try self.append(DeclSyntax(syntax()))
    }
    
}
