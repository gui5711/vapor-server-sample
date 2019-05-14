import Vapor
import MongoKitten

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    let serverConfig = NIOServerConfig.default(hostname: "127.0.0.1", port: 8080)
    services.register(serverConfig)
    let websockets = NIOWebSocketServer.default()
    websockets.get("socket", use: socketHandler)
    services.register(websockets, as: WebSocketServer.self)
    
    let connectionURI = "mongodb://0.0.0.0/RiseTime"
    services.register { container -> MongoKitten.Database in
        return try MongoKitten.Database.lazyConnect(connectionURI, on: container.eventLoop)
    }
}

extension MongoKitten.Database: Service {}
