//
// Created by liyulong on 2017/3/2.
//

import Vapor
import HTTP

final class HelloController {
    func sayHello(_ req: Request) throws -> ResponseRepresentable {
        guard  let name = req.data["name"] else {
            throw Abort.custom(status: .badRequest, message: "参数不全")

        }
        return "Hello, \(name)"
    }

    func sayHelloAlernate(_ req: Request, _ name: String) -> ResponseRepresentable {
        return "Hello, \(name) "
    }
}