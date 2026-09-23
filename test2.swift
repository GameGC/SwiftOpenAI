import Foundation
@testable import SwiftOpenAI

let input: InputType = .messages([
    .user(content: [
        .inputText("Hello"),
        .inputFile(fileId: "file-123")
    ])
])
let param = ModelResponseParameter(input: input)
let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
let data = try! encoder.encode(param)
print(String(data: data, encoding: .utf8)!)
