//
//  ContentView.swift
//  howtodj
//
//  Created by Paul Crews on 10/13/23.
//

import SwiftUI
import SwiftData
import ChatGPTSwift

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var songs: [Song]
    @State var answers : [String] = []
    @State var query: String = ""
    @State var my_song : Song = Song(name: "name", artist: "artist", bpm: "BPM", key: "key", favorite: "fave")
    
    var body: some View {
        NavigationSplitView {
            VStack{
                TextField("Song Title", text: $query)
                    .frame(height: 30)
                    .padding(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                Button(action: {
                    if query.count > 5 {
                        aiQuery(query: query)
                    }
                }, label: {
                    Text("Get Query")
                })
            }
            .padding()
            List {
                ForEach(answers, id: \.self) { item in
                    let my_item = item.replacingOccurrences(of: " || ", with: "\r").replacingOccurrences(of: " Song", with: "Song")
                    let split = item.split(separator: " || ")
                    NavigationLink {
                        //                        Text("Item at \(my_item)")
                        MySongs()
                    } label: {
                        VStack{
                            Text(split[0].replacingOccurrences(of: "Song: ", with: ""))
                                .fontWeight(.bold)
                                .font(.title2)
                            Text(split[1])
                            Spacer()
                            HStack{
                                Text(split[2])
                                Spacer()
                                Text(("\(split[3])").trimmingAllSpaces())
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                        .swipeActions {
                            Button{
                                var my_ : Song = Song(
                                    name: "\(split[0])",
                                    artist: "\(split[1].replacingOccurrences(of: "Artist: ", with: ""))",
                                    bpm: "\(split[2].replacingOccurrences(of: "BPM: ", with: ""))",
                                    key: "\(split[3].replacingOccurrences(of: "Key: ", with: ""))",
                                    favorite: "true")
                                my_song = my_
                                addItem()
                            } label: {
                                Image(systemName: "text.badge.star")
                            }
                            .tint(.green)
                            .foregroundStyle(.white)
                            
                            Button {
                            } label: {
                                Image(systemName: "trash.fill")
                            }
                            .tint(.red)
                            .foregroundStyle(.white)
                            
                        }
                        
                    }
                    .background(Color("\(split[3].replacingOccurrences(of: "Key:", with: "").trimmingAllSpaces())"))
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        MySongs()
                    } label: {
                        Text("Library")
                    }
                    
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Suggested songs.")
        }
    }
    
    
    private func addItem() {
        let was_i_used = songs.filter({ $0.id == my_song.id }).first
        if (was_i_used != nil) {
            print("I'm null")
            return
        }
        modelContext.insert(my_song)
        
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(songs[index])
            }
        }
    }
    func aiQuery(query: String) {
        let my_query = "can you list 5 songs that are 5 to 10 BPM less than or greater that \"And the beat goes on \" by the whispers. The songs should range from 9B to 11B key with the output using the camelot system. Sorted in descending order of key. Wrap your answer in '=========='. The list style should be '---->'. separate the song, artist, bpm and key using '||'."
        var messageLog: [[String: String]] = [
            /// Modify this to change the personality of the assistant.
            /// let m
            
            ["role": "system", "content": my_query]
        ]
        let ai_url = "https://api.openai.com/v1/chat/completions"  // Update with the appropriate endpoint for ChatGPT
        let ai_key = "Bearer sk-G3tY0()R0vvn"
        
        // Prepare the request payload
        let requestBody: [String: Any] = [
            "temperature": 0,
            "model": "gpt-3.5-turbo",
            "messages": messageLog,
            "max_tokens": 1000  // Adjust the max tokens based on your requirements
        ]
        
        // Convert the payload to JSON
        guard let requestData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("Error encoding request data to JSON")
            return
        }
        
        var ai_req = URLRequest(url: URL(string: ai_url)!)
        ai_req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        ai_req.addValue(ai_key, forHTTPHeaderField: "Authorization")
        ai_req.httpMethod = "POST"
        ai_req.httpBody = requestData
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: ai_req) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                // Parse the JSON response
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let poc = jsonObject["choices"] as! [Any]
                    let poc_msg = poc[0] as! [String:Any]
                    let poc_con = poc_msg["message"] as! [String:Any]
                    let final_output = poc_con["content"] as! String
                    
                    let splitter = final_output.split(separator: "---->")
                    
                    for song in splitter {
                        //                                print("This is the song \(song)")
                        if !answers.contains("\(song)"){
                            let song_to_add = song.replacingOccurrences(of: "==========", with: "")
                            if song_to_add.count > 10{
                                withAnimation(.bouncy){
                                    answers.append("\(song_to_add)")
                                }
                            }
                        }
                    }
                    
                } else {
                    print("Failed to parse JSON response")
                }
            } catch {
                print("Error parsing JSON response: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
}

extension String {
    func trimmingAllSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return components(separatedBy: characterSet).joined()
    }
}

func getColor(key:String){
    let color_wheel : [String] = [
        "1A -- A-flat minor",
        "2A -- E-flat minor",
        "3A -- B-flat minor",
        "4A -- F minor",
        "5A -- C minor",
        "6A -- G minor",
        "7A -- D minor",
        "8A -- A minor",
        "9A -- E minor",
        "10A -- B minor",
        "11A -- F-sharp minor",
        "12A -- D-flat minor",
        "B -- A-flat major",
        "2B -- E-flat major",
        "3B -- B-flat major",
        "4B -- F major",
        "5B -- C major",
        "6B -- G major",
        "7B -- D major",
        "8B -- A major",
        "9B -- E major",
        "10B -- B major",
        "11B -- F-sharp major",
        "12B -- D-flat major"
    ]
    
    if color_wheel.contains(key){
        print("nullx \(key)")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Song.self, inMemory: true)
}

