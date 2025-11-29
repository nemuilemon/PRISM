# Implementation Plan - 2025-11-29

## 概要
本計画は、PRISMの「Phase 1: MVP」の完了と「Phase 2: Philosophy Implementation」の初期実装を目的とします。
特に、トランザクション（取引）の記録機能と、PRISMの核となる「感情スコア」「自己投資フラグ」の統合に焦点を当てます。

## Phase 1.5: Transaction Core (取引機能の基盤)
**目的**: ユーザーが日々の収支を記録・閲覧できるようにする。

### 1. Domain Layer
- [x] **Entity**: `Transaction` entity (`lib/domain/entities/transaction.dart`) の作成 (Freezed)。
    - プロパティ: `id`, `accountId`, `amount`, `date`, `categoryId`, `emotionalScore`, `emotionalTag`, `isInvestment`, `note` (if any).
- [x] **Repository Interface**: `TransactionRepository` (`lib/domain/repositories/transaction_repository.dart`) の定義。
    - `Stream<List<Transaction>> watchTransactions()`
    - `Future<void> addTransaction(Transaction transaction)`
    - `Future<void> deleteTransaction(int id)`
    - `Future<void> updateTransaction(Transaction transaction)`

### 2. Data Layer
- [x] **Repository Implementation**: `TransactionRepositoryImpl` (`lib/data/repositories/transaction_repository_impl.dart`) の実装。
    - Driftの `Transactions` テーブルとの連携。
    - DTO (Drift Class) と Domain Entity の相互変換 (`Mapper`の作成推奨)。

### 3. Presentation Layer (State Management)
- [x] **Controller**: `TransactionListController` (`lib/presentation/controllers/transaction_list_controller.dart`) の作成。
    - `AsyncValue<List<Transaction>>` を管理。
    - 追加・削除メソッドの公開。

### 4. Presentation Layer (UI)
- [x] **Page**: `TransactionListPage` (`lib/presentation/pages/transaction/transaction_list_page.dart`)。
    - `NeumorphicContainer` を使用したリストアイテム。
    - 日付ごとのセクション分け。
    - **日本語化対応完了**。
    - **FABサイズ修正完了**。
- [x] **Page**: `AddTransactionPage` (`lib/presentation/pages/transaction/add_transaction_page.dart`)。
    - 入力フォーム:
        - 金額 (Amount) - 大きく表示
        - 日付 (Date) - DatePicker
        - 口座選択 (Account Selector) - Dropdown
        - メモ (Note)
    - **日本語化対応完了**。

## Phase 2: Philosophy Integration (哲学の実装)
**目的**: 支出に「感情」と「投資」の意味付けを行う。

### 1. UI Expansion (AddTransactionPage)
- [x] **Emotional Score Input**:
    - スライダー (-5 ~ +5)。
    - 選択時のインタラクション（色が変化するなど）。
- [x] **Investment Flag**:
    - 「自己投資（資産）」トグルスイッチ。
    - ONの場合、UI上で「Asset」として扱われる演出。

### 2. Logic Implementation
- [x] **Asset Calculation**:
    - 口座残高の動的計算（初期残高 + トランザクション合計）。
    - ※ 現状の `Accounts` テーブルには `balance` カラムがないため、トランザクションからの算出または `Accounts` へのカラム追加を検討（今回はトランザクション集計を採用予定）。

## Phase 3: Dashboard & Visualization (可視化)
**目的**: ユーザーに資産と感情の状態をフィードバックする。

### 1. Dashboard UI
- [x] **Home Page**:
    - 総資産表示 (Total Assets)。
    - 「無形資産（自己投資）」の分離表示。
    - 直近のトランザクション（簡易リスト）。

---

## 実行手順 (Step-by-Step Execution)

### Step 1: Transaction Domain & Data Layer
- [x] `lib/domain/entities/transaction.dart` 作成。
- [x] `lib/domain/repositories/transaction_repository.dart` 作成。
- [x] `lib/data/repositories/transaction_repository_impl.dart` 実装。

### Step 2: Transaction UI (Basic)
- [x] `TransactionListController` 実装。
- [x] `TransactionListPage` 実装 (FABで追加画面へ遷移)。
- [x] `AddTransactionPage` (Basic) 実装。
- [x] UI日本語化対応。
- [x] ナビゲーション順序変更（Transactions -> Accounts）。

### Step 3: Philosophy Features
- [x] `AddTransactionPage` に `EmotionalScore` と `InvestmentFlag` を追加。
- [x] DB保存処理の確認。

### Step 4: Logic & Dashboard (Current Focus)
- [x] **Asset Calculation Logic**:
    - `AccountRepository` に残高集計ロジックを追加（Driftの集計クエリ活用）。
    - `AccountListController` が残高付きのデータを返すように修正。
- [x] **Dashboard Page**:
    - `lib/presentation/pages/dashboard/dashboard_page.dart` 作成。

### Step 5: Refinement (Ad-hoc Requests)
- [x] **Income/Expense Separation**:
    - `Transactions` テーブルに `type` カラム追加。
    - `AddTransactionPage` に収入/支出切り替えトグル追加。
- [x] **Transaction Editing**:
    - `AddTransactionPage` を編集モードに対応。
    - `TransactionListPage` から編集画面への遷移追加。

## Phase 4: Advanced Features (Future)
- [x] **Category Management**: カテゴリ編集機能。
- [x] **Data Export**: CSV/JSONエクスポート。
- [x] **Data Import**: CSVインポート機能。