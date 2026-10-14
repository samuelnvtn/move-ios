//
//  Injected.swift
//  Move
//
//  Created by Samuel Novotný on 09.06.2026.
//

@propertyWrapper
struct Injected<T> {
    let wrappedValue: T

    init() {
        wrappedValue = DIContainer.shared.resolve()
    }
}
