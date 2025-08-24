// File: Views/WelcomeView.swift
import SwiftUI

struct WelcomeView: View {
    @Binding var hasSeenWelcomeView: Bool
    
    var body: some View {
        // ZStack 允许我们将视图堆叠在一起，非常适合用来制作背景图 + 前景内容的效果
        ZStack {
            // MARK: - 背景图片
            // 1. 使用 Image("您的图片名称") 来加载 Assets 中的图片
            Image("chiropractor")
                .resizable() // 2. 让图片可以被调整大小
                .scaledToFill() // 3. 让图片填满整个萤幕（可能会有部分被裁切）
                .edgesIgnoringSafeArea(.all) // 4. 让图片延伸到萤幕的安全区域之外，实现全萤幕背景
                .overlay(Color.themeHighlight.opacity(0.4)) // 5. (可选) 在图片上覆盖一层半透明的黑色，让文字更清晰

            // MARK: - 前景内容
            VStack(spacing: 30) {
                Spacer() // 将所有内容向下推
                
                // 欢迎标题
                Text("歡迎使用\n醫療管家")
                    .font(.system(size:48,weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center) // 让文字居中对齐
                    .shadow(radius: 5) // (可选) 给文字加上阴影，增加立体感

                Spacer() // 在中间创造一些空间
                Spacer()

                Button(action: {
                    // 当按钮被点击时，我们执行这个动作：
                    // 将 hasSeenWelcomeView 的值设定为 true。
                    // 因为这是 @Binding，这个修改会立刻同步回 HealthGuardianApp.swift，
                    // 同时 AppStorage 也会自动将这个 true 的值永久储存起来。
                    // SwiftUI 会侦测到状态改变，并自动将画面切换到 ContentView。
                    self.hasSeenWelcomeView = true
                }) {
                    Text("開始使用")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.themeHighlight)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - 预览
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(hasSeenWelcomeView: .constant(false))
    }
}
