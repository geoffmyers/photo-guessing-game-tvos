import SwiftUI

struct PhotoDisplayView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            // Photo frame
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)

            // Photo content
            Group {
                if let photo = viewModel.currentPhoto {
                    if let imageData = photo.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        // Demo photo placeholder
                        DemoPhotoPlaceholder(photo: photo)
                    }
                } else {
                    // No photo available
                    VStack(spacing: 20) {
                        Image(systemName: "photo")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)

                        Text("No photo")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(8)

            // Photo counter badge
            PhotoCounterBadge(text: viewModel.photoCountText)
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .aspectRatio(16/10, contentMode: .fit)
    }
}

// MARK: - Demo Photo Placeholder

struct DemoPhotoPlaceholder: View {
    let photo: GamePhoto

    var body: some View {
        ZStack {
            // Gradient background based on photo properties
            LinearGradient(
                colors: [
                    Color(hue: Double(photo.id.hashValue % 360) / 360.0, saturation: 0.5, brightness: 0.6),
                    Color(hue: Double((photo.id.hashValue + 60) % 360) / 360.0, saturation: 0.5, brightness: 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Photo info overlay
            VStack(spacing: 10) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.5))

                if let location = photo.location?.city {
                    Text(location)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.7))
                }

                Text("Demo Photo")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

// MARK: - Photo Counter Badge

struct PhotoCounterBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.6))
            )
    }
}

#Preview {
    PhotoDisplayView()
        .environmentObject(GameViewModel())
        .frame(height: 400)
        .padding()
}
