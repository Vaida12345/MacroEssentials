//
//  PropertyType.swift
//  MacroEssentials
//
//  Created by Vaida on 2024/3/7.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros


public enum PropertyType: Equatable {
    
    case storedConstant
    
    case storedVariable
    
    case computed
    
    case staticConstant
    
    case staticVariable
    
    
    public init(of syntax: VariableDeclSyntax) {
        if syntax.modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) }) {
            switch syntax.bindingSpecifier.tokenKind {
            case .keyword(.var):
                self = .staticVariable
            case .keyword(.let):
                self = .staticConstant
            default:
                fatalError("Unrecognized variable binding specifier keyword: \(syntax.bindingSpecifier.tokenKind)")
            }
            return
        }
        
        let binding = syntax.bindings.last! // only observe the last binding. As only the last binding is declared in full.
        
        switch syntax.bindingSpecifier.tokenKind {
        case .keyword(.var):
            switch binding.accessorBlock?.accessors { // check if is computed property
            case nil: // no accessor block, not a computed property
                break
            case let .accessors(accessor):
                if accessor.contains(where: { $0.accessorSpecifier.tokenKind == .keyword(.get) || $0.accessorSpecifier.tokenKind == .keyword(.set) }) {
                    self = .computed
                    return
                } else {
                    break
                }
            case .getter:
                self = .computed
                return
            }
            
            self = .storedVariable
        case .keyword(.let):
            self = .storedConstant
        default:
            fatalError("Unrecognized variable binding specifier keyword: \(syntax.bindingSpecifier.tokenKind)")
        }
    }
    
}
