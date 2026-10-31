//
//  View+NavigationStyle.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-27.
//

import SwiftUI

extension View {
    
    func appNavigationStyle() -> some View {
        self
            .toolbarBackground(AppTheme.Colors.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .tint(.white)
    }
}
