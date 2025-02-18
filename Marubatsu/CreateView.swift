//
//  SwiftUIView.swift
//  Marubatsu
//
//  Created by 佐藤幸久 on 2025/02/15.
//

import SwiftUI

struct CreateView: View { // Viewプロトコルを遵守するCreateView構造体
    @Binding var quizzesArray: [Quiz] // ContentView(親)からクイズデータを受け取る
    @State var questionText = "" // 問題文を管理
    @State var selectedAnswer = "○" // 選択された解答を管理
    let answers = ["○", "×"] // 解答の選択肢
    @State private var showingAlert = false // アラート表示状態を管理
    @FocusState private var isQuestionFieldFocused: Bool // フォーカスをバインド
    @State private var alertMessage = "" // アラートメッセージを管理
    
    var body: some View { // ビューを返す
        VStack { // 垂直スタックを使用して要素を配置
            Text("問題文と回答を入力して、追加ボタンを押してください。") // テキストを表示
                .foregroundStyle(.gray) // テキストの色をグレーに
                .padding() // 余白を追加
            
            TextField(text: $questionText) { // テキストフィールドを表示
                Text("問題文を入力してください") // テキストフィールドのプレースホルダー
            }
            .padding() // 余白を追加
            .textFieldStyle(.roundedBorder) // テキストフィールドのスタイルを変更
            .focused($isQuestionFieldFocused) // フォーカスをバインド
            .onSubmit {
                isQuestionFieldFocused = false // フォーカスを外す
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer() // 左側にスペースを追加してボタンを右に寄せる
                        Button("Done") {
                            isQuestionFieldFocused = false // フォーカスを外してキーボードを閉じる
                        }
                    }
                }
            }
            .alert(alertMessage, isPresented: $showingAlert) { // アラートを表示
                Button("OK") {
                    showingAlert = false // アラートを閉じる
                }
            }
            
            Picker("解答", selection: $selectedAnswer) { // ピッカーを表示
                ForEach(answers, id: \.self) { answer in // 解答の選択肢を表示
                    Text(answer) // 解答の選択肢を表示
                }
            }
            .pickerStyle(.segmented) // ピッカーのスタイルを変更
            .frame(maxWidth: 300) // ピッカーの幅を300に
            .padding() // 余白を追加
            
            Button("追加") {
                addQuiz(question: questionText, answer: selectedAnswer) // 追加ボタンが押されたらaddQuiz関数を呼び出す
            }
            .padding() // 余白を追加
            
            Button { // ボタンが押されたらダイアログを表示
                showingAlert = true // ダイアログを表示
            } label: {
                Text("全削除") // テキストを表示
                    .foregroundStyle(.red) // テキストの色を赤色に
            }
            .alert("確認", isPresented: $showingAlert) {
                Button("削除", role: .destructive) { // 削除ボタンが押されたらquizzesArrayを空にする
                    quizzesArray.removeAll() // クイズデータを空にする
                    UserDefaults.standard.removeObject(forKey: "quiz") // クイズデータを削除
                }
                Button("キャンセル", role: .cancel) { } // キャンセルボタンが押されたら何もしない
            } message: {
                Text("本当に全てのクイズを削除しますか？") // メッセージを表示
            }
            
            List { // リストを表示
                ForEach(quizzesArray) { quiz in // クイズデータを表示
                    HStack { // 水平スタックを使用して要素を配置
                        Text("問題:") // テキストを表示
                        Text(quiz.question) // 問題を表示
                        Spacer() // スペースを確保
                        Text("解答: \(quiz.answer ? "○" : "×")") // 解答を表示
                    }
                }
                .onMove { indexSet, destination in // 移動ボタンが押されたらクイズデータを移動
                    var tempQuizzes = quizzesArray // 一時的な変数に保存
                    tempQuizzes.move(fromOffsets: indexSet, toOffset: destination)
                    
                    if saveQuizzes(tempQuizzes) { // エンコードが成功したら更新
                        quizzesArray = tempQuizzes
                    }
                }
                .onDelete { indexSet in // 削除ボタンが押されたらクイズデータを削除
                    var tempQuizzes = quizzesArray // 一時的な変数に保存
                    tempQuizzes.remove(atOffsets: indexSet)
                    
                    if saveQuizzes(tempQuizzes) { // エンコードが成功したら更新
                        quizzesArray = tempQuizzes
                    }
                }
            }
            .toolbar { // ツールバーを表示
                EditButton() // 編集ボタンを表示
            }
        }
    }
    
    func addQuiz(question: String, answer: String) { // 追加ボタンが押されたらクイズデータを追加
        if question.isEmpty { // 問題文が入力されていない場合
            alertMessage = "問題文が入力されていません" // アラートメッセージを設定
            showingAlert = true // アラートを表示
            return // 何もしない
        }
        
        var savingAnswer = true // 解答を保存する変数
        
        switch answer { // 解答を保存する
        case "○":
            savingAnswer = true // 解答を保存する
        case "×":
            savingAnswer = false // 解答を保存する
        default:
            print("適切な答えが入っていません") // 適切な答えが入っていない場合
            break // 何もしない
        }
        let newQuiz = Quiz(question: question, answer: savingAnswer) // 新しいクイズを作成
        
        var tempQuizzes = quizzesArray // 一時的な変数に保存
        tempQuizzes.append(newQuiz) // 新しいクイズを追加
        
        if saveQuizzes(tempQuizzes) { // エンコードが成功したら更新
            quizzesArray = tempQuizzes // クイズデータを更新
            questionText = "" // 問題文を空にする
        } else {
            alertMessage = "問題文の保存に失敗しました" // 保存に失敗した場合
            showingAlert = true // アラートを表示
        }
    }
    
    private func saveQuizzes(_ quizzes: [Quiz]) -> Bool { // クイズデータを保存する
        let storeKey = "quiz" // 保存するキー
        if let encodedQuizzes = try? JSONEncoder().encode(quizzes) { // エンコードが成功したら保存
            UserDefaults.standard.setValue(encodedQuizzes, forKey: storeKey) // クイズデータを保存
            return true // 保存に成功した場合
        }
        return false // 保存に失敗した場合
    }
}

#Preview {
    CreateView(quizzesArray: .constant([])) // プレビューを表示
}
