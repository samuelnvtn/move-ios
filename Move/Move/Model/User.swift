//
//  User.swift
//  Move
//
//  Created by Samuel Novotný on 12.06.2026.
//

import Foundation

struct User: Identifiable {
    var id: UUID
    var xp: Int

    var level: Int { xp / 1000 + 1 }
    var xpInCurrentLevel: Int { xp % 1000 }
    var xpToNextLevel: Int { 1000 - xpInCurrentLevel }
}
