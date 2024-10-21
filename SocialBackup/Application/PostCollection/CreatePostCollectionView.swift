//
//  CreatePostCollectionView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct CreatePostCollectionView: View {
    
    @Binding var isPresented: Bool
    var onSave: (_ collectionName: String) -> Void
    
    @State private var collectionName: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("New Collection")
                .font(.custom(Constants.FontName.heavy, size: 20.0))
            TextField("Enter collection name...", text: $collectionName)
                .appTextFieldStyle()
            
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .appButtonStyle(foregroundColor: Colors.elementBackgroundColor, backgroundColor: Colors.elementTextColor)
                }
                Button(action: {
                    onSave(collectionName)
                    isPresented = false
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .appButtonStyle()
                }
            }
        }
    }
    
}

@available(iOS 17, *)
#Preview {
    
    @Previewable @State var isPresented: Bool = false
    
    return CreatePostCollectionView(
        isPresented: $isPresented,
        onSave: { collectionName in
            
        })
        .frame(maxHeight: .infinity)
        .padding()
        .background(Colors.background)
    
}
