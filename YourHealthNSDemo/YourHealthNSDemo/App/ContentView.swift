//
//  ContentView.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-27.
//

import SwiftUI

struct ContentView: View {

    private let container = AppContainer.shared
    
    var body: some View {
        TabView{
            
            //First Tab
            NavigationStack{
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
    
            //Second Tab
            NavigationStack
            {
                RecordsHomeView(recordsViewModel: container.recordsViewModel)
            }
            .tabItem{
                Label("Records", systemImage: "folder.badge.person.crop")
            }
            
        }
        .tint(AppTheme.Colors.primary)
    }
}

#Preview {
    ContentView()
}
