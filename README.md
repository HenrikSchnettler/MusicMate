# MusicMate

## Introduction

MusicMate is an iOS application developed as a personal project to serve as an extension to the Apple Music app. It introduces enhanced functionalities not present in the default Apple Music app. The primary feature of MusicMate is its ability to suggest song previews to users based on their preferences, retrieved directly from the Apple Music API or through the MusicKit wrapper.

## Features

- **Song Suggestions**: Directly tap into the potential of Apple Music's vast library and get song suggestions tailored to your liking.
- **API Integration**: Songs and suggestions are fetched either directly from the Apple Music API or via the MusicKit.
- **Interactive UI**: Swipeable card stack interface allows users to easily like, dislike, add to their library/playlist, or even share a song with friends.
- **Intuitive Actions**: All user actions for a song can be performed by simply dragging/holding a song card.
- **Seamless Integration**: Directly adds songs to your Apple Music library or playlists with just a drag. Additional liking/disliking is done when holding the current card for some seconds in one of the dropzones and then releasing it.

## Technical Details

- **Development Environment**: Developed in the latest version of Xcode.
- **Compatibility**: Requires at least iOS 16 to run.
- **Languages & Frameworks**: The app is primarily built using SwiftUI & Swift with portions in UIKit. The following built-in libraries have been utilized:
  - MusicKit
  - StoreKit
  - Combine
  - CoreData
  - AVFoundation
  - AVKit
  - CoreMotion
  - Network
  
## Usage

Please note that MusicMate is currently under active development and is for personal use only. Any distribution or commercial use is not permitted at this time.
