# typophile.github.io

本仓库包含一个简单的只读版 typophile 副本，由热爱之情重建而成。

# 实时站点: <http://typophile-archive.simon-cozens.org>

[Typophile](https://en.wikipedia.org/wiki/Typophile_(Internet_forum)) 是一个极棒的字体设计网络论坛，始创于 2000 年，一直运行到 2015 年。
它曾是字体设计和字体工程知识的宝库，涵盖了该领域在那个时期的每一个重要进展。
但它经常被垃圾邮件充斥，在完全关闭 6 个月后，遗憾的是，它似乎短期内不会回来了。

为了应对 typophile 的消逝，在 2016 年 1 月，以 SILE 闻名的 Simon Cozens 开发了一个脚本，用于从 [Archive.org Wayback Machine](https://web.archive.org) 下载存档，Dave Crossland 与他合作将原始材料转换成了这个站点。

## 您可以如何提供帮助

1. 留意那些尚未补全的细节（例如评论者姓名），并 [提交 issue](https://github.com/typophile/typophile.github.io/issues)。
   为了帮助找回细节，请使用 “view original” 链接查看原始 HTML，并找出能够识别它们的 CSS 选择器，以便将其提取。

2. 通过 [提交 issue](https://github.com/typophile/typophile.github.io/issues) 建议改进网站设计和提升可用性的方法。

3. 通过在 [issue #4](https://github.com/typophile/typophile.github.io/issues/4) 中发布链接并注明原因，让大家了解最重要的讨论帖。

4. 研究如何提取第二页或之后的讨论页面，详见 [Issue #2](https://github.com/typophile/typophile.github.io/issues/2)。

5. 审查并参与任何其他 [开放 issue](https://github.com/typophile/typophile.github.io/issues/)。

## 获取 HTML 文件

Wayback Machine 提供了一系列 API，其中之一是 [CDX Server API](https://github.com/internetarchive/wayback/tree/master/wayback-cdx-server)。
它可以列出从给定站点存档的所有 URI，可以通过如下方式调用 typophile：

    curl 'http://web.archive.org/cdx/search/cdx?url=*.typophile.com&fl=urlkey,timestamp' > urls.txt ;

这需要几分钟时间，并将返回其已知的所有 471,100 个 URL 的完整列表。
由于有 1,796 个重复项，我们可以将其删除：

    awk '{print $1}' urls.txt | sort | uniq > urls-unique.txt ;

要获取论坛讨论页面，请运行：

    grep '/node/' urls-unique.txt | grep -v cms | grep -v crss | perl wayback-typophile.pl

该脚本会创建一个 `typophile.com` 目录，其中包含每个页面在被抹除前最后一次存档时的副本。该目录的内容约 1.3Gb，因此不包含在本仓库中。

## 提取内容

接下来的阶段是对这些内容进行解析和索引。使用 `rake convert` 将 `typophile.com` 目录转换为充满 JSON 文件的目录。为了方便起见，此过程的输出已包含在仓库中。

## 索引内容

您现在需要一个 Elasticsearch 服务器和 [elasticsearch-fileimport](https://github.com/codecentric/elasticsearch-fileimport) 工具。使用 `mvn` 构建导入器，并将生成的 JAR 文件复制到此目录中。然后运行 `rake reindex`。（如果您使用的是 Homebrew，可能首先需要在 `file_import_settings.yml` 中添加以下内容：

    cluster:
        name: elasticsearch_youruserid

）

## 提供内容服务

随后，可以通过一个使用 [Sinatra](http://www.sinatrarb.com) 编写的前端搜索界面访问 Typophile 文章。安装 Sinatra（`bundle install` 应该可以完成所有操作），然后运行 `thin start`。瞧，您就拥有了自己的 Typophile 存档。

* * * 

> “字体排印的民主化”这一短语已变得常见，指的是字体和排版设计生产工具的广泛普及。
> 一个人对此可能会持怀疑态度：毕竟，对于大多数人来说，这些工具的生成和生产仍然在少数几家公司的掌握之中——尽管 [软件自由] 运动可能提供另一种选择。
> 准则依然是：怀疑、批判、理性和希望。

Robin Kinross, "Modern Typography" (2004, p.182, 最后一页)
