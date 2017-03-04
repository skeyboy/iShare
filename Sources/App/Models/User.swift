//
// Created by liyulong on 2017/3/2.
//

import Foundation
import Vapor
import Fluent

final class User {

    var name: String
    var id: String?

    init(name: String) {
        self.name = name
    }
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                "id": id,
                "name": name
        ])
    }

    static func prepare(_ database: Database) throws {
        try database.create("users") { users in
            users.id()
            users.string("name")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete("users")
    }

}