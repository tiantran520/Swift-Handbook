# Cơ Bản về Async/Await trong Swift

> Trong lập trình iOS, việc xử lý các tác vụ bất đồng bộ thường gặp phải nhiều thách thức, đặc biệt là trong việc quản lý callback và xử lý lỗi. Từ phiên bản Swift 5.5, ngôn ngữ Swift đã được cải thiện với việc giới thiệu async/await, là một cách tiếp cận mới để xử lý các tác vụ bất đồng bộ một cách dễ dàng và hiệu quả hơn.

## Tham khảo tài liệu Swift

- Swift book: [https://docs.swift.org/swift-book/documentation/the-swift-programming-language/](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/)

## 1. Async/Await là gì?

- Async/Await là một mô hình lập trình bất đồng bộ, cho phép bạn viết mã như là tuần tự, mặc dù tác vụ đang chạy bất đồng bộ.
- Thay vì sử dụng callback hoặc closure như trong cách tiếp cận truyền thống, bạn có thể sử dụng từ khóa async để đánh dấu một hàm là bất đồng bộ, và từ khóa await để chờ đợi kết quả của một tác vụ bất đồng bộ khác mà không chặn luồng chính.

## 2. Cú Pháp Cơ Bản

- async: Đánh dấu một hàm là bất đồng bộ.
- await: Chờ đợi kết quả của một tác vụ bất đồng bộ và tiếp tục thực hiện các dòng mã tiếp theo một cách đồng bộ.

```shell
// Hàm bất đồng bộ lấy dữ liệu từ URL
func fetchData() async throws -> Data {
    let url = URL(string: "https://api.example.com/data")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}

// Hàm bất đồng bộ xử lý dữ liệu
func processData() async {
    do {
        let data = try await fetchData() // Chờ đợi kết quả từ fetchData()
        let processedData = process(data) // Tiếp tục thực hiện dòng mã này một cách đồng bộ
        print(processedData)
    } catch {
        print("Error: \(error)")
    }
}
```

Trong ví dụ này, hàm fetchData() được đánh dấu là bất đồng bộ với từ khóa async, và await được sử dụng để chờ đợi kết quả trả về từ URLSession.shared.data(from:). Sau đó, kết quả được chuyển đến hàm process() để xử lý.

> Ta cũng có một số quy tắc sau cho async/await:
>
> - Các hàm đồng bộ (Synchronous) sẽ không gọi trực tiếp được các hàm bất đồng bộ
> - Các hàm bất đồng bộ có thể gọi được các hàm bất đồng bộ khác và các hàm đồng bộ bình thường khác
> - Nếu các hàm đồng bộ & bất đồng mà giống nhau về cách gọi hàm. Thì Swift sẽ dựa vào ngữ cảnh để gọi.

## 3. Ưu Nhược Điểm của Async/Await

**Ưu điểm:**

- Mã Sạch và Dễ Hiểu: Loại bỏ callback hell và làm cho mã trở nên dễ đọc và hiểu hơn.
- Quản Lý Lỗi Dễ Dàng: Xử lý lỗi trong mã bất đồng bộ trở nên dễ dàng hơn với từ khóa try, catch, và throws.
- Hiệu Suất Cải Thiện: Tối ưu hóa việc sử dụng luồng và tài nguyên, tăng hiệu suất của ứng dụng.

**Nhược điểm:**

- Hỗ Trợ Trong Một Số Trường Hợp Còn Hạn Chế: Async/Await có thể không phù hợp với một số trường hợp đặc biệt, như khi cần quản lý nhiều tác vụ bất đồng bộ đồng thời.

## 4. Async/Await để Lấy Dữ liệu từ REST API

Việc giao tiếp với các REST API là một phần quan trọng của việc phát triển ứng dụng di động. Sử dụng async/await trong Swift giúp làm cho việc này trở nên dễ dàng và sáng sủa hơn.

Đầu tiên, chúng ta cần một hàm để gửi yêu cầu đến REST API và nhận kết quả trả về. Trong ví dụ này, chúng ta sẽ sử dụng URLSession để thực hiện yêu cầu mạng.

```shell
// Hàm bất đồng bộ để lấy dữ liệu từ REST API
func fetchDataFromAPI() async throws -> [String: Any] {
    let url = URL(string: "https://api.example.com/data")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
    return json
}
```

Trong đoạn mã trên:

- Chúng ta sử dụng URL để xác định URL của API mà chúng ta muốn truy vấn.
- URLSession.shared.data(from:) được sử dụng để gửi yêu cầu và nhận lại dữ liệu từ API. Hàm này là bất đồng bộ và được gọi bằng từ khóa await.
- Kết quả trả về là dữ liệu từ API, được chuyển đổi thành một đối tượng từ điển [String: Any].

Tiếp theo, chúng ta có thể gọi hàm này trong một hàm bất đồng bộ khác và xử lý kết quả một cách đồng bộ:

```shell
// Hàm bất đồng bộ xử lý dữ liệu từ API
func processDataFromAPI() async {
    do {
        let jsonData = try await fetchDataFromAPI() // Chờ đợi kết quả từ fetchDataFromAPI()
        // Xử lý dữ liệu ở đây
        print(jsonData)
    } catch {
        print("Error: \(error)")
    }
}
```

Trong hàm processDataFromAPI():

- Chúng ta gọi hàm fetchDataFromAPI() để lấy dữ liệu từ API. Hàm này được gọi bằng từ khóa await, và mã sau nó chỉ được thực thi sau khi kết quả trả về từ API.
- Kết quả trả về từ API được lưu trữ trong biến jsonData, và chúng ta có thể xử lý nó một cách đồng bộ trong phần tiếp theo của hàm.

Sử dụng async/await giúp làm cho việc lấy dữ liệu từ REST API trở nên dễ dàng và linh hoạt hơn bằng cách loại bỏ các callback phức tạp và làm cho mã của bạn trở nên dễ đọc và hiểu hơn.
