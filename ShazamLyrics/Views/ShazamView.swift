//
//  ShazamView.swift
//  ShazamLyrics
//
//  Created by Enrique Sarmiento on 30/4/24.
//

import SwiftUI

struct ShazamView: View {
   @StateObject private var shazam = ShazamViewModel()
    var body: some View {
       NavigationView{
          VStack(alignment: .center){
             Spacer()
             
             if shazam.recording {
                ProgressView()
             }
             
             AsyncImage(url: shazam.shazamModel.album){ image in
                image.resizable()
                   .scaledToFit()
                   .ignoresSafeArea()
             } placeholder: {
                EmptyView()
             }
             
             Text(shazam.shazamModel.title ?? "Sin titulo")
                .font(.title)
                .bold()
             
             Text(shazam.shazamModel.artist ?? "Sin artista")
                .font(.title2)
                .bold()
             
             Spacer()
             
             HStack{
                Button(action: {
                   shazam.startListening()
                }) {
                  
                   Text(shazam.recording ? "Escuchando": "Escuchar")
                }.buttonStyle(BorderedButtonStyle())
                   .controlSize(.large)
                   .shadow(radius: 4)
                   .tint(.orange)

             }
             
             Spacer()
             
          }.padding(.all)
             .navigationTitle("Shazam Lyrics")
       }
    }
}
