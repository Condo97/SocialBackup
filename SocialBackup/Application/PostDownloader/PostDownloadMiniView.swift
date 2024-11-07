//
//  PostDownloadMiniView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct PostDownloadMiniView: View {
    
    @Binding var text: String
    @Binding var isLoading: Bool
    var inputIsValid: Bool
    var onSubmit: () -> Void
    
    @State private var isShowingOnSubmitButton: Bool = false // State so that it can be set with animation
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("", text: $text, prompt: Text("Enter Post URL...").foregroundColor(Colors.text.opacity(0.6)))
                    .disabled(isLoading)
                Button(action: {
                    if let pasteboardText = PasteboardHelper.paste() {
                        DispatchQueue.main.async {
                            self.text = pasteboardText
                        }
                    }
                }) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.custom(Constants.FontName.medium, size: 17.0))
                        .foregroundStyle(Colors.elementBackgroundColor)
                }
            }
            .font(.custom(Constants.FontName.body, size: 17.0))
            .foregroundStyle(Colors.text)
            .padding()
            .background(Capsule()
                .fill(Colors.foreground))
                
//            if isShowingOnSubmitButton {
                Button(action: onSubmit) {
//                    HStack {
//                        Spacer()
//                        Text("Save")
//                            .font(.custom(Constants.FontName.heavy, size: 17.0))
//                        if isLoading {
//                            ProgressView()
//                                .tint(.elementText)
//                        } else {
//                            Text("\(Image(systemName: "square.and.arrow.down"))")
//                                .fontWeight(.light)
//                                .padding(.bottom, 1)
//                        }
//                        Spacer()
//                    }
//                    .appButtonStyle()
                    ZStack {
                        HStack {
                            Spacer()
                            Text("Save")
                                .font(.custom(Constants.FontName.heavy, size: 17.0))
                            if isLoading {
                                ProgressView()
                                    .tint(.elementText)
                            } else {
                                Text("\(Image(systemName: "square.and.arrow.down"))")
                                    .fontWeight(.light)
                                    .padding(.bottom, 1)
                            }
                            Spacer()
                        }
                        .appButtonStyle()
                        .overlay {
                            
                        }
//                        .overlay {
//                            Capsule()
////                                .strokeBorder(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round, dash: [1], dashPhase: isAnimatingSubmitButtonLoading ? 1000 : 500))
//                                .stroke(
//                                    AngularGradient(
//                                        stops: [
//                                            .init(color: .white, location: 0),
//                                            .init(color: .green, location: 0.1),
//                                            .init(color: .green, location: 0.4),
//                                            .init(color: .white, location: 0.5)
//                                        ],
//                                        center: .center,
//                                        angle: .degrees(isAnimatingSubmitButtonLoading ? 360 : 0)
//                                    ),
//                                    lineWidth: 2.0
//                                )
////                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.indigo, .white, .purple, .mint, .white, .orange, .indigo]), startPoint: .trailing, endPoint: .leading))
//                                .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: isAnimatingSubmitButtonLoading)
//                                .onAppear {
//                                    isAnimatingSubmitButtonLoading = true
//                                }
//                        }
                    }
                }
                .disabled(isLoading || !inputIsValid)
                .opacity(isLoading || !inputIsValid ? 0.4 : 1.0)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .zIndex(-1)
//            }
        }
        .onChange(of: text) { newValue in
            withAnimation(.bouncy(duration: 0.3)) {
                isShowingOnSubmitButton = !newValue.isEmpty
            }
        }
    }
    
}

@available(iOS 17, *)
#Preview {
    
    @Previewable @State var text: String = ""
    @Previewable @State var isLoading: Bool = false
    
    return PostDownloadMiniView(
        text: $text,
        isLoading: $isLoading,
        inputIsValid: true,
        onSubmit: {
            
        })
    
}
