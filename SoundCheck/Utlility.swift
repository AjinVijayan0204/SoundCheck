//
//  Utlility.swift
//  SoundCheck
//
//  Created by Ajin on 03/02/25.
//

import Foundation

func mean<T: BinaryFloatingPoint>(of numbers: [T]) -> T? {
    guard !numbers.isEmpty else { return nil } // Avoid division by zero
    let sum = numbers.reduce(0, +)
    return sum / T(numbers.count)
}
