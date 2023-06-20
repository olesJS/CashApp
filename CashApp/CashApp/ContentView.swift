//
//  ContentView.swift
//  CashApp
//
//  Created by Олексій Якимчук on 18.06.2023.
//

import SwiftUI

struct CashItem: Identifiable, Codable {
    let id = UUID()
    var name: String
    var type: String
    var price: Double
}

class Cash: ObservableObject {
    @Published var privateItems = [CashItem]() {
        didSet {
            let encoder1 = JSONEncoder()
            if let data1 = try? encoder1.encode(privateItems) {
                UserDefaults.standard.set(data1, forKey: "PrivateItems")
            }
        }
    }
    
    @Published var businessItems = [CashItem]() {
        didSet {
            let encoder2 = JSONEncoder()
            if let data2 = try? encoder2.encode(businessItems) {
                UserDefaults.standard.set(data2, forKey: "BusinessItems")
            }
        }
    }
    
    init() {
        if let savedPrivateItems = UserDefaults.standard.data(forKey: "PrivateItems") {
            if let decodedPrivateItems = try? JSONDecoder().decode([CashItem].self, from: savedPrivateItems) {
                privateItems = decodedPrivateItems
            } else {
                privateItems = []
            }
        }
        
        if let savedBusinessItems = UserDefaults.standard.data(forKey: "BusinessItems") {
            if let decodedBusinessItems = try? JSONDecoder().decode([CashItem].self, from: savedBusinessItems) {
                businessItems = decodedBusinessItems
                return
            }
        }
        businessItems = []
    }
}

// Sheet View
struct SheetView: View {
    @ObservedObject var cash: Cash
    @Environment(\.dismiss) var dismiss
    
    let types = ["Personal", "Business"]
    
    @State private var name: String = ""
    @State private var type: String = "Personal"
    @State private var price: Double = 0.0
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                
                Picker("Type", selection: $type) {
                    ForEach(types, id: \.self) {
                        Text($0)
                    }
                }
                
                TextField("Price", value: $price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add new expense")
            .toolbar {
                Button {
                    if type == "Personal" {
                        cash.privateItems.append(CashItem(name: name, type: type, price: price))
                    } else {
                        cash.businessItems.append(CashItem(name: name, type: type, price: price))
                    }
                    dismiss()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
    }
}

// The main View
struct ContentView: View {
    @StateObject var cash = Cash()
    @State private var sheetViewActive = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Private expenses:")
                    
                    List {
                        ForEach(cash.privateItems) { item in
                            HStack {
                                Text(item.name)
                                    .bold()
                                Spacer()
                                Text("\(item.price.formatted())$")
                            }
                        }
                        .onDelete(perform: removePrivateRows)
                    }
                }

                Section {
                    Text("Business expenses:")
                        
                    List {
                        ForEach(cash.businessItems) { item in
                            HStack {
                                Text(item.name)
                                    .bold()
                                Spacer()
                                Text("\(item.price.formatted())$")
                            }
                        }
                        .onDelete(perform: removeBusinessRows)
                    }
                }
            }
            .navigationTitle("CashApp💸")
            .toolbar {
                Button {
                    sheetViewActive = true
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
            .sheet(isPresented: $sheetViewActive) {
                SheetView(cash: cash)
            }
        }
    }
    
    func removePrivateRows(at offsets1: IndexSet) {
        cash.privateItems.remove(atOffsets: offsets1)
    }
    
    func removeBusinessRows(at offsets2: IndexSet) {
        cash.businessItems.remove(atOffsets: offsets2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
