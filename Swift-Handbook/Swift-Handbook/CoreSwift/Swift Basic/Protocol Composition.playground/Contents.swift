//: # Protocol Composition
//: Kết hợp nhiều Protocol bằng toán tử &

import Foundation

// MARK: - 1. Định nghĩa các Protocol nhỏ

protocol Readable {
    func read() -> String
}

protocol Writable {
    func write(_ content: String)
}

protocol Shareable {
    func share(to destination: String)
}

protocol Deletable {
    func delete()
}


// MARK: - 2. Protocol Composition bằng &

// Yêu cầu đối tượng vừa Readable vừa Writable
func processFile(_ file: Readable & Writable) {
    let content = file.read()
    file.write("Processed: \(content)")
}

// MARK: - 3. Các class conform nhiều Protocol

class ReadOnlyFile: Readable {
    let name: String
    init(name: String) { self.name = name }
    func read() -> String { "Nội dung file \(name)" }
}

class ReadWriteFile: Readable, Writable {
    let name: String
    private var content = ""
    init(name: String) { self.name = name }
    
    func read() -> String { content }
    func write(_ content: String) { self.content = content }
}

class FullFeatureFile: Readable, Writable, Shareable, Deletable {
    let name: String
    private var content = ""
    init(name: String) { self.name = name }
    
    func read() -> String { content }
    func write(_ content: String) { self.content = content }
    func share(to destination: String) {
        print("📤 Chia sẻ \(name) đến \(destination)")
    }
    func delete() {
        print("🗑 Đã xóa \(name)")
    }
}

// MARK: - 4. Sử dụng

let readOnly = ReadOnlyFile(name: "config.json")
let readWrite = ReadWriteFile(name: "notes.txt")
let fullFeature = FullFeatureFile(name: "report.pdf")

// ✅ OK — ReadWriteFile conform cả Readable & Writable
processFile(readWrite)

// ❌ Compile error — ReadOnlyFile không Writable
// processFile(readOnly)

readWrite.write("Hello")
print(readWrite.read())


// MARK: - 5. Protocol Composition trong tham số

func shareAndDelete(_ file: Shareable & Deletable, to dest: String) {
    file.share(to: dest)
    file.delete()
}

shareAndDelete(fullFeature, to: "iCloud")


// MARK: - 6. Ví dụ thực tế — UI Component

protocol Renderable {
    func render()
}

protocol Tappable {
    func onTap()
}

protocol Scrollable {
    func onScroll()
}

// Button chỉ cần Render + Tap
class Button: Renderable, Tappable {
    func render() { print("🔘 Button rendered") }
    func onTap() { print("👆 Button tapped") }
}

// TableView cần Render + Scroll
class TableView: Renderable, Scrollable {
    func render() { print("📋 TableView rendered") }
    func onScroll() { print("📜 TableView scrolled") }
}

// ViewController cần cả 3
class ComplexView: Renderable, Tappable, Scrollable {
    func render() { print("🖼 ComplexView rendered") }
    func onTap() { print("👆 ComplexView tapped") }
    func onScroll() { print("📜 ComplexView scrolled") }
}

// MARK: - 7. Hàm nhận tổ hợp Protocol

func makeInteractive(_ view: Renderable & Tappable) {
    view.render()
    view.onTap()
}

let button = Button()
let complexView = ComplexView()

makeInteractive(button)
makeInteractive(complexView)

// TableView không Tappable → không dùng được
// makeInteractive(TableView()) // ❌ Compile error


// MARK: - 8. Type Alias cho tổ hợp Protocol

typealias InteractiveView = Renderable & Tappable
typealias FullView = Renderable & Tappable & Scrollable

func setupView(_ view: InteractiveView) {
    view.render()
    view.onTap()
}

func setupFullView(_ view: FullView) {
    view.render()
    view.onTap()
    view.onScroll()
}

setupView(button)
setupFullView(complexView)


// MARK: - 9. Composition với Class + Protocol

protocol Identifiable {
    var id: String { get }
}

class BaseView {
    var frame: CGRect = .zero
}

// Kết hợp class và protocol
class MyView: BaseView, Identifiable {
    let id: String
    init(id: String) { self.id = id }
}

func configure(_ view: BaseView & Identifiable) {
    print("View \(view.id) tại frame \(view.frame)")
}

let myView = MyView(id: "view-001")
configure(myView)


// MARK: - 10. So sánh — Không dùng Composition

// ❌ Cách cũ — tạo Protocol mới cho mỗi tổ hợp
protocol ReadWritable {
    func read() -> String
    func write(_ content: String)
}

protocol ReadWriteShareable {
    func read() -> String
    func write(_ content: String)
    func share(to destination: String)
}

// ... Protocol explosion! Mỗi tổ hợp là 1 protocol mới

// ✅ Cách mới — dùng Composition
// Chỉ cần 3 protocol nhỏ, kết hợp bằng &
// Không cần tạo protocol mới


// MARK: - 11. Ví dụ nâng cao — Dependency Injection

protocol Loggable {
    func log(_ message: String)
}

protocol NetworkReachable {
    func isConnected() -> Bool
}

protocol Cacheable {
    func cache(_ data: Data)
    func getCache() -> Data?
}

typealias ServiceDependencies = Loggable & NetworkReachable & Cacheable

class DataService {
    private let dependencies: ServiceDependencies
    
    init(dependencies: ServiceDependencies) {
        self.dependencies = dependencies
    }
    
    func fetchData() {
        dependencies.log("Bắt đầu fetch")
        guard dependencies.isConnected() else {
            dependencies.log("Không có mạng")
            return
        }
        let data = Data("Hello".utf8)
        dependencies.cache(data)
        dependencies.log("Đã cache dữ liệu")
    }
}

class AppDependencies: Loggable, NetworkReachable, Cacheable {
    private var cache: Data?
    
    func log(_ message: String) { print("📝 \(message)") }
    func isConnected() -> Bool { true }
    func cache(_ data: Data) { cache = data }
    func getCache() -> Data? { cache }
}

let service = DataService(dependencies: AppDependencies())
service.fetchData()
