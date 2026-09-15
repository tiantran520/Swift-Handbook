import UIKit
//: # associatedtype
//: Kiểu liên kết trong Protocol

import Foundation

// MARK: - 1. Protocol không dùng associatedtype — cứng nhắc

protocol IntContainer {
    func getItem() -> Int
}

// Chỉ chứa được Int
struct IntBox: IntContainer {
    let value: Int
    func getItem() -> Int { value }
}


// MARK: - 2. Protocol dùng associatedtype — linh hoạt

protocol Container {
    associatedtype Item
    mutating func append(_ item: Item)
    var count: Int { get }
    subscript(i: Int) -> Item { get }
}

// Container chứa Int
struct IntStack: Container {
    var items: [Int] = []
    
    mutating func append(_ item: Int) {
        items.append(item)
    }
    
    var count: Int { items.count }
    
    subscript(i: Int) -> Int {
        return items[i]
    }
}

// Container chứa String
struct StringQueue: Container {
    var items: [String] = []
    
    mutating func append(_ item: String) {
        items.append(item)
    }
    
    var count: Int { items.count }
    
    subscript(i: Int) -> String {
        return items[i]
    }
}

// Cùng Protocol, khác kiểu dữ liệu
var intStack = IntStack()
intStack.append(1)
intStack.append(2)
print("IntStack: \(intStack.items)")

var stringQueue = StringQueue()
stringQueue.append("Hello")
stringQueue.append("World")
print("StringQueue: \(stringQueue.items)")


// MARK: - 3. Generic Function với associatedtype

func printAllItems<C: Container>(in container: C) {
    for i in 0..<container.count {
        print(container[i])
    }
}

print("--- IntStack ---")
printAllItems(in: intStack)


// MARK: - 4. associatedtype với ràng buộc (Constraints)

protocol NumericContainer {
    associatedtype Item: Numeric   // Chỉ nhận kiểu Numeric
    var items: [Item] { get }
    func sum() -> Item
}

extension NumericContainer {
    func sum() -> Item {
        return items.reduce(0, +)
    }
}

struct NumberBox: NumericContainer {
    var items: [Int]
}

struct DoubleBox: NumericContainer {
    var items: [Double]
}

let numberBox = NumberBox(items: [1, 2, 3, 4])
print("Sum Int: \(numberBox.sum())")   // 10

let doubleBox = DoubleBox(items: [1.5, 2.5, 3.0])
print("Sum Double: \(doubleBox.sum())")  // 7.0


// MARK: - 5. associatedtype với Equatable

protocol EquatableContainer {
    associatedtype Item: Equatable
    var items: [Item] { get }
    func contains(_ item: Item) -> Bool
}

extension EquatableContainer {
    func contains(_ item: Item) -> Bool {
        return items.contains(item)
    }
}

struct StringList: EquatableContainer {
    var items: [String]
}

let list = StringList(items: ["An", "Binh", "Cuong"])
print("Có 'An'? \(list.contains("An"))")
print("Có 'Dung'? \(list.contains("Dung"))")


// MARK: - 6. Ví dụ thực tế — Repository Pattern

protocol Repository {
    associatedtype Entity
    func fetchAll() -> [Entity]
    func save(_ entity: Entity)
}

struct User {
    let id: Int
    let name: String
}

struct Product {
    let id: Int
    let title: String
}

class UserRepository: Repository {
    typealias Entity = User
    private var users: [User] = []
    
    func fetchAll() -> [User] { users }
    
    func save(_ entity: User) {
        users.append(entity)
    }
}

class ProductRepository: Repository {
    typealias Entity = Product
    private var products: [Product] = []
    
    func fetchAll() -> [Product] { products }
    
    func save(_ entity: Product) {
        products.append(entity)
    }
}

let userRepo = UserRepository()
userRepo.save(User(id: 1, name: "Thien"))
userRepo.save(User(id: 2, name: "An"))
print("Users: \(userRepo.fetchAll().map { $0.name })")

let productRepo = ProductRepository()
productRepo.save(Product(id: 1, title: "iPhone"))
print("Products: \(productRepo.fetchAll().map { $0.title })")


// MARK: - 7. protocol với associatedtype làm Type Erasure (nâng cao)

// Khó dùng trực tiếp vì không thể viết: let x: Container = ...
// Phải dùng "any Container" (Swift 5.7+)
let containers: [any Container] = [intStack, stringQueue]
print("Số container: \(containers.count)")
