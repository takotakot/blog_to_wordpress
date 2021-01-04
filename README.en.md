## Tool to post blog posts to WordPress

## Features

This tool is designed to scrape a general blog and move it to WordPress. May be useful if you have a large number of post pages and manual work is difficult.
Not much thought has been given to (fixed) pages.

The major steps are follows:

- Download from existing sites
  - Download articles (scraping)
  - Parse the article and list images, etc. (referred to as media below)
  - Download images
- Upload to the new site
  - Prepare the article as a draft
  - Upload images
  - Rewrite the article (to the URL corresponding to the uploaded image)
  - Publish the article
.

From the actual code I wrote for the relocation, I have isolated the parts that depend on a particular site, and published the parts that are safe to publish.

There are still many parts that need to be refactored, but they are left not to spend my time. It's not the kind of tool to use for a long time...

Pull requests are welcome. If you have questions about how to use it, please create an Issue.

## Deployment

**Requirements:**

- **Ruby** 3.0.0 is tested
- **SQLite3** is tested

Because it uses SQLite3, it is not suitable for parallel processing.

If you use a database other than SQLite3, please be careful about the column size limit.

## Usage

## Preparation

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


#### Scraping

1. list traversal
    1. edit `app/controllers/application_controller.rb` etc. appropriately.
    2. `bin/rails c` and call the `ApplicationController.crawl_list_pages` method. `BlogPage::Base.crawl_list_page` will be called, and the URL of the article will be stored in the database in `BlogPage::Base.add_all_detail_uri`.
2. get individual articles
    1. edit `app/models/post.rb`.
      The `id` is embedded in the `get_page_title` and `article` methods. Prepare it beforehand so that it fits the target blog.
    2. Call the `ApplicationController.scrape_and_analyze_all_zero` method.
        ```ruby
        post.scrape
        post.analyze
        ```
        The scraping and analysis will be processced.
3. get media
    1. Call `ApplicationController.download_all_media_zero`.

#### Uploading

1. prepare the API  
    Prepare an API password in WordPress.
2. prepare DB
    ```ruby
    SecretLogicHelper.create_not_processed_wp_posts(status: 200, type_id: 10, limit: -1);
    ```
    By calling the method `create_not_processed_wp_posts` like this, prepare each post record in `WordpressPost`.
3. upload
    ```ruby
    SecretLogicHelper.proceed_wp_posts(limit: -1, status: 1..7);
    ```
    You can call the `proceed_wp_posts` method to post articles and upload media as follows.

## License

Released under the [MIT License](https://opensource.org/licenses/MIT).
