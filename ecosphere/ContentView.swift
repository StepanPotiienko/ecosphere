import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

#Preview(body: {MainView()})
struct MainView: View {
    var body: some View {
        VStack {
            ContentView()
        }
    }
}

struct ControlsView: View {
    let soundPlayer = SoundPlayer()

    var body: some View {
        HStack {
            Button("Play Ambient Sound") {
                soundPlayer.playSound(named: "rain") // Example: "rain.mp3"
            }
            Button("Stop Sound") {
                soundPlayer.stopSound()
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
    }
}


struct ContentView: View {
    @State private var wallpaper: NSImage? = nil
    
    func setDesktopWallpaper(fileUrl: URL) {
        // TODO: For all screens
        do {
            if let screen = NSScreen.main {
                try NSWorkspace.shared.setDesktopImageURL(fileUrl, for: screen, options: [:])
            }
        }
        catch {
            print(error)
        }
    }


    var body: some View {
        ZStack {
            VStack {
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



struct SoundPlayerView: View {
    var body: some View {
        Text("Hello, World!")
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
            player?.numberOfLoops = -1 // Loop indefinitely
            player?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }

    func stopSound() {
        player?.stop()
    }
}

