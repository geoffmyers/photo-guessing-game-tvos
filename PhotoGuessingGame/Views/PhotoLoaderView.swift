import SwiftUI

struct PhotoLoaderView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 25) {
            Text("Photos")
                .font(.title2)
                .fontWeight(.semibold)

            if viewModel.isLoadingPhotos {
                // Loading state
                VStack(spacing: 15) {
                    ProgressView(value: viewModel.loadingProgress)
                        .progressViewStyle(.linear)
                        .frame(width: 400)

                    Text(viewModel.loadingMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(30)
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)

            } else if viewModel.allPhotos.isEmpty {
                // No photos loaded
                VStack(spacing: 20) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text("No photos loaded")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    HStack(spacing: 20) {
                        Button(action: loadPhotos) {
                            Label("Load from Library", systemImage: "photo.stack")
                                .padding(.horizontal, 25)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)

                        Button(action: loadDemoPhotos) {
                            Label("Use Demo Photos", systemImage: "wand.and.stars")
                                .padding(.horizontal, 25)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(40)
                .background(Color.white.opacity(0.05))
                .cornerRadius(20)

            } else {
                // Photos loaded
                VStack(spacing: 20) {
                    // Photo stats
                    HStack(spacing: 40) {
                        PhotoStatBadge(
                            icon: "photo.stack.fill",
                            count: viewModel.allPhotos.count,
                            label: "Total Photos",
                            color: .blue
                        )

                        PhotoStatBadge(
                            icon: "calendar",
                            count: viewModel.photosWithValidDate,
                            label: "With Dates",
                            color: viewModel.photosWithValidDate >= 3 ? .green : .orange
                        )

                        PhotoStatBadge(
                            icon: "mappin",
                            count: viewModel.photosWithValidLocation,
                            label: "With Location",
                            color: viewModel.photosWithValidLocation >= 3 ? .green : .orange
                        )
                    }

                    // Photo thumbnails preview
                    PhotoThumbnailGrid()

                    // Reload button
                    Button(action: clearPhotos) {
                        Label("Clear & Reload", systemImage: "arrow.counterclockwise")
                            .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                }
                .padding(30)
                .background(Color.white.opacity(0.05))
                .cornerRadius(20)
            }
        }
    }

    private func loadPhotos() {
        Task {
            await viewModel.loadPhotos()
        }
    }

    private func loadDemoPhotos() {
        let photoService = PhotoService()
        viewModel.allPhotos = photoService.loadDemoPhotos()
    }

    private func clearPhotos() {
        viewModel.allPhotos = []
    }
}

// MARK: - Photo Stat Badge

struct PhotoStatBadge: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)

            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 120)
    }
}

// MARK: - Photo Thumbnail Grid

struct PhotoThumbnailGrid: View {
    @EnvironmentObject var viewModel: GameViewModel

    private let columns = Array(repeating: GridItem(.fixed(80), spacing: 10), count: 8)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Array(viewModel.allPhotos.prefix(16).enumerated()), id: \.element.id) { index, photo in
                PhotoThumbnail(photo: photo)
            }

            if viewModel.allPhotos.count > 16 {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))

                    Text("+\(viewModel.allPhotos.count - 16)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .frame(width: 80, height: 80)
            }
        }
    }
}

struct PhotoThumbnail: View {
    let photo: GamePhoto

    var body: some View {
        Group {
            if let imageData = photo.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Placeholder for demo photos
                ZStack {
                    Color.gray.opacity(0.3)
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    PhotoLoaderView()
        .environmentObject(GameViewModel())
}
