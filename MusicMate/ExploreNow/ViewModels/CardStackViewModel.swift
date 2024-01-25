//
//  CardStackViewModel.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 16.01.24.
//

import Foundation
import SwiftUI
import Combine

class CardStackViewModel: ObservableObject {
    // Published properties for the normal and reversed audio queues
    @Published var normalQueue: [AudioPlayerItem] = []
    @Published var reversedQueue: [AudioPlayerItem] = []

    private var audioPlayer: AudioPlayer
    private var cancellables = Set<AnyCancellable>()

    // ViewModel initializer
    init(audioPlayer: AudioPlayer) {
        self.audioPlayer = audioPlayer

        // Subscribe to changes in the audioPlayer's audio queue
        audioPlayer.$queue
            .sink { [weak self] queue in
                self?.normalQueue = queue
                self?.reversedQueue = queue.reversed().suffix(3)
            }
            .store(in: &cancellables)
    }

    // Computed property for calculating the first three indices
    var firstThreeIndices: Range<Array<AudioPlayerItem>.Index> {
        return normalQueue.startIndex..<(normalQueue.startIndex + min(2, normalQueue.count))
    }

    // Function to determine if an item is active
    func isActive(item: AudioPlayerItem) -> Bool {
        return item.id == normalQueue.first?.id
    }

    // Function to determine if a view should be finalized
    func viewShouldBeFinalized(for item: AudioPlayerItem) -> Bool {
        if let index = normalQueue.firstIndex(where: { $0.id == item.id }) {
            return firstThreeIndices.contains(index)
        }
        return false
    }
}



