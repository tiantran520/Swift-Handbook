import UIKit

//: # Memory — Heap & Stack
//: Minh họa nơi lưu trữ và hành vi bộ nhớ

import Foundation

// MARK: - 1. Stack vs Heap — Trực quan

struct StackObject {
    var value: Int
    // Struct lưu trên Stack (khi là biến cục bộ)
}

class HeapObject {
    var value: Int
    init(value: Int) { self.value = value }
    // Class lưu trên Heap
}

func demonstrateMemory() {
    // Biến cục bộ → Stack
    let stackObj = StackObject(value: 42)
    
    // Đối tượng class → Heap, con trỏ → Stack
    let heapObj = HeapObject(value: 42)
    
    print("Stack object: \(stackObj.value)")
    print("Heap object: \(heapObj.value)")
}

demonstrateMemory()

// MARK: - 2. Stack Overflow

// ❌ Hàm đệ quy vô hạn → Stack Overflow
/*
func infiniteRecursion() {
    infiniteRecursion()
}
// infiniteRecursion() // Crash: Stack Overflow
*/

// ✅ Đệ quy có điều kiện dừng
//3

// MARK: - 3. Heap — Đối tượng chia sẻ giữa các scope
/**
class SharedCounter {
    var count = 0
}

func increment(_ counter: SharedCounter) {
    counter.count += 1   // Cùng object → thay đổi luôn
}

let counter = SharedCounter()
increment(counter)
increment(counter)
print("Count sau 2 lần tăng: \(counter.count)")   // 2


// MARK: - 4. Struct không chia sẻ

struct ValueCounter {
    var count = 0
}

func incrementValue(_ counter: ValueCounter) {
    var counter = counter   // Copy
    counter.count += 1      // Chỉ thay đổi bản copy
}

var valueCounter = ValueCounter()
incrementValue(valueCounter)
incrementValue(valueCounter)
print("Count sau 2 lần tăng: \(valueCounter.count)")   // 0

// MARK: - 5. Thread Safety — Heap vs Stack

// ❌ Class không an toàn đa luồng
class UnsafeCounter {
    var count = 0
}

let unsafeCounter = UnsafeCounter()

// ⚠️ Data race — chạy nhiều lần có thể crash
DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    unsafeCounter.count += 1   // Không an toàn
}
print("Unsafe counter: \(unsafeCounter.count)")   // Có thể không phải 1000


// ✅ Dùng Actor để an toàn
actor SafeCounter {
    var count = 0
    
    func increment() {
        count += 1
    }
    
    func getCount() -> Int {
        count
    }
}

let safeCounter = SafeCounter()
Task {
    await withTaskGroup(of: Void.self) { group in
        for _ in 0..<1000 {
            group.addTask {
                await safeCounter.increment()
            }
        }
    }
    let finalCount = await safeCounter.getCount()
    print("Safe counter: \(finalCount)")   // 1000
}


// MARK: - 6. Memory Layout

print("--- Memory Layout ---")
print("Int: \(MemoryLayout<Int>.size) bytes")
print("Double: \(MemoryLayout<Double>.size) bytes")
print("Bool: \(MemoryLayout<Bool>.size) bytes")
print("StackObject: \(MemoryLayout<StackObject>.size) bytes")
print("HeapObject ref: \(MemoryLayout<HeapObject>.size) bytes") 
*/
