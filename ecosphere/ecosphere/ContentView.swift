import SwiftUI
import AppKit
import AVFoundation
import UniformTypeIdentifiers

#Preview(body: { MainView() })

struct MainView: View {
    var body: some View {
        VStack(spacing: 20) {
            WallpaperPreviewHolder()
            ContentView()
        }
        .padding()
        .frame(minWidth: 600, minHeight: 400)
    }
}

struct WallpaperPreviewHolder: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    let imageUrls = [
        URL(string: "https://cdn.pixabay.com/photo/2025/05/07/19/13/soap-bubbles-9585871_1280.jpg")!,
        URL(string: "https://hws.dev/paul.jpg")!,
        URL(string: "https://cdn.pixabay.com/photo/2023/12/26/10/30/ai-generated-8469223_1280.jpg")!,
        URL(string: "https://cdn.pixabay.com/photo/2023/05/29/07/53/wallpaper-8026297_1280.jpg")!
    ]
    
    let numberOfRows: CGFloat = 4


        var body: some View {
            ZStack {
                Color.white
                GeometryReader { geo in
                    LazyVGrid(columns: columns) {
                        ForEach(imageUrls, id: \.self) { url in
                            WallpaperPreview(url: url)
                        }
                    }
                }
                .padding()
            }
        }
}

struct WallpaperPreview: View {
    var url: URL

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ProgressView()
        }
        .frame(width: 250, height: 150)
        .clipped()
        .cornerRadius(10)
    }
}

struct ContentView: View {
    func setDesktopWallpaper(fileUrl: URL) {
        do {
            if let screen = NSScreen.main {
                try NSWorkspace.shared.setDesktopImageURL(fileUrl, for: screen, options: [:])
            }
        } catch {
            print("Error setting wallpaper: \(error)")
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Button("Choose Wallpaper") {
                selectImage { selectedURL in
                    if let url = selectedURL {
                        setDesktopWallpaper(fileUrl: url)
                    } else {
                        print("No image selected.")
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
        }
    }

    func selectImage(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg]
        panel.begin { response in
            if response == .OK, let url = panel.url {
                completion(url)
            } else {
                completion(nil)
            }
        }
    }
}

class SoundPlayer {
    var player: AVAudioPlayer?

    func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Sound not found")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }

    func stopSound() {
        player?.stop()
    }
}
