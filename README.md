# ⏱️ Just 1 Second

**ちょうど1秒でストップできるか?** あなたの反射神経と集中力を試すシンプルで中毒性のあるタイミングゲーム!

## 🎮 今すぐプレイ!

**👉 [https://sukimamieldesign.github.io/20260126_flutter/](https://sukimamieldesign.github.io/20260126_flutter/)**

> GitHub Pagesでホスティングされています。ブラウザで今すぐプレイできます!

## 🎮 ゲーム概要

「Just 1 Second」は、ストップウォッチをちょうど **1.00秒** で止めることを目指すミニマルなタイミングゲームです。シンプルなルールながら、奥深いゲーム性で何度も挑戦したくなります。

### ✨ 特徴

- 🎯 **シンプルなルール**: STARTボタンを押してタイマーを開始し、1.00秒ぴったりでSTOPを押すだけ
- 🏆 **連続成功システム**: 3回連続で成功すると「HALL OF FAME」達成!
- 💀 **ゲームオーバー**: 3回連続で失敗すると「GAME OVER」
- 🎨 **美しいUI**: ダークテーマのグラデーション背景と滑らかなアニメーション
- 📱 **レスポンシブデザイン**: Web、モバイル、デスクトップに対応
- ⚡ **PWA対応**: Progressive Web Appとしてインストール可能

## 🎲 ゲームルール

### 成功条件
- タイマーを **0.90秒 〜 1.10秒** の範囲で止めると成功 ✅
- それ以外は失敗 ❌

### スコアリング
- ✅ **連続成功**: 成功するたびにカウントアップ
- ❌ **連続失敗**: 失敗するたびにカウントアップ
- 🏆 **3回連続成功**: HALL OF FAME 達成!
- 👻 **3回連続失敗**: GAME OVER

## 🚀 セットアップ

### 必要要件
- Flutter SDK 3.10.7 以上
- Dart SDK

### インストール手順

1. リポジトリをクローン
```bash
git clone https://github.com/sukimamieldesign/20260126_flutter.git
cd 20260126_flutter
```

2. 依存関係をインストール
```bash
flutter pub get
```

3. アプリを起動

**Web版:**
```bash
flutter run -d chrome
```

**Linux版:**
```bash
flutter run -d linux
```

**その他のプラットフォーム:**
```bash
flutter devices  # 利用可能なデバイスを確認
flutter run -d <device-id>
```

## 🌐 PWAとしてビルド

```bash
flutter build web --release
```

ビルドされたファイルは `build/web/` ディレクトリに出力されます。

## 🎨 技術スタック

- **Flutter** - クロスプラットフォームUIフレームワーク
- **Dart** - プログラミング言語
- **Material Design 3** - デザインシステム
- **Custom Animations** - スケールアニメーションとトランジション

## 📱 スクリーンショット

### メイン画面
- 円形のストップウォッチディスプレイ
- グラデーションボタン（START/STOP）
- リアルタイムカウンター（成功/失敗）

### ゲーム状態
- 🎉 **SUCCESS**: 緑色のハイライトとアニメーション
- 💀 **FAILED**: 赤色のハイライト
- 🏆 **HALL OF FAME**: 金色の演出
- 👻 **GAME OVER**: リトライボタン表示

## 🎯 開発の背景

このプロジェクトは、シンプルながらも中毒性のあるゲーム体験を提供することを目的として開発されました。Flutter の強力なアニメーション機能と Material Design 3 を活用し、モダンで洗練されたUIを実現しています。

## 📝 ライセンス

このプロジェクトはプライベートプロジェクトです。

## 👤 作成者

**sukimamieldesign**
- GitHub: [@sukimamieldesign](https://github.com/sukimamieldesign)

---

**挑戦してみよう!** あなたは3回連続で1秒ぴったりを出せますか? 🎯
