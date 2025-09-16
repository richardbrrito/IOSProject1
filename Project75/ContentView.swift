//
//  ContentView.swift
//  Project1
//
//  Created by Richard Brito on 9/15/25.
//
import SwiftUI

struct ContentView: View {
    @State private var scavengerItems: [HuntItem] = [
        HuntItem(title: "Your favorite local restaurant", description:"Where do you go to get the best pasta?"),
        HuntItem(title: "Your favorite local cafe", description:"Best place for coffee"),
        HuntItem(title: "Your go-to brunch place", description:"Where do you grab eggs and pancakes?"),
        HuntItem(title: "Your favorite hiking spot", description:"Where do you go to be one with nature?")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach($scavengerItems) { $item in
                    NavigationLink(destination: ItemDetailView(item: $item)) {
                        HStack {
                            Text(item.title)
                            Spacer()
                            Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isComplete ? .green : .red)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text("Photo Scavenger Hunt")
                            .font(.headline)
                            .padding(.top, -2)

                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 2)
                    }
                }
            }
        }
    }
}

