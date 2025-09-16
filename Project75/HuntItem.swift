//
//  HuntItem.swift
//  Project1
//
//  Created by Richard Brito on 9/15/25.
//

import Foundation
import SwiftUI
import UIKit
import CoreLocation


struct HuntItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    var image: UIImage?
    var imageLocation: CLLocation?
    var isComplete: Bool {
        image != nil
    }
}
