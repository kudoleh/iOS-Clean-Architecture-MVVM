//
//  Observable.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 16.02.19.
//

import Foundation

final public class Observable<Value> {
    
    private struct Observer<Value> {
        weak var observer: AnyObject?
        let block: (Value) -> Void
    }
    
    // To make observers array Thread Safe
    private let queue = DispatchQueue(label: "ObservableQueue", attributes: .concurrent)
    private var observers = [Observer<Value>]()
    
    public var value: Value {
        didSet { notifyObservers() }
    }
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public func observe(on observer: AnyObject, observerBlock: @escaping (Value) -> Void) {
        queue.async(flags: .barrier) {
            self.observers.append(Observer(observer: observer, block: observerBlock))
            DispatchQueue.main.async { observerBlock(self.value) }
        }
    }
    
    public func remove(observer: AnyObject) {
        queue.async(flags: .barrier) {
            self.observers = self.observers.filter { $0.observer !== observer }
        }
    }
    
    private func notifyObservers() {
        queue.sync() {
            for observer in self.observers {
                DispatchQueue.main.async { observer.block(self.value) }
            }
        }
    }
}
