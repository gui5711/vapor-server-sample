import Vapor
import MongoKitten

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let db = try Database.synchronousConnect("mongodb://0.0.0.0/RiseTime")
    
    // Select
    router.post("/mongodb/rtUsers/login") { req -> Future<String> in
        let data = try req.content.syncDecode(rtUsers.self)
        
        let users = db["rt_users"]
        return users.findOne("lg_usuario" == data.lg_usuario! && "sh_usuario" == data.sh_usuario!).map { (user: Document?) -> String in
            let id = (user?["_id"] as? ObjectId)?.hexString
            return id ?? ""
        }
    }
    
}
