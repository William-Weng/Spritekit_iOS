//
//  GameUtility.swift
//  SpriteKit_TileMap
//
//  Created by William-Weng on 2018/12/3.
//  Copyright © 2018年 William-Weng. All rights reserved.
//

import UIKit

class GameUtility: NSObject {
    
    /// 從檔案讀取地圖配置
    static public func readMapCodes(withFileName filaname: String) -> [String] {
        
        guard let filename = Bundle.main.path(forResource: filaname, ofType: nil),
              let content = try? String(contentsOfFile: filename),
              let codes = Optional.some(content.split(separator: "\n")),
              let codeArray = Optional.some(codes.map({ "\($0)" }))
        else {
            return [String]()
        }
        
        return codeArray
    }
}
