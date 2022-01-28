//
//  ContentView.swift
//  WordScramble
//
//  Created by Kimmortal on 27.1.2022.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    @State private var letterCount = 0
    @State private var totalScore = 0
    @State private var highScore = 0
    
    var body: some View {
        ZStack {
            Image("wordscramble")
                .resizable()
                .scaledToFit()
            NavigationView {
                List {
                    Section {
                        TextField("Enter your Word", text: $newWord)
                            .autocapitalization(.none)
                        
                        HStack {
                            Text("Word score: \(score)")
                                .frame(width: 160)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text("Letter count: \(letterCount)")
                                .frame(width: 160)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                            }
                        HStack {
                            Text("Total Score: \(totalScore)")
                                .frame(width: 160)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text("Highscore: \(highScore)")
                                .frame(width: 160)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                        
                        }
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                                
                            }
                        }
                    }
                }
                .navigationTitle("Rootword: \(rootWord.uppercased())")
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                .toolbar {
                    Button("New Word", action: startGame)
                }
            }
        }
}

func addNewWord() {
    let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    guard answer.count > 2 else {
        wordError(title: "Too short word", message: "Use words with atleast 3 letters")
        return
    }
    
    guard isRootWord(word: answer) else {
        wordError(title: "Can't use rootword", message: "Can't use that one smartypants")
        return
    }
    
    guard isOriginal(word: answer) else {
        wordError(title: "Word already used", message: "Could you be more original")
        return
    }
    
    guard isPossible(word: answer) else {
        wordError(title: "Word not possible", message: "Youn can't' spell that word from '\(rootWord)'!")
        return
    }
            
    guard isReal(word: answer) else {
        wordError(title: "Word not recognized", message: "You can't just make words up")
        return
    }
        
    withAnimation {
        usedWords.insert(answer, at: 0)
    }
    newWord = ""
    
    if answer.count > 5 {
    score += 2
    } else {
    score += 1
    }
    letterCount += answer.count
    totalScore = score + letterCount
    
    if totalScore >= highScore {
        highScore = totalScore
    }
}

func startGame() {
    score = 0
    letterCount = 0
    totalScore = 0
    usedWords = [String]()
    
    
    // 1. Find the URL for start.txt in our app bundle
    if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
        // 2. Load start.txt into a string
        if let startWords = try? String(contentsOf: startWordsURL) {
            // 3. Split the string up into an array of strings, splitting on line breaks
            let allWords = startWords.components(separatedBy: "\n")
            // 4. Pick one random word, or use "silkworm" as a sensible default
            
            rootWord = allWords.randomElement() ?? "silkworm"
            // If we are here everything has worked, so we can exit
            return
        }
    }
    // If were are *here* then there was a problem – trigger a crash and report the error
    fatalError("Could not load start.txt from bundle.")
    
}

func isOriginal(word: String) -> Bool {
    !usedWords.contains(word)
}

func isPossible(word: String) -> Bool {
    var tempWord = rootWord
    
    for letter in word {
        if let pos = tempWord.firstIndex(of: letter) {
            tempWord.remove(at: pos)
        } else {
            return false
        }
    }
    return true
}

func isReal(word: String) -> Bool {
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    
    return misspelledRange.location == NSNotFound
    }

func wordError(title: String, message: String) {
    errorTitle = title
    errorMessage = message
    showingError = true
    
    }
    
func isRootWord(word: String) -> Bool {
    word != rootWord
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
