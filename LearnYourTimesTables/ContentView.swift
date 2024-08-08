//
//  ContentView.swift
//  LearnYourTimesTables
//
//  Created by Adam Sayer on 27/7/2024.
//

import SwiftUI

struct setUpGame: View {
    
    let questionChoices = [5, 10, 20]
    
    @Binding var gameInPlay: Bool
    @Binding var timesTable: Int
    @Binding var numberOfQuestions: Int
    @State private var animationAmount = 0.0
    
    var body: some View {
        
        ZStack {
            Color.gray.opacity(0.1) // Set your background color here
                .ignoresSafeArea()
            
            VStack {
                
                Form {
                    
                    Section {
                        Text("Learn your Times Tables")
                            .foregroundStyle(.indigo)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }.listRowBackground(Color.clear)
                    
                    Section {
                        VStack(alignment: .leading) {
                            Text("What Timestable would you like to practice")
                            Stepper("Times Table: \(timesTable)", value: $timesTable, in: 1...12, step: 1)
                        }
                        
                    }
                    //.listRowBackground(Color.indigo.opacity(0.1))
                    
                    
                    Section {
                        VStack(alignment: .leading) {
                            Text("How Many Questions would you like?")
                            Picker("Number of Questions", selection: $numberOfQuestions) {
                                ForEach(questionChoices, id: \.self) {
                                    Text($0, format: .number)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                    }
                    //.listRowBackground(Color.indigo.opacity(0.1))
                }
                //.scrollContentBackground(.hidden)
                
                Spacer()
                
                Button("Go") {
                    withAnimation(.spring(duration: 1, bounce: 0.5)) {
                        animationAmount += 360
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        gameInPlay.toggle()
                    }
                    
                }
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(40)
                .background(.indigo)
                .foregroundStyle(.white)
                .clipShape(.circle)
                .shadow(radius: 5)
                .rotation3DEffect(.degrees(animationAmount), axis: (x: 0.0, y: 1.0, z: 0.0)
                )
            }
        }
    }
}

struct gameView: View {
    @Binding var gameInPlay: Bool
    @Binding var timesTable: Int
    @Binding var numberOfQuestions: Int
    
    @State private var questionNumber = 1
    @State private var userScore = 0
    @State private var timesBy = Int.random(in: 1...12)
    @State private var userAnswer: Int?
    @State private var animationAmount = 0.0
    
    @State private var showingAlert = false
    @State private var showingQuitConfirmation = false
    @State private var answerTitle = ""
    
    @State private var selectedAnswer = -1
    
    @State private var possibleAnswers: [Int] = []
    @State private var nextQuestionTrigger = false
    
    var correctAnswer: Int {
        timesTable * timesBy
    }
    
    @State private var selectedFlag = -1
    
    
    var body: some View {
        
        ZStack {
            Color.gray.opacity(0.1) // Set your background color here
                .ignoresSafeArea()
            
            NavigationStack {
                
                if questionNumber <= numberOfQuestions {
                    
                    VStack {
                        
                        Text("The \(timesTable) Times Tables")
                            .foregroundStyle(.indigo)
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Question \(questionNumber) of \(numberOfQuestions)")
                        
                        Spacer()
                        
                        Text("What is \(timesBy) x \(timesTable)?")
                            .foregroundStyle(.teal)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        ForEach(possibleAnswers, id: \.self) { answer in
                            Button("\(answer)") {
                                answerProvided(answer)
                            }
                            .padding(25)
                            .frame(width: 250, height: 70)
                            .foregroundStyle(.white)
                            .background( // Conditionally set the background color
                                selectedAnswer == answer ?
                                (answer == correctAnswer ? .green : .red) :
                                .indigo
                            )
                            .clipShape(.rect(cornerRadius: 15))
                            .animation(.default, value: selectedAnswer) // Animate background color change
                        }
                    }
                    .onChange(of: timesTable) { _, newTimesTable in // Two-parameter closure
                        generatePossibleAnswers()
                      }
                    .onAppear {
                        generatePossibleAnswers()
                    }
                    
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Quit") {
                                showingQuitConfirmation = true
                            }
                            .foregroundStyle(.teal)
                        }
                    }
            
                }
                
                
            }
            
            
        }

        .alert(answerTitle, isPresented: $showingAlert) {
            if questionNumber > numberOfQuestions { // Check if game is over
                Button("New Game", action: endGame)
            } else {
                Button("Continue", action: nextQuestion)
            }
        } message: {
            if questionNumber > numberOfQuestions {
                Text("Well done, that's the end of the game. You scored \(userScore)")
            } else {
                Text("Your Score is \(userScore)")
            }
        }
        
        .alert("Are you sure you want to quit?", isPresented: $showingQuitConfirmation) {
            Button("Quit", role: .destructive) {
                endGame()
            }
            Button("Cancel", role: .cancel) { } // Do nothing if the user cancels
        }
    }

    func responseOptions(timesTable: Int, timesBy: Int) -> [Int] {
      let correctAnswer = timesTable * timesBy

      // Create a shuffled array of all possible answers
      var allOptions = Array(1...(timesTable * 12)).shuffled()

      // Remove the correct answer
      if let index = allOptions.firstIndex(of: correctAnswer) {
        allOptions.remove(at: index)
      }

      // Select two random wrong answers
      let wrongAnswers = Array(allOptions.prefix(2))

      // Combine and shuffle again to randomize correct answer position
      return ([correctAnswer] + wrongAnswers).shuffled()
    }
    
    func answerProvided(_ number: Int) {
        selectedAnswer = number
        
        if number == timesTable * timesBy {
            answerTitle = "Correct"
            userScore += 1
            
        } else {
            answerTitle = "Wrong, the answer is \(number)"
        }
        
        questionNumber += 1
        showingAlert = true
    }
    
    func nextQuestion() {
        if questionNumber <= numberOfQuestions { // Only go to next question if there are questions left
            timesBy = Int.random(in: 1...12)
            generatePossibleAnswers()
        } else {
            endGame() // End the game if all questions answered
        }
        
        selectedAnswer = -1
        showingAlert = false
    }
    
    func endGame() {
        questionNumber = 1 // Reset question number when ending or restarting
        userScore = 0
        gameInPlay.toggle()
        selectedAnswer = -1
        timesTable = 1
    }
    
    func generatePossibleAnswers() {
        possibleAnswers = responseOptions(timesTable: timesTable, timesBy: timesBy)
    }
}

struct ContentView: View {

    @State private var gameInPlay = false
    @State private var timesTable = 1
    @State private var numberOfQuestions = 5
    @State private var questionsSoFar = 1
    @State private var currentViewOffset: CGFloat = 0 // Track the offset
    
    var body: some View {
        ZStack {
            setUpGame(gameInPlay: $gameInPlay, timesTable: $timesTable, numberOfQuestions: $numberOfQuestions)
                .offset(x: gameInPlay ? -UIScreen.main.bounds.width : currentViewOffset) // Slide out when gameInPlay is true

            gameView(gameInPlay: $gameInPlay, timesTable: $timesTable, numberOfQuestions: $numberOfQuestions)
                .offset(x: gameInPlay ? currentViewOffset : UIScreen.main.bounds.width) // Slide in when gameInPlay is true
        }
        .animation(.default, value: gameInPlay) // Animate the offset change
        .onAppear {
            // Initial animation (optional)
            withAnimation(.easeInOut(duration: 0.5)) {
                currentViewOffset = 0
            }
        }
    }
}

#Preview {
    ContentView()
}
