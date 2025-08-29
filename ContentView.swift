import SwiftUI
import ARKit
import RealityKit

struct ContentView: View {
    @StateObject private var arViewModel = ARViewModel()
    @State private var searchText = ""
    @State private var showingSearch = false
    @State private var isNavigating = false
    
    var body: some View {
        ZStack {
            // AR Camera View
            ARViewContainer(arViewModel: arViewModel)
                .edgesIgnoringSafeArea(.all)
            
            // UI Overlay
            VStack {
                // Top UI Elements
                HStack {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search destination", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onTapGesture {
                                showingSearch = true
                            }
                        
                        Button(action: {
                            // Voice search functionality
                        }) {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Navigation Info Panel
                if isNavigating {
                    NavigationInfoPanel(
                        destination: "Meeting Room B",
                        distance: "50 ft",
                        estimatedTime: "2 min"
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                
                // Bottom Navigation Bar
                HStack {
                    NavigationButton(
                        icon: "map",
                        title: "Map",
                        isActive: false
                    ) {
                        // Show map view
                    }
                    
                    Spacer()
                    
                    NavigationButton(
                        icon: "safari",
                        title: "Explore",
                        isActive: true
                    ) {
                        // Current AR view
                    }
                    
                    Spacer()
                    
                    NavigationButton(
                        icon: "gearshape",
                        title: "Settings",
                        isActive: false
                    ) {
                        // Show settings
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                .background(Color.white.opacity(0.9))
                .cornerRadius(25)
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(searchText: $searchText, isNavigating: $isNavigating)
        }
    }
}

struct NavigationButton: View {
    let icon: String
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isActive ? .blue : .gray)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isActive ? .blue : .gray)
            }
        }
    }
}

struct NavigationInfoPanel: View {
    let destination: String
    let distance: String
    let estimatedTime: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Navigating to")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(destination)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(distance)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text(estimatedTime)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button("Stop") {
                // Stop navigation
            }
            .foregroundColor(.red)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.white.opacity(0.95))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

#Preview {
    ContentView()
}

