//
//  ContentView.swift
//  Marubatsu
//
//  Created by 佐藤幸久 on 2025/02/15.
//

import SwiftUI

// Quizの構造体
struct Quiz: Identifiable, Codable { // Identifiable: 一意のIDを持つ要素を識別するためのプロトコル、Codable: コードとデータの相互変換を可能にするプロトコル
    var id = UUID() // 一意のIDを生成
    var question: String // 問題の内容を格納するプロパティ
    var answer: Bool // 解答の内容を格納するプロパティ
}

struct ContentView: View { // Viewプロトコルを遵守するContentView構造体
    
    let quizExamples: [Quiz] = [
        Quiz(question: "iPhoneアプリを開発する統合環境はZcodeである", answer: false),
        Quiz(question: "Xcode画面の右側にはユーティリティーズがある", answer: true),
        Quiz(question: "Textは文字列を表示する際に利用する", answer: true),
    ]
    
    @AppStorage("quiz") var quizzeData = Data() // クイズデータをユーザーデフォルトに保存するためのプロパティ
    @State var quizzesArray: [Quiz] = [] // クイズデータを格納する配列  
    @State var currentQuestionNum: Int = 0 // 今、何問目の数字
    @State var showingAlert = false // アラート表示状態を管理するプロパティ
    @State var alertTitle = "" // アラートのタイトルを管理するプロパティ
    
    init() { // 初期化処理
        if let decodedQuizzes = try? JSONDecoder().decode([Quiz].self, from: quizzeData) { // デコードが成功した場合
            _quizzesArray = State(initialValue: decodedQuizzes) // デコードされたデータをquizzesArrayに設定
        }
    }
    
    var body: some View { // ビューを返す
        GeometryReader { geometry in // ジオメトリリーダーを使用して画面のサイズを取得
            NavigationStack { // ナビゲーションスタックを使用してナビゲーションを管理
                VStack { // 垂直スタックを使用して要素を配置
                    Text(showQuestion()) // 質問を表示
                        .padding()   // 余白の追加
                        .frame(width: geometry.size.width * 0.8, alignment: .leading) // 横幅を250、左寄せに
                        .font(.system(size: 25)) // フォントサイズを25に
                        .fontDesign(.rounded)    // フォントを丸みのあるものに
                        .background(.yellow)     // 背景を黄色に
                    
                    Spacer() // スペースを確保
                    
                    HStack { // 水平スタックを使用してボタンを配置
                        Button { // ボタンをクリックしたときのアクション
                            checkAnswer(yourAnswer: true) // 解答を確認
                        } label: { // ボタンのラベル
                            Text("○") // ボタンの表示文字
                        }
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4) // geometry.size.width * 0.4は画面の幅の40%,正方形
                        .font(.system(size: 100, weight: .bold)) // フォントサイズを100に、太字に
                        .foregroundStyle(.white) // テキストの色を白に
                        .background(.red) // 背景を赤色に
                        
                        Button { // ボタンをクリックしたときのアクション
                            checkAnswer(yourAnswer: false) // 解答を確認
                        } label: { // ボタンのラベル
                            Text("Ｘ") // ボタンの表示文字
                        }
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4) // geometry.size.width * 0.4は画面の幅の40%、正方形 
                        .font(.system(size: 100, weight: .bold)) // フォントサイズを100に、太字に
                        .foregroundStyle(.white) // テキストの色を白に
                        .background(.blue) // 背景を青色に
                    }
                }
                .padding() // 余白の追加
                .navigationTitle("マルバツクイズ") // ナビゲーションタイトルを設定
                .alert(alertTitle, isPresented: $showingAlert) { // アラートを表示
                    Button("OK", role: .cancel) {
                        // アラートを閉じる
                    }
                }
                .toolbar { // ツールバーを設定
                    ToolbarItem(placement: .topBarTrailing) { // ツールバーの右側に配置
                        NavigationLink { // ナビゲーションリンクを設定
                            CreateView(quizzesArray: $quizzesArray, currentQuestionNum: $currentQuestionNum) // CreateViewを表示
                                .navigationTitle("問題を作ろう") // ナビゲーションタイトルを設定
                                .onDisappear { // ビューが非表示になったときのアクション
                                    currentQuestionNum = 0 // 現在の問題番号を0に設定
                                }
                        } label: { // ボタンのラベル
                            Image(systemName: "plus") // プラスのアイコンを表示
                                .font(.title) // フォントサイズをタイトルに
                        }
                    }
                }
            }
        }
    }

    func showQuestion() -> String { // 問題を表示する関数
        var question = "問題がありません！" // 問題がない場合のメッセージ
        
        if !quizzesArray.isEmpty { // クイズが存在する場合
            let quiz = quizzesArray[currentQuestionNum] // 現在の問題を取得
            question = quiz.question // 問題を表示
        }

        return question // 問題を返す
    }

    func checkAnswer(yourAnswer: Bool) { // 解答を確認する関数
        if quizzesArray.isEmpty { return } // クイズが存在しない場合は何もしない
        let quiz = quizzesArray[currentQuestionNum] // 現在の問題を取得
        let ans = quiz.answer // 解答を取得
        if yourAnswer == ans { // 解答が正しい場合
            alertTitle = "正解" // アラートのタイトルを設定
            if currentQuestionNum + 1 < quizzesArray.count { // 次の問題が存在する場合
                currentQuestionNum += 1 // 次の問題に移動
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
