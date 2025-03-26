//
//  ContentView.swift
//  CombineVincent
//
//  Created by Donat on 23.3.25.
//

import SwiftUI
import Combine

enum MyCombineError: Error {
    case numberTooLow
}

class ContentViewModel: ObservableObject {
    @Published var totalCharacterCount: Int = 0 // Tracks the total character count
    @Published var myText: String = ""
    private var cancellable: AnyCancellable?

    let publisher = PassthroughSubject<Int, MyCombineError>() // Change the Publisher type

    init() {
        cancellable = publisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .flatMap { number -> AnyPublisher<Int, Never> in // Must return a Publisher
                if number > 15 {
                    print("flatMap: Number \(number) is valid. Passing downstream via Just.")
                    return Just(number)
                           .eraseToAnyPublisher()
                } else {
                    print("flatMap: Number \(number) is too low. Handling and returning Empty.")
                    return Empty<Int, Never>()
                           .eraseToAnyPublisher()
                }
            }
            .scan(0) { currentTotal, newValidNumber -> Int in
                 print("scan: currentTotal=\(currentTotal), newValidNumber=\(newValidNumber)")
                 return currentTotal + newValidNumber // Only receives numbers > 15
            }
            .removeDuplicates()
            .sink(receiveCompletion: { completion in
                // Handles completion (either .finished or .failure(let error))
                switch completion {
                case .finished:
                    print("Pipeline finished successfully.")
                case .failure(let error):
                    print("Pipeline failed with error: \(error)")
                }
            }, receiveValue: { value in
                // Handles each value received (like your current .sink)
                self.totalCharacterCount = value
                print("Received value: \(value)")
            })
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
                    viewModel.publisher.send(newValue.count)
                }

            Button("Send new text") {
                viewModel.publisher.send(value)
                value += 1
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
