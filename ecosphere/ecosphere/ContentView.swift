import SwiftUI
import AppKit
import AVFoundation
import UniformTypeIdentifiers

#Preview(body: { MainView() })

struct MainView: View {
    var body: some View {
        VStack() {
            WallpaperPreviewHolder()
            ContentView()
        }
        .frame(width: 600, height: 500)
    }
}

struct WallpaperPreviewHolder: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    let imageUrls = [
        URL(string: "https://cdn.pixabay.com/photo/2025/05/07/19/13/soap-bubbles-9585871_1280.jpg")!,
        URL(string: "https://hws.dev/paul.jpg")!,
        URL(string: "https://cdn.pixabay.com/photo/2025/05/04/11/13/california-9577976_1280.jpg")!,
        URL(string: "https://cdn.pixabay.com/photo/2025/04/30/04/39/sunflower-9568413_1280.jpg")!,
        URL(string: "https://cdn.pixabay.com/photo/2022/09/05/04/53/snake-7433282_1280.jpg")!,
        URL(string: "https://cdn.pixabay.com/photo/2025/05/04/18/04/bird-9578746_1280.jpg")!
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(imageUrls, id: \.self) { url in
                    WallpaperPreview(url: url, onClick: {
                        setDesktopWallpaper(from: url)
                    })
                }
            }
            .padding()
        }
    }
    
    func setDesktopWallpaper(from url: URL) {
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
        
        URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL, error == nil else {
                print("Download error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                try? FileManager.default.removeItem(at: destination)
                try FileManager.default.copyItem(at: tempURL, to: destination)
                
                if let screen = NSScreen.main {
                    try NSWorkspace.shared.setDesktopImageURL(destination, for: screen, options: [:])
                }
            } catch {
                print("Failed to set wallpaper: \(error)")
            }
        }.resume()
    }
}

struct WallpaperPreview: View {
    var url: URL
    var onClick: () -> Void
    
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ProgressView()
        }
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .onTapGesture {
            onClick()
        }
        .frame(width: 180, height: 120)
        .clipped()
        .cornerRadius(10)
    }
}

struct ContentView: View {
    func setDesktopWallpaperFromLocalFile(fileUrl: URL) {
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
            Button("Choose Wallpaper from Gallery") {
                selectImage { selectedURL in
                    if let url = selectedURL {
                        setDesktopWallpaperFromLocalFile(fileUrl: url)
                    } else {
                        print("No image selected.")
                    }
                }
            }
            .padding()
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
