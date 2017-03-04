//
// Created by liyulong on 2017/3/2.
//

import Foundation
import HTTP

final class VersionMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)

        response.headers["Version"] = "API v1.0"

        return response
    }

}