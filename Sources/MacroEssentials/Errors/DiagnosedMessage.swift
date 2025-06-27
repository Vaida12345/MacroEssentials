//
//  DiagnosedMessage.swift
//  MacroEssentials
//
//  Created by Vaida on 2023/12/16.
//


import Foundation
import SwiftDiagnostics


/// The message.
///
/// Use the `diagnostic` static method in `DiagnosticMessage`, `FixItMessage`, `NoteMessage`.
public struct DiagnosedMessage: DiagnosticMessage, FixItMessage, NoteMessage {
    
    private let id: SwiftDiagnostics.MessageID
    
    public let message: String
    
    public let severity: SwiftDiagnostics.DiagnosticSeverity
    
    public var diagnosticID: SwiftDiagnostics.MessageID { self.id }
    
    public var fixItID: SwiftDiagnostics.MessageID { self.id }
    
    public var noteID: SwiftDiagnostics.MessageID {
        self.id
    }
    
    
    fileprivate init(message: String, diagnosticID: String, severity: SwiftDiagnostics.DiagnosticSeverity = .error) {
        self.message = message
        self.id = MessageID(domain: "MacroCollection", id: diagnosticID)
        self.severity = severity
    }
    
}


extension DiagnosticMessage {
    
    public static func diagnostic(message: String, diagnosticID: String, severity: SwiftDiagnostics.DiagnosticSeverity = .error) -> DiagnosedMessage where Self == DiagnosedMessage {
        DiagnosedMessage(message: message, diagnosticID: diagnosticID, severity: severity)
    }
    
}

extension FixItMessage {
    
    public static func diagnostic(message: String, diagnosticID: String) -> DiagnosedMessage where Self == DiagnosedMessage {
        DiagnosedMessage(message: message, diagnosticID: diagnosticID)
    }
    
}


extension NoteMessage {
    
    public static func diagnostic(message: String, diagnosticID: String) -> DiagnosedMessage where Self == DiagnosedMessage {
        DiagnosedMessage(message: message, diagnosticID: diagnosticID)
    }
    
}
