import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    @Binding var isNavigating: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchResults: [PointOfInterest] = []
    @State private var recentDestinations: [PointOfInterest] = []
    @State private var categories: [POICategory] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search for stores, rooms, or facilities", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: searchText) { _ in
                                performSearch()
                            }
                        
                        if !searchText.isEmpty {
                            Button("Clear") {
                                searchText = ""
                                searchResults = []
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    // Category Filter Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: false
                                ) {
                                    filterByCategory(category)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Search Results
                List {
                    if searchText.isEmpty {
                        // Show recent destinations and categories when not searching
                        if !recentDestinations.isEmpty {
                            Section("Recent") {
                                ForEach(recentDestinations) { poi in
                                    POIRow(poi: poi) {
                                        selectDestination(poi)
                                    }
                                }
                            }
                        }
                        
                        Section("Browse by Category") {
                            ForEach(categories) { category in
                                CategoryRow(category: category) {
                                    filterByCategory(category)
                                }
                            }
                        }
                    } else {
                        // Show search results
                        if searchResults.isEmpty {
                            Text("No results found")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(searchResults) { poi in
                                POIRow(poi: poi) {
                                    selectDestination(poi)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Find Destination")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            loadSearchData()
        }
    }
    
    private func loadSearchData() {
        // Load sample data - in a real app, this would come from an API
        categories = [
            POICategory(id: UUID(), name: "Stores", icon: "bag", color: .blue),
            POICategory(id: UUID(), name: "Restaurants", icon: "fork.knife", color: .orange),
            POICategory(id: UUID(), name: "Services", icon: "wrench", color: .green),
            POICategory(id: UUID(), name: "Restrooms", icon: "figure.walk", color: .purple),
            POICategory(id: UUID(), name: "Exits", icon: "arrow.right.square", color: .red),
            POICategory(id: UUID(), name: "Information", icon: "info.circle", color: .gray)
        ]
        
        recentDestinations = [
            PointOfInterest(
                id: UUID(),
                name: "Meeting Room B",
                category: "Conference Rooms",
                floor: 2,
                description: "Large conference room with video conferencing",
                position: SIMD3<Float>(20, 0, 5)
            ),
            PointOfInterest(
                id: UUID(),
                name: "Starbucks Coffee",
                category: "Restaurants",
                floor: 1,
                description: "Coffee shop on the main floor",
                position: SIMD3<Float>(15, 0, -10)
            )
        ]
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        // Simulate search - in a real app, this would query a database or API
        let allPOIs = [
            PointOfInterest(
                id: UUID(),
                name: "Meeting Room A",
                category: "Conference Rooms",
                floor: 2,
                description: "Small meeting room for up to 6 people",
                position: SIMD3<Float>(18, 0, 3)
            ),
            PointOfInterest(
                id: UUID(),
                name: "Meeting Room B",
                category: "Conference Rooms",
                floor: 2,
                description: "Large conference room with video conferencing",
                position: SIMD3<Float>(20, 0, 5)
            ),
            PointOfInterest(
                id: UUID(),
                name: "Starbucks Coffee",
                category: "Restaurants",
                floor: 1,
                description: "Coffee shop on the main floor",
                position: SIMD3<Float>(15, 0, -10)
            ),
            PointOfInterest(
                id: UUID(),
                name: "Apple Store",
                category: "Stores",
                floor: 1,
                description: "Electronics and accessories",
                position: SIMD3<Float>(25, 0, -5)
            ),
            PointOfInterest(
                id: UUID(),
                name: "Restroom",
                category: "Services",
                floor: 1,
                description: "Public restroom facilities",
                position: SIMD3<Float>(10, 0, 8)
            )
        ]
        
        searchResults = allPOIs.filter { poi in
            poi.name.localizedCaseInsensitiveContains(searchText) ||
            poi.category.localizedCaseInsensitiveContains(searchText) ||
            poi.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func filterByCategory(_ category: POICategory) {
        searchText = category.name
        performSearch()
    }
    
    private func selectDestination(_ poi: PointOfInterest) {
        // Start navigation to selected destination
        isNavigating = true
        
        // Add to recent destinations
        if !recentDestinations.contains(where: { $0.id == poi.id }) {
            recentDestinations.insert(poi, at: 0)
            if recentDestinations.count > 5 {
                recentDestinations.removeLast()
            }
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct POIRow: View {
    let poi: PointOfInterest
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(poi.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(poi.category)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    if !poi.description.isEmpty {
                        Text(poi.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        Image(systemName: "building")
                            .foregroundColor(.gray)
                        Text("Floor \(poi.floor)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryRow: View {
    let category: POICategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(category.color)
                    .frame(width: 24, height: 24)
                
                Text(category.name)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryButton: View {
    let category: POICategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                
                Text(category.name)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? category.color : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

#Preview {
    SearchView(
        searchText: .constant(""),
        isNavigating: .constant(false)
    )
}

