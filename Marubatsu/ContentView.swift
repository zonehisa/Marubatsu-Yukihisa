//
//  ContentView.swift
//  Marubatsu
//
//  Created by 佐藤幸久 on 2025/02/15.
//

import SwiftUI

// Quizの構造体
struct Quiz: Identifiable, Codable {
    var id = UUID()
    var question: String
    var answer: Bool
}

struct ContentView: View {
    
    let quizExamples: [Quiz] = [
        Quiz(question: "iPhoneアプリを開発する統合環境はZcodeである", answer: false),
        Quiz(question: "Xcode画面の右側にはユーティリティーズがある", answer: true),
        Quiz(question: "Textは文字列を表示する際に利用する", answer: true),
    ]
    
    @State var currentQuestionNum: Int = 0 // 今、何問目の数字
    @State var showingAlert = false
    @State var alertTitle = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(showQuestion())
                    .padding()   // 余白の追加
                    .frame(width: geometry.size.width * 0.8, alignment: .leading) // 横幅を250、左寄せに
                    .font(.system(size: 25)) // フォントサイズを25に
                    .fontDesign(.rounded)    // フォントを丸みのあるものに
                    .background(.yellow)     // 背景を黄色に
                
                Spacer()
                
                HStack {
                    Button {
                        checkAnswer(yourAnswer: true)
                    } label: {
                        Text("○")
                    }
                    .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                    .font(.system(size: 100, weight: .bold))
                    .foregroundStyle(.white)
                    .background(.red)
                    Button {
                        checkAnswer(yourAnswer: false)
                    } label: {
                        Text("Ｘ")
                    }
                    .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                    .font(.system(size: 100, weight: .bold))
                    .foregroundStyle(.white)
                    .background(.blue)
                }
            }
            .padding()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    //
                }
            }
        }
    }

    func showQuestion() -> String {
        let question = quizExamples[currentQuestionNum].question
        return question
    }

    func checkAnswer(yourAnswer: Bool) {
        let quiz = quizExamples[currentQuestionNum]
        let ans = quiz.answer
        if yourAnswer == ans {
            alertTitle = "正解"
            if currentQuestionNum + 1 < quizExamples.count {
                currentQuestionNum += 1
            } else {
                currentQuestionNum = 0
            }
        } else {
            alertTitle = "不正解"
        }
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
