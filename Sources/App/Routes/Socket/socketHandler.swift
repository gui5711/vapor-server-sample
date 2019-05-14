//
//  socketHandler.swift
//  App
//
//  Created by Guilherme Fischer on 08/05/19.
//

import Vapor

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

func socketHandler(ws: WebSocket, request: Request) {
    
    var vetRooms = [[String:Any]]()
    var countDisponivel = 0;
    var vetClients = [WebSocket]()
    
    ws.send("Connected")
    vetClients.append(ws)
    print("Conexões ativas: \(vetClients.count)")
    
    ws.onText { ws, string in
        
        let result = convertToDictionary(text: string)
        
        switch ((result?["acao"] ?? "") as! String) {
        case ("getRoom"):
            //                    {"acao":"getRoom", "cd_usuario": 1}
            //                    {"acao":"getRoom", "cd_usuario": 2}
            
            
            if countDisponivel == 0 {
                
                var tmpArray = [[String:Any]]()
                tmpArray.append(["cd_usuario": result!["cd_usuario"] as! Int, "ws_client" : ws, "character": ""])
                
                vetRooms.self.append([ "tp_sala" : 1, "usuarios" : tmpArray, "st_sala" : 0])
                countDisponivel += 1
                
                ws.send("{\"return\":\"search_players\"}")
                
            } else {
                
                for i in 0..<vetRooms.self.count {
                    
                    let st_sala = vetRooms.self[i]["st_sala"] as? Int
                    
                    if st_sala == 0 {
                        
                        var vetObstacles = [String]()
                        
                        for _ in 0...50 {
                            let sprite = Int(round(drand48()*11))
                            var x = round(100*drand48()*2048)/100
                            var y = round(100*drand48()*1536)/100
                            
                            var checker = false
                            
                            while !checker {
                                if x < 100 && y < 100 {
                                    checker = false
                                } else if x > 1948 && y > 1436 {
                                    checker = false
                                } else {
                                    checker = true
                                }
                                
                                if !checker {
                                    x = round(100*drand48()*2048)/100
                                    y = round(100*drand48()*1536)/100
                                }
                            }
                            
                            vetObstacles.append("{\"sprite\": \(sprite), \"x\": \(x), \"y\": \(y)}")
                        }
                        
                        if var arr = vetRooms.self[i]["usuarios"] as? [[String:Any]] {
                            arr.append(["cd_usuario": result!["cd_usuario"] as! Int, "ws_client" : ws, "character": ""])
                            vetRooms.self[i]["usuarios"] = arr
                            
                            for usuario in arr {
                                
                                if let ws_client = usuario["ws_client"] as? WebSocket {
                                    ws_client.send("{\"return\":\"roomFound\", \"cd_sala\": \(i), \"position_obstacles\": \(vetObstacles)}")
                                }
                            }
                        }
                        
                        vetRooms.self[i]["st_sala"] = 1
                        countDisponivel -= 1
                    }
                }
            }
            
            print(vetRooms.self)
            
        case ("setCharacter"):
            
            //                  {"acao":"setCharacter", "cd_sala": 0, "cd_usuario": 1, "character":"damiert"}
            //                    {"acao":"setCharacter", "cd_sala": 0, "cd_usuario": 2, "character":"mongor"}
            
            var countCharacters: Int = 0;
            var tmpArray = [String]()
            
            var vetPositionX = [200, 1848]
            var vetPositionY = [1336, 200]
            
            print((result!["cd_sala"] as! Int))
            
            if var arr = vetRooms.self[(result!["cd_sala"] as! Int)]["usuarios"] as? [[String:Any]] {
                for i in 0..<arr.count {
                    
                    if (arr[i]["cd_usuario"] as! Int) == (result!["cd_usuario"] as! Int) {
                        arr[i]["character"] = result!["character"]
                    }
                    
                    if (arr[i]["character"] as! String) != "" {
                        print((arr[i]["character"] as! String))
                        countCharacters = countCharacters+1
                    }
                    
                    tmpArray.append("{\"cd_usuario\": \((arr[i]["cd_usuario"] as! Int)), \"character\": \"\((arr[i]["character"] as! String))\", \"x\": \(vetPositionX[i]), \"y\": \(vetPositionY[i])}")
                }
                
                vetRooms.self[(result!["cd_sala"] as! Int)]["usuarios"] = arr
                
                print("Count: \(countCharacters)")
                
                if countCharacters == arr.count {
                    for usuario in arr {
                        
                        if let ws_client = usuario["ws_client"] as? WebSocket {
                            
                            ws_client.send("{\"return\":\"gotChar\", \"usuarios\": \(tmpArray)}")
                        }
                    }
                }
            }
            
            print(vetRooms.self)
            
            
        case ("setPosition"):
            
            //                  {"acao":"setPosition", "cd_sala": 1, "cd_usuario": 2, "x": 20.12, "y": 10.77}
            
            let cd_sala = (result!["cd_sala"] as! Int)
            let cd_usuario = (result!["cd_usuario"] as! Int)
            let x = (result!["x"] as! Double)
            let y = (result!["y"] as! Double)
            
            if let arr = vetRooms.self[cd_sala]["usuarios"] as? [[String:Any]] {
                
                for usuario in arr {
                    
                    if let ws_client = usuario["ws_client"] as? WebSocket {
                        if cd_usuario != (usuario["cd_usuario"] as! Int) {
                            ws_client.send("{\"return\":\"charPosition\", \"cd_usuario\": \(cd_usuario), \"x\": \(x), \"y\": \(y)}")
                        }
                    }
                }
            }
            
            print(vetRooms.self)
            
            
            
        default:
            print("nothing")
            ws.send("nothing")
        }
    }
}
