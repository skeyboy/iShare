import Vapor
import MySQL
import HTTP
import VaporRedis
import VaporMySQL


let drop = Droplet()

print(drop.config)
let address = "127.0.0.1"
let port: Int = 6379
var redispassword: String?

//try drop.addProvider(VaporRedis.Provider(address: address, port: port))
try drop.addProvider(VaporRedis.Provider(config: drop.config))
//try drop.addProvider(VaporMySQL.Provider.self)


try drop.cache.set("cacheKey", Node("test"))
print(try drop.cache.get("cacheKey")) // Will print "test"


let host = "127.0.0.1"
let user = "root"
let password = "180531301324"
let database = "tieba"

let mysql = try MySQL.Database(host: host,
        user: user,
        password: password,
        database: database)

//print("\(results)")
//for item in results {
//    print(item)
//    print("\n")
//}

extension Request {

    func getValue(for key: String, default value: Node) -> Node {
        var tmpValue = value
        if let query = self.query {
            if let nodeObject = query.nodeObject {
                let pageNode: Node? = nodeObject[key]
                if let pnNode = pageNode {
                    tmpValue = pnNode
                }
            }
        }

        return tmpValue
    }
}


drop.get("category") { request in

    let sql = "select id, name from movie_category where  id >= 2 and  id <=8"

    var node: Node

    var cacheNode: Node? = try drop.cache.get(sql)
    if let letCacheNode = cacheNode {
        node = letCacheNode
    } else {
        var nodes: [Node] = [Node]()
        let results = try mysql.execute(sql)
        results.forEach { (item: [String: Node]) in
            nodes.append(Node(item))
        }
        node = Node(nodes)
        try drop.cache.set(sql, node)


    }

    print(JSON(node))
    return try JSON(node)
}

drop.get("mysql") { request in


    var items: [[String: Node]] = [[String: Node]]()

    var pn = 20

    var pnNode = request.getValue(for: "pn", default: Node(20))

    pn = pnNode.int!

    var page = request.getValue(for: "page", default: Node(0))

    var node: Node

    var nodes: [Node] = [Node]()

    var catId: Node = request.getValue(for: "catId", default: Node(2))

    let sql = "SELECT * FROM movie_down_url WHERE movie_cat_id = \(catId.int!)  limit  \(pn) offset \(pn * page.int!)"


    var tmpNode: Node? = try drop.cache.get(sql)
    if let letNode = tmpNode {

        node = letNode
    } else {

        let results = try mysql.execute(sql)



        for item: [String: Node] in results {
            nodes.append(Node(item))
        }
        node = Node(nodes)
        try drop.cache.set(sql, node)


    }

    print(sql)


    return try JSON(node)
//    return try drop.view.make("mysql",
//            ["items":Node(nodes)])
}


drop.get { req in
    return try drop.view.make("welcome", [
            "message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.get("welcome") { request in
    return try drop.view.make("welcome",
            ["message": drop.localization[request.lang, "welcome", "title"]
            ])
}

drop.get { request in
    return try drop.view.make("welcome",
            ["message": drop.localization[request.lang, "welcome"]]
//            ["message": request.parameters.string!]
    )

}

//json
drop.get("json") { request in
    guard let name = request.json?["name"]?.string else {
        throw Abort.badRequest
    }
    return "Hello, \(name)"
}

//response
drop.get("version") { request in
    return try JSON(node: [
            "version": "1.0"
    ])
}

drop.get("leaf") { request in
    return try drop.view.make("index",
            ["message": request.parameters.string!])
}

//controller
let hc = HelloController()
drop.get("hello", handler: hc.sayHello)
drop.get("safeHello", String.self, handler: hc.sayHelloAlernate)


drop.resource("posts", PostController())

drop.run()


