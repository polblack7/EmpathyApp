import Foundation
import JWTDecode

struct JWTToken {
    let sub: String // subject (user id)
    let email: String
    let username: String
    let exp: Date // expiration time
    
    var isExpired: Bool {
        return Date() > exp
    }
    
    static func decode(_ token: String) -> JWTToken? {
        do {
            
            let jwt = try JWTDecode.decode(jwt: token)
            
            guard let sub = jwt.claim(name: "userId").string,
                  let email = jwt.claim(name: "email").string,
                  let username = jwt.claim(name: "username").string,
                  let exp = jwt.expiresAt else {
                return nil
            }
            return JWTToken(
                sub: sub,
                email: email,
                username: username,
                exp: exp
            )
        } catch {
            LogService.shared.error("Failed to decode JWT token", error: error)
            return nil
        }
    }
} 
