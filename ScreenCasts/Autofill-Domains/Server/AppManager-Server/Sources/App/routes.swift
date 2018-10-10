import Vapor
import Leaf

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("/") { req in
        return try req.view().render("index")
    }
    
    router.post("/login") { req in
        return try req.view().render("authenticated")
    }
    
}
