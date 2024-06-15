# ``MacroEssentials``

A collection of tools to build macros.

@Metadata {
    @PageColor(gray)
    
    @SupportedLanguage(swift)
    
    @Available(macOS,       introduced: 10.5)
    @Available(iOS,         introduced: 13.0)
    @Available(tvOS,        introduced: 13.0)
    @Available(macCatalyst, introduced: 13.0)
    @Available(watchOS,     introduced:  6.0)
}


## Overview

This package provides a collection of tools to build macros, and a collection of semantic analysis methods.


## Getting Started

`MacroEssentials` uses [Swift Package Manager](https://www.swift.org/documentation/package-manager/) as its build tool. If you want to import in your own project, it's as simple as adding a `dependencies` clause to your `Package.swift`:
```swift
dependencies: [
    .package(name: "MacroEssentials", 
             path: "~/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/MacroEssentials")
]
```
and then adding the appropriate module to your target dependencies.

### Using Xcode Package support

You can add this framework as a dependency to your Xcode project by clicking File -> Swift Packages -> Add Package Dependency. The package is located at:
```
~/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/MacroEssentials
```

## Topics

### Performing Analysis

- ``SemanticAnalysis``
