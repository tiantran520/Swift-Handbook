import UIKit
import Foundation
//: # Protocol-Oriented Programming
//: Lập trình hướng giao thức với ví dụ động vật

// MARK: - 1. Định nghĩa Protocol hành vi

protocol Swimmable {
    func swim()
}

protocol Flyable {
    func fly()
}

protocol Walkable {
    func walk()
}

// MARK: - 2 Default Implementation qua Extension
extension Swimmable {
    func swim() {
        print("🏊 \(Self.self) đang bơi")
    }
}

extension Flyable {
    func fly() {
        print("✈️ \(Self.self) đang bay")
    }
}

extension Walkable {
    func walk() {
        print("🚶 \(Self.self) đang đi")
    }
}

// MARK: - 3. Struct conform Protocol

struct Duck: Swimmable, Flyable, Walkable {
    let name: String
    // Không cần viết swim/fly/walk — dùng default
}

struct Penguin: Swimmable, Walkable {
    let name: String
    // Không fly — chỉ bơi và đi
}

struct Eagle: Flyable, Walkable {
    let name: String
    // Không bơi
}

// MARK: - 4. Sử dụng

let duck = Duck(name: "Donald")
let penguin = Penguin(name: "Pingu")
let eagle = Eagle(name: "Aquila")

print("--- Duck ---")
duck.swim()
duck.fly()
duck.walk()

print("\n--- Penguin ---")
penguin.swim()
penguin.walk()
// penguin.fly() // ❌ Compile error — Penguin không Flyable

print("\n--- Eagle ---")
eagle.fly()
eagle.walk()

// MARK: - 5. Hàm nhận Protocol
print("Hàm nhận Protocol")

func makeItSwim(_ animal: Swimmable) {
    animal.swim()
}

func makeItFly(_ animal: Flyable) {
    animal.fly()
}

makeItSwim(duck)
makeItSwim(penguin)
makeItFly(duck)
makeItFly(eagle)

// MARK: - 6. Override Default Implementation

struct Fish: Swimmable {
    let name: String
    
    // Ghi đè default
    func swim() {
        print("🐟 \(name) bơi cực nhanh!")
    }
}

let fish = Fish(name: "Nemo")
fish.swim()

// MARK: - 7. So sánh OOP vs POP

// ❌ Cách OOP — cây kế thừa phức tạp
/*
class Animal { }
class Bird: Animal { }
class FlyingBird: Bird { }
class SwimmingBird: Bird { }
class FlyingAndSwimmingBird: FlyingBird, SwimmingBird { } // ❌ Không được
*/
// ✅ Cách POP — lắp ghép linh hoạt
struct Robot: Flyable, Walkable {
    let model: String
}

let robot = Robot(model: "T-1000")
robot.fly()
robot.walk()

// MARK: - 8. Protocol với Property

protocol Identifiable {
    var id: String { get }
    var displayName: String { get }
}

extension Identifiable {
    var displayName: String {
        "ID: \(id)"
    }
}

struct Product: Identifiable {
    let id: String
    let price: Double
}

let product = Product(id: "P001", price: 99.99)
print(product.displayName)

// MARK: - 9. Protocol áp dụng cho Class kế thừa

class Vehicle: Flyable {
    let name: String
    init(name: String) { self.name = name }
}

class Airplane: Vehicle {
    // Kế thừa cả Flyable
}

let plane = Airplane(name: "Boeing 747")
plane.fly()
