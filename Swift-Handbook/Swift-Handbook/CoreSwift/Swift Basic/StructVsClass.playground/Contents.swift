import UIKit
import Foundation

//: # Struct vs Class
// MARK: - Create Struct (struct is a value type)
//để chứng minh struct là một value type ta làm như sao
//Tạo toạ độ B sao đó tạo thêm một toạ độ B, gán giá trị toạ độ A vào toạ độ B. Thau đổi toạ độ A và in ra kết quả
// => kết quả mong muốn là toạ độ B giữ nguyên không phụ thuộc vào sự thay đổi của toạ độ A
struct PointStruct {
    var x: Int
    var y: Int
}

var pointA = PointStruct(x: 1, y: 2)

var pointB = pointA
pointA.x = 10
print(pointA.x)
print(pointB.x)

// MARK: - Tạo một Point là class
// Để chưng minh class là Reference Type
//Tạo toạ độ B sao đó tạo thêm một toạ độ B, gán giá trị toạ độ A vào toạ độ B. Thau đổi toạ độ A và in ra kết quả
// => kết quả mong muốn là toạ độ B thay đổi và phụ thuộc vào sự thay đổi của toạ độ A
class PointClass {
    var x: Int
    var y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

var pointC = PointClass(x: 1, y: 2)

var pointD = pointC
pointC.x = 10
print(pointC.x)
print(pointD.x)

// MARK: - 3. Copy-on-Write (COW) của Struct

var arrayA = [1, 2, 3, 4, 5]
var arrayB = arrayA          // Chưa copy ngay — COW
print("Trước khi sửa — cùng bộ nhớ: \(arrayA) | \(arrayB)")

arrayB.append(6)             // Bây giờ mới thực sự copy
print("Sau khi sửa arrayB: \(arrayA) | \(arrayB)")


// MARK: - 4. Memberwise Initializer của Struct
struct User {
    var name: String
    var age: Int
    var email: String
}

// Struct tự động có memberwise init có hàm init tự tạo
let user = User(name: "Thien", age: 25, email: "thien@dev.io")
print(user)

// MARK: - 5. Class cần Custom Initializer

class UserClass {
    var name: String
    var age: Int
    var email: String
    
    init(name: String, age: Int, email: String) {
        self.name = name
        self.age = age
        self.email = email
    }
}

let userClass = UserClass(name: "Thien", age: 25, email: "thien@dev.io")
print(userClass.name)

// MARK: - 6. deinit chỉ có ở Class

class Resource {
    let name: String
    
    init(name: String) {
        self.name = name
        print("🟢 \(name) được tạo")
    }
    
    deinit {
        print("🔴 \(name) bị giải phóng")
    }
}

do {
    let resource = Resource(name: "DatabaseConnection")
    print("Đang sử dụng: \(resource.name)")
}
// Khi ra khỏi scope, deinit được gọi
// Struct KHÔNG có deinit

// MARK: - 7. So sánh hiệu năng (tham khảo)

// Tạo 1 triệu struct
let startStruct = Date()
var structs: [PointStruct] = []
for i in 0..<1_000_000 {
    structs.append(PointStruct(x: i, y: i))
}
let structTime = Date().timeIntervalSince(startStruct)
print("⏱ Struct 1 triệu phần tử: \(structTime)s")

// Tạo 1 triệu class
let startClass = Date()
var classes: [PointClass] = []
for i in 0..<1_000_000 {
    classes.append(PointClass(x: i, y: i))
}
let classTime = Date().timeIntervalSince(startClass)
print("⏱ Class 1 triệu phần tử: \(classTime)s")
