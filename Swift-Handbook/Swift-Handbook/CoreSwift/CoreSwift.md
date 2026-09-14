# Swift Vault — Tổng hợp kiến thức Swift

> Kho tài liệu tổng hợp kiến thức Swift dành cho iOS Developer.
> Bao gồm: Struct vs Class, POP, Closure, ARC, Retain Cycle, và nhiều hơn nữa.

---

## 📑 Mục lục

- [1. Struct vs Class](#1-struct-vs-class)
- [2. Bộ nhớ Heap và Stack](#2-bộ-nhớ-heap-và-stack)
- [3. Bảng so sánh nhanh](#3-bảng-so-sánh-nhanh)
- [4. Protocol-Oriented Programming (POP)](#4-protocol-oriented-programming-pop)
- [5. Extension](#5-extension)
- [6. associatedtype](#6-associatedtype)
- [7. Protocol Composition](#7-protocol-composition)
- [8. Closure & Capture List](#8-closure--capture-list)
- [9. Retain Cycle & ARC](#9-retain-cycle--arc)

---

## 1. Struct vs Class

### 🟢 Struct (Kiểu Tham Trị — Value Type)

- **Bản chất**: Struct là kiểu tham trị (Value type). Khi bạn gán hoặc truyền một struct đi, bạn đang tạo ra một bản sao (copy). Tuy nhiên, Swift rất thông minh nhờ cơ chế **Copy-on-write**: nó chỉ thực sự tạo ra một bản copy mới trong bộ nhớ khi bạn thay đổi dữ liệu của bản sao đó.
- **Memory Leak**: Struct **không thể** gây ra memory leak. Vì chúng chỉ là những giá trị được truyền đi, không có sự ràng buộc hay phụ thuộc lẫn nhau về địa chỉ bộ nhớ như Class. Apple khuyên nên dùng Struct làm mặc định khi tạo kiểu dữ liệu mới.
- **Kế thừa**: Struct **không hỗ trợ kế thừa**. Nhưng trong phỏng vấn, bạn có thể ghi điểm bằng cách nói:

  > "Ta có thể mô phỏng tính kế thừa cho Struct bằng cách kết hợp Protocol và Default Implementation (Extension)."

- **Khởi tạo**: Struct được Swift tự động tặng kèm một hàm khởi tạo tự động gọi là **memberwise initializer**.
- **Nơi lưu trữ**: **Stack Memory**.
- **Cơ chế**: Stack hoạt động theo nguyên tắc **LIFO** (Vào sau ra trước). Cực kỳ nhanh vì hệ thống chỉ cần dịch chuyển một con trỏ (stack pointer).
- **An toàn đa luồng**: Mỗi Thread trong Swift có một Stack độc quyền. Không có luồng nào khác truy cập được vào Stack này. Do đó, Struct cực kỳ **an toàn trong môi trường đa luồng**.
- **Chi phí**: Cấp phát và huỷ vùng nhớ trên Stack là rất rẻ.

### 🔵 Class (Kiểu Tham Chiếu — Reference Type)

- **Bản chất**: Class là kiểu tham chiếu. Nghĩa là nhiều biến có thể cùng trỏ về một địa chỉ bộ nhớ. Khi bạn sửa ở một nơi, tất cả các nơi khác đều bị thay đổi theo. **Không có cơ chế copy-on-write** ở đây.
- **Memory Leak**: Rất dễ gây rò rỉ bộ nhớ do việc trỏ chéo lẫn nhau (**Retain Cycle**).
- **Vòng đời**: Không có hàm khởi tạo tự động (phải tự viết). Bù lại, Class có hàm `deinit` (được gọi trước khi object bị huỷ). Dùng `deinit` là một cách hay để test xem Class có bị rò rỉ bộ nhớ hay không.
- **Kế thừa**: Hỗ trợ kế thừa mạnh mẽ (Class con có thể kế thừa và override Class cha).
- **Nơi lưu trữ**: **Heap Memory**.
- **Cơ chế**: Bộ nhớ Heap phức tạp và chậm hơn Stack nhiều (Tốc độ `O(log n)` so với `O(1)` của Stack). Nó dùng để lưu trữ những đối tượng mà kích thước hoặc thời gian sống của nó không thể tính toán chính xác lúc compile-time. Swift phải dùng hệ thống đếm tham chiếu (**ARC**) để dọn dẹp Heap.
- **An toàn đa luồng**: **KHÔNG an toàn**. Khác với Stack là đồ dùng riêng của từng Thread, Heap là bộ nhớ dùng chung (Global). Mọi Thread đều có thể chọc vào Heap cùng lúc. Nếu hai Thread cùng sửa một Class, ứng dụng có thể bị crash (**Data race**).

### 🟣 Actor (Ngôi sao mới giải quyết bài toán Đa luồng)

Actor ra đời ở các bản Swift mới. Nó có mọi tính năng như Class (thuộc tính, hàm, conform protocol, cũng là Reference Type, cũng lưu ở Heap).

**Điểm khác biệt ăn tiền**: Actor tự động đảm bảo tính **An toàn luồng** (Thread-safe). Nó ngầm quản lý việc truy cập dữ liệu, đảm bảo tại một thời điểm chỉ có một luồng được phép đụng vào dữ liệu của nó. Bạn không cần phải tự viết các cơ chế phức tạp như Locks hay Dispatch Barriers nữa.

---

## 2. Bộ nhớ Heap và Stack

### 🗄️ Heap

| Đặc điểm | Mô tả |
|----------|-------|
| **Cấp phát** | Động. Dữ liệu được lưu trữ tự do, không theo thứ tự cố định |
| **Tốc độ** | Truy cập chậm hơn Stack vì cần tìm kiếm vùng trống trong bộ nhớ |
| **Lưu trữ** | Rất lớn, chỉ giới hạn bởi dung lượng RAM vật lý và cấu hình hệ điều hành. Thích hợp cho các đối tượng lớn, mảng khổng lồ |
| **Phạm vi** | Được chia sẻ chung cho toàn bộ các luồng (threads) trong chương trình |
| **Quản lý** | Dữ liệu tồn tại cho đến khi được giải phóng tường minh (như `delete`/`free` trong C++) hoặc tự động thu gom bởi Garbage Collector (Java/C#). Nếu quên giải phóng sẽ gây **Memory Leak** |

### 📚 Stack

| Đặc điểm | Mô tả |
|----------|-------|
| **Cơ chế** | Hoạt động theo kiểu **LIFO** (Last In, First Out). Khi một hàm được gọi, các biến cục bộ được đẩy vào Stack; khi hàm kết thúc, chúng tự biến mất |
| **Tốc độ** | Cấp phát và truy xuất dữ liệu **rất nhanh** do CPU quản lý trực tiếp qua con trỏ ngăn xếp |
| **Dung lượng** | Nhỏ và bị giới hạn cứng (thường chỉ vài MB tùy hệ thống). Dễ gây lỗi **Stack Overflow** nếu gọi đệ quy quá sâu hoặc khai báo mảng quá lớn |
| **Phạm vi** | Riêng tư cho từng luồng (thread) xử lý |

---

## 3. Bảng so sánh nhanh

| Tiêu chí | Class | Struct |
|----------|-------|--------|
| **Kế thừa** | Hỗ trợ kế thừa theo OOP | Không hỗ trợ kế thừa |
| **Khởi tạo / Deinit** | Phải khai báo hàm khởi tạo và hàm `deinit` | Luôn tạo ra một hàm khởi tạo (memberwise) ngay từ đầu |
| **Bản chất** | Kiểu tham chiếu — truy xuất đến vùng nhớ | Kiểu tham trị — tạo ra bản copy mới nên khi thay đổi phần gốc không bị thay đổi |
| **Memory Leak** | Có thể gây ra memory leak do sự ánh xạ qua lại lẫn nhau | Không gây ra memory leak do chỉ là những giá trị truyền đi |
| **Bộ nhớ** | Lưu trữ ở **Heap** | Lưu trữ ở **Stack** |
| **Giải phóng bộ nhớ** | Có hàm `deinit` để giải phóng vùng nhớ | Không có hàm `deinit` |
| **Đa luồng** | Sử dụng cho một luồng chính (không an toàn) | Riêng tư cho từng luồng do sử dụng Stack → an toàn cho đa luồng |
| **Khi nào dùng** | Khi tạo đối tượng có các thuộc tính phức tạp hơn | Khi tạo đối tượng có nhiều thuộc tính và có kiểu dữ liệu đơn giản |

---

## 4. Protocol-Oriented Programming (POP)

### POP là gì?

**POP (Protocol-Oriented Programming — Lập trình hướng giao thức)** là một mô hình lập trình được Apple giới thiệu cùng với ngôn ngữ Swift vào năm 2015.

Trong khi **OOP** coi Class là trung tâm của mọi thứ, thì **POP** lại lấy **Protocol** làm nền tảng. Thay vì bắt đầu thiết kế hệ thống bằng cách tạo ra một hệ thống phân cấp các Class phức tạp, trong POP, bạn bắt đầu bằng cách định nghĩa các Protocol để mô tả **hành vi** (những gì một đối tượng có thể làm), sau đó để các kiểu dữ liệu (Struct, Enum, Class) **tuân thủ** (conform) theo các Protocol đó.

### POP giải quyết vấn đề gì?

POP ra đời chủ yếu để giải quyết những "điểm nghẽn" và hạn chế cố hữu của OOP truyền thống:

#### 🔴 Khủng hoảng thừa kế (God Classes & Inheritance Tax)

Trong OOP, để chia sẻ code, bạn thường phải tạo ra một Class cha (Superclass) và cho các Class con kế thừa. Lâu dần, Class cha sẽ phình to ra vì phải chứa tất cả các thuộc tính/hàm mà một vài Class con cần tới. Những Class con đôi khi phải kế thừa những hành vi mà chúng **hoàn toàn không sử dụng**.

#### 🔴 Vấn đề tham chiếu (Reference Type Issues)

OOP phụ thuộc hoàn toàn vào Class (là kiểu tham chiếu). Nhiều biến cùng trỏ vào một vùng nhớ có thể dẫn đến việc dữ liệu bị thay đổi ngoài ý muốn (**side effects**), gây khó khăn khi lập trình đa luồng hoặc gây rò rỉ bộ nhớ.

#### 🔴 Giới hạn đơn kế thừa

Hầu hết các ngôn ngữ hiện đại (bao gồm cả Swift) không cho phép một Class kế thừa từ nhiều Class cha cùng lúc để tránh xung đột (**Diamond Problem**). Điều này làm cho việc tái sử dụng code từ nhiều nguồn khác nhau trở nên rất khó khăn.

### POP giải quyết vấn đề gì trong Swift?

#### ✅ Mang sức mạnh của OOP lên Struct và Enum

Nhờ POP, bạn có thể định nghĩa các Protocol và để Struct tuân thủ theo. Điều này giúp Value Types vừa có sự an toàn về vùng nhớ, lại vừa có khả năng **đa hình** (polymorphism) như Class.

#### ✅ Cung cấp triển khai mặc định (Protocol Extensions)

Đây là **"vũ khí tối thượng"** của POP trong Swift. Bạn có thể viết code thực thi sẵn các hàm ngay bên trong bản mở rộng của Protocol (`extension ProtocolName`). Bất kỳ Struct/Class nào tuân thủ Protocol này đều tự động có được đoạn code đó mà không cần phải viết lại, giải quyết triệt để bài toán **lặp code**.

#### ✅ Thay thế "Kế thừa" bằng "Kết hợp" (Composition over Inheritance)

Nhờ POP, một Struct có thể tuân thủ (conform) **hàng chục Protocol khác nhau cùng lúc**. Bạn giống như đang "lắp ráp lắp ghép lego", nhặt các hành vi như `Bơi`, `Bay`, `Chạy` ghép vào một Struct cụ thể (ví dụ: `Vịt`) thay vì phải cố gắng tạo ra một cây phả hệ thừa kế rườm rà.

---

## 5. Extension

### Extension là gì?

Trong Swift, **Extension (Phần mở rộng)** là một tính năng vô cùng mạnh mẽ cho phép bạn thêm các chức năng mới vào một kiểu dữ liệu đã có sẵn (như Class, Struct, Enum, hoặc Protocol).

Điều tuyệt vời nhất: bạn có thể mở rộng chức năng của một kiểu dữ liệu **ngay cả khi bạn không có quyền truy cập vào mã nguồn gốc** của nó. Ví dụ: bạn hoàn toàn có thể thêm các hàm mới vào các kiểu có sẵn của chính Apple như `String`, `Int`, `Double`, hay `Array`.

### Bạn có thể "đắp" gì vào Extension?

- **Thêm phương thức (Methods)**: Thêm các hàm xử lý mới cho Instance hoặc Type.
- **Thêm thuộc tính tính toán (Computed Properties)**: Thêm các biến trả về giá trị dựa trên tính toán (không được thêm biến lưu trữ — Stored Properties).
- **Thêm hàm khởi tạo (Initializers)**: Cung cấp thêm các cách thức mới để tạo ra một đối tượng.
- **Áp dụng Protocol mới**: Dùng Extension để khai báo rằng một Class/Struct hiện tại sẽ tuân thủ theo một Protocol nào đó, giúp code gọn gàng và dễ tổ chức hơn.

---

## 6. associatedtype

Trong Swift, **`associatedtype` (kiểu liên kết)** là một từ khóa dùng bên trong Protocol để tạo ra một **"tên thay thế"** (placeholder) cho một kiểu dữ liệu chưa được xác định.

Nói một cách đơn giản: Thay vì ép Protocol phải làm việc với một kiểu dữ liệu cụ thể (như `Int` hay `String`), bạn dùng `associatedtype` để nói rằng:

> "Protocol này sẽ làm việc với một kiểu dữ liệu nào đó, nhưng kiểu cụ thể là gì thì để các Struct hoặc Class áp dụng Protocol này tự quyết định."

### Tại sao phải dùng associatedtype?

- **Tính tái sử dụng cao (Reusability)**: Bạn chỉ cần viết một Protocol duy nhất nhưng có thể áp dụng cho hàng tá Struct/Class với các kiểu dữ liệu hoàn toàn khác nhau.
- **An toàn kiểu dữ liệu (Type Safety)**: Dù chưa biết kiểu dữ liệu cụ thể ở thời điểm viết Protocol, nhưng khi Compiler chạy, nó sẽ buộc các Struct phải tuân thủ đúng kiểu dữ liệu đã chọn, tránh việc gán nhầm kiểu gây crash ứng dụng.
- **Linh hoạt**: Bạn thậm chí có thể đặt điều kiện cho `associatedtype`. Ví dụ: `associatedtype Product: Equatable` (bắt buộc kiểu dữ liệu được chọn phải có khả năng so sánh bằng nhau).

---

## 7. Protocol Composition

**Protocol Composition (Kết hợp giao thức)** là một tính năng trong Swift cho phép bạn yêu cầu một đối tượng hoặc tham số phải tuân thủ **nhiều Protocol cùng một lúc**.

Thay vì phải tạo ra một Protocol mới bao trùm tất cả, bạn chỉ cần dùng toán tử `&` để nối các Protocol lại với nhau. Nó tạo ra một "yêu cầu tổng hợp" ngay tại nơi bạn cần sử dụng.

### Protocol Composition giải quyết vấn đề gì?

#### ✅ Tuân thủ Nguyên tắc phân tách Interface (ISP)

Nguyên tắc chữ **I** trong **SOLID** khuyên rằng: *Không bao giờ ép một đối tượng triển khai những hàm mà nó không sử dụng.* Nếu bạn gộp chung `read()` và `write()` vào một Protocol duy nhất là `FileHandler`, thì `ReadOnlyFile` sẽ bị ép phải chứa một hàm `write()` trống rỗng hoặc báo lỗi. Việc chia nhỏ ra và dùng `&` để gộp lại khi cần giúp loại bỏ hoàn toàn các đoạn code dư thừa.

#### ✅ Ngăn chặn bùng nổ file và mã nguồn (Protocol Explosion)

Nếu không có tính năng này, mỗi lần cần một tổ hợp hành vi, bạn phải định nghĩa hẳn một Protocol mới. Ví dụ: `protocol ReadAndWritable`, `protocol ReadAndShareable`, `protocol WriteAndShareable`... Điều này làm dự án chứa đầy những Protocol rác. Composition giúp bạn tạo ra các kết hợp **"on-the-fly"** (chỉ kết hợp ngay tại thời điểm cần).

#### ✅ Lắp ráp linh hoạt như Lego (Granularity)

Bạn có thể định nghĩa các Protocol siêu nhỏ gọn chỉ có 1 chức năng (`Flyable`, `Swimmable`, `Walkable`). Tùy vào yêu cầu của hệ thống, bạn linh hoạt ghép chúng lại. Ví dụ: yêu cầu một `Vịt` là `Flyable & Swimmable & Walkable`, nhưng lại yêu cầu chim `Cánh cụt` chỉ cần `Swimmable & Walkable`. Không cần kế thừa phức tạp, mọi thứ được lắp ráp tùy biến.

---

## 8. Closure & Capture List

### Closure là gì?

**Closure** trong Swift là một khối mã (block of code) độc lập chứa các đoạn lệnh có thể được truyền đi và sử dụng ở bất kỳ đâu trong code của bạn. Bạn có thể hiểu nó giống như một hàm (function) nhưng **không cần thiết phải có tên**.

### Closure hoạt động như thế nào?

Closure được định nghĩa trong cặp dấu ngoặc nhọn `{}`. Phần khai báo tham số và kiểu trả về được ngăn cách với phần thân code bằng từ khóa `in`.

Đặc tính mạnh mẽ nhất của Closure là **Capture (Bắt giữ giá trị)**. Một Closure có thể "nhớ" và truy cập các biến hoặc hằng số ở môi trường bên ngoài nơi nó được tạo ra, ngay cả khi môi trường đó đã kết thúc hoặc không còn tồn tại. Nó đóng gói (enclose) các giá trị đó vào bên trong chính nó để sử dụng.

### Closure giải quyết vấn đề gì?

Closure giúp loại bỏ các cấu trúc mã rườm rà và giải quyết 3 bài toán chính:

1. **Xử lý bất đồng bộ (Asynchronous Tasks)**: Khi bạn gọi một API tải dữ liệu, bạn không biết lúc nào mạng mới tải xong. Closure đóng vai trò là một "lời hứa" (callback). Bạn truyền Closure vào hàm gọi mạng để dặn dò: *"Khi nào có dữ liệu, hãy chạy đoạn code này"*.
2. **Tùy biến các hàm bậc cao (Higher-Order Functions)**: Thay vì viết các vòng lặp `for` dài dòng, bạn có thể truyền Closure vào các hàm như `map`, `filter`, `sort` để nói cho Swift biết chính xác logic bạn muốn thực hiện trên từng phần tử của mảng.
3. **Giảm thiểu code phân mảnh**: Thay vì phải tạo hàng loạt các hàm nhỏ lẻ (helper functions) hoặc dùng mẫu thiết kế Delegate cồng kềnh cho những tác vụ chỉ dùng đúng một lần (như thao tác bấm nút), bạn viết thẳng logic bằng Closure ngay tại nơi gọi lệnh.

### Escaping và Non-escaping Closures

| Loại | Đặc điểm |
|------|----------|
| **Non-escaping** | Thực thi code trong scope của nó một cách tức thì và không có khả năng lưu trữ hay sử dụng sau đó |
| **Escaping** | Có thể lưu trữ vào 1 biến hoặc 1 closure khác và có thể thực thi trong tương lai |

**Lưu ý quan trọng**:
- Non-escaping (như higher-order function) **không gây ra reference cycle** → không cần `weak`/`unowned`.
- Escaping **có thể gây ra reference cycle** khi không sử dụng `weak`/`unowned`. Tuy nhiên chỉ khi nó đảm bảo 2 điều:
  1. Closure được lưu trữ vào 1 biến hoặc 1 closure khác.
  2. Có sử dụng `self` để tham chiếu trong closure.

### Capture List trong Swift là gì?

Trong Swift, **Capture List (danh sách bắt giữ)** là một cú pháp đặc biệt được sử dụng trong closures để xác định rõ ràng cách mà closure sẽ "bắt" (capture) các biến/hằng từ môi trường xung quanh nó.

Nói đơn giản: Nó là danh sách các biến được đặt trong dấu `[ ]` ngay trước danh sách tham số của closure, giúp bạn kiểm soát việc reference cycle và quyền sở hữu (`weak`/`unowned`).

**Tại sao cần Capture List?**
- Mặc định, Closure bắt giữ mạnh (Strong Capture).
- Capture List giải quyết vấn đề bằng cách dùng `weak` hoặc `unowned` để phá vỡ vòng lặp tham chiếu.

---

## 9. Retain Cycle & ARC

### Retain Cycle là gì?

**Retain Cycle (vòng lặp tham chiếu)** là hiện tượng hai hoặc nhiều đối tượng tham chiếu lẫn nhau bằng **strong reference**, khiến cho bộ đếm tham chiếu (retain count) của chúng **không bao giờ về 0**, dẫn đến rò rỉ bộ nhớ (memory leak) — bộ nhớ không được giải phóng dù không còn ai sử dụng.

### Cơ chế ARC trong Swift là gì?

Swift sử dụng **ARC (Automatic Reference Counting)** để quản lý bộ nhớ:

- Mỗi đối tượng có một **retain count**.
- Khi một strong reference trỏ đến đối tượng → retain count **+1**.
- Khi một strong reference bị giải phóng → retain count **-1**.
- Khi retain count = **0** → đối tượng bị `deinit` và giải phóng bộ nhớ.

### Cách khắc phục Retain Cycle

#### ✅ Sử dụng `weak` hoặc `unowned` trong Closure (Capture List)

Đây là trường hợp gặp nhiều nhất khi bạn gọi `self` bên trong một Closure được giữ bởi chính class đó.

- **`weak`**: Biến đối tượng thành kiểu Optional. Nếu đối tượng bị giải phóng, biến sẽ tự động bằng `nil`.
- **`unowned`**: Dùng khi bạn chắc chắn đối tượng sẽ không bao giờ bị giải phóng trước Closure. Nếu đối tượng bị giải phóng mà vẫn gọi thì app sẽ bị **crash**.

#### ✅ Sử dụng `weak` cho Delegate Pattern

Khi định nghĩa một Protocol làm Delegate, bạn phải khai báo biến delegate là `weak` để tránh việc Controller và View giữ chặt lấy nhau.

**Điều kiện**: Protocol phải kế thừa từ `AnyObject`.

#### ✅ Phá vỡ mối quan hệ Parent - Child

Nếu Class A chứa Class B, và Class B cũng cần tham chiếu ngược lại Class A:

→ Hãy để biến tham chiếu ngược lại của Class B là `weak`.

### Làm sao để kiểm tra Retain Cycle?

**Cách đơn giản nhất**: Luôn thêm `deinit` vào class:

```swift
deinit {
    print("Đã giải phóng bộ nhớ")
}
```

Nếu bạn tắt màn hình/xóa đối tượng mà **không thấy dòng này in ra**, chắc chắn đã bị Retain Cycle.

---

## 📌 Tổng kết

| Chủ đề | Điểm cần nhớ |
|--------|--------------|
| **Struct vs Class** | Struct = Value Type, Stack, an toàn đa luồng. Class = Reference Type, Heap, dễ gây Retain Cycle |
| **Actor** | Giải quyết bài toán đa luồng, tự động thread-safe |
| **POP** | Lấy Protocol làm trung tâm, thay thế kế thừa bằng kết hợp |
| **Extension** | Thêm chức năng cho kiểu dữ liệu có sẵn mà không cần mã nguồn gốc |
| **associatedtype** | Placeholder cho kiểu dữ liệu trong Protocol |
| **Protocol Composition** | Dùng `&` để kết hợp nhiều Protocol |
| **Closure** | Khối mã độc lập, có khả năng capture giá trị |
| **Capture List** | Kiểm soát cách closure bắt giữ biến (`weak`/`unowned`) |
| **Retain Cycle** | Vòng lặp strong reference → memory leak |
| **ARC** | Cơ chế đếm tham chiếu tự động của Swift |

---

> 📝 **Ghi chú**: Tài liệu này được tổng hợp cho mục đích học tập và ôn phỏng vấn iOS.
> Nếu bạn phát hiện lỗi hoặc muốn đóng góp, hãy tạo Pull Request!


