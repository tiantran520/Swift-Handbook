# Struct vs Class
### **1. Struct (Kiểu Tham Trị - Value Type)**
- Bản chất: Struct là kiểu tham trị (Value type). Khi bạn gán hoặc truyền một struct đi, bạn đang tạo ra một bản sao (copy). Tuy nhiên, Swift rất thông minh nhờ cơ chế Copy-on-write: nó chỉ thực sự tạo ra một bản copy mới trong bộ nhớ khi bạn thay đổi dữ liệu của bản sao đó.
- Memory Leak (Rò rỉ bộ nhớ): Struct không thể gây ra memory leak. Vì chúng chỉ là những giá trị được truyền đi, không có sự ràng buộc hay phụ thuộc lẫn nhau về địa chỉ bộ nhớ như Class. Apple khuyên nên dùng Struct làm mặc định khi tạo kiểu dữ liệu mới.
- Kế thừa (Inheritance): Struct không hỗ trợ kế thừa. Nhưng trong phỏng vấn, bạn có thể ghi điểm bằng cách nói: "Ta có thể mô phỏng tính kế thừa cho Struct bằng cách kết hợp Protocol và Default Implementation (Extension)".
- Khởi tạo (Initializer): Struct được Swift tự động tặng kèm một hàm khởi tạo tự động gọi là memberwise initializer.
- Nơi lưu trữ: Stack Memory.
- Cơ chế: Stack hoạt động theo nguyên tắc LIFO (Vào sau ra trước). Cực kỳ nhanh vì hệ thống chỉ cần dịch chuyển một con trỏ (stack pointer).
- An toàn đa luồng (Thread-safe): Mỗi một Thread (luồng) trong Swift có một Stack độc quyền. Không có luồng nào khác truy cập được vào Stack này. Do đó, Struct cực kỳ an toàn trong môi trường đa luồng.
- Chi phí cấp phát và huỷ vùng nhớ trên Stack là rất rẻ.

### **2. Class (Kiểu Tham Chiếu - Reference Type)**
- Bản chất: Class là kiểu tham chiếu. Nghĩa là nhiều biến có thể cùng trỏ về một địa chỉ bộ nhớ. Khi bạn sửa ở một nơi, tất cả các nơi khác đều bị thay đổi theo. Không có cơ chế copy-on-write ở đây.
Memory Leak: Rất dễ gây rò rỉ bộ nhớ do việc trỏ chéo lẫn nhau (Retain Cycle).
- Vòng đời: Không có hàm khởi tạo tự động (phải tự viết). Bù lại, Class có hàm deinit (được gọi trước khi object bị huỷ). Dùng deinit là một cách hay để test xem Class có bị rò rỉ bộ nhớ hay không.
Kế thừa: Hỗ trợ kế thừa mạnh mẽ (Class con có thể kế thừa và override Class cha).
- Nơi lưu trữ: Heap Memory.
Cơ chế: Bộ nhớ Heap phức tạp và chậm hơn Stack nhiều (Tốc độ O(log n) so với O(1) của Stack). Nó dùng để lưu trữ những đối tượng mà kích thước hoặc thời gian sống của nó không thể tính toán chính xác lúc biên dịch (compile-time). Swift phải dùng hệ thống đếm tham chiếu (ARC) để dọn dẹp Heap.
- KHÔNG an toàn đa luồng (Thread-unsafe): Khác với Stack là đồ dùng riêng của từng Thread, Heap là bộ nhớ dùng chung (Global). Mọi Thread đều có thể chọc vào Heap cùng lúc. Nếu hai Thread cùng sửa một Class, ứng dụng có thể bị crash (Data race).

### Lưu ý: Cách hoạt động của vùng nhớ Heap và Stack
- Heap: Cấp phát động. Dữ liệu được lưu trữ tự do không theo thứ tự cố định
- Tốc độ: Truy cập chậm hơn Stack vì cần tìm kiếm vùng trống trong bộ nhớ.
- Lưu Trữ: Rất lớn, chỉ giới hạn bởi dung lượng RAM vật lý và cấu hình của hệ điều hành/chương trình. Thích hợp cho các đối tượng lớn, mảng khổng lồ.
- Phạm vi: Được chia sẻ chung cho toàn bộ các luồng (threads) trong chương trình
- Quản lý: Dữ liệu tồn tại cho đến khi được giải phóng tường minh (như dùng delete/free trong C++) hoặc tự động thu gom bởi bộ thu gom rác (Garbage Collector trong Java/C#). Nếu quên giải phóng sẽ gây rò rỉ bộ nhớ (Memory Leak).
- Stack: Hoạt động theo kiểu LIFO (Last In, First Out - vào sau ra trước). Khi một hàm được gọi, các biến cục bộ được đẩy vào Stack; khi hàm kết thúc, chúng tự biến mất.
- Tốc độ: Cấp phát và truy xuất dữ liệu rất nhanh do CPU quản lý trực tiếp qua con trỏ ngăn xếp.
- Dung lượng: Nhỏ và bị giới hạn cứng (thường chỉ vài MB tùy hệ thống). Dễ gây lỗi tràn bộ nhớ (Stack Overflow) nếu gọi đệ quy quá sâu hoặc khai báo mảng quá lớn.
- Phạm vi: Riêng tư cho từng luồng (thread) xử lý

Chúng ta có thể liệt kê một số điểm giống nhau giữa Struct và Class trong Swift như sau:
* Công dụng: Giúp cấu hình/định nghĩa 1 object.
* Properties: struct và class đều có property (thuộc tính).
* Method: cả struct và class đều có method (phương thức).
* Initializier: struct và class hỗ trợ các phương thức khởi tạo mặc định, hoặc các phương thức khởi tạo tuỳ chỉnh theo mục đích và logic của lập trình viên.
* Subscript: Struct và class hỗ trợ các subscript syntax (câu lệnh con bên trong một thuộc tính, hoặc một hàm).
* Extension: Extension là khái niệm mới trong Swift, nó giúp lập trình viên có thể mở rộng các struct, hoặc class sẵn có hoặc đã được xây dựng từ trước.

| Class (Kiểu tham chiếu)   | Struct (Kiểu tham trị)   |
| --- | --- |
|  Hỗ trợ kế thừa theo OOP  |  Không hỗ trợ kế thừa  |
|  Phải khai báo hàm khởi tạo và deinit|  Tự động tạo memberwise initializer  |
|  Truy xuất vùng nhớ; Dễ gây memory leak (Retain Cycle)  |Tạo bản copy mới khi thay đổi; Không gây memory leak    |
|  Lưu trữ ở bộ nhớ Heap  |  Lưu trữ ở bộ nhớ Stack  |
|  Có hàm deinit để giải phóng bộ nhớ  |  Không có hàm deinit  |
| Hỗ trợ kế thừa|Không hỗ trợ kế thưà| 
| Dễ gây memory leak  | Tạo bản copy mới nên không gây memmory leak  |

Khác nhau:

* Type (kiểu): struct là value type còn class là reference type.
* Inheritance (kế thừa): Struct không thể kế thừa, còn class thì có thể ( hiển nhiên – OOP mà).
* Deinitializers: Struct không có hàm huỷ (destructor trong java/C++), chỉ có hàm khởi tạo initializer (constructor trong java/C++), còn Class thì có đầy đủ
* The way they deal with constants:
  * If you have a constant struct with a variable property, that property can’t be changed because the struct itself is constant.
  * If you have a constant class with a variable property, that property can be changed.

```swift
struct StructA {
    var name: String
}

class ClassB {
    var name: String
}

func viewDidLoad() {
    let structA = StructA(name: "Bradley")
    structA.name = "HT Kien" // Error: Cannot assign to property: 'structA' is a 'let' constant
    let classB = ClassB(name: "Hoang Trong Kien")
    classB.name = "Bradley"  // Success
}
```

* Multiple reference (đa tham chiếu): chúng ta có thể có nhiều đối tượng cùng tham chiếu đến 1 class instance, còn ở struct thì không thể (vì nó là value type mà).
