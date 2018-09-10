//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Manel matougui on 9/9/18.
//  Copyright © 2018 udacity. All rights reserved.
//

import Foundation
func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
