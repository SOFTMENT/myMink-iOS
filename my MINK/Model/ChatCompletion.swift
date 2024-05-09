//
//  ChatCompletion.swift
//  my MINK
//
//  Created by Vijay Rathore on 22/02/24.
//

import Foundation

// Define the structs matching the JSON structure
struct ChatCompletion : Codable {
    let choices: [Choice]
    let model: String
    let id: String
    let created: Int
    let usage: Usage
}

struct Choice: Codable {
    let finishReason: String
    let index: Int
    let message: Message
    
    enum CodingKeys: String, CodingKey {
        case finishReason = "finish_reason"
        case index, message
    }
}

struct Message: Codable {
    let content: String
    let role: String
}

struct Usage: Codable {
    let completionTokens: Int
    let promptTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case completionTokens = "completion_tokens"
        case promptTokens = "prompt_tokens"
        case totalTokens = "total_tokens"
    }
}
