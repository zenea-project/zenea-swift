import Vapor
import zenea
import utils

func routes(_ app: Application) throws {
    app.get { req async in
        return Response(status: .notFound, body: "Nothing to see here. Please go do something with your life.")
    }
    
    app.get(.catchall) { req async in
        return Response(status: .notFound, body: "Nothing to see here. Please go do something with your life.")
    }

    app.get("hello") { req async in
        "Hello, world!"
    }
    
    app.get("block", .parameter("id")) { req async in
        guard let idString = req.parameters.get("id") else {
            return Response(status: .noContent, body: "may i see your id please")
        }
        
        guard let blockID = Block.ID(parsing: idString) else {
            return Response(status: .badRequest, body: "what the hell is that supposed to be")
        }
        
        switch blockID {
        case .sha256(let hash): return Response(body: Response.Body(stringLiteral: hash.toHexString()))
        }
    }
}
