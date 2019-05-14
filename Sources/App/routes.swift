import Vapor
import MongoKitten

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let db = try Database.synchronousConnect("mongodb://206.189.239.109:27017/RiseTime")
    
    // Select
    router.post("/mongodb/rtUsers/login") { req -> String in
        let data = try req.content.syncDecode(rtUsers.self)
        
        var cd_usuario : String? = ""
        
        let users = db["rt_users"]
        
        users.find("lg_usuario" == data.lg_usuario! && "sh_usuario" == data.sh_usuario!).forEach { (user: Document) in
            cd_usuario = (user["_id"] as! ObjectId?)?.hexString
        }
        
        return cd_usuario!
    }
    
    // Select
    router.post("/mongodb/rtUsers/login") { req -> Future<Response> in
        let data = try req.content.syncDecode(rtUsers.self)
        
        var cd_usuario : String? = ""
        
        let users = db["rt_users"]
        
        return users.find("lg_usuario" == data.lg_usuario! && "sh_usuario" == data.sh_usuario!).map { (user: Document) in
            if let user = user,
                let userID = user["_id"] as? ObjectId {
                return req.response(http: .init(status: .ok, body: userID.hexString))
            }
            
            return req.response(http: .init(status: .notFound))
        }
    }
    
}
