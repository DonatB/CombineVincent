//
//  ContentView.swift
//  CombineVincent
//
//  Created by Donat on 23.3.25.
//

import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    @Published var totalCharacterCount: Int = 0 // Tracks the total character count
    @Published var myText: String = ""
    private var cancellable: AnyCancellable?

    let publisher = PassthroughSubject<Int, Never>() // Change the Publisher type

    init() {
        cancellable = publisher
            .map { text in
                return "Received: " + text
            }
            .filter { text in
                return text.count > 15
            }
            .scan( /* Initial value here */, { (currentTotal, newText) in
               //Your code to define behaviour of scan

            }) // Add scan here
            .removeDuplicates()
            .sink { [weak self] newTotal in
                guard let self = self else { return }
                 self.totalCharacterCount = newTotal
                print("newTotal \(newTotal)") // Debug print
            }
    }
}
struct ContentView: View {
    @ObservedObject private var viewModel = ContentViewModel()
    @State private var searchText: String = ""
     @State private var value = 1


    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Total chars: \(viewModel.totalCharacterCount)") // Display total character count
            Text(viewModel.myText)

            TextField("Enter text", text: $searchText) // Add TextField
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: searchText) { newValue in //Send values to PassthroughSubject
                    viewModel.publisher.send(newValue)
                }

            Button("Send new text") {
                viewModel.publisher.send("New text here! This many times? \(value)")
                value += 1
            }
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
