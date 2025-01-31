//
//  Calculator.swift
//  calculator
//
//  Created by Илья Лошкарёв on 21.09.17.
//  Copyright © 2017 Илья Лошкарёв. All rights reserved.
//

import Foundation


/// Доступные операции
public enum Operation: String {
    case add = "+",
    sub = "-",
    mul = "×",
    div = "÷",
    sign = "±",
    perc = "%"
}


/// Протокол калькулятора
public protocol Calculator: class { // можно реализовывать только в ссылочном типе
    
    /// Представитель – объект, реагирующий на изменение внутреннего состояния калькулятора
    var delegate: CalculatorDelegate? { get set }
    
    /// Инициализатор
    /// `inputLength` – максимальная длина поля ввода (количество символов)
    /// `fractionLength` – максимальное количество знаков после заятой
    init(inputLength len: UInt, maxFraction frac: UInt)
    
    // Хранимое выражение: <левое значение> <операция> <правое значение>
    
    /// Левое значение - обычно хранит результат предыдущей операции
    var result: Double? { get }
    
    /// Текущая операция
    var operation: Operation? { get }
    
    /// Правое значение - к нему пользователь добавляет цифры
    var input: Double? { get }
    
    /// Добавить цифру к правому значению
    func addDigit(_ d: Int)
    
    /// Добавить точку к правому значению
    func addPoint()
    
    /// Правое значение содержит точку
    var hasPoint: Bool { get }
    
    /// Количество текущих знаков после запятой в правом значении
    var fractionDigits: UInt { get }
    
    /// Добавить операцию, если операция уже задана,
    /// вычислить предыдущее значение
    func addOperation(_ op: Operation)
    
    /// Вычислить значение выражения и записать его в левое значение
    func compute()
    
    /// Очистить правое значение
    func clear()
    
    /// Очистить всё выражение
    func reset()
}

class CalculatorImpl: Calculator {
    var delegate: CalculatorDelegate?
    
    var len: UInt
    var frac: UInt
    
    required init(inputLength len: UInt, maxFraction frac: UInt) {
        self.len = len
        self.frac = frac
        result = 0
        input = nil
        operation = nil
        fractionDigits = 0
        hasPoint = false
        curCount = 0
    }
    
    var curCount: UInt
    var result: Double?
    var operation: Operation?
    var input: Double?
    var hasPoint: Bool
    var fractionDigits: UInt
    
    func addDigit(_ d: Int) {
        curCount += 1
        if (curCount > len){
            delegate?.calculatorDidInputOverflow(self)
            curCount -= 1
            return
        }
        if(input == nil) {
            input = 0
        }
        if (input == 0 && d == 0 && !hasPoint) {
            curCount -= 1
            return
        }
        if (hasPoint){
            fractionDigits += 1
            if (fractionDigits > frac){
                delegate?.calculatorDidInputOverflow(self)
                fractionDigits -= 1
                curCount -= 1
                return
            }
            input! += Double(d) * pow(10, -Double(fractionDigits))
        }
        else {
            input! = input! * 10 + Double(d)
        }
        delegate?.calculatorDidUpdateValue(self, with: input!, valuePrecision: fractionDigits)
    }
    
    func addPoint() {
        self.hasPoint = true
        if (input == nil) {
            input = 0
            curCount += 1
        }
        delegate?.calculatorDidUpdateValue(self, with: input!, valuePrecision: fractionDigits)
    }
    
    
    func addOperation(_ op: Operation) {
        if (op == .sign){
            input = -(input ?? result ?? 0)
            delegate?.calculatorDidUpdateValue(self, with: input!, valuePrecision: fractionDigits)
            return
        }
        if (op == .perc) {
            if (operation == nil && result != nil) {
                result! /= 100
                delegate?.calculatorDidUpdateValue(self, with: result!, valuePrecision: fractionDigits)
            }
            else {
                input = (input ?? result ?? 0) / 100 * (result ?? 1)
                delegate?.calculatorDidUpdateValue(self, with: input!, valuePrecision: fractionDigits)
            }
            return
        }
        if (input == nil){
            self.operation = op
            return
        }
        compute()
        self.operation = op
        input = nil
    }
    
    func compute() {
        if (result == nil){
            result = input
            clear()
            delegate?.calculatorDidUpdateValue(self, with: result!, valuePrecision: fractionDigits)
            return
        }
        switch operation {
        case .add:
            result! += input ?? result ?? 0
        case .sub:
            result! -= input ?? result ?? 0
        case .mul:
            result! *= input ?? result ?? 0
        case .div:
            if ((input ?? result ?? 0) == 0){
                delegate?.calculatorDidNotCompute(self, withError: "Division by zero")
            }
            result! /= input!
        default:
            return
        }
        clear()
        operation = nil
        hasPoint = false
        delegate?.calculatorDidUpdateValue(self, with: result!, valuePrecision: UInt(countDecimalPlaces(result!) < Int(frac) ? countDecimalPlaces(result!) : Int(frac)))
    }
    
    func clear() {
        input = nil
        fractionDigits = 0
        hasPoint = false
        curCount = 0
        delegate?.calculatorDidUpdateValue(self, with: input ?? 0, valuePrecision: fractionDigits)
    }
    
    func reset() {
        result = nil
        operation = nil
        clear()
        delegate?.calculatorDidUpdateValue(self, with: input ?? 0, valuePrecision: fractionDigits)
    }
    
    
}

func countDecimalPlaces(_ number: Double) -> Int {
    let stringRepresentation = String(number)
    guard let decimalPointIndex = stringRepresentation.firstIndex(of: ".") else { return 0 }
    let decimalPlaces = stringRepresentation.distance(from: decimalPointIndex, to: stringRepresentation.endIndex) - 1
    return decimalPlaces
}

