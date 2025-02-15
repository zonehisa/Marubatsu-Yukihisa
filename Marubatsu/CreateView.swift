//
//  SwiftUIView.swift
//  Marubatsu
//
//  Created by 佐藤幸久 on 2025/02/15.
//

import SwiftUI

struct CreateView: View {
    @Binding var quizzesArray: [Quiz]
    @State var questionText = ""
    @State var selectedAnswer = "○"
    let answers = ["○", "×"]
    
    var body: some View {
        VStack {
            Text("問題文と回答を入力して、追加ボタンを押してください。")
                .foregroundStyle(.gray)
                .padding()
            
            TextField(text: $questionText) {
                Text("問題文を入力してください")
            }
            .padding()
            .textFieldStyle(.roundedBorder)
            
            Picker("解答", selection: $selectedAnswer) {
                ForEach(answers, id: \.self) { answer in
                    Text(answer)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 300)
            .padding()
            
            Button("追加") {
                addQuiz(question: questionText, answer: selectedAnswer)
            }
            .padding()
            
            Button {
                quizzesArray.removeAll()
                UserDefaults.standard.removeObject(forKey: "quiz")
            } label: {
                Text("全削除")
            }
            .foregroundStyle(.red)
            .padding()
        }
    }
    
    func addQuiz(question: String, answer: String) {
        if question.isEmpty {
            print("問題文が入力されていません")
            return
        }
        
        var savingAnswer = true
        
        switch answer {
        case "○":
            savingAnswer = true
        case "×":
            savingAnswer = false
        default:
            print("適切な答えが入っていません")
            break
        }
        let newQuiz = Quiz(question: question, answer: savingAnswer)
        
        var array = quizzesArray
        array.append(newQuiz)
        let storeKey = "quiz"
        
        if let encodedQuizzes = try? JSONEncoder().encode(array) {
            UserDefaults.standard.setValue(encodedQuizzes, forKey: storeKey)
            questionText = ""
            quizzesArray = array
        }
    }
}

#Preview {
    CreateView(quizzesArray: .constant([]))
}
