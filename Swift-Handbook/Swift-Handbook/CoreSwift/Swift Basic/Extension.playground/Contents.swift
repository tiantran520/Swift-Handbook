import UIKit
//: # Extension — Mở rộng kiểu dữ liệu
//: Thêm chức năng cho String, Int, Array, Protocol...

import Foundation

// MARK: - 1. Extension cho String

extension String {
    var isEmail: Bool {
        return contains("@") && contains(".")
    }
    
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func reversedWords() -> String {
        return split(separator: " ")
            .reversed()
            .joined(separator: " ")
    }
}

let email = "thien@dev.io"
print("'\(email)' là email? \(email.isEmail)")   // true

let name = "  Thien Tran  "
print("Trimmed: '\(name.trimmed)'")             // "Thien Tran"

let sentence = "Hello World Swift"
print(sentence.reversedWords())                 // "Swift World Hello"


// MARK: - 2. Extension cho Int

extension Int {
    var squared: Int { self * self }
    var isEven: Bool { self % 2 == 0 }
    var isOdd: Bool { !isEven }
    
    func times(_ action: () -> Void) {
        for _ in 0..<self { action() }
    }
    
    var factorial: Int {
        return self <= 1 ? 1 : (1...self).reduce(1, *)
    }
}

print("5² = \(5.squared)")             // 25
print("7 chẵn? \(7.isEven)")           // false
print("5! = \(5.factorial)")           // 120

3.times {
    print("👋 Hello")
}


// MARK: - 3. Extension cho Array

extension Array where Element: Comparable {
    var isSorted: Bool {
        return self == self.sorted()
    }
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

let numbers = [1, 2, 3, 4, 5]
print("Sorted? \(numbers.isSorted)")       // true
print("Chunked: \(numbers.chunked(into: 2))")  // [[1,2],[3,4],[5]]

let unsorted = [3, 1, 4, 2]
print("Sorted? \(unsorted.isSorted)")     // false


// MARK: - 4. Extension cho Protocol

protocol Greetable {
    var name: String { get }
}

extension Greetable {
    func greet() -> String {
        return "Hello, \(name)!"
    }
    
    func greetFormal() -> String {
        return "Good day, \(name)."
    }
}

struct Person: Greetable {
    let name: String
}

struct Company: Greetable {
    let name: String
}

let person = Person(name: "Thien")
let company = Company(name: "Apple")

print(person.greet())       // Hello, Thien!
print(company.greetFormal())  // Good day, Apple.


// MARK: - 5. Extension thêm Initializer

struct Temperature {
    var celsius: Double
}

extension Temperature {
    init(fahrenheit: Double) {
        self.celsius = (fahrenheit - 32) * 5 / 9
    }
    
    init(kelvin: Double) {
        self.celsius = kelvin - 273.15
    }
}

let temp1 = Temperature(celsius: 25)
let temp2 = Temperature(fahrenheit: 77)
let temp3 = Temperature(kelvin: 300)

print("25°C = \(temp2.celsius)°C từ °F")
print("300K = \(temp3.celsius)°C")


// MARK: - 6. Extension áp dụng Protocol cho kiểu có sẵn

protocol JSONRepresentable {
    var jsonString: String { get }
}

extension Dictionary: JSONRepresentable where Key == String, Value == Any {
    var jsonString: String {
        guard let data = try? JSONSerialization.data(
            withJSONObject: self, options: .prettyPrinted),
            let str = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return str
    }
}

let dict: [String: Any] = ["name": "Thien", "age": 25]
print(dict.jsonString)


// MARK: - 7. Extension chia nhỏ file lớn

// Thay vì 1 class phình to:
// extension UserViewController: UITableViewDataSource { ... }
// extension UserViewController: UITableViewDelegate { ... }
// extension UserViewController: UISearchBarDelegate { ... }

// Ví dụ minh họa:
protocol DataSource {
    func numberOfItems() -> Int
}

protocol Delegate {
    func didSelectItem(at index: Int)
}

class ListVC {
    let items = ["A", "B", "C"]
}

extension ListVC: DataSource {
    func numberOfItems() -> Int { items.count }
}

extension ListVC: Delegate {
    func didSelectItem(at index: Int) {
        print("Selected: \(items[index])")
    }
}

let listVC = ListVC()
print("Số item: \(listVC.numberOfItems())")
listVC.didSelectItem(at: 1)


// MARK: - 8. Extension với Generic

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

var optionalString: String? = nil
print("Nil hoặc empty? \(optionalString.isNilOrEmpty)")   // true

optionalString = ""
print("Nil hoặc empty? \(optionalString.isNilOrEmpty)")   // true

optionalString = "Hello"
print("Nil hoặc empty? \(optionalString.isNilOrEmpty)")   // false
