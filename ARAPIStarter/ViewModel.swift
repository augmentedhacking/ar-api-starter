//
//  ViewModel.swift
//  APIStarter
//
//  Created by Nien Lam on 10/19/23.
//  Copyright © 2023 Line Break, LLC. All rights reserved.
//

import Foundation
import Combine

@MainActor
class ViewModel: ObservableObject {
    @Published var sliderValue: Float = 0.5

    @Published var dateString: String = ""
    @Published var timer: Timer?

    // For handling different button presses.
    enum UISignal {
        case reset
    }
    
    let uiSignal = PassthroughSubject<UISignal, Never>()
    
    init() {
        // Setup timer.
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil, 
                                     repeats: true)
    }

    // Helper method for getting current time.
    func getDateString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .long
        let dateString = formatter.string(from: Date())
        return dateString
    }

    // Called every second.
    @objc func updateTimer() {
        dateString = getDateString()
    }
}
