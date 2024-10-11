//
//  VideoStatsView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct VideoStatsView: View {
    
    var videoInfo: GetVideoInfoResponse

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
//                // Video Cover Image
//                if let coverURL = URL(string: videoInfo.downloadResponse.data.cover) {
//                    AsyncImage(url: coverURL) { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .cornerRadius(10)
//                    } placeholder: {
//                        ProgressView()
//                    }
//                }

                // Author Info
                HStack(spacing: 12) {
                    // Author Avatar
                    if let avatarURL = URL(string: videoInfo.downloadResponse.data.author.avatar) {
                        AsyncImage(url: avatarURL) { image in
                            image
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                    }

                    // Author Name and ID
                    VStack(alignment: .leading) {
                        Text(videoInfo.downloadResponse.data.author.nickname)
                            .font(.headline)
                        Text("@\(videoInfo.downloadResponse.data.author.uniqueID)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                // Video Statistics
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 20
                ) {
                    StatisticView(iconName: "play.fill", value: videoInfo.downloadResponse.data.playCount)
                    StatisticView(iconName: "hand.thumbsup.fill", value: videoInfo.downloadResponse.data.diggCount)
                    StatisticView(iconName: "bubble.right.fill", value: videoInfo.downloadResponse.data.commentCount)
                    StatisticView(iconName: "arrowshape.turn.up.right.fill", value: videoInfo.downloadResponse.data.shareCount)
                }
                .padding(.vertical)
                
                // Video Title
                Text(videoInfo.downloadResponse.data.title)
                    .font(.custom(Constants.FontName.heavy, size: 17.0))

                // Music Info
                HStack(spacing: 12) {
                    // Music Cover Image
                    if let musicCoverURL = URL(string: videoInfo.downloadResponse.data.musicInfo.cover) {
                        AsyncImage(url: musicCoverURL) { image in
                            image
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                        } placeholder: {
                            ProgressView()
                        }
                    }

                    // Music Title and Author
                    VStack(alignment: .leading) {
                        Text(videoInfo.downloadResponse.data.musicInfo.title)
                            .font(.headline)
                        Text(videoInfo.downloadResponse.data.musicInfo.author)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
    
}

// Helper view for displaying statistics
struct StatisticView: View {
    
    var iconName: String
    var value: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .foregroundColor(.gray)
            Text("\(value)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
}

//#Preview {
//
//    VideoStatsView()
//
//}
