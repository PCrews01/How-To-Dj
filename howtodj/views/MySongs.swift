//
//  MySongs.swift
//  howtodj
//
//  Created by Paul Crews on 10/14/23.
//

import SwiftUI
import SwiftData

struct MySongs: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @Query private var songs: [Song]
    var body: some View {
        NavigationSplitView {
            List{
                if songs.count > 0 {
                    ForEach(songs, id:\.self){
                        song in
                        Text("\(song.name)")
                            .swipeActions(content: {
                                Button(action: {
                                    deleteItems(id: song.id)
                                }, label: {
                                    Image(systemName: "trash.fill")
                                })
                            })
                    }
                } else {
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                }
            }
        } detail: {
            Text("My song list")
        }

    }
    private func deleteItems(id: String) {
        let deleted_song = songs.first(where: { $0.id == id })
        if let my_deleted_song = deleted_song{
            withAnimation {
                    modelContext.delete(my_deleted_song)
                }
        } else {
            print("Error deleeting song")
        }
 }
}

#Preview {
    MySongs()
        .modelContainer(for: Song.self, inMemory: true)
}
