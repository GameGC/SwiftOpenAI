import Foundation

struct FileContent: Codable {
  public let type = "input_file"
  public let fileData: String?
  public let fileId: String?
  public let fileUrl: String?
  public let filename: String?

  public init(fileData: String? = nil, fileId: String? = nil, fileUrl: String? = nil, filename: String? = nil) {
    self.fileData = fileData
    self.fileId = fileId
    self.fileUrl = fileUrl
    self.filename = filename
  }

  enum CodingKeys: String, CodingKey {
    case type
    case fileData = "file_data"
    case fileId = "file_id"
    case fileUrl = "file_url"
    case filename
  }
}

let file = FileContent(fileId: "file-123")
let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
let data = try! encoder.encode(file)
print(String(data: data, encoding: .utf8)!)
