//
//  ExprSyntax.swift
//  MacroEssentials
//
//  Created by Vaida on 2023/12/15.
//

import Foundation
import SwiftSyntax
import SwiftDiagnostics


extension SemanticAnalysis where Syntax == ExprSyntax {
    
    /// Returns the inferred type of the expression.
    ///
    /// - Precondition: the expression is something like `Int(3)`, `[1, 2, nil]`.
    public var inferredType: (any TypeSyntaxProtocol) {
        get throws {
            // The literal cases
            if syntax.is(IntegerLiteralExprSyntax.self) {
                return IdentifierTypeSyntax(name: "Int")
            } else if syntax.is(BooleanLiteralExprSyntax.self) {
                return IdentifierTypeSyntax(name: "Bool")
            } else if syntax.is(FloatLiteralExprSyntax.self) {
                return IdentifierTypeSyntax(name: "Double")
            } else if syntax.is(SimpleStringLiteralExprSyntax.self) || syntax.is(StringLiteralExprSyntax.self) {
                return IdentifierTypeSyntax(name: "String")
            }
            
            // The `let a = 1 as? Double` case
            if let sequence = syntax.as(SequenceExprSyntax.self),
               sequence.elements.count == 3,
               let asSyntax = sequence.elements[sequence.elements.index(after: sequence.elements.startIndex)].as(UnresolvedAsExprSyntax.self),
               let base = sequence.elements[sequence.elements.index(before: sequence.elements.endIndex)].as(TypeExprSyntax.self)?.type {
                return asSyntax.questionOrExclamationMark?.tokenKind == .postfixQuestionMark ? OptionalTypeSyntax(wrappedType: base) : base
            }
            
            // The `let a = [1, 2, nil]` case
            if let array = syntax.as(ArrayExprSyntax.self),
               let element = array.elements.first(where: { !$0.expression.is(NilLiteralExprSyntax.self) }),
               let type = try? element.expression.analysis.inferredType {
                let containsOptional = array.elements.contains(where: { $0.expression.is(NilLiteralExprSyntax.self) })
                let elementType = containsOptional ? OptionalTypeSyntax(wrappedType: type) : type
                return ArrayTypeSyntax(element: elementType)
            }
            
            // The `let a = ["a": 3, "b": nil]` case
            if let dictionary = syntax.as(DictionaryExprSyntax.self),
               let content = dictionary.content.as(DictionaryElementListSyntax.self),
               let element = content.first(where: { !$0.value.is(NilLiteralExprSyntax.self) }),
               let keyType = try? element.key.analysis.inferredType,
               let valueType = try? element.value.analysis.inferredType {
                let containsOptional = content.contains(where: { $0.value.is(NilLiteralExprSyntax.self) })
                let elementType = containsOptional ? OptionalTypeSyntax(wrappedType: valueType) : valueType
                return DictionaryTypeSyntax(key: keyType, value: elementType)
            }
            
            // The `let a = (1, 2)` case
            if let tuple = syntax.as(TupleExprSyntax.self),
               let elementTypes = try? tuple.elements.map({ try $0.expression.analysis.inferredType }) {
                let elements = TupleTypeElementListSyntax(elementTypes.map({ TupleTypeElementSyntax(type: $0) }))
                return TupleTypeSyntax(elements: elements)
            }
            
            // The `let a = { return 3 }` case
            if let closure = syntax.as(ClosureExprSyntax.self) {
                let parameterClause: [TupleTypeElementSyntax] = closure.signature?.parameterClause?.as(ClosureParameterClauseSyntax.self)?.parameters.compactMap {
                    guard let type = $0.type else { return nil }
                    return TupleTypeElementSyntax(leadingTrivia: $0.leadingTrivia,
                                                  nil,
                                                  inoutKeyword: nil,
                                                  nil,
                                                  firstName: $0.firstName,
                                                  $0.unexpectedBetweenFirstNameAndSecondName,
                                                  secondName: $0.secondName,
                                                  $0.unexpectedBetweenSecondNameAndColon,
                                                  colon: $0.colon,
                                                  $0.unexpectedBetweenColonAndType,
                                                  type: type,
                                                  $0.unexpectedBetweenTypeAndEllipsis,
                                                  ellipsis: $0.ellipsis,
                                                  $0.unexpectedBetweenEllipsisAndTrailingComma,
                                                  trailingComma: $0.trailingComma,
                                                  $0.unexpectedAfterTrailingComma,
                                                  trailingTrivia: $0.trailingTrivia)
                } ?? []
                
                if let returnClause = closure.signature?.returnClause {
                    return FunctionTypeSyntax(parameters: .init(parameterClause), effectSpecifiers: closure.signature?.effectSpecifiers, returnClause: returnClause)
                } else if closure.statements.count == 1 {
                    var item: ExprSyntax?
                    switch closure.statements.first?.item {
                    case let .expr(expr):
                        item = expr
                    case let .stmt(stmt):
                        item = stmt.as(ReturnStmtSyntax.self)?.expression
                    default:
                        throw InferTypeError.closureTooComplicated
                    }
                    guard let item else { throw InferTypeError.closureTooComplicated }
                    
                    let hasTrySpecifier, hasAwaitSpecifier: Bool
                    let returnType: (any TypeSyntaxProtocol)?
                    if let item = item.as(TryExprSyntax.self)?.expression {
                        hasTrySpecifier = true
                        if let item = item.as(AwaitExprSyntax.self) {
                            hasAwaitSpecifier = true
                            returnType = try? item.expression.analysis.inferredType
                            dump(item.expression)
                        } else {
                            hasAwaitSpecifier = false
                            returnType = try? item.analysis.inferredType
                        }
                    } else {
                        hasTrySpecifier = false
                        if let item = item.as(AwaitExprSyntax.self)?.expression {
                            hasAwaitSpecifier = true
                            returnType = try? item.analysis.inferredType
                        } else {
                            hasAwaitSpecifier = false
                            returnType = try? ExprSyntax(item).analysis.inferredType
                        }
                    }
                    guard let returnType else { throw InferTypeError.closureTooComplicated }
                    
                    return FunctionTypeSyntax(
                        parameters: .init(parameterClause),
                        effectSpecifiers: TypeEffectSpecifiersSyntax(
                            asyncSpecifier: hasAwaitSpecifier ? .keyword(.async) : nil,
                            throwsClause: hasTrySpecifier ? ThrowsClauseSyntax(throwsSpecifier: .keyword(.throws)) : nil // the throws is inferred, impossible to know type without a compiler
                        ),
                        returnClause: ReturnClauseSyntax(type: returnType)
                    )
                } else {
                    throw InferTypeError.closureTooComplicated
                }
            }
            
            // The `let a = b` case
            if let closure = syntax.as(DeclReferenceExprSyntax.self) {
                throw InferTypeError.cannotInferFromReference(closure.baseName.text)
            }
            
            // The `let a = call()` case
            if let closure = syntax.as(FunctionCallExprSyntax.self) {
                // some shortcuts
                if let calledExpression = closure.calledExpression.as(DeclReferenceExprSyntax.self) {
                    if calledExpression.baseName.isEqual(to: "UUID") {
                        return IdentifierTypeSyntax(name: "UUID")
                    }
                }
                
                throw InferTypeError.cannotInferFromReference(closure.calledExpression.description)
            }
            
            throw InferTypeError.unexpectedPattern
        }
    }
    
    enum InferTypeError: CustomStringConvertible, Error {
        case unexpectedPattern
        case closureTooComplicated
        case cannotInferFromReference(String)
        case cannotInferBindingWithoutTypeOrInitializer
        
        var description: String {
            switch self {
            case .unexpectedPattern:
                "Unexpected pattern caused type inference failure"
            case .closureTooComplicated:
                "Closure too complicated to infer type. Please annotate types explicitly"
            case let .cannotInferFromReference(name):
                "Type cannot be inferred from referring to `\(name)`"
            case .cannotInferBindingWithoutTypeOrInitializer:
                "Cannot infer the type of a binding without type annotation or initializer"
            }
        }
    }
    
}


