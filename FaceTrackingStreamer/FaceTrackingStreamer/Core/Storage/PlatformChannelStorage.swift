//
//  PlatformChannelStorage.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 27.04.2024.
//

import Foundation

enum StreamingPlatform: Codable {
    case twitch
    case youtube
}

struct SavedChannels: UserDefaultsStorable {
    static let key = "channels"
    
    let channels: [StreamingPlatform: String]
}

protocol IPlatformChannelStorage {
    func get() -> SavedChannels?
    func set(_ value: SavedChannels?)
    func add(_ name: String, for platform: StreamingPlatform)
    func get(for platform: StreamingPlatform) -> String?
}

final class PlatformChannelStorage: UserDefaultsStorage<SavedChannels>, IPlatformChannelStorage {
    
    func add(_ name: String, for platform: StreamingPlatform) {
        var data = get()?.channels
        
        if var data = data {
            data[platform] = name
            set(SavedChannels(channels: data))
        } else {
            set(SavedChannels(
                channels: [platform: name])
            )
        }
    }
    
    func get(for platform: StreamingPlatform) -> String? {
        let data = get()?.channels
        return data?[platform]
    }
}
