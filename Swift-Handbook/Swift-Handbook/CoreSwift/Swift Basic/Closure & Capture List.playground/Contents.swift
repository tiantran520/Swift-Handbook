//: # Closure & Capture List
//: Từ cơ bản đến nâng cao
import UIKit
import Foundation

// MARK: - 1. Closure cơ bản

let greet = { (name: String) -> String in
    return "Hello, \(name)!"
}
print(greet("Thien"))


// MARK: - 2. Closure rút gọn

let numbers = [1, 2, 3, 4, 5]

// Cách 1: Đầy đủ
let doubled1 = numbers.map { (n: Int) -> Int in
    return n * 2
}

// Cách 2: Bỏ type
let doubled2 = numbers.map { n in
    return n * 2
}

// Cách 3: Bỏ return
let doubled3 = numbers.map { n in n * 2 }

// Cách 4: Shorthand $0
let doubled4 = numbers.map { $0 * 2 }

print(doubled4)   // [2, 4, 6, 8, 10]


// MARK: - 3. Closure capture giá trị

func makeCounter() -> () -> Int {
    var count = 0
    return {
        count += 1
        return count
    }
}

let counter1 = makeCounter()
print(counter1())   // 1
print(counter1())   // 2
print(counter1())   // 3

let counter2 = makeCounter()   // Closure mới, count mới
print(counter2())   // 1


// MARK: - 4. Escaping vs Non-escaping

// Non-escaping (mặc định)
func performNow(_ action: () -> Void) {
    action()   // Gọi ngay
}

// Escaping — lưu trữ để gọi sau
nonisolated(unsafe) var storedClosure: (() -> Void)?

func performLater(_ action: @escaping () -> Void) {
    storedClosure = action   // Lưu lại
}

performNow {
    print("Chạy ngay")
}

performLater {
    print("Chạy sau")
}
storedClosure?()


// MARK: - 5. Retain Cycle với Closure

class BadViewModel {
    var name = "BadVM"
    var onUpdate: (() -> Void)?
    
    func setup() {
        // ❌ Retain cycle — không có [weak self]
        onUpdate = {
            print("Update \(self.name)")
        }
    }
    
    deinit { print("BadViewModel deinit") }
}

var badVM: BadViewModel? = BadViewModel()
badVM?.setup()
badVM = nil
// Không in "BadViewModel deinit" → LEAK!


class GoodViewModel {
    var name = "GoodVM"
    var onUpdate: (() -> Void)?
    
    func setup() {
        // ✅ Không còn cycle
        onUpdate = { [weak self] in
            guard let self = self else { return }
            print("Update \(self.name)")
        }
    }
    
    deinit { print("GoodViewModel deinit") }
}

var goodVM: GoodViewModel? = GoodViewModel()
goodVM?.setup()
goodVM = nil
// In "GoodViewModel deinit" → OK


// MARK: - 6. Capture List — Các biến thể

@MainActor
class DataManager {
    var data: [String] = []
    
    func load(completion: @escaping () -> Void) {
        // Vì class đã @MainActor, mọi method đều chạy trên main
        // Không cần DispatchQueue.main.async nữa
        data.append("Loaded")
        completion()
    }
}

// Capture nhiều biến
class MultiCapture {
    var a = 1
    var b = 2
    
    func test() {
        let closure = { [weak self, weak other = self] in
            print(self?.a ?? 0)
            print(other?.b ?? 0)
        }
        closure()
    }
}

// Capture giá trị tại thời điểm tạo closure
var x = 10
let captureValue = { [x] in print("Captured: \(x)") }
x = 20
captureValue()   // In "Captured
