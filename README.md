# ブログ記事を WordPress に投稿するツール

## 特徴

一般的なブログをスクレイピングし、WordPress に移設するためのツールです。多数の記事ページがあり、手作業が大変な場合に役立つ可能性があります。
固定ページについては、あまり考えられてはいません。

大きな流れとしては：

- 既設サイトからのダウンロード
  - 記事のダウンロード（スクレイピング）
  - 記事を解析し、画像等（以下メディアとする）を列挙
  - 画像のダウンロード
- 新設サイトへのアップロード
  - 記事をドラフトとして準備
  - 画像をアップロード
  - 記事の書き換え（アップロード画像に対応する URL に）
  - 記事の公開

をするものです。

実際に移設のために書いたコードから、特定のサイトに依存する部分を分離し、公開して問題ない部分を公開しています。

リファクタリングをしたい箇所は数多く残っていますが、時間がもったいないのでそのままです。長期に使い続ける類のツールではないので…。

プルリクエストは歓迎です。また、使い方に疑問がある場合、Issue を建ててください。

## Deployment

**Requirements:**

- **Ruby** 3.0.0 is tested
- **SQLite3** is tested

SQLite3 を使っているため、並列処理には適していません。

SQLite3 以外のデータベースを利用する場合、カラムのサイズ上限に気を付けてください。

## Usage

### Preparation

Currently only `RAILS_ENV=development` is tested.

1. git colne

        $ bin/rails credentials:edit

2. bundle install

        $ cd blog_to_wordpress
        $ bundle install --path vendor/bundle

3. Database creation
    ```
    bin/rails db:create
    ```

4. Database initialization
    ```
    bin/rails db:migrate && bin/rails db:seed
    ```

5. Seve credentials like below:
    ```
    blog_domain: 'example.jp'
    wp_api_uri: 'https://example.jp/wp-json/wp/v2/'
    wp_api_username: 'wpadmin'
    wp_api_password: 'API_PASSWORD'
    ```

### Run

#### スクレイピング

1. 一覧の巡回
    1. `app/controllers/application_controller.rb` 等を適切に編集します。
    2. `bin/rails c` し、 `ApplicationController.crawl_list_pages`メソッドを呼び出してください。`BlogPage::Base.crawl_list_page` が呼ばれ、`BlogPage::Base.add_all_detail_uri`内で記事のURLがデータベースに格納されます。
2. 個別記事の取得
    1. `app/models/post.rb`を編集します。
      `get_page_title`や`article`メソッド内に、`id`が埋め込まれています。対象のブログに適合するように予め準備しておきます。
    2. `ApplicationController.scrape_and_analyze_all_zero`メソッドを呼び出してください。
        ```ruby
        post.scrape
        post.analyze
        ```
        という具合に、スクレイピングと解析が行われます。
3. メディアの取得
    1. `ApplicationController.download_all_media_zero`を呼び出してください。

#### アップロード

1. APIの準備  
    詳細は省略します。WordPressでAPIパスワードを発行しておきます。
2. DBの準備
    ```ruby
    SecretLogicHelper.create_not_processed_wp_posts(status: 200, type_id: 10, limit: -1);
    ```
    のように`create_not_processed_wp_posts`メソッドを呼び出すことで、`WordpressPost`に記事1つ1つと対応するレコードを準備します。
3. アップロード
    ```ruby
    SecretLogicHelper.proceed_wp_posts(limit: -1, status: 1..7);
    ```
    のように`proceed_wp_posts`メソッドを呼び出すことで、記事の投稿と、メディアのアップロードを行います。

## License

Released under the [MIT License](https://opensource.org/licenses/MIT).
