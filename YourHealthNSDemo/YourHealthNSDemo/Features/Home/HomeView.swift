//
//  HomeView.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-27.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack{
            AppTheme.Colors.background
            .ignoresSafeArea()
            VStack{
                Text("Demo App")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                Spacer()
            }
           
                
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationStyle()
    }
}

#Preview {
    HomeView()
}
