//
//  SavedScores.swift
//  Nine
//
//  Created by Alexander Podkopaev on 11.12.14.
//  Copyright (c) 2014 Alexander Podkopaev. All rights reserved.
//

import Foundation
import CoreData


@objc(SavedScores)
class SavedScores: NSManagedObject {

    @NSManaged var highScore: NSNumber

}
