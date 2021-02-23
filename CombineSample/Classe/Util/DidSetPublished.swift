//
//  DidSetPublished.swift
//  CombineSample
//
//  Created by zrn_ns on 2021/02/23.
//

import Combine

/// didSetのタイミングで通知を行うPublished。
/// 通常の@PublishedではwillSetのタイミングで通知が行われるため、通知受信時に元のオブジェクトを
/// 参照すると変更前の値が取得されてしまうが、didSetのタイミングで通知すればこの問題は発生しない。
///  （ReactiveSwiftのPropertyクラスと同じ挙動になる）
/// https://stackoverflow.com/questions/58403338/is-there-an-alternative-to-combines-published-that-signals-a-value-change-afte
@propertyWrapper
class DidSetPublished<Value> {
    private var val: Value
    private let subject: CurrentValueSubject<Value, Never>

    init(wrappedValue value: Value) {
        val = value
        subject = CurrentValueSubject(value)
        wrappedValue = value
    }

    var wrappedValue: Value {
        set {
            val = newValue
            subject.send(val)
        }
        get { val }
    }

    public var projectedValue: CurrentValueSubject<Value, Never> {
        get { subject }
    }
}
