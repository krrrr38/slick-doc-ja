slick-doc-ja 3.0
================

[Slick 3.0 documentation](http://slick.typesafe.com/doc/3.0.0/)の日本語訳です。

- 編集先: [GitHub - krrrr38/slick-doc-ja](https://github.com/krrrr38/slick-doc-ja)
- 連絡先: [@krrrr38](https://twitter.com/krrrr38)


他のバージョンのドキュメント
---------------------------
- [Slick 1.0 翻訳](http://krrrr38.github.io/slick-doc-ja/v1.0.out/slick-doc-ja+1.0.html)
- [Slick 2.0 翻訳](http://krrrr38.github.io/slick-doc-ja/v2.0.out/slick-doc-ja+2.0.html)
- Slick 3.0 翻訳

API Documentation (scaladoc)
---------------------------
- [Slick Core](http://slick.typesafe.com/doc/3.0.0/api/index.html) (slick)
- [TestKit](http://slick.typesafe.com/doc/3.0.0/testkit-api/index.html) (slick-testkit)
- [Code Generator](http://slick.typesafe.com/doc/3.0.0/codegen-api/index.html) (slick-codegen)
- [Direct Embedding](http://slick.typesafe.com/doc/3.0.0/direct-api/index.html) (slick-direct) (Deprecated)
- [Slick Extensions](http://slick.typesafe.com/doc/3.0.0/extensions-api/index.html) (slick-extensions)

Slick 3.0.0 documentation - 01 Introduction

[Permalink to Introduction — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/introduction.html)

Introduction
============

What is Slick
--------------
<!-- What is Slick -->

Slick ("Scala Language-Integrated Connection Kit")は[Typesafe社](http://www.typesafe.com)によってリレーショナルデータベースを簡単に扱うための、ScalaのFRM (Functional Relational Mapping)ライブラリである。まるでScalaのコレクションを扱うかのような操作でデータベースにアクセスし、データを操作出来る。SQLを直接扱うことも可能である。[Play](https://playframework.com/)や[Akka](http://akka.io/)を基にしたリアクティブアプリケーションに完璧にフィットするよう、データベースへの処理は非同期に実行される。

<!-- Slick ("Scala Language-Integrated Connection Kit") is [Typesafe](http://www.typesafe.com)'s Functional Relational Mapping (FRM) library for Scala that makes it easy to work with relational databases. It allows you to work with stored data almost as if you were using Scala collections while at the same time giving you full control over when a database access happens and which data is transferred. You can also use SQL directly. Execution of database actions is done asynchronously, making Slick a perfect fit for your reactive applications based on Play\_ and Akka\_. -->

```scala
val limit = 10.0
// クエリはこのように書く事が出来る
( for( c <- coffees; if c.price < limit ) yield c.name ).result
// こちらのSQLと等しい: select COF_NAME from COFFEES where PRICE < 10.0
```

SQLを直接書くのに比べ、Scalaを通してSQLを発行すると、コンパイル時により良いクエリを型安全に提供する事が出来る。Slickは独自のクエリコンパイラを用いてDBに対するクエリを発行する。

<!--When using Scala instead of SQL for your queries you profit from the compile-time safety(何これ) and compositionality. Slick can generate queries for different backends including your own, using its extensible query compiler. -->

すぐにSlickを試したいのなら、[Typesafe Activator](https://typesafe.com/activator)を利用して、[Hello Slick template](https://typesafe.com/activator/template/hello-slick-3.0)を試してみると良い。[こちら](http://slick.typesafe.com/doc/3.0.0/supported-databases.html)を読むと、Slickがコードを生成したり出来る、サポートされたデータベースの概要が分かる。

<!-- Get started learning Slick in minutes using the Hello Slick template\_ in Typesafe Activator\_. See here \<supported-databases\> for an overview of the supported database systems for which Slick can generate code. -->

Functional Relational Mapping
-----------------------------

関数型言語を用いるプログラマは長い間、リレーショナルデータベースを用いる際に、Object-RelationalとObject-Mathのミスマッチに悩まされてきた。Slickの新たなFRMのパラダイムは、Scalaを通して、疎結合で最小限の設定のみで、リレーショナルデータベースへ接続する複雑さを抽象化する事を可能にした。。

<!-- Functional programmers have long suffered Object-Relational and Object-Math impedance mismatches when connecting to relational databases. Slick's new Functional Relational Mapping (FRM) paradigm allows mapping to be completed within Scala, with loose-coupling, minimal configuration requirements, and a number of other major advantages that abstract the complexities away from connecting with relational databases. -->

我々はリレーショナルモデルと闘おうとはしていない。ただ、関数型のパラダイムを通してリレーショナルモデルを包み込んだのだ。オブジェクトモデルとデータベースモデルのギャップに対してのブリッジを作ることで、Scala側へデータベースモデルを持ち込み、結果としてエンジニアはSQLを書く必要がなくなった。

<!-- We don't try to fight the relational model, we embrace it through a functional paradigm. Instead of trying to bridge the gap between the object model and the database model, we've brought the database model into Scala so developers don't need to write SQL code. -->

```scala
lass Coffees(tag: Tag) extends Table[(String, Double)](tag, "COFFEES") {
  def name = column[String]("COF_NAME", O.PrimaryKey)
  def price = column[Double]("PRICE")
  def * = (name, price)
}
val coffees = TableQuery[Coffees]
```

Slickはデータベースに関する事柄を直接Scala側へと統合させる。そして、メモリ上のデータを操作するのと同じように、従来のScalaのクラスやコレクションを扱うかのように、クエリを発行して外部のデータを操作するのである。

<!-- Slick integrates databases directly into Scala, allowing stored and remote data to be queried and processed in the same way as in-memory data, using ordinary Scala classes and collections. -->

```scala
// nameカラムのみを取り出すクエリ (select NAME from COFFEES)
coffees.map(_.name)
...
// 10.0未満のpriceで絞り込んだクエリ (select * from COFFEES where PRICE < 10.0)
coffees.filter(_.price < 10.0)
```

これは、いつデータベースにアクセスしただとか、どのデータが変更されたかなどといったアクションを全てコントロール出来る。SlcikのFRMに含まれる言語に統合されたクエリモデルは、MicrosoftのLINQや、EricssonのMnesiaの早期のコンセプトに影響を受けている。

<!-- This enables full control over when a database is accessed and which data is transferred. The language integrated query model in Slick's FRM is inspired by the LINQ project at Microsoft and leverages concepts tracing all the way back to the early work of Mnesia at Ericsson. -->

関数型言語のためのSlickのFRMにおけるアプローチは、以下のようないくつかの利点を持っている:

<!-- Some of the key benefits of Slick's FRM approach for functional programming include: -->

- 事前最適化による効率化
<!-- -   Efficiency with Pre-Optimization -->

FRMはORMとは異なり、より効率的にデータベースへ接続を行う。これは、データベースとの接続を最適化する機能を備えているためであり、さらにFRMを用いる事であなたはその仕組みを知らなくても利用が出来る。より高速化されたアプリを作るためには、FRMはORMに比べ役に立つ。

<!-- FRM is more efficient way to connect; unlike ORM it has the ability to pre-optimize its communication with the database - and with FRM you get this out of the box. The road to making an app faster is much shorter with FRM than ORM. -->

- 型安全なため、迷惑なトラブルシューティングを行う必要が無い
<!-- -   No More Tedious Troubleshooting with Type Safety -->

FRMは型安全にデータベースのクエリを作成する事が出来る。今まで型のないただの文字列だけでエラーを探してきたデベロッパーにとっても、今や自動的にコンパイラがエラーを見つけてきてくれるのだ。

<!-- FRM brings type safety to building database queries. Developers are more productive because the compiler finds errors automatically versus the typical tedious troubleshooting required of finding errors in untyped strings. -->

`price`カラムのタイポがある場合には、コンパイラはこんな感じであなたにエラーを知らせてくれる。
<!-- Misspelled the column name `price`? The compiler will tell you: -->

```
GettingStartedOverview.scala:89: value prices is not a member of com.typesafe.slick.docs.GettingStartedOverview.Coffees
        coffees.map(_.prices).result
                      ^
```

他にも、こんな型エラーを知らせてくれる。
<!-- The same goes for type errors: -->

```
GettingStartedOverview.scala:89: type mismatch;
 found   : slick.driver.H2Driver.StreamingDriverAction[Seq[String],String,slick.dbio.Effect.Read]
    (which expands to)  slick.profile.FixedSqlStreamingAction[Seq[String],String,slick.dbio.Effect.Read]
 required: slick.dbio.DBIOAction[Seq[Double],slick.dbio.NoStream,Nothing]
        coffees.map(_.name).result
                            ^
```

- クエリを作成するための、より生産性のある組み立てしやすいモデル
<!-- -   A More Productive, Composable Model for Building Queries -->

FRMはクエリを作成するための組立可能なモデルをサポートしている。これはクエリを作るためにいくつかのピースを組み立てるのに非常に自然なモデルになっているし、コード内で再利用もしやすいようになっている。
<!-- FRM supports a composable model for building queries. It's a very natural model to compose pieces together to build a query, and then reuse pieces across your code base. -->

```scala
// priceが10未満で、name順にソートしたcoffeeの名前のみ取り出すクエリを作る
coffees.filter(_.price < 10.0).sortBy(_.name).map(_.name)
// select name from COFFEES where PRICE < 10.0 order by NAME
```

Reactive Applications
---------------------

Slickは非同期を中心にデザインされたアプリケーションや、[Reactive Manifesto](http://www.reactivemanifesto.org/)に従って作られたアプリケーションにとって非常に使いやすいようになっている。一般的なブロッキングするようなシンプルなデータベースAPIとは異なり、Slickは以下の事をあなたに提供する。
<!-- Slick is easy to use in asynchronous, non-blocking application designs, and supports building applications according to the Reactive Manifesto\_. Unlike simple wrappers around traditional, blocking database APIs, Slick gives you: -->

- I/OとCPUに処理が集中するコードを綺麗に分割している。I/O処理が分離されていることで、バックグラウンドでI/O処理を待っている間にアプリケーションはCPUに処理が集中する処理をメインスレッドで上手く動かす事が出来る。
- 即応性: データベースがあなたのアプリケーションを支えきれなくなった時、Slickは(状況を悪化させるような)必要以上のスレッドを作ったりはしないし、なんらかのI/O処理をロックしたりもしない。バックプレッシャーはデータベースI/Oアクションのためのキューを通して効率的に管理され、少ないリソースに対してはリクエストを制限し、もし限界に達したならば即座に失敗させる。
- 非同期ストリーミングのための、[Reactive Streams](http://www.reactive-streams.org/)
- データベースリソースの効率的な利用: Slickはあなたのデータベースサーバの並列度（同時にアクティブになっているジョブの数）やリソースの利用度（現在停止しているデータベースセッションの数）を簡単に、そして正確に調整させれる。
<!-- -   Clean separation of I/O and CPU-intensive code: Isolating I/O allows you to keep your main thread pool busy with CPU-intensive parts of the application while waiting for I/O in the background. -->
<!-- -   Resilience under load: When a database cannot keep up with the load of your application, Slick will not create more and more threads (thus making the situation worse) or lock out all kinds of I/O. Back-pressure is controlled efficiently through a queue (of configurable size) for database I/O actions, allowing a certain number of requests to build up with very little resource usage and failing immediately once this limit has been reached. -->
<!-- -   Reactive Streams\_ for asynchronous streaming. -->
<!-- -   Efficient utilization of database resources: Slick can be tuned easily and precisely for the parallelism (number of concurrent active jobs) and resource ussage (number of currently suspended database sessions) of your database server. -->

Plain SQL Support
-----------------

SlickのScalaベースなクエリAPIは、Scalaコレクションを扱うかのように、データベースクエリを記述することが出来る。[Getting Started](http://slick.typesafe.com/doc/3.0.0/gettingstarted.html)は、このAPIに焦点を当てたマニュアルになっている。
<!-- The Scala-based query API for Slick allows you to write database queries like queries for Scala collections. Please see gettingstarted for an introduction. Most of this user manual focuses on this API. -->

もし、あなたが独自のSQL文を通常のSlickのクエリと同様に非同期に実行したいと言うのならば、[Plain SQL](http://slick.typesafe.com/doc/3.0.0/sql.html) APIを利用する事が出来る。
<!-- If you want to write your own SQL statements and still execute them asynchronously like a normal Slick queries, you can use the Plain SQL\<sql\> API: -->

```scala
val limit = 10.0
sql"select COF_NAME from COFFEES where PRICE < $limit".as[String]
// 変数はSQLインジェクションが無いように自動的に束縛される
// select COF_NAME from COFFEES where PRICE < ?
```

License
-------

> Slick is released under a BSD-Style free and open source software [license](https://github.com/slick/slick/blob/3.0.0/LICENSE.txt). See the chapter on the commercial [Slick Extensions](http://slick.typesafe.com/doc/3.0.0/extensions.html) add-on package for details on licensing the Slick drivers for the big commercial database systems.

Next Steps
----------

- Slickを使うのが初めてならば、このまま[Getting Started](http://slick.typesafe.com/doc/3.0.0/gettingstarted.html)へ
- もし古いバージョンのSLickを使っていたならば、[Upgrade Guides](http://slick.typesafe.com/doc/3.0.0/upgrade.html)へ
- 以前にORMを利用していたならば、[Comming from ORM to Slick](http://slick.typesafe.com/doc/3.0.0/orm-to-slick.html)へ
- もしSQLに詳しいのならば、[Coming from SQL to Slick](http://slick.typesafe.com/doc/3.0.0/sql-to-slick.html)

<!-- -   If you are new to Slick, continue to Getting Started \<gettingstarted\> -->
<!-- -   If you have used an older version of Slick, make sure to read the Upgrade Guides \<upgrade\> -->
<!-- -   If you have used an ORM before, see Coming from ORM to Slick \<orm-to-slick\> -->
<!-- -   If you are familiar with SQL, see Coming from SQL to Slick \<sql-to-slick\> -->


Slick 3.0.0 documentation - 02 Supported Databases

[Permalink to Suppoerted Databases — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/supported-databases.html)

Supported Databases
===================

-   DB2 (via [slick-extensions](http://slick.typesafe.com/doc/3.0.0/extensions.html))
-   Derby/JavaDB
-   H2
-   HSQLDB/HyperSQL
-   Microsoft Access
-   Microsoft SQL Server (via [slick-extensions](http://slick.typesafe.com/doc/3.0.0/extensions.html)
-   MySQL
-   Oracle (via [slick-extensions](http://slick.typesafe.com/doc/3.0.0/extensions.html)
-   PostgreSQL
-   SQLite

様々なSQLデータベースへSlickなら簡単にアクセスする事が出来る。独自のSQLベースのバックエンドを持つデータベースも、プラグインを作成する事でSlickを利用することが出来ます。そのようなプラグインの作成は大きな貢献となります。NoSQLのような他のバックエンドを持つようなデータベースに関しては現在開発中であるため、まだ利用する事はできない。

<!-- Other SQL databases can be accessed right away with a reduced feature set. Writing a fully featured plugin for your own SQL-based backend can be achieved with a reasonable amount of work. Support for other backends (like NoSQL) is under development but not yet available. -->

特別な機能については、ドライバーによってサポートされているかが異なる。"Yes"は完全にサポートされているもの、その他は部分的にサポートされていたり、十分なサポートがされていないものである。個々のドライバーのAPIドキュメントについては、リンク先から確認して欲しい。

<!-- The following capabilities are supported by the drivers. "Yes" means that a capability is fully supported. In other cases it may be partially supported or not at all. See the individual driver's API documentation for details. -->

**訳注**
表が大きいため、[こちらのページ](http://slick.typesafe.com/doc/3.0.0/supported-databases.html)を直接参照して下さい。

Slick 3.0.0 documentation - 03 Getting Started

[Permalink to Getting Started — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/gettingstarted.html)

Getting Started
===============

Slickを試す最も簡単方法は、[Typesafe Activator](http://typesafe.com/activator)を使ってアプリケーションのテンプレートを作成することだ。以下のテンプレートはSlickのチームによって作られたものであり、Slickの新しいバージョンがリリースされる毎に更新されるだろう。

<!-- The easiest way to get started is with a working application in Typesafe Activator\_. The following templates are created by the Slick team, with updated versions being made for new Slick releases: -->

- Slickの基本を学びたいのなら、[Hello Slick template](https://typesafe.com/activator/template/hello-slick-3.0)から始めると良い。これはチュートリアルやこのページにあるコードを拡張したものを含んでいる。
- [Slick Plain SQL Queries template](https://typesafe.com/activator/template/slick-plainsql-3.0)はSlickを用いてどのようにしてクエリを実行させるかを知る事ができる。
- [Slick Multi-DB Patterns template](http://typesafe.com/activator/template/slick-multidb-3.0)は異なるデータベースシステムを用いたSlickのアプリケーションをどのようにして書くのか、まぁ特別なデータベース関数に対し、Slickのクエリをどのようにして取り扱うのかを学ぶ事ができる。
- [Slick TestKit Example template](https://typesafe.com/activator/template/slick-testkit-example-3.0)はあなたが独自に作成したSlickのドライバーをテストするSlick TestKitの使い方を教えてくれる。
<!-- -   To learn the basics of Slick, start with the Hello Slick template\_. It contains an extended version of the tutorial and code from this page. -->
<!-- -   The Slick Plain SQL Queries template\_ shows you how to do SQL queries with Slick. -->
<!-- -   The Slick Multi-DB Patterns template\_ shows you how to write Slick applications that can use different database systems and how to use custom database functions in Slick queries. -->
<!-- -   The Slick TestKit Example template\_ shows you how to use Slick TestKit to test your own Slick drivers. -->

これ以上にも、他のSlickのリリースにも対応した、コミュニティにより作られたSLickのテンプレートが数多く存在する。これらのテンプレートはTypesafeのウェブサイト上で、[all Slick templates](https://typesafe.com/activator/templates#filter:slick)から見つける事ができる。
<!-- There are more Slick templates created by the community, as well as versions of our own templates for other Slick releases. You can find [all Slick templates](https://typesafe.com/activator/templates#filter:slick) on the Typesafe web site. -->

Adding Slick to Your Project
----------------------------

Slickを既存のプロジェクトで利用するには、Maven Centralにあるライブラリを用いれば良い。sbtプロジェクトの場合、以下の記述を`build.sbt`や`project/Build.scala`に追加すれば良い。
<!-- To include Slick in an existing project use the library published on Maven Central. For sbt projects add the following to your build definition - `build.sbt` or `project/Build.scala`: -->

```scala
libraryDependencies ++= Seq(
  "com.typesafe.slick" %% "slick" % "|release|", "org.slf4j" %
  "slf4j-nop" % "1.6.4"
)
```

Mavenプロジェクトの場合`<dependencies>`へ以下のような記述を書き加える。Scalaのバージョンプレフィックス（`_2.10`、`_2.11`）を正しく付け加える必要がある。
<!-- For Maven projects add the following to your `<dependencies>` (make sure to use the correct Scala version prefix, `_2.10` or `_2.11`, to match your project's Scala version): -->

```
<dependency>
  <groupId>com.typesafe.slick</groupId>
  <artifactId>slick_2.10</artifactId>
  <version>3.0.0</version>
</dependency>
<dependency>
  <groupId>org.slf4j</groupId>
  <artifactId>slf4j-nop</artifactId>
  <version>1.6.4</version>
</dependency>
```

Slickは[SLF4J](http://www.slf4j.org/)をデバッグロギングのために利用しているため、SLF4Jの実装を持ったライブラリをあなたが選んで追加する必要がある。上の例では、ロギング出力を破棄するために、`slf4j-nop`を追加している。もし何かしらのログ出力が欲しいのならば、[Logback](http://logback.qos.ch/)のようなロギングフレームワークを`slf4j-nop`の代わりに追加して欲しい。
<!-- Slick uses SLF4J\_ for its own debug logging so you also need to add an SLF4J implementation. Here we are using `slf4j-nop` to disable logging. You have to replace this with a real logging framework like Logback\_ if you want to see log output. -->

リアクティブストリームAPIは自動的に追従的な依存で取得される。
<!-- The Reactive Streams API is pulled in automatically as a transitive dependency. -->

もしコネクションプールを用いたいのなら、[HikariCP](http://brettwooldridge.github.io/HikariCP/)の依存性を追加して欲しい。
<!-- If you want to use Slick's connection pool support, you need to add HikariCP\_ as a dependency. -->

Quick Introduction
------------------

> **Note**
>
> このチャプターの残り部分は、[Hello Slick template](https://typesafe.com/activator/template/hello-slick-3.0)を基にしています。[Activator](https://typesafe.com/activator)からコードを手元に用意して、編集・実行しながらチュートリアルを読むと良いでしょう。

Slickをりようするには、あなたの利用するデータベースに対応したAPIのimport文を以下のように書き加える必要がある。
<!-- To use Slick you first need to import the API for the database you will be using, like: -->

```scala
// H2データベースに接続するためのH2Driver
import slick.driver.H2Driver.api._
import scala.concurrent.ExecutionContext.Implicits.global
```

この例では[H2](http://h2database.com/)データベースを利用しているため、Slickの`H2Driver`をimportしている。ドライバーの`api`オブジェクトは[database handling](http://slick.typesafe.com/doc/3.0.0/database.html)のようなSlickの一般的なAPIを含んでいる。
<!-- Since we are using H2\_ as our database system, we need to import features from Slick's `H2Driver`. A driver's `api` object contains all commonly needed imports from the driver and other parts of Slick such as database handling \<database\>. -->

SlickのAPI、分離されたスレッドプールに置いて、全て非同期でデータベース処理を実行する。`DBIOAction`のコンポジションにおけるあなたのコードや`Future`の値を実行して取得するには、globalな`ExecutionContext`をインポートする必要がある。Slickを[Play](https://playframework.com/)や[Akka](http://akka.io/)を用いた大きなアプリケーションの一部として用いる場合には、そのようなフレームワークが提供しているより良い`ExecutionContext`を利用すべきだ。
<!-- Slick's API is fully asynchronous and runs database call in a separate thread pool. For running user code in composition of `DBIOAction` and `Future` values, we import the global `ExecutionContext`. When using Slick as part of a larger application (e.g. with Play\_ or Akka\_) the framework may provide a better alternative to this default `ExecutionContext`. -->

### Database Configuration

データベースに接続する方法を特定するために、アプリケーションの中で`Database`オブジェクトを作る必要がある。大抵の場合、[Typesafe Config](https://github.com/typesafehub/config)を用いて記述した`application.conf`からデータベースコネクションの設定を行うだろう。`application.conf`は[Play](https://playframework.com/)や[Akka](http://akka.io/)でも設定を記述するために用いられている。
<!-- In the body of the application we create a `Database` object which specifies how to connect to a database. In most cases you will want to configure database connections with Typesafe Config\_ in your `application.conf`, which is also used by Play\_ and Akka\_ for their configuration: -->

```
h2mem1 = {
  url = "jdbc:h2:mem:test1"
  driver = org.h2.Driver
  connectionPool = disabled
  keepAliveConnection = true
}
```

この例では、コネクションプールは用いないで、keep-alive接続をリクエストするように設定している（インメモリデータベースにコネクションプールは必要無いし、keep-aliveはデータベース利用中に接続を切らないようにするためである）。データベースオブジェクトは以下のように利用される。
<!-- For the purpose of this example we disable the connection pool (there is no point in using one for an embedded in-memory database) and request a keep-alive connection (which ensures that the database does not get dropped while we are using it). The database can be easily instantiated from the configuration like this: -->

```scala
val db = Database.forConfig("h2mem1")
try {
  // ...
} finally db.close
```

> ** Note**
>
> `Database`オブジェクトは通常スレッドプールとコネクションプールを管理する。必要がなくなった段階で、適切にシャットダウンすべきである（JVMプロセスが終了するしないに関わらず）。

### Schema

Slickのクエリを記述する前に、テーブル毎に`Table`と`TableQuery`を用いてデータベーススキーマを書く必要がある。直接手で書いても良いし、[code generator](http://slick.typesafe.com/doc/3.0.0/code-generation.html)を利用して既存のデータベーススキーマから自動生成しても良い。
<!-- Before we can write Slick queries, we need to describe a database schema with `Table` row classes and `TableQuery` values for our tables. You can either use the code generator \<code-generation\> to automatically create them for your database schema or you can write them by hand: -->

```scala
// SUPPLIERSテーブルの定義
class Suppliers(tag: Tag) extends Table[(Int, String, String, String, String, String)](tag, "SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey) // 主キー
  def name = column[String]("SUP_NAME")
  def street = column[String]("STREET")
  def city = column[String]("CITY")
  def state = column[String]("STATE")
  def zip = column[String]("ZIP")
  // 全てのテーブルで * 射影をテーブルの型パラメータに合うように定義する必要がある。
  def * = (id, name, street, city, state, zip)
}
val suppliers = TableQuery[Suppliers]
...
// COFFEESテーブルの定義
class Coffees(tag: Tag) extends Table[(String, Int, Double, Int, Int)](tag, "COFFEES") {
  def name = column[String]("COF_NAME", O.PrimaryKey)
  def supID = column[Int]("SUP_ID")
  def price = column[Double]("PRICE")
  def sales = column[Int]("SALES")
  def total = column[Int]("TOTAL")
  def * = (name, supID, price, sales, total)
  // joinなどを発行するために用いられる外部キー
  def supplier = foreignKey("SUP_FK", supID, suppliers)(_.id)
}
val coffees = TableQuery[Coffees]
```

全てのカラムは名前とScalaの型が必要になる。名前はSQL側では大文字とアンダースコアで、Scala側ではcamelCaseで記述される。SQLの型はScalaの型から自動的に導出される。テーブルオブジェクトにもScalaの名前とSQLの名前とその型が必要になる。テーブルの型引数は、`*`射影の型と合っている必要がある。このような単純な例でえは、全てのカラムをタプルで表現出来るが、より複雑なマッピングも可能である。
<!-- All columns get a name (usually in camel case for Scala and upper case with underscores for SQL) and a Scala type (from which the SQL type can be derived automatically). The table object also needs a Scala name, SQL name and type. The type argument of the table must match the type of the special `*` projection. In simple cases this is a tuple of all columns but more complex mappings are possible. -->

`coffees`テーブルの`foreignKey`の定義は、`supID`の値が、`suppliers`テーブルの`id`に存在している制約を保証するものである。ここでは`n:1`関係を作成している。1つの`Coffees`の列に対して、1つの`Suppliers`の列が対応しているが、複数の`Coffees`の列が同じ`Suppliers`の列を指し示す事もある。この制約はデータベースレベルで強制されるものである。
<!-- The `foreignKey` definition in the `coffees` table ensures that the `supID` field can only contain values for which a corresponding `id` exists in the `suppliers` table, thus creating an *n to one* relationship: A `Coffees` row points to exactly one `Suppliers` row but any number of coffees can point to the same supplier. This constraint is enforced at the database level. -->

### Populating the Database

インメモリのH2データベースエンジンへのコネクションは、空のデータベースを我々に提供してくれる。クエリを実行する前に、データベーススキーマ（`coffees`と`suppliers`テーブルを含む）を作成して、テストデータを挿入してみよう。
<!-- The connection to the embedded H2 database engine provides us with an empty database. Before we can execute queries, we need to create the database schema (consisting of the `coffees` and `suppliers` tables) and insert some test data: -->

```scala
val setup = DBIO.seq(
  // 主キーや外部キーを含むテーブルを作成
  (suppliers.schema ++ coffees.schema).create,
...
  // supplierをいくつか挿入
  suppliers += (101, "Acme, Inc.",      "99 Market Street", "Groundsville", "CA", "95199"),
  suppliers += ( 49, "Superior Coffee", "1 Party Place",    "Mendocino",    "CA", "95460"),
  suppliers += (150, "The High Ground", "100 Coffee Lane",  "Meadows",      "CA", "93966"),
  // 以下のSQLと等価
  // insert into SUPPLIERS(SUP_ID, SUP_NAME, STREET, CITY, STATE, ZIP) values (?,?,?,?,?,?)
...
  // coffeeをいくつか挿入（もしDBがサポートしてる場合にはバッチinsertが用いられる）
  coffees ++= Seq(
    ("Colombian",         101, 7.99, 0, 0),
    ("French_Roast",       49, 8.99, 0, 0),
    ("Espresso",          150, 9.99, 0, 0),
    ("Colombian_Decaf",   101, 8.99, 0, 0),
    ("French_Roast_Decaf", 49, 9.99, 0, 0)
  )
  // 以下のSQLと等価
  // insert into COFFEES(COF_NAME, SUP_ID, PRICE, SALES, TOTAL) values (?,?,?,?,?)
)
...
val setupFuture = db.run(setup)
```

`TableQuery`の`ddl`メソッドは、テーブルを作成・削除するため`DDL`(data definition language)オブジェクトを生成する。複数の`DDL`を`++`により結合した場合には、たとえ循環依存が存在したとしても、正しい順番に作成と削除を実行する。
<!-- The `TableQuery`'s `ddl` method creates `DDL` (data definition language) objects with the database-specific code for creating and dropping tables and other database entities. Multiple `DDL` values can be combined with `++` to allow all entities to be created and dropped in the correct order, even when they have circular dependencies on each other. -->

データの挿入には`+=`や`++=`が用いられる。これはScalaのミュータブルなコレクション操作APIとよく似ている。
<!-- Inserting the tuples of data is done with the `+=` and `++=` methods, similar to how you add data to mutable Scala collections. -->

`create`、`+=`、`++=`といったメソッドは、データベースへの処理の後に一定時間後に結果を生成する`Action`を返却する。複数の`Action`をシーケンスへと結合し、他の`Action`を生成ためのコンビネータがいくつか存在する。最もシンプルな方法は、`Action.seq`であり、これは複数の`Action`を順に結合し、結果を破棄するものである。例として、`Action`が`Unit`を返却する場合などに用いる。準備された`Action`は`db.run`により実行され、`Future[Unit]`が生成される。
<!-- The `create`, `+=` and `++=` methods return an `Action` which can be executed on a database at a later time to produce a result. There are several different combinators for combining multiple Actions into sequences, yielding another Action. Here we use the simplest one, `Action.seq`, which can concatenate any number of Actions, discarding the return values (i.e. the resulting Action produces a result of type `Unit`). We then execute the setup Action asynchronously with `db.run`, yielding a `Future[Unit]`. -->

> **Note**
>
> データベースのコネクションとトランザクションはSLickにより自動的に管理される。デフォルトでは、*auto-commit*モードの際にはコネクションは都度開放される。このモードでは、外部キーの影響により、`suppliers`テーブルのデータを`coffees`のデータより先に挿入しなくてはならない。明示的なトランザクションブラケットで内包された処理を実行することもできる（`db.run(setup.transactionally)`）。そのような記述を行う際には、トランザクションがコミットされる際にのみ制約が課せられるため、記述時の順序などを気にする必要はない。

### Querying

テーブルからデータをイテレートさせる最もシンプルな方法を見てみよう。
<!-- The simplest kind of query iterates over all the data in a table: -->

```scala
// 全てのcoffeeを読み込んで、コンソールに出力する
println("Coffees:")
db.run(coffees.result).map(_.foreach {
  case (name, supID, price, sales, total) =>
    println("  " + name + "\t" + supID + "\t" + price + "\t" + sales + "\t" + total)
})
// 以下のSQLと等価
// select COF_NAME, SUP_ID, PRICE, SALES, TOTAL from COFFEES
```

上の例は`SELECT * FROM COFFEES`というSQLと等価である（ただしこれは`*`がテーブルに定義された`*`射影と等しいためである）。ループの中で得られる型は、まぁ驚くこともなく、`Coffees`の型引数と同じものになる。
<!-- This corresponds to a `SELECT * FROM COFFEES` in SQL (except that the `*` is the table's `*` projection we defined earlier and not whatever the database sees as `*`). The type of the values we get in the loop is, unsurprisingly, the type parameter of `Coffees`. -->

基本的なクエリに対し、射影を追加してみよう。ここでは、Scalaの`map`メソッドか、`for`式が用いて記述される。
<!-- Let's add a *projection* to this basic query. This is written in Scala with the `map` method or a *for comprehension*: -->

```scala
// Why not let the database do the string conversion and concatenation?
val q1 = for(c <- coffees)
  yield LiteralColumn("  ") ++ c.name ++ "\t" ++ c.supID.asColumnOf[String] ++
    "\t" ++ c.price.asColumnOf[String] ++ "\t" ++ c.sales.asColumnOf[String] ++
    "\t" ++ c.total.asColumnOf[String]
// 最初の文字列は、自動的に`LiteralColumn`へ持ち上げられる
...
// これは以下のSQLと等価になる
// select '  ' || COF_NAME || '\t' || SUP_ID || '\t' || PRICE || '\t' SALES || '\t' TOTAL from COFFEES
...
db.stream(q1.result).foreach(println)
```

出力は同じで、全てのカラムがタブで区切られて結合されたものになる。異なるのは、データベースエンジン内で行われた処理のみで、結果は全く変わらないまま得られる。注意して欲しいのは、ここではScalaの`+`オペレータは使わずに`++`を用いている。また、他の型から文字列への自動的な変換は存在しない。ここでは明示的に`asColumnOf`を用いて変換を行っている。
<!-- The output will be the same: For each row of the table, all columns get converted to strings and concatenated into one tab-separated string. The difference is that all of this now happens inside the database engine, and only the resulting concatenated string is shipped to the client. Note that we avoid Scala's `+` operator (which is already heavily overloaded) in favor of `++` (commonly used for sequence concatenation). Also, there is no automatic conversion of other argument types to strings. This has to be done explicitly with the type conversion method `asColumnOf`. -->

[Reactive Streams](http://www.reactive-streams.org/)でも、データベースから値をストリームとして取り出し、全ての結果を得る前に順に出力させるという事が出来る。
<!-- This time we also use Reactive Streams\_ to get a streaming result from the database and print the elements as they come in instead of materializing the whole result set upfront. -->

テーブルの結合とフィルタリングは、Scalaのコレクション操作と同様の記述で行える。
<!-- Joining and filtering tables is done the same way as when working with Scala collections: -->

```scala
// 9.0未満のpriceのcoffeeから、coffeeの名前とsupplierの名前をjoinを用いて取得する
val q2 = for {
  c <- coffees if c.price < 9.0
  s <- suppliers if s.id === c.supID
} yield (c.name, s.name)
// 以下のSQLと等価
// select c.COF_NAME, s.SUP_NAME from COFFEES c, SUPPLIERS s where c.PRICE < 9.0 and s.SUP_ID = c.SUP_ID
```

> **Warning**
>
> 2つの値の比較には、`==`の代わりに`===`を、`!=`の代わりに`=!=`を用いて欲しい。なぜならこれは既に`Any`を基に実装されたオペレータであり、拡張することが出来ないためである。`<`、`<=`、`>=`、`>`のような比較オペレータはそのままのものを用いる事が出来る。

`suppliers if s.id === c.supID`という表現あ、`Coffees.supplier`という外部キーを用いる事で、書き換える事ができる。joinの条件を繰り返し書く代わりに、外部キーを直接記述すれば良いのである。
<!-- The generator expression `suppliers if s.id === c.supID` follows the relationship established by the foreign key `Coffees.supplier`. Instead of repeating the join condition here we can use the foreign key directly: -->

```scala
val q3 = for {
  c <- coffees if c.price < 9.0
  s <- c.supplier
} yield (c.name, s.name)
// 以下のSQLと等価
// select c.COF_NAME, s.SUP_NAME from COFFEES c, SUPPLIERS s where c.PRICE < 9.0 and s.SUP_ID = c.SUP_ID
```

Slick 3.0.0 documentation - 04 Database Configuration

[Permalink to Database Configuration — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/database.html)

Database Configuration
======================

どのようにしてデータベースへ接続するかを、[Database](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.JdbcBackend@Database:Database)オブジェクトを作成する際に情報を内包して、Slickに教えてあげなくてはならない。_slick.jdbc.JdbcBackend.Database_ のためのいくつかの[factory methods](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.JdbcBackend$DatabaseFactoryDef)が存在する。
<!-- You can tell Slick how to connect to the JDBC database of your choice by creating a Database <slick.jdbc.JdbcBackend@Database:Database> object, which encapsulates the information. There are several factory methods <slick.jdbc.JdbcBackend$DatabaseFactoryDef> on slick.jdbc.JdbcBackend.Database that you can use depending on what connection data you have available. -->

Using Typesafe Config
---------------------

[Play](https://playframework.com/)や[Akka](http://akka.io/)で使われてる`application.conf`に、[Typesafe Config](https://github.com/typesafehub/config)でデータベースに接続する設定を記述するのを推奨する。
<!-- The prefered way to configure database connections is through Typesafe Config\_ in your `application.conf`, which is also used by Play\_ and Akka\_ for their configuration. -->

```scala
mydb = {
  dataSourceClass = "org.postgresql.ds.PGSimpleDataSource"
  properties = {
    databaseName = "mydb"
    user = "myuser"
    password = "secret"
  }
  numThreads = 10
}
```
_Database.forConfig_ を用いて、設定を読み込むことができる。引数などの詳細については[API documentation][API documentation]を見て欲しい。
<!-- Such a configuration can be loaded with Database.forConfig (see the API documentation <slick.jdbc.JdbcBackend$DatabaseFactoryDef@forConfig(String,Config,Driver):Database> of this method for details on the configuration parameters). -->

```scala
val db = Database.forConfig("mydb")
```

Using a JDBC URL
----------------
JDBC URLは[forURL][forURL]に渡してあげる（URLについては各種利用するデータベースのJDBCドライバーのドキュメントを読んで欲しい）。
<!-- You can pass a JDBC URL to forURL <slick.jdbc.JdbcBackend$DatabaseFactoryDef@forURL(String,String,String,Properties,String,AsyncExecutor,Boolean):DatabaseDef>. (see your database's JDBC driver's documentation for the correct URL syntax). -->

```scala
val db = Database.forURL("jdbc:h2:mem:test1;DB_CLOSE_DELAY=-1", driver="org.h2.Driver")
```

ここでは、JVMが終了するまで使うことの出来る`test1`という名前の、新しい空のインメモリH2データベースへの情報を記述し、接続を作っている（`DB_CLOSE_DELAY=-1`ってのはH2データベース特有の設定だ）。
<!-- Here we are connecting to a new, empty, in-memory H2 database called `test1` and keep it resident until the JVM ends (`DB_CLOSE_DELAY=-1`, which is H2 specific). -->

Using a DataSource
------------------
[DataSource](http://docs.oracle.com/javase/7/docs/api/javax/sql/DataSource.html)は、[forDataSource][forDataSource]に渡してあげる。これは、アプリケーションフレームワークのコネクションプールから得られたものを、Slickのプールへと繋げている。
<!-- You can pass a DataSource <javax/sql/DataSource> object to forDataSource <slick.jdbc.JdbcBackend$DatabaseFactoryDef@forDataSource(DataSource,AsyncExecutor):DatabaseDef>. If you got it from the connection pool of your application framework, this plugs the pool into Slick. -->

```scala
val db = Database.forDataSource(dataSource: javax.sql.DataSource)
```

Using a JNDI Name
-----------------
もし[JNDI](http://en.wikipedia.org/wiki/JNDI)を使っているのならば、[DataSource](http://docs.oracle.com/javase/7/docs/api/javax/sql/DataSource.html)オブジェクトを見つけられるように、JNDIの名前を[forName](forName)へ渡してあげたら良い。
<!-- If you are using JNDI you can pass a JNDI name to forName <slick.jdbc.JdbcBackend$DatabaseFactoryDef@forName(String,AsyncExecutor):DatabaseDef> under which a DataSource <javax/sql/DataSource> object can be looked up. -->

```scala
val db = Database.forName(jndiName: String)
```

Database thread pool
--------------------
どの`Database`も、データベースのI/O Actionを非同期に実行するためのスレッドプールを管理する[AsyncExecutor](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.util.AsyncExecutor)を保持している。そのサイズは、`Database`オブジェクトが最も良いパフォーマンスを出せるように調整されたものとなる。昔からある同期的なアプリケーションなどにおいては、コネクションプール数を調整すべきだ（[HikariCP](http://brettwooldridge.github.io/HikariCP/)の[About Pool Sizing](https://github.com/brettwooldridge/HikariCP/wiki/About-Pool-Sizing)などのドキュメントも参考にして欲しい）。[Database.forConfig][Database.forConfig]を用いると、スレッドプールは、直接外部の設定からコネクションパラメータなどと一緒に設定する事が出来る。もし`Database`を取得するのに、その他のファクトリーメソッドを用いているのなら、デフォルトの設定をそのまま用いるか、`AsyncExecutor`をカスタマイズして利用して欲しい。
<!-- Every `Database` contains an slick.util.AsyncExecutor that manages the thread pool for asynchronous execution of Database I/O Actions. Its size is the main parameter to tune for the best performance of the `Database` object. It should be set to the value that you would use for the size of the *connection pool* in a traditional, blocking application (see About Pool Sizing\_ in the HikariCP\_ documentation for further information). When using Database.forConfig <slick.jdbc.JdbcBackend$DatabaseFactoryDef@forConfig(String,Config,Driver):Database>, the thread pool is configured directly in the external configuration file together with the connection parameters. If you use any other factory method to get a `Database`, you can either use a default configuration or specify a custom AsyncExecutor: -->

```scala
val db = Database.forURL("jdbc:h2:mem:test1;DB_CLOSE_DELAY=-1", driver="org.h2.Driver",
  executor = AsyncExecutor("test1", numThreads=10, queueSize=1000))
```

Connection pools
----------------

コネクションプールを用いているのなら（プロダクション環境などでは利用していると思うが...）、コネクションプール数の最小値は少なくとも同じ数分だけ設定すべきである。（`When using a connection pool the minimum size of the connection pool should also be set to at least the same size.`）コネクションプール数の最大値については、同期的なアプリケーションにおいて利用される数より多めの値を設定するのが良い。スレッドプール数を超えるコネクションは、データベースセッションをオープンし続けるために他のコネクションが要求された際に用いられる事になる（例として、トランザクション中の非同期的な計算結果を待っている時など）。
<!-- When using a connection pool (which is always recommended in production environments) the *minimum* size of the *connection pool* should also be set to at least the same size. The *maximum* size of the *connection pool* can be set much higher than in a blocking application. Any connections beyond the size of the *thread pool* will only be used when other connections are required to keep a database session open (e.g. while waiting for the result from an asynchronous computation in the middle of a transaction) but are not actively doing any work on the database. -->

ちなみに、[Database.forConfig][Database.forConfig]を利用した際には、スレッドプール数をもとに系あsんされたコネクションプール数がデフォルト値として提供される。
<!-- Note that reasonable defaults for the connection pool sizes are calculated from the thread pool size when using Database.forConfig <slick.jdbc.JdbcBackend$DatabaseFactoryDef@forConfig(String,Config,Driver):Database>. -->

Slickはプリペアドステートメントを利用可能な場所では利用しているものの、Slick側でそれらをキャッシュしていない。それゆえ、あなた自身でコネクションプールの設定時にプリペアドステートメントのキャッシュを有効化して欲しい。
<!-- Slick uses *prepared* statements wherever possible but it does not cache them on its own. You should therefore enable prepared statement caching in the connection pool's configuration. -->

DatabaseConfig
--------------

`Database`の設定のトップにおいて、[DatabaseConfig](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.backend.DatabaseConfig)のフォーム内にSlickドライバーに合う`Database`を追加する設定も置くことが出来る。これを利用すると、異なるデータベースを利用する上で、簡単に設定ファイルを変更出来るようにするための抽象化が簡単に行える。
<!-- On top of the configuration syntax for `Database`, there is another layer in the form of slick.backend.DatabaseConfig which allows you to configure a Slick driver plus a matching `Database` together. This makes it easy to abstract over different kinds of database systems by simply changing a configuration file. -->

`driver`にSlickのドライバーを、`db`にデータベースの設定を記述した`DatabaseConfig`の例は次のようになる。
<!-- Here is a typical `DatabaseConfig` with a Slick driver object in `driver` and the database configuration in `db`: -->

```
tsql {
  driver = "slick.driver.H2Driver$"
  db {
    connectionPool = disabled
    driver = "org.h2.Driver"
    url = "jdbc:h2:mem:tsql1;INIT=runscript from 'src/main/resources/create-schema.sql'"
  }
}
```

[API documentation]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.JdbcBackend$DatabaseFactoryDef@forConfig(String,Config,Driver):Database
[forURL]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.JdbcBackend$DatabaseFactoryDef@forURL(String,String,String,Properties,String,AsyncExecutor,Boolean):DatabaseDef
[forDataSource]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.JdbcBackend$DatabaseFactoryDef@forDataSource(DataSource,AsyncExecutor):DatabaseDef
[Database.forConfig]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.JdbcBackend$DatabaseFactoryDef@forConfig(String,Config,Driver):Database

Slick 3.0.0 documentation - 05 Database I/O Actions

[Permalink to Database I/O Actions — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/dbio.html)

Database I/O Actions
====================

クエリの結果を取得したり（`myQuery.result`）、テーブルを作成したり（`myTable.schema.create`）、データを挿入する（`myTable += item`）といったデータベースに対して実行する全ての事柄は、[DBIOAction](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction)のインスタンスで表される。
<!-- Anything that you can execute on a database, whether it is a getting the result of a query (`myQuery.result`), creating a table (`myTable.schema.create`), inserting data (`myTable += item`) or something else, is an instance of slick.dbio.DBIOAction, parameterized by the result type it will produce when you execute it. -->

_Database I/O Actions_ はいくつかの異なるコンビネータにより結合されるが（詳細は[DBIOAction class](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction)と[DBIO object](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIO$)で）、それらはいつも直列に実行され、（少なくとも概念上は）1つのデータベースセッションにおいて実行される。
<!-- *Database I/O Actions* can be combined with several different combinators (see the DBIOAction class \<slick.dbio.DBIOAction\> and DBIO object \<slick.dbio.DBIO$\> for details), but they will always be executed strictly sequentially and (at least conceptually) in a single database session. -->

大抵の場合、[DBIO](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.package@DBIO[+R]:DBIO[R])の型エイリアスを通常時のデータベースI/Oアクションとして、[StreamingDBIO](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.package@StreamingDBIO[+R,+T]:StreamingDBIO[R,T])の型エイリアスををストリーミング可能なデータベースI/Oアクションとして利用したいと思うだろう。これらは、[DBIOAction](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction)によって与えられる副次的な _effect types_ を省略する。
<!-- In most cases you will want to use the type aliases DBIO \<slick.dbio.package@DBIO[+R]:DBIO[R]\> and StreamingDBIO \<slick.dbio.package@StreamingDBIO[+R,+T]:StreamingDBIO[R,T]\> for non-streaming and streaming Database I/O Actions. They omit the optional *effect types* supported by slick.dbio.DBIOAction.  -->

Executing Database I/O Actions
------------------------------

`DBIOActions`はデータベースから得られた具象化された結果やストリーミングデータを生み出すために実行されるものである。
<!-- `DBIOAction`s can be executed either with the goal of producing a fully materialized result or streaming data back from the database. -->

### Materialized

データベースに対し`DBIOAction`を実行し、具象化された結果を得るには`run`を用いる。これは例えば、単一のクエリ結果を引く場合（`myTable.length.result`）、コレクションを結果として得るクエリを引く場合（`myTable.to[Set].result`）などに利用される。どの`DBIOAction`もこのような実行処理をサポートしている。
<!-- You can use `run` to execute a `DBIOAction` on a Database and produce a materialized result. This can be, for example, a scalar query result (`myTable.length.result`), a collection-valued query result (`myTable.to[Set].result`), or any other action. Every `DBIOAction` supports this mode of execution. -->

`run`が呼ばれた時に、アクションの実行が開始される。そして具象化された結果は非同期に処理が実行され終了されるものとして、`Future`にくるまって返却される。
<!-- Execution of the action starts when `run` is called, and the materialized result is returned as a `Future` which is completed asynchronously as soon as the result is available: -->

```scala
val q = for (c <- coffees) yield c.name
val a = q.result
val f: Future[Seq[String]] = db.run(a)
f.onSuccess { case s => println(s"Result: $s") }
```

### Streaming

コレクションが得られるクエリにはストリーミングの結果を返却する機能が備わっている。この場合、実際のコレクションの型は虫され、要素が直接[Reactive Streams](http://www.reactive-streams.org/)の`Publisher`を通して返却されることになる。これは[Akka Streams](http://akka.io/docs/)により処理・計算されたものとなる。
<!-- Collection-valued queries also support streaming results. In this case, the actual collection type is ignored and elements are streamed directly from the result set through a Reactive Streams\_ `Publisher`, which can be processed and consumed by Akka Streams\_. -->

`DBIOAction`の実行処理は、`Subscriber`をストリームに繋げるまで実行されない。`Subscriber`1つのみサポートされており、それ以上の _購読_ を行おうとするとそれらは失敗してしまう。ストリームの各要素は、`DBIOAction`のストリーミング部分において利用出来る状態になるとすぐに、実行可能であると合図を送る。例えばトランザクションの中でストリーミング処理を行った場合にも、全ての要素は正常に届けられ、トランザクションがコミットされなかった場合にもきちんとストリームも失敗するようにできている。
<!-- Execution of the `DBIOAction` does not start until a `Subscriber` is attached to the stream. Only a single `Subscriber` is supported, and any further attempts to subscribe again will fail. Stream elements are signaled as soon as they become available in the streaming part of the `DBIOAction`. The end of the stream is signaled only after the entire action has completed. For example, when streaming inside a transaction and all elements have been delivered successfully, the stream can still fail afterwards if the transaction cannot be committed. -->

```scala
val q = for (c <- coffees) yield c.name
val a = q.result
val p: DatabasePublisher[String] = db.stream(a)
...
// .foreach is a convenience method on DatabasePublisher.
// Use Akka Streams for more elaborate stream processing.
p.foreach { s => println(s"Element: $s") }
```

JDBCの結果集合をストリーミングする際、もし`Subscriber`が多くのデータを受け取る準備が出来ていないのなら、次の結果ページはバックグラウンドにバッファリングされる。一方で、全ての結果要素は同期的に渡されるし、結果集合は同期処理が終了する前に先に進んでしまったりはしない。これにより、結果集合の状態に依存する`Blob`のようなJDBCの低レベルな値に対しても同期的なコールバックが利用可能となる。`mapResult`のような便利なメソッドがこの目的のために提供されている。
<!-- When streaming a JDBC result set, the next result page will be buffered in the background if the Subscriber is not ready to receive more data, but all elements are signaled synchronously and the result set is not advanced before synchronous processing is finished. This allows synchronous callbacks to low-level JDBC values like `Blob` which depend on the state of the result set. The convenience method `mapResult` is provided for this purpose: -->

```scala
val q = for (c <- coffees) yield c.image
val a = q.result
val p1: DatabasePublisher[Blob] = db.stream(a)
val p2: DatabasePublisher[Array[Byte]] = p1.mapResult { b =>
  b.getBytes(0, b.length().toInt)
}
```

### Transactions and Pinned Sessions

いくつかの小さいアクションで構成された`DBIOAction`を実行する際には、Slickはコネクションプールから得られたセッションを要求し、その後セッションを開放する。データベース外の計算から結果を得るのを待ち合わせる間（例えば、[flatMap][flatMap]）、不必要なセッションは保持されない。データベースに計算させることなく、2つのデータベースのアクションを結合する[DBIOAction combinators](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction)（[andThen][andThen]や[zip][zip]）は、1つのセッション内で融合されたアクションを実行する副作用を伴いつつ、より効率的にこれらのアクションを融合する。1つのセッションでの利用を強制するには、[withPinnedSession](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction@withPinnedSession:DBIOAction[R,S,E])を利用すれば良い。これを用いる事で、データベース外での計算を待ち合わせる際に、既存のセッションを開き続けたままにしておくことが出来る。
<!-- When executing a `DBIOAction` which is composed of several smaller actions, Slick acquires sessions from the connection pool and releases them again as needed so that a session is not kept in use unnecessarily while waiting for the result from a non-database computation (e.g. the function passed to flatMap \<slick.dbio.DBIOAction@flatMap[R2,S2\<:NoStream,E2\<:Effect]((R)⇒DBIOAction[R2,S2,E2])(ExecutionContext):DBIOAction[R2,S2,EwithE2]\> that determines the next Action to run). All DBIOAction combinators \<slick.dbio.DBIOAction\> which combine two database actions without any non-database computations in between (e.g. andThen \<slick.dbio.DBIOAction@andThen[R2,S2\<:NoStream,E2\<:Effect](DBIOAction[R2,S2,E2]):DBIOAction[R2,S2,EwithE2]\> or zip \<slick.dbio.DBIOAction@zip[R2,E2\<:Effect](DBIOAction[R2,NoStream,E2]):DBIOAction[(R,R2),NoStream,EwithE2]\>) can fuse these actions for more efficient execution, with the side-effect that the fused action runs inside a single session. You can use withPinnedSession \<slick.dbio.DBIOAction@withPinnedSession:DBIOAction[R,S,E]\> to force the use of a single session, keeping the existing session open even when waiting for non-database computations. -->

トランザクションの利用を強制する[transactionally](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcActionComponent$JdbcActionExtensionMethods@transactionally:DBIOAction[R,S,EwithTransactional])と呼ばれるコンビネータもある。これは、実行される`DBIOAction`の処理全体が自動的に成功か失敗のいずれかに収まる。
<!-- There is a similar combinator called transactionally \<slick.driver.JdbcActionComponent$JdbcActionExtensionMethods@transactionally:DBIOAction[R,S,EwithTransactional]\> to force the use of a transaction. This guarantees that the entire `DBIOAction` that is executed will either succeed or fail atomically. -->

> **Warning**
>
> 失敗というのは`transactionally`でラップされた個々の`DBIOAction`のアトミック性を保証するものでは無いため、この時点でエラー回復を図るコンビネータを適用すべきではない。作成されたデータベース側のトランザクションは、`transactionally`アクションの外側でコミットやロールバックを行う。

```scala
val a = (for {
  ns <- coffees.filter(_.name.startsWith("ESPRESSO")).map(_.name).result
  _ <- DBIO.seq(ns.map(n => coffees.filter(_.name === n).delete): _*)
} yield ()).transactionally
val f: Future[Unit] = db.run(a)
```

JDBC Interoperability
---------------------

Slickで利用出来ない機能を使うためにJDBCのレベルを落とすには、`SimpleDBIO`アクションを用いれば良い。これは、データベースのスレッド上で実行され、JDBCの`Connection`への接続を取得出来るものである。
<!-- In order to drop down to the JDBC level for functionality that is not available in Slick, you can use a `SimpleDBIO` action which is run on a database thread and gets access to the JDBC `Connection`:  -->

```scala
val getAutoCommit = SimpleDBIO[Boolean](_.connection.getAutoCommit)
```

[flatMap]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction@flatMap[R2,S2<:NoStream,E2<:Effect]((R)%E2%87%92DBIOAction[R2,S2,E2])(ExecutionContext):DBIOAction[R2,S2,EwithE2]
[andThen]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction@andThen[R2,S2<:NoStream,E2<:Effect](DBIOAction[R2,S2,E2]):DBIOAction[R2,S2,EwithE2]
[zip]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction@zip[R2,E2<:Effect](DBIOAction[R2,NoStream,E2]):DBIOAction[(R,R2),NoStream,EwithE2]

Slick 3.0.0 documentation - 06 Schemas

[Permalink to Schemas — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/schemas.html)

Schemas
=======

この章では、既存のデータベースを持たない新しいアプリケーションを作る際に役立つものとして、Scalaのコードでどのようにしてデータベースのスキーマを手で記述するのかを説明する。もしデータベースのスキーマを既に持っているのなら、[code generator](http://slick.typesafe.com/doc/3.0.0/code-generation.html)を利用することで、手で書く手間は省ける。
<!-- This chapter describes how to work with database schemas in Scala code, in particular how to write them manually, which is useful when you start writing an application without a pre-existing database. If you already have a schema in the database, you can also use the code generator \<code-generation\> to take this work off your hands. -->

Table Rows
----------

型安全なクエリにするためのScalaのAPIを利用するため、データベーススキーマに応じた`Table`クラスを定義する必要がある。これは、テーブルの構造を表現するものである。
<!-- In order to use the Scala API for type-safe queries, you need to define `Table` row classes for your database schema. These describe the structure of the tables: -->

```scala
class Coffees(tag: Tag) extends Table[(String, Int, Double, Int, Int)](tag, "COFFEES") {
  def name = column[String]("COF_NAME", O.PrimaryKey)
  def supID = column[Int]("SUP_ID")
  def price = column[Double]("PRICE")
  def sales = column[Int]("SALES", O.Default(0))
  def total = column[Int]("TOTAL", O.Default(0))
  def * = (name, supID, price, sales, total)
}
```

全てのカラムは、`column`メソッドを通して定義される。どのカラムもScalaの型と、データベースで利用されるカラム名を持つ（カラム名は一般的には大文字）。以下のプリミティブな型は、`JdbcProfile`においてJDBCベースなデータベースのためのサポートがなされている（個々のデータベースドライバーによっていくつかの制限が存在するが）。
<!-- All columns are defined through the `column` method. Each column has a Scala type and a column name for the database (usually in upper-case). The following primitive types are supported out of the box for JDBC-based databases in `JdbcProfile` (with certain limitations imposed by the individual database drivers):  -->

-   *数値型*: Byte, Short, Int, Long, BigDecimal, Float, Double
-   *LOB型*: java.sql.Blob, java.sql.Clob, Array[Byte]
-   *Date型*: java.sql.Date, java.sql.Time, java.sql.Timestamp
-   Boolean
-   String
-   Unit
-   java.util.UUID

Nullになりえるカラムについては、`T`がプリミティブ型でサポートされている場合、`Option[T]`で表現することが出来る。
<!-- Nullable columns are represented by `Option[T]` where `T` is one of the supported primitive types. -->

> **Note**
>
> このOptionに対する全ての操作は、ScalaのOption操作と異なり、データベースのnullプロパゲーションセマンティクスを用いてしまう事に注意して欲しい。特に、`None === None`という式は`None`になる。これはSlickのメジャーリリースで将来的に変更されるかもしれない。

<!-- **note** Currently all operations on Option values use the database's null propagation semantics which may differ from Scala's Option semantics. In particular, `None === None` evaluates to `None`. This behaviour may change in a future major release of Slick. -->

カラム名のうしろには、`column`の定義につけるオプションを付与する事ができる。適用可能なオプションは、テーブルの`O`オブジェクトを通して利用出来る。以下のオプションが、`JdbcProfile`用に定義されている。
<!-- After the column name, you can add optional column options to a `column` definition. The applicable options are available through the table's `O` object. The following ones are defined for `JdbcProfile`:  -->

- `PrimaryKey`
	- DDLステートメントを作成する際に、このカラムが主キーであることをマークする
<!-- :   Mark the column as a (non-compound) primary key when creating the     DDL statements.  -->

- `Default[T](defaultValue: T)`
	- カラムの値を設定せずにテーブルにデータを挿入するする際のデフォルト値を設定する。この情報は、DDLステートメントを作成する時のみに利用される。

<!-- :   Specify a default value for inserting data into the table without     this column. This information is only used for creating DDL     statements so that the database can fill in the missing information. -->

- `DBType(dbType: String)`
	- DDBステートメントのために、データベースの型を明示する際に利用する。例として、`String`型のカラムに対して、`DBType("VARCHAR(20)")`を明示して指定したりする。
<!-- :   Use a non-standard database-specific type for the DDL statements     (e.g. `DBType("VARCHAR(20)")` for a `String` column). -->

- `AutoInc`
	- DDBステートメントを作成する際に、このカラムがAutoIncrementさせるカラムであることを指定させる。他のカラムオプションと異なりこれはDDL作成時以外にも利用される。多くのデータベースがAutoIncなカラムでないものが値を返すのを許容していないため、Slickは値を返すカラムが適切にAutoIncなカラムになっているかをチェックしている。

<!-- :   Mark the column as an auto-incrementing key when creating the DDL     statements. Unlike the other column options, this one also has a     meaning outside of DDL creation: Many databases do not allow     non-AutoInc columns to be returned when inserting data (often     silently ignoring other columns), so Slick will check if the return     column is properly marked as AutoInc where needed.  -->

- `NotNull`, `Nullable`
	- テーブルのDDLステートメントを作成する際に、nullを許容するか・しないかを明示して指定する。`Option`かそうでないかでnullを許容するかを指定出来るため、一般的にはこのオプションは用いられない。

<!-- :   Explicitly mark the column as nullable or non-nullable when creating     the DDL statements for the table. Nullability is otherwise     determined from the type (Option or non-Option). There is usually no     reason to specify these options.  -->

全てのテーブルはデフォルトの射影として`*`メソッドを定義している。これは、クエリの結果として列を返す際に、あなたがどんな情報を求めているのかを説明するためのものである。Slickの`*`射影は、データベース内のものと一致している必要は無い。何かしらの計算結果を追加したり、いくつかのカラムを省いて使っても良い。`*`射影の結果は、`Table`の型引数と一致する必要があり、これはマッピングされた何かしらのクラスか、カラムが用いられることになるだろう。

<!-- Every table requires a `*` method containing a default projection. This describes what you get back when you return rows (in the form of a table row object) from a query. Slick's `*` projection does not have to match the one in the database. You can add new columns (e.g. with computed values) or omit some columns as you like. The non-lifted type corresponding to the `*` projection is given as a type parameter to `Table`. For simple, non-mapped tables, this will be a single column type or a tuple of column types.  -->

もしデータベースが _schema names_ を必要とするなら、テーブル名の前にその名前を明示して欲しい。
<!-- If your database layout requires *schema names*, you can specify the schema name for a table in front of the table name, wrapped in `Some()`:  -->

```scala
class Coffees(tag: Tag)
  extends Table[(String, Int, Double, Int, Int)](tag, Some("MYSCHEMA"), "COFFEES") {
  //...
}
```

Table Query
-----------

`Table`のクラスに対して、実際のデータベーステーブルを表す`TableQuery`も必要になるだろう。
<!-- Alongside the `Table` row class you also need a `TableQuery` value which represents the actual database table:  -->

```scala
val coffees = TableQuery[Coffees]
```

`TableQuery[T]`というシンプルなシンタックスはマクロであり、これは`new TableQuery(new T(_))`のようなテーブルのコンストラクタを呼び出すTableQueryのインスタンスとなる。
<!-- The simple `TableQuery[T]` syntax is a macro which expands to a proper TableQuery instance that calls the table's constructor (`new TableQuery(new T(_))`).  -->

テーブルに関連する追加機能を提供するために、`TableQuery`を継承しても良いだろう。
<!-- You can also extend `TableQuery` to use it as a convenient namespace for additional functionality associated with the table:  -->

```scala
object coffees extends TableQuery(new Coffees(_)) {
  val findByName = this.findBy(_.name)
}
```

Mapped Tables
-------------

`*`射影の結果を独自の型にマッピングしたいのなら、`<>`オペレータを利用して双方向マッピングを定義してあげると良い。
<!-- It is possible to define a mapped table that uses a custom type for its `*` projection by adding a bi-directional mapping with the `<>` operator:  -->

```scala
case class User(id: Option[Int], first: String, last: String)
class Users(tag: Tag) extends Table[User](tag, "users") {
  def id = column[Int]("id", O.PrimaryKey, O.AutoInc)
  def first = column[String]("first")
  def last = column[String]("last")
  def * = (id.?, first, last) <> (User.tupled, User.unapply)
}
val users = TableQuery[Users]
```

これは`apply`と`unapply`を持つケースクラス用に最適化されているが、任意のマッピングを行う事も可能である。適切に型を推測してくれるタプルを生成してくれる`.shaped`という便利なメソッドもある。任意のマッピングを行う場合には、マッピング用の型アノテーションを適宜書いて欲しい。
<!-- It is optimized for case classes (with a simple `apply` method and an `unapply` method that wraps its result in an `Option`) but it can also be used with arbitrary mapping functions. In these cases it can be useful to call `.shaped` on a tuple on the left-hand side in order to get its type inferred properly. Otherwise you may have to add full type annotations to the mapping functions.  -->

ケースクラスのコンパニオのブジェクとを手で書いている場合には、Scalaの機能に合うように実装が行われている場合にのみ、`.tupled`は上手く動作する。他にも`(User.apply _).tupled`などを使ったりも出来るだろう。 [SI-3664](https://issues.scala-lang.org/browse/SI-3664)や[SI-4808](https://issues.scala-lang.org/browse/SI-4808)も目を通しておいて欲しい。
<!-- For case classes with hand-written companion objects, `.tupled` only works if you manually extend the correct Scala function type. Alternatively you can use `(User.apply _).tupled`. See [SI-3664](https://issues.scala-lang.org/browse/SI-3664) and [SI-4808](https://issues.scala-lang.org/browse/SI-4808).  -->

Constraints
-----------

外部キーは、Tableの[foreignKey][foreignKey]によって定義される。第一引数には、制約名、関連カラム、関連テーブルの3つを渡す。続く第二引数は、関連テーブルの紐付けるカラムに加えて、`OnUpdate`や`OnDelete`のような[ForeignKeyAction](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.model.ForeignKeyAction$)に関するものを指定できる。`ForeignKeyAction`のデフォルト値は[NoAction](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.model.ForeignKeyAction$$NoAction$)となっている。テーブルのDDLステートメントが作成された時に、宣言された外部キーが定義される。
<!-- A foreign key constraint can be defined with a Table's foreignKey \<slick.profile.RelationalTableComponent$Table@foreignKey[P,PU,TT\<:AbstractTable[\_],U](String,P,TableQuery[TT])((TT)⇒P,ForeignKeyAction,ForeignKeyAction)(Shape[\_\<:FlatShapeLevel,TT,U,\_],Shape[\_\<:FlatShapeLevel,P,PU,\_]):ForeignKeyQuery[TT,U]\> method. It first takes a name for the constraint, the referencing column(s) and the referenced table. The second argument list takes a function from the referenced table to its referenced column(s) as well as ForeignKeyAction \<slick.model.ForeignKeyAction$\> for `onUpdate` and `onDelete`, which are optional and default to NoAction \<slick.model.ForeignKeyAction$$NoAction$\>. When creating the DDL statements for the table, the foreign key definition is added to it.  -->

```scala
class Suppliers(tag: Tag) extends Table[(Int, String, String, String, String, String)](tag, "SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey)
  //...
}
val suppliers = TableQuery[Suppliers]
```
```scala
class Coffees(tag: Tag) extends Table[(String, Int, Double, Int, Int)](tag, "COFFEES") {
  def supID = column[Int]("SUP_ID")
  //...
  def supplier = foreignKey("SUP_FK", supID, suppliers)(_.id, onUpdate=ForeignKeyAction.Restrict, onDelete=ForeignKeyAction.Cascade)
  // compiles to SQL:
  //   alter table "COFFEES" add constraint "SUP_FK" foreign key("SUP_ID")
  //     references "SUPPLIERS"("SUP_ID")
  //     on update RESTRICT on delete CASCADE
}
val coffees = TableQuery[Coffees]
```

データベースに定義された制約とは別に、_join_時に利用出来る外部キーを用意する事もできる。この外部キーは、他のテーブルから関連を取得する便利メソッドとして利用することが出来る。
<!-- Independent of the actual constraint defined in the database, such a foreign key can be used to navigate to the referenced data with a *join*. For this purpose, it behaves the same as a manually defined utility method for finding the joined data:  -->

```scala
def supplier = foreignKey("SUP_FK", supID, suppliers)(_.id, onUpdate=ForeignKeyAction.Restrict, onDelete=ForeignKeyAction.Cascade)
def supplier2 = suppliers.filter(_.id === supID)
```

主キー制約は`primaryKey`というメソッドを用いる事で同様に定義出来る。これは`O.PrimaryKey`を使う時とは異なり、複合主キーを定義する際に役立つ。
<!-- A primary key constraint can be defined in a similar fashion by adding a method that calls `primaryKey`. This is useful for defining compound primary keys (which cannot be done with the `O.PrimaryKey` column option):  -->

```scala
class A(tag: Tag) extends Table[(Int, Int)](tag, "a") {
  def k1 = column[Int]("k1")
  def k2 = column[Int]("k2")
  def * = (k1, k2)
  def pk = primaryKey("pk_a", (k1, k2))
  // compiles to SQL:
  //   alter table "a" add constraint "pk_a" primary key("k1","k2")
}
```

インデックスについても、`index`メソッドを用いる事で同様に定義出来る。これらはデフォルトではユニーク制約はつかず、もし必要な場合には`unique`パラメータに値をセットして欲しい。
<!-- Other indexes are defined in a similar way with the `index` method. They are non-unique by default unless you set the `unique` parameter:  -->

```scala
class A(tag: Tag) extends Table[(Int, Int)](tag, "a") {
  def k1 = column[Int]("k1")
  def k2 = column[Int]("k2")
  def * = (k1, k2)
  def idx = index("idx_a", (k1, k2), unique = true)
  // compiles to SQL:
  //   create unique index "idx_a" on "a" ("k1","k2")
}
```

全ての制約は、テーブルに定義された適切な返り値と共に、メソッドが都度探索される。この挙動は`tableConstraints`メソッドをオーバーライドする事でカスタマイズ可能だ。
<!-- All constraints are discovered reflectively by searching for methods with the appropriate return types which are defined in the table. This behavior can be customized by overriding the `tableConstraints` method.  -->

Data Definition Language
------------------------

テーブルのDDLステートメントはそのテーブルの`TableQuery`の`schema`メソッドを基に作成される。複数の`DDL`オブジェクトは`++`メソッドにより1つの`DDL`オブジェクトに統合される。これはcreate時もdrop時も全ての制約に対し、たとえ循環依存がテーブル間に存在したとしても、正しい挙動をするように実行されるものとなる。`create`や`drop`メソッドはDDLステートメントを実行するActionを生成する。
<!-- DDL statements for a table can be created with its `TableQuery`'s `schema` method. Multiple `DDL` objects can be concatenated with `++` to get a compound `DDL` object which can create and drop all entities in the correct order, even in the presence of cyclic dependencies between tables. The `create` and `drop` methods produce the Actions for executing the DDL statements:  -->

```scala
val schema = coffees.schema ++ suppliers.schema
db.run(DBIO.seq(
  schema.create,
  //...
  schema.drop
))
```

`statemens`メソッドを用いる事で、SQLのコードを取得出来る。スキーマのActionは、1つ以上のステートメントを生成するようになっている。
<!-- You can use the the `statements` method to get the SQL code, like for most other SQL-based Actions. Schema Actions are currently the only Actions that can produce more than one statement.  -->

```scala
schema.create.statements.foreach(println)
schema.drop.statements.foreach(println)
```

[foreignKey]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.profile.RelationalTableComponent$Table@foreignKey[P,PU,TT<:AbstractTable[_],U](String,P,TableQuery[TT])((TT)⇒P,ForeignKeyAction,ForeignKeyAction)(Shape[_<:FlatShapeLevel,TT,U,_],Shape[_<:FlatShapeLevel,P,PU,_]):ForeignKeyQuery[TT,U]

Slick 3.0.0 documentation - 07 Queries

[Permalink to Queries — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/queries.html)

Queries
=======

本章ではselect, insert, update, deleteといった処理を、SlickのクエリAPIでどのようにして型安全なクエリを記述するのかを説明する。
<!-- This chapter describes how to write type-safe queries for selecting, inserting, updating and deleting data with Slick's Scala-based query API.  -->

このAPIは *Lifted Embedding* と呼ばれる。これは、実際にはScalaの基本的な型を操作するのではなく、[Rep](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.Rep)の型コンストラクタへと *持ち上げられた型* を用いてる事に由来する。以下のように、Scalaのコレクション操作で扱う型と比較すると分かりやすい。

<!-- It is also called the *Lifted Embedding*, due to the fact that you are not working with standard Scala types but with types that are *lifted* into a slick.lifted.Rep type constructor. This becomes clearer when you compare the types of a simple Scala collections example  -->

```scala
case class Coffee(name: String, price: Double)
val coffees: List[Coffee] = //...
...
val l = coffees.filter(_.price > 8.0).map(_.name)
//                       ^       ^          ^
//                       Double  Double     String
```

Slickにおいて似たような記述を行うと、以下のようになる。
<!-- ... with the types of similar code in Slick: -->

```scala
class Coffees(tag: Tag) extends Table[(String, Double)](tag, "COFFEES") {
def name = column[String]("COF_NAME")
def price = column[Double]("PRICE")
def * = (name, price)
}
val coffees = TableQuery[Coffees]
...
val q = coffees.filter(_.price > 8.0).map(_.name)
//                       ^       ^          ^
//               Rep[Double]  Rep[Double]  Rep[String]
```

全ての基本的な型は`Rep`へと持ち上げられる。`Coffees`の列を表す型も`Rep[(String, Double)]`として扱われるのと等価になる。`8.0`というリテラルも、暗黙的変換により、`Rep[Double]`となる。これは`>`オペレータが`Rep[Double]`を要求するためである。この持ち上げ操作は、クエリを生成する際のシンタックスツリーを作成するのに必要になる。Scalaの基本的な関数や値はSQLへ変換するのに十分な情報を含んではいない。
<!-- All plain types are lifted into `Rep`. The same is true for the table row type `Coffees` which is a subtype of `Rep[(String, Double)]`. Even the literal `8.0` is automatically lifted to a `Rep[Double]` by an implicit conversion because that is what the `>` operator on `Rep[Double]` expects for the right-hand side. This lifting is necessary because the lifted types allow us to generate a syntax tree that captures the query computations. Getting plain Scala functions and values would not give us enough information for translating those computations to SQL.  -->

Expressions
-----------

レコードでもコレクションでも無い単純なスカラー値は、暗黙的な`TypedType[T]`が存在し、`Rep[T]`により表現される。
<!-- Scalar (non-record, non-collection) values are represented by type `Rep[T]` for which an implicit `TypedType[T]` exists.  -->

クエリ内で一般的に用いられるオペレータやメソッドは、`ExtensionMethodConversions`で定義された暗黙的な変換を通して利用される。実際のメソッドは`AnyExtensionMethods`、`ColumnExtensionMethods`、`NumericColumnExtensionMethods`、`BooleanColumnExtensionMethods`、`StringColumnExtensionMethods`に存在する。（cf. [ExtensionMethods](https://github.com/slick/slick/blob/3.0.0/src/main/scala/slick/lifted/ExtensionMethods.scala)）
<!-- The operators and other methods which are commonly used in queries are added through implicit conversions defined in `ExtensionMethodConversions`. The actual methods can be found in the classes `AnyExtensionMethods`, `ColumnExtensionMethods`, `NumericColumnExtensionMethods`, `BooleanColumnExtensionMethods` and `StringColumnExtensionMethods` (cf. ExtensionMethods \<src/main/scala/slick/lifted/ExtensionMethods.scala\>).  -->

> **Warning**
>
> Scalaの基本的な比較演算子は、凡そ同じように動作するものの、`==`と`!=`に関しては、`===`と`=!=`を代わりに用いなくてはならない。これはこれらのメソッドが`Any`に定義されていることから拡張する事が出来ないためである。
<!-- **warning** -->
<!-- Most operators mimic the plain Scala equivalents, but you have to use `===` instead of `==` for comparing two values for equality and `=!=` instead of `!=` for inequality. This is necessary because these operators are already defined (with unsuitable types and semantics) on the base type `Any`, so they cannot be replaced by extension methods.  -->

コレクションは`Query`クラスにより`Rep[Seq[T]]`のように表現される。ここには`flatMap`、`filter`、`take`、`groupBy`のような基本的なコレクションメソッドが含まれている。2つの異なる複合型を表すために（持ち上げられたものと、持ち上げられる前のもの e.g. `Query[(Rep[Int], Rep[String]), (Int, String), Seq]`）、これらのシグネチャはとても複雑なものになっている。ただ意味的には基本的にScalaのコレクションと同じようなものになっていることは確認して欲しい。
<!-- Collection values are represented by the `Query` class (a `Rep[Seq[T]]`) which contains many standard collection methods like `flatMap`, `filter`, `take` and `groupBy`. Due to the two different component types of a `Query` (lifted and plain, e.g. `Query[(Rep[Int), Rep[String]), (Int, String), Seq]`), the signatures for these methods are very complex but the semantics are essentially the same as for Scala collections.  -->

`SingleColumnQueryExtensionMethods`への暗黙的変換により、クエリやスカラー値のためのメソッドが多く宣言されている。
<!-- Additional methods for queries of scalar values are added via an implicit conversion to `SingleColumnQueryExtensionMethods`.  -->

Sorting and Filtering
---------------------

並び替えや選択を行うための様々なメソッドが存在する。これらは、`Query`から新しい`Query`を生成して返す。
<!-- There are various methods with sorting/filtering semantics (i.e. they take a `Query` and return a new `Query` of the same type), for example:  -->

```scala
val q1 = coffees.filter(_.supID === 101)
// compiles to SQL (simplified):
//   select "COF_NAME", "SUP_ID", "PRICE", "SALES", "TOTAL"
//     from "COFFEES"
//     where "SUP_ID" = 101
...
val q2 = coffees.drop(10).take(5)
// compiles to SQL (simplified):
//   select "COF_NAME", "SUP_ID", "PRICE", "SALES", "TOTAL"
//     from "COFFEES"
//     limit 5 offset 10
...
val q3 = coffees.sortBy(_.name.desc.nullsFirst)
// compiles to SQL (simplified):
//   select "COF_NAME", "SUP_ID", "PRICE", "SALES", "TOTAL"
//     from "COFFEES"
//     order by "COF_NAME" desc nulls first
...
// building criteria using a "dynamic filter" e.g. from a webform.
val criteriaColombian = Option("Colombian")
val criteriaEspresso = Option("Espresso")
val criteriaRoast:Option[String] = None
...
val q4 = coffees.filter { coffee =>
  List(
    criteriaColombian.map(coffee.name === _),
    criteriaEspresso.map(coffee.name === _),
    criteriaRoast.map(coffee.name === _) // not a condition as `criteriaRoast` evaluates to `None`
  ).collect({case Some(criteria)  => criteria}).reduceLeftOption(_ || _).getOrElse(true: Column[Boolean])
}
// compiles to SQL (simplified):
//   select "COF_NAME", "SUP_ID", "PRICE", "SALES", "TOTAL"
//     from "COFFEES"
//     where ("COF_NAME" = 'Colombian' or "COF_NAME" = 'Espresso')
```

Joining and Zipping
-------------------

joinは2つの異なるテーブルやクエリに対して、1つのクエリを適用するのに用いられる。*Applicative*と*Monadic*の2種類のjoinの書き方が存在する。
<!-- Joins are used to combine two different tables or queries into a single query. There are two different ways of writing joins: *Applicative* and *monadic*.  -->

### Applicative joins

*Applicative*なjoinはそれぞれの結果を取得するクエリへ2つのクエリを結合するメソッドを呼ぶ事で実行出来る。SQLにおけるjoinと同様の制約がかかり、右側は左側に依存しなかったりする。これはScalaのスコープにおけるルールを通して自然に強制される。
<!-- *Applicative* joins are performed by calling a method that joins two queries into a single query of a tuple of the individual results. They have the same restrictions as joins in SQL, i.e. the right-hand side may not depend on the left-hand side. This is enforced naturally through Scala's scoping rules.  -->

```scala
val crossJoin = for {
  (c, s) <- coffees join suppliers
} yield (c.name, s.name)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     inner join "SUPPLIERS" x3
...
val innerJoin = for {
  (c, s) <- coffees join suppliers on (_.supID === _.id)
} yield (c.name, s.name)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     inner join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
...
val leftOuterJoin = for {
  (c, s) <- coffees joinLeft suppliers on (_.supID === _.id)
} yield (c.name, s.map(_.name))
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     left outer join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
...
val rightOuterJoin = for {
  (c, s) <- coffees joinRight suppliers on (_.supID === _.id)
} yield (c.map(_.name), s.name)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     right outer join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
...
val fullOuterJoin = for {
  (c, s) <- coffees joinFull suppliers on (_.supID === _.id)
} yield (c.map(_.name), s.map(_.name))
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     full outer join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
```

outer joinの節では、`yield`の中で`map`している。これらのjoinにおいては追加でNULLになるようなカラムが生じ、結果のカラム型が`Option`に包まって返却されるためである（`None`になるのは、対応する列がなかった時など）。
<!-- Note the use of `map` in the `yield` clauses of the outer joins. Since these joins can introduce additional NULL values (on the right-hand side for a left outer join, on the left-hand sides for a right outer join, and on both sides for a full outer join), the respective sides of the join are wrapped in an `Option` (with `None` representing a row that was not matched).  -->

### Monadic joins

*Monadic*なjoinは`flatMap`を利用する事で自動的に生成される。右辺が左辺に依存するため、理論上*Monadic*なjoinは*Applicative*なジョインより強力なものとなる。一方で、これは通常のSQLに適したものとはならない。そのため、Slickは*Monadic*なjoinを*Applicative*なjoinへと変換している。もし*Monadic*なjoinを適切な形に変換出来なければ、実行時に失敗する事になるだろう。
<!-- *Monadic* joins are created with `flatMap`. They are theoretically more powerful than applicative joins because the right-hand side may depend on the left-hand side. However, this is not possible in standard SQL, so Slick has to compile them down to applicative joins, which is possible in many useful cases but not in all of them (and there are cases where it is possible in theory but Slick cannot perform the required transformation yet). If a monadic join cannot be properly translated, it will fail at runtime.  -->

*cross-join*は`Query`の`flatMap`により作成される。1つ以上のジェネレータを用いる際には、for式が役立つ。
<!-- A *cross-join* is created with a `flatMap` operation on a `Query` (i.e. by introducing more than one generator in a for-comprehension):  -->

```scala
val monadicCrossJoin = for {
  c <- coffees
  s <- suppliers
} yield (c.name, s.name)
// compiles to SQL:
//   select x2."COF_NAME", x3."SUP_NAME"
//     from "COFFEES" x2, "SUPPLIERS" x3
```

もし何かしらの絞込を行うのなら、それは*inner join*となる。
<!-- If you add a filter expression, it becomes an *inner join*:  -->

```scala
val monadicInnerJoin = for {
  c <- coffees
  s <- suppliers if c.supID === s.id
} yield (c.name, s.name)
// compiles to SQL:
//   select x2."COF_NAME", x3."SUP_NAME"
//     from "COFFEES" x2, "SUPPLIERS" x3
//     where x2."SUP_ID" = x3."SUP_ID"
```

この*Monadic*なjoinはScalaコレクションの`flatMap`を利用した時と同じ意味を持つ。
<!-- The semantics of these monadic joins are the same as when you are using `flatMap` on Scala collections.  -->

> **Note**
>
> Slickは*Monadic*なjoinに対し暗黙的なjoin（`select ... from a, b where ...`）を、*Applicative*なjoinに対し明示的なjoin（`select ... from a join b on ...`）を生成する。これについては、将来のバージョンで変更があるかもしれない。
<!-- **note** Slick currently generates *implicit* joins in SQL (`select ... from a, b where ...`) for monadic joins, and *explicit* joins (`select ... from a join b on ...`) for applicative joins. This is subject to change in future versions.  -->

### Zip joins

関係でデータベースによってサポートされている一般的な*Applicative* joinに加えて、Slickは2つのクエリのペアを作成する*zip join*を提供している。これは`zip`や`zipWith`メソッドを用いれば利用でき、Scalaコレクションで利用するものと同じような挙動をするものである。
<!-- In addition to the usual applicative join operators supported by relational databases (which are based off a cross join or outer join), Slick also has *zip joins* which create a pairwise join of two queries. The semantics are again the same as for Scala collections, using the `zip` and `zipWith` methods:  -->

```scala
val zipJoinQuery = for {
  (c, s) <- coffees zip suppliers
} yield (c.name, s.name)
...
val zipWithJoin = for {
  res <- coffees.zipWith(suppliers, (c: Coffees, s: Suppliers) => (c.name, s.name))
} yield res
```

また別のzip joinとして、`zipWithIndex`というものも存在する。これは0から始まる無限数列をクエリ結果と結合してくれるものである。この数列はSQLデータベースによって提供されたものではなく、Slickがサポートしているものでもない。ただの数字を吐く関数とSQLの結果を統合したものとして、`zipWithIndex`がプリミティブなオペレータとして提供されているのである。
<!-- A particular kind of zip join is provided by `zipWithIndex`. It zips a query result with an infinite sequence starting at 0. Such a sequence cannot be represented by an SQL database and Slick does not currently support it, either. The resulting zipped query, however, can be represented in SQL with the use of a *row number* function, so `zipWithIndex` is supported as a primitive operator:  -->

```scala
val zipWithIndexJoin = for {
  (c, idx) <- coffees.zipWithIndex
} yield (c.name, idx)
```

Unions
------

互換性のある2つのクエリは`++`（もしくは`unionAll`）や`union`で結合することが出来る。
<!-- Two queries can be concatenated with the `++` (or `unionAll`) and `union` operators if they have compatible types:  -->

```scala
val q1 = coffees.filter(_.price < 8.0)
val q2 = coffees.filter(_.price > 9.0)
...
val unionQuery = q1 union q2
// compiles to SQL (simplified):
//   select x8."COF_NAME", x8."SUP_ID", x8."PRICE", x8."SALES", x8."TOTAL"
//     from "COFFEES" x8
//     where x8."PRICE" < 8.0
//   union select x9."COF_NAME", x9."SUP_ID", x9."PRICE", x9."SALES", x9."TOTAL"
//     from "COFFEES" x9
//     where x9."PRICE" > 9.0
...
val unionAllQuery = q1 ++ q2
// compiles to SQL (simplified):
//   select x8."COF_NAME", x8."SUP_ID", x8."PRICE", x8."SALES", x8."TOTAL"
//     from "COFFEES" x8
//     where x8."PRICE" < 8.0
//   union all select x9."COF_NAME", x9."SUP_ID", x9."PRICE", x9."SALES", x9."TOTAL"
//     from "COFFEES" x9
//     where x9."PRICE" > 9.0
```

`union`は重複する値については省いてしまうのに対し、`++`は個々のクエリ結果を単純に、より効率的に繋げるものとなっている。
<!-- Unlike `union` which filters out duplicate values, `++` simply concatenates the results of the individual queries, which is usually more efficient.  -->

Aggregation
-----------

集約関数はQueryから単一の値、主に計算された数値を返すものである。
<!-- The simplest form of aggregation consists of computing a primitive value from a Query that returns a single column, usually with a numeric type, e.g.:  -->

```scala
val q = coffees.map(_.price)
...
val q1 = q.min
// compiles to SQL (simplified):
...
val q2 = q.max
// compiles to SQL (simplified):
//   select max(x4."PRICE") from "COFFEES" x4
...
val q3 = q.sum
// compiles to SQL (simplified):
//   select sum(x4."PRICE") from "COFFEES" x4
...
val q4 = q.avg
// compiles to SQL (simplified):
//   select avg(x4."PRICE") from "COFFEES" x4
```

集約クエリはコレクションではなく、スカラー値を返却する。いくつかの集約関数は以下のような恣意的なクエリで定義されている。
<!-- Note that these aggregate queries return a scalar result, not a collection. Some aggregation functions are defined for arbitrary queries (of more than one column):  -->

```scala
val q1 = coffees.length
// compiles to SQL (simplified):
//   select count(1) from "COFFEES"
...
val q2 = coffees.exists
// compiles to SQL (simplified):
//   select exists(select * from "COFFEES")
```

グループ化は`groupBy`メソッドにより処理出来る。これはScalaのコレクションでの操作と同じような意味を持つ。
<!-- Grouping is done with the `groupBy` method. It has the same semantics as for Scala collections:  -->

```scala
val q = (for {
  c <- coffees
  s <- c.supplier
} yield (c, s)).groupBy(_._1.supID)
val q2 = q.map { case (supID, css) =>
  (supID, css.length, css.map(_._1.price).avg)
}
// compiles to SQL:
//   select x2."SUP_ID", count(1), avg(x2."PRICE")
//     from "COFFEES" x2, "SUPPLIERS" x3
//     where x3."SUP_ID" = x2."SUP_ID"
//     group by x2."SUP_ID"
```

中間クエリである`q`はネストされた`Query`の値を持っている。クエリを実行した際に、ネストしたコレクションが返却される。それゆえ、`q2`においては、集約関数を用いてネストを解消している。
<!-- The intermediate query `q` contains nested values of type `Query`. These would turn into nested collections when executing the query, which is not supported at the moment. Therefore it is necessary to flatten the nested queries immediately by aggregating their values (or individual columns) as done in `q2`.  -->

Querying
--------

Queryは`result`メソッドを呼ぶことで[Action](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction)へ変換される。Actionはストリーム、個々の分割された方法、もしくは他のアクションを混在したものとして直接[実行される](http://slick.typesafe.com/doc/3.0.0/dbio.html#executing-actions)。
<!-- A Query can be converted into an Action \<slick.dbio.DBIOAction\> by calling its `result` method. The Action can then be executed \<executing-actions\> directly in a streaming or fully materialized way, or composed further with other Actions:  -->

```scala
val q = coffees.map(_.price)
val action = q.result
val result: Future[Seq[Double]] = db.run(action)
val sql = action.statements.head
```

もし結果を1つのみ受け取りたいのなら、`head`か`headOption`を用いれば良い。
<!-- If you only want a single result value, you can call `head` or `headOption` on the `result` Action.  -->

Deleting
--------

削除はクエリの場合と同じように動作する。はじめに削除したい行をクエリで選択した上で、`delete`メソッドを呼ぶことで削除を行うActionが得られる。
<!-- Deleting works very similarly to querying. You write a query which selects the rows to delete and then get an Action by calling the `delete` method on it:  -->

```scala
val q = coffees.filter(_.supID === 15)
val action = q.delete
val affectedRowsCount: Future[Int] = db.run(action)
val sql = action.statements.head
```

削除を行うクエリは、1つのテーブルのみを指定しなくてはならない。どんな射影も無視され、行はまるまる削除される。
<!-- A query for deleting must only select from a single table. Any projection is ignored (it always deletes full rows).  -->

Inserting
---------

挿入は1つのテーブルから特定のカラムを射影したものに対して実行する。テーブルを直接用いた場合には、挿入は`*`射影に対して実行される。挿入時にいくつかのカラムを省略した場合には、テーブル定義にあるデフォルト値が用いられるか、明示的なデフォルト値が無い場合には型に応じたデフォルト値が挿入される。挿入Actionに関する全てのメソッドは、[CountingInsertActionComposer](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcActionComponent@CountingInsertActionComposer[U]:JdbcDriver.CountingInsertActionComposer[U])か[ReturningInsertActionComposer](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcActionComponent@ReturningInsertActionComposer[U,RU]:JdbcDriver.ReturningInsertActionComposer[U,RU])に定義されている。
<!-- Inserts are done based on a projection of columns from a single table. When you use the table directly, the insert is performed against its `*` projection. Omitting some of a table's columns when inserting causes the database to use the default values specified in the table definition, or a type-specific default in case no explicit default was given. All methods for building insert Actions are defined in CountingInsertActionComposer \<slick.driver.JdbcActionComponent@CountingInsertActionComposer[U]:JdbcDriver.CountingInsertActionComposer[U]\> and ReturningInsertActionComposer \<slick.driver.JdbcActionComponent@ReturningInsertActionComposer[U,RU]:JdbcDriver.ReturningInsertActionComposer[U,RU]\>.  -->

```scala
val insertActions = DBIO.seq(
  coffees += ("Colombian", 101, 7.99, 0, 0),
  coffees ++= Seq(
    ("French_Roast", 49, 8.99, 0, 0),
    ("Espresso",    150, 9.99, 0, 0)
  ),
  // "sales" と "total" にはデフォルト値として0が入る
  coffees.map(c => (c.name, c.supID, c.price)) += ("Colombian_Decaf", 101, 8.99)
)
// insertを行うsqlのステートメントを取得
val sql = coffees.insertStatement
// compiles to SQL:
//   INSERT INTO "COFFEES" ("COF_NAME","SUP_ID","PRICE","SALES","TOTAL") VALUES (?,?,?,?,?)
```

`AutoInc`がついたカラムが挿入された際には、データベースが適切な値を生成した値が挿入される。大抵の場合、自動で生成された主キーの値などを取得したいと考えるだろう。デフォルトでは`+=`は影響を与えた行の数を返却する（普通は成功時に1が返る）。`++=`は`Option`に包まれた結果数を返す。`None`になるのはデータベースシステムが影響を与えた数を返さない時である。これらの返り値は`returning`メソッドを用いることで、好きな値が返るように変更出来る。この場合、`+=`に対して単一の値やタプルを返すように設定すると、`++=`にはその値の`Seq`が返却されることになる。以下の様な記述で、`AutoInc`で生成された主キーを返すことが出来る。
<!-- When you include an `AutoInc` column in an insert operation, it is silently ignored, so that the database can generate the proper value. In this case you usually want to get back the auto-generated primary key column. By default, `+=` gives you a count of the number of affected rows (which will usually be 1) and `++=` gives you an accumulated count in an `Option` (which can be `None` if the database system does not provide counts for all rows). This can be changed with the `returning` method where you specify the columns to be returned (as a single value or tuple from `+=` and a `Seq` of such values from `++=`):  -->

```scala
val userId =
  (users returning users.map(_.id)) += User(None, "Stefan", "Zeiger")
```
> **Note**
>
> 多くのデータベースでは、1つのテーブルのAutoIncrementな主キーのみを返却することを許可している。もし他のカラムについても同様の事をしようとしたならば、データベースがサポートしていない時には`SlickException`が投げられる。
<!-- **note** Many database systems only allow a single column to be returned which must be the table's auto-incrementing primary key. If you ask for other columns a `SlickException` is thrown at runtime (unless the database actually supports it).  -->

`returning`に`into`を続けて用いると、挿入された値と自動生成された値をもとに返り値を変更する事ができる。得られた`id`を用いて更新されたオブジェクトを返却する例は以下の通りとなる。
<!-- You can follow the `returning` method with the `into` method to map the inserted values and the generated keys (specified in returning) to a desired value. Here is an example of using this feature to return an object with an updated id:  -->

```scala
val userWithId =
  (users returning users.map(_.id)
         into ((user,id) => user.copy(id=Some(id)))
  ) += User(None, "Stefan", "Zeiger")
```

クライアント側でデータを挿入する以外にも、データベースサーバ側で実行されるスカラー表現や`Query`を作る事でデータを挿入することも出来る。
<!-- Instead of inserting data from the client side you can also insert data created by a `Query` or a scalar expression that is executed in the database server:  -->

```scala
class Users2(tag: Tag) extends Table[(Int, String)](tag, "users2") {
  def id = column[Int]("id", O.PrimaryKey)
  def name = column[String]("name")
  def * = (id, name)
}
val users2 = TableQuery[Users2]
val actions = DBIO.seq(
  users2.schema.create,
  users2 forceInsertQuery (users.map { u => (u.id, u.first ++ " " ++ u.last) }),
  users2 forceInsertExpr (users.length + 1, "admin")
)
```

この場合、`AutoInc`なカラムは _無視されない_ 。
<!-- In these cases, `AutoInc` columns are *not* ignored.  -->

Updating
--------
更新は更新を行いたいデータを選択してから、新しいデータで置き換える事で実行される。更新時の返り値は計算された値ではなく、1つのテーブルから取得された生のカラムをそのまま返却しなくてはならない。更新に関連するメソッドは、[UpdateExtensionMethods](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcActionComponent@UpdateActionExtensionMethodsImpl[T]:JdbcDriver.UpdateActionExtensionMethodsImpl[T])で定義されている。
<!-- Updates are performed by writing a query that selects the data to update and then replacing it with new data. The query must only return raw columns (no computed values) selected from a single table. The relevant methods for updating are defined in UpdateExtensionMethods \<slick.driver.JdbcActionComponent@UpdateActionExtensionMethodsImpl[T]:JdbcDriver.UpdateActionExtensionMethodsImpl[T]\>.  -->

```scala
val q = for { c <- coffees if c.name === "Espresso" } yield c.price
val updateAction = q.update(10.49)
// 値を更新することなくステートメントを取得する
val sql = q.updateStatement
// compiles to SQL:
//   update "COFFEES" set "PRICE" = ? where "COFFEES"."COF_NAME" = 'Espresso'
```

現時点では、データベースにある更新用の変換表現等を利用したりすることは出来ない。
<!-- There is currently no way to use scalar expressions or transformations of the existing data in the database for updates.  -->

Compiled Queries
----------------

通常、データベースクエリはいくつかのパラメータに依存している（IDは一致する列を取得するために用いられるなど）。パラメータ化された`Query`オブジェクトを実行の度に作ることも出来るが、これはSlickが毎度クエリをコンパイルするコストが高くついてしまう（パラメータに値を代入しない場合など特に）。パラメータ化されたクエリ関数を事前にSlick側でコンパイルする、より効率的な方法が存在する。
<!-- Database queries typically depend on some parameters, e.g. an ID for which you want to retrieve a matching database row. You can write a regular Scala function to create a parameterized `Query` object each time you need to execute that query but this will incur the cost of recompiling the query in Slick (and possibly also on the database if you don't use bind variables for all parameters). It is more efficient to pre-compile such parameterized query functions:  -->

```scala
def userNameByIDRange(min: Rep[Int], max: Rep[Int]) =
for {
  u <- users if u.id >= min && u.id < max
} yield u.first
val userNameByIDRangeCompiled = Compiled(userNameByIDRange _)
// このクエリは1度しかコンパイルされない
val namesAction1 = userNameByIDRangeCompiled(2, 5).result
val namesAction2 = userNameByIDRangeCompiled(1, 3).result
// .insert にも .update にも .delete にも使える
```

これは個々のカラムやカラムの[records](http://slick.typesafe.com/doc/3.0.0/userdefined.html#record-types)をパラメータに取る全てのメソッドに対し上手く機能し、`Query`オブジェクトなどを返却する。[Compiled](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.Compiled)のAPIドキュメントを見て、そのサブクラスなど、コンパイルされたクエリの詳細について学んで欲しい。
<!-- This works for all functions that take parameters consisting only of individual columns or or records \<record-types\> of columns and return a `Query` object or a scalar query. See the API documentation for slick.lifted.Compiled and its subclasses for details on composing compiled queries.  -->

`ConstColumn[Long]`をパラメータ似とる`take`や`drop`を使う場合には気をつけて欲しい。クエリによって計算された他の値に取って代わられる`Rep[Long]`と異なり、`ConstColumn`はリテラル値かコンパイルされたクエリのパラメータのみを要求する。これは、クエリがSlickによって実行される前までに実際の値を知っておかなくてはならないため、必要になる。
<!-- Be aware that `take` and `drop` take `ConstColumn[Long]` parameters. Unlike `Rep[Long]]`, which could be substituted by another value computed by a query, a ConstColumn can only be literal value or a parameter of a compiled query. This is necessary because the actual value has to be known by the time the query is prepared for execution by Slick.  -->

```scala
val userPaged = Compiled((d: ConstColumn[Long], t: ConstColumn[Long]) => users.drop(d).take(t))
...
val usersAction1 = userPaged(2, 1).result
val usersAction2 = userPaged(1, 3).result
```

データの選択、挿入、更新、削除において、コンパイルされたクエリを用いる事ができる。Slick1.0への後方互換用に、[Parameters](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.Parameters)オブジェクトに`flatMap`を呼ぶ事で、コンパイルされたクエリを作成する事も可能である。大抵の場合、これはコンパイルされたクエリを1つのfor式で書くのに役立つだろう。
<!-- You can use a compiled query for querying, inserting, updating and deleting data. For backwards-compatibility with Slick 1.0 you can still create a compiled query by calling `flatMap` on a slick.lifted.Parameters object. In many cases this enables you to write a single *for comprehension* for a compiled query:  -->

```scala
val userNameByID = for {
  id <- Parameters[Int]
  u <- users if u.id === id
} yield u.first
...
val nameAction = userNameByID(2).result.head
...
val userNameByIDRange = for {
  (min, max) <- Parameters[(Int, Int)]
  u <- users if u.id >= min && u.id < max
} yield u.first
val namesAction = userNameByIDRange(2, 5).result
```

Slick 3.0.0 documentation - 08 Schema Code Generation

[Permalink to Schema Code Generation — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/code-generation.html)

Schema Code Generation
======================

SLickのコードジェネレータはデータベーススキーマが既に存在している場合に、非常に便利なツールとなる。これはジェネレータ単独で利用する事もできるし、sbtのbuildと組わわせて全ての必要なSlickのコードを生成する事が出来る。
<!-- The Slick code generator is a convenient tool for working with an existing or evolving database schema. It can be run stand-alone or integrated into you sbt build for creating all code Slick needs to work.  -->

Overview
--------

デフォルトでは、コードジェネレータは全てのテーブルに対する`Table`クラスと、対応する`TableQuery`の値を生成する。列に対応するものは、各カラムを引数に取るケースクラスとして生成される。22より多くのカラムを持つテーブルについては、コードジェネレータは自動的にSlickの実験的な機能である`HList`を用いた実装に変更する。これはScalaのタプルサイズ問題を解決する1つの方法である。（Scalaのバージョンが2.10.3以下である場合、コンパイル時間に対する問題を解決するために`HCons`が`::`の代わりに用いられるが、これはScala2.10.4以上では解決されている話だ）
<!-- By default, the code generator generates `Table` classes, corresponding `TableQuery` values, which can be used in a collection-like manner, as well as case classes for holding complete rows of values. For tables with more than 22 columns the generator automatically switches to Slick's experimental `HList` implementation for overcoming Scala's tuple size limit. (In Scala \<= 2.10.3 use `HCons` instead of `::` as a type contructor due to performance issues during compilation, which are fixed in 2.10.4 and later.)  -->

ジェネレータについては、[talk at Scala eXchange 2013](http://slick.typesafe.com/docs/#20131203_patterns_for_slick_database_applications_at_scala_exchange_2013)にも説明があるから、是非見て欲しい。
<!-- Parts of the generator are also explained in our [talk at Scala eXchange 2013](http://slick.typesafe.com/docs/#20131203_patterns_for_slick_database_applications_at_scala_exchange_2013).  -->

Standalone use
--------------

SlickのコードジェネレータはそのライブラリがSlick本体とは独立して公開されている。sbtプロジェクトにおいては、以下のような記述をビルド定義（`build.sbt`や`project/Build.scala`など）に加える事で利用可能となる。
<!-- To include Slick's code generator use the published library. For sbt projects add following to your build definition -`build.sbt` or `project/Build.scala`:  -->

```scala
libraryDependencies += "com.typesafe.slick" %% "slick-codegen" % "3.0.0"
```

Mavenプロジェクトには、以下のような`<dependency>`を加えて欲しい。
<!-- For Maven projects add the following to your `<dependencies>`: -->

```xml
<dependency>
  <groupId>com.typesafe.slick</groupId>
  <artifactId>slick-codegen_2.10</artifactId>
  <version>3.0.0</version>
</dependency>
```

Slickのコードジェネレータはコマンドラインから、もしくはJavaやScalaからAPIを利用して使う事が出来る。単純な例だと、以下のように実行すれば良い。
<!-- Slick's code generator comes with a default runner that can be used from the command line or from Java/Scala. You can simply execute  -->

```
slick.codegen.SourceCodeGenerator.main(
  Array(slickDriver, jdbcDriver, url, outputFolder, pkg)
)
```

もしくは、こんな感じに。
<!-- or -->

```scala
slick.codegen.SourceCodeGenerator.main(
  Array(slickDriver, jdbcDriver, url, outputFolder, pkg, user, password)
)
```

引数は、以下のようなものを取る。
<!-- and provide the following values -->

-   **slickDriver** Slick driver class, e.g. *"slick.driver.H2Driver"*
-   **jdbcDriver** jdbc driver class, e.g. *"org.h2.Driver"*
-   **url** jdbc url, e.g. *"jdbc:postgresql://localhost/test"*
-   **outputFolder** 生成されたコードを出力するためのフォルダ
-   **pkg** 生成されたコードが置かれるべきScalaのパッケージ名
-   **user** データベースに接続するユーザ名
-   **password** データベースにユーザが接続する際に利用するパスワード

<!-- -   **slickDriver** Fully qualified name of Slick driver class, e.g. *"slick.driver.H2Driver"* -->
<!-- -   **jdbcDriver** Fully qualified name of jdbc driver class, e.g. *"org.h2.Driver"* -->
<!-- -   **url** jdbc url, e.g. *"jdbc:postgresql://localhost/test"* -->
<!-- -   **outputFolder** Place where the package folder structure should be put -->
<!-- -   **pkg** Scala package the generated code should be places in -->
<!-- -   **user** database connection user name -->
<!-- -   **password** database connection password -->

Integrated into sbt
-------------------

コードジェネレータは[sbt](http://www.scala-sbt.org/)で手で実行したり、コンパイル前に毎度実行したりも出来る。[slick-codegen-example](https://github.com/slick/slick-codegen-example)に例があるから参考にして欲しい。
<!-- The code generator can be run before every compilation or manually in sbt\_. An example project showing both can be [found here](https://github.com/slick/slick-codegen-example).  -->
（訳注: [tototoshi/sbt-slick-codegen](https://github.com/tototoshi/sbt-slick-codegen)も参考までに）

Generated Code
--------------

デフォルトでは、生成されたコードは指定されたフォルダー以下に`Tables.scala`という名前のファイルで保存される。このファイルは、良い感じにインポート出来るコードを持つ`object Tables`を含んでいる。Slickドライバーが適切なものになっているのかも確認出来る。このファイルには`trait Tables`も含まれていて、Cakeパターンを用いたい場合にはこちらを利用すると良い。
<!-- By default, the code generator places a file `Tables.scala` in the given folder in a subfolder corresponding to the package. The file contains an `object Tables` from which the code can be imported for use right away. Make sure you use the same Slick driver. The file also contains a `trait Tables` which can be used in the cake pattern.  -->

> **Warning**
>
> 生成されたコードを用いる際には、異なるデータベースドライバを誤って混ぜてしまわないように注意して欲しい。デフォルトの`object Tables`はコード生成の際にドライバを用いる。異なるドライバを一緒に使ってしまうと、ランタイムエラーを引き起こす。生成された`trait Tables`は異なるドライバーにより用いられるが、これは現在テストされておらず非公式な使い方となっている。あなたの環境では上手く動かないかもしれない。将来的にこれらについては公式でサポートする予定だ。

<!-- **warning** When using the generated code, be careful **not** to mix different database drivers accidentally. The default `object Tables` uses the driver used during code generation. Using it together with a different driver for queries will lead to runtime errors. The generated `trait Tables` can be used with a different driver, but be aware, that this is currently untested and not officially supported. It may or may not work in your case. We will officially support this at some point in the future.  -->

Customization
-------------

ジェネレータはデータモデルに対しどんなコードも生成出来るように様々なメソッドをオーバライドして自由にカスタマイズすることが出来る。簡単なカスタマイズから非常に大きなカスタマイズまで、様々なカスタマイズに対応出来ます。[Play](https://playframework.com/)に対応するフレームワークバインディングを行うだとか、そのような例があります。
<!-- The generator can be flexibly customized by overriding methods to programmatically generate any code based on the data model. This can be used for minor customizations as well as heavy, model driven code generation, e.g. for framework bindings in Play\_, other data-related, repetitive sections of applications, etc.  -->

[This example](https://github.com/slick/slick-codegen-customization-example)では、どのようにしてコードジェネレータをカスタマイズするのか、sbtのmulti-projectに対しどのようにセットアップするのか、メインとなるソースに対して、コンパイル前に毎度コードジェネレータをどのようにして実行させるのかを見ることが出来ます。
<!-- [This example](https://github.com/slick/slick-codegen-customization-example) shows a customized code-generator and how to setup up a multi-project sbt build, which compiles and runs it before compiling the main sources.  -->

コードジェネレータ、異なるフラグメントに対して最適化された小さなサブジェネレータの階層を構造化して実装されています。サブジェネレータの実装は、個々のファクトリメソッドをオーバーライドすることで、カスタマイズしたものに取り替える事ができる。[SourceCodeGenerator](http://slick.typesafe.com/doc/3.0.0/codegen-api/index.html#slick.codegen.SourceCodeGenerator)は各々のテーブルのためのサブジェネレータを生成するファクトリメソッドを含んでいる。サブジェネレータはTableクラス自体、エンティティとなるケースクラス、カラム、キー、インデックスなど、様々なものを生成するサブジェネレータを含んでいる。カスタマイズされたサブジェネレータも簡単に同様に扱う事ができる。
<!-- The implementation of the code generator is structured into a small hierarchy of sub-generators responsible for different fragments of the complete output. The implementation of each sub-generator can be swapped out for a customized one by overriding the corresponding factory method. SourceCodeGenerator \<slick.codegen.SourceCodeGenerator\> contains a factory method Table, which it uses to generate a sub-generator for each table. The sub-generator Table in turn contains sub-generators for Table classes, entity case classes, columns, key, indices, etc. Custom sub-generators can easily be added as well.  -->

様々なサブジェネレータにおいて、Slickのデータモデルに関連する部分はコード生成を実行させる際にアクセスされる。
<!-- Within the sub-generators the relevant part of the Slick data model can be accessed to drive the code generation.  -->

カスタマイズ可能なオーバーライド出来るメソッド一覧については、[api documentation](http://slick.typesafe.com/doc/3.0.0/codegen-api/index.html#slick.codegen.SourceCodeGenerator)を見て欲しい。
<!-- Please see the api documentation \<slick.codegen.SourceCodeGenerator\> for info on all of the methods that can be overridden for customization.  -->

以下にジェネレータをカスタマイズするサンプルを載せる。
<!-- Here is an example for customizing the generator: -->

```scala
import slick.codegen.SourceCodeGenerator
// データモデルを取得する
val modelAction = H2Driver.createModel(Some(H2Driver.defaultTables)) // テーブルのフィルタリングはここで行う
val modelFuture = db.run(modelAction)
// コードジェネレータをカスタマイズする
val codegenFuture = modelFuture.map(model => new SourceCodeGenerator(model) {
  // マッピングするテーブルとクラス名をオーバーライド
  override def entityName =
    dbTableName => dbTableName.dropRight(1).toLowerCase.toCamelCase
  override def tableName =
    dbTableName => dbTableName.toLowerCase.toCamelCase
  // いくつか追加のimportを加える
  override def code = "import foo.{MyCustomType,MyCustomTypeMapper}" + "\n" + super.code
  // テーブルジェネレータをカスタマイズ
  override def Table = new Table(_){
    // エンティティクラスの生成を抑制する
    override def EntityType = new EntityType{
      override def classEnabled = false
    }
    // カラムジェネレータをカスタマイズ
    override def Column = new Column(_){
      // 特定のカラムに対して、Scalaの型を変更するようカスタマイズ
      // e.g. to a custom enum or anything else
      override def rawType =
        if(model.name == "SOME_SPECIAL_COLUMN_NAME") "MyCustomType" else super.rawType
    }
  }
})
codegenFuture.onSuccess { case codegen =>
  codegen.writeToFile(
    "slick.driver.H2Driver","some/folder/","some.packag","Tables","Tables.scala"
  )
}
```

Slick 3.0.0 documentation - 09 User-Defined Features

[Permalink to User-Defined Features — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/userdefined.html)

User-Defined Features
=====================

本章では、どのようにしてカスタマイズしたデータ型を、SlickのScala APIを通して利用するのかということについて説明する。
<!-- This chapter describes how to use custom data types and database functions with Slick's Scala API.  -->

Scalar Database Functions
-------------------------

もしデータベースシステムがSlickで利用できないメソッドを関数としてサポートしているのならば、[SimpleFunction](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.SimpleFunction)を通してその関数を利用することが出来る。固定されたパラメータと返り値を用いる1つ・2つ・3つ組といった関数が様々なデータベースに存在している。
<!-- If your database system supports a scalar function that is not available as a method in Slick you can define it as a slick.lifted.SimpleFunction. There are predefined methods for creating unary, binary and ternary functions with fixed parameter and return types. -->

```scala
// H2データベースでは day_of_week() 関数により、timestampから曜日を取得することが出来る
val dayOfWeek = SimpleFunction.unary[Date, Int]("day_of_week")
...
// 曜日別にグループ化したクエリを用いたクエリは以下のようになる
val q1 = for {
  (dow, q) <- salesPerDay.map(s => (dayOfWeek(s.day), s.count)).groupBy(_._1)
} yield (dow, q.map(_._2).sum)
```

もっと柔軟に型を変形したい場合（複数引数であったり、OptionとNon-Optionの型を使い分けたい）などには、`SimpleFunction.apply`を使って、適切な型チェックを行うラッパー関数を書く事が出来る。
<!-- If you need more flexibility regarding the types (e.g. for varargs, polymorphic functions, or to support Option and non-Option types in a single function), you can use `SimpleFunction.apply` to get an untyped instance and write your own wrapper function with the proper type-checking:  -->

```scala
def dayOfWeek2(c: Rep[Date]) =
  SimpleFunction[Int]("day_of_week").apply(Seq(c))
```

[SimpleBinaryOperator](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.SimpleBinaryOperator)と[SimpleLiteral](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.SimpleLiteral)も同じように扱うことが出来る。もっと柔軟な操作を行いたい場合には、[SimpleExpression](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.SimpleExpression)を用いると良い。
<!-- slick.lifted.SimpleBinaryOperator and slick.lifted.SimpleLiteral work in a similar way. For even more flexibility (e.g. function-like expressions with unusual syntax), you can use slick.lifted.SimpleExpression.  -->

```scala
val current_date = SimpleLiteral[java.sql.Date]("CURRENT_DATE")
salesPerDay.map(_ => current_date)
```

Other Database Functions And Stored Procedures
----------------------------------------------

全てのテーブルを返すようなデータベースの関数を利用したり、、ストアドプロシージャを用いたいといった場合には、[Plain SQL Queries](http://slick.typesafe.com/doc/3.0.0/sql.html)を用いて欲しい。
<!-- For database functions that return complete tables or stored procedures please use sql. Stored procedures that return multiple result sets are currently not supported.  -->

Using Custom Scalar Types in Queries
------------------------------------

もしカラムに対しカスタマイズした型を適用したいのなら、[ColumnType](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcProfile@ColumnType[T]:JdbcDriver.ColumnType[T])を実装して欲しい。大抵の場合においてアプリケーション特有の型を、データベースにおいて既にサポートされた型へマッピングする。これを実現するには、[MappedColumnType](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcProfile@MappedColumnType:JdbcDriver.MappedJdbcType.type)を用いて、これに対するボイラープレートを実装するだけで済む。これはドライバをimportする中に含まれており、[JdbcDriver](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcDriver$)のシングルトンオブジェクトから別途importしなくて良い。
<!-- If you need a custom column type you can implement ColumnType \<slick.driver.JdbcProfile@ColumnType[T]:JdbcDriver.ColumnType[T]\>. The most common scenario is mapping an application-specific type to an already supported type in the database. This can be done much simpler by using MappedColumnType \<slick.driver.JdbcProfile@MappedColumnType:JdbcDriver.MappedJdbcType.type\> which takes care of all the boilerplate. It comes with the usual import from the driver. Do not import it from the JdbcDriver \<slick.driver.JdbcDriver$\> singleton object.  -->

```scala
// booleanの代数的表現
sealed trait Bool
case object True extends Bool
case object False extends Bool
...
// BoolをIntの1と0にマッピングするためのColumnType
implicit val boolColumnType = MappedColumnType.base[Bool, Int](
  { b => if(b == True) 1 else 0 },    // map Bool to Int
  { i => if(i == 1) True else False } // map Int to Bool
)
...
// この状態で、Boolをビルトインされた型としてテーブルやクエリで利用出来る。
```

[MappedJdbcType](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcProfile@MappedJdbcType)を使うと、もっと柔軟なマッピングが行える。
<!-- You can also subclass MappedJdbcType \<slick.driver.JdbcProfile@MappedJdbcType\> for a bit more flexibility.  -->

もし既にサポートされた型のラッパークラス（ケースクラスやバリュークラスになりえるもの）があるのなら、マクロで生成される暗黙的な`ColumnType`を自由に取得出来る[MappedTo](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.MappedTo)を継承したものを利用する。そのようなラッパークラスは一般的に型安全でテーブル特有な主キーの型に対ししばしば用いられる。
<!-- If you have a wrapper class (which can optionally be a case class and/or value class) for an underlying value of some supported type, you can make it extend slick.lifted.MappedTo to get a macro-generated implicit `ColumnType` for free. Such wrapper classes are commonly used for type-safe table-specific primary key types:  -->

```scala
// カスタマイズされたテーブルのID型
case class MyID(value: Long) extends MappedTo[Long]
...
// MyIDをテーブルのID型としてそのまま用いる -- 特別なボイラープレートは必要ない
class MyTable(tag: Tag) extends Table[(MyID, String)](tag, "MY_TABLE") {
  def id = column[MyID]("ID")
  def data = column[String]("DATA")
  def * = (id, data)
}
```

Using Custom Record Types in Queries
------------------------------------

個々に宣言されたいくつかの型を用いてレコード型というのは構成される。SlickはScalaのタプルをサポートしている以外にも、22個より大きい数のカラム数に対応するためにSlick独自に[HList](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.collection.heterogeneous.HList)というものを用意している。
<!-- Record types are data structures containing a statically known number of components with individually declared types. Out of the box, Slick supports Scala tuples (up to arity 22) and Slick's own slick.collection.heterogeneous.HList implementation. Record types can be nested and mixed arbitrarily.  -->

カスタマイズされたレコード型（ケースクラス、カスタマイズされたHLists、タプルに似た型など...）を用いるために、Slickに対しどのようにしてクエリと結果型をマッピングするのかといいうのを伝える必要がある。これに対しては、[MappedScalaProductShape](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.MappedScalaProductShape)を継承した[Shape](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.Shape)を用いると良い。
<!-- In order to use custom record types (case classes, custom HLists, tuple-like types, etc.) in queries you need to tell Slick how to map them between queries and results. You can do that using a slick.lifted.Shape extending slick.lifted.MappedScalaProductShape.  -->

### Polymorphic Types (e.g. Custom Tuple Types or HLists)

ポリモーフィックなレコード型の顕著な特徴として、それは要素となる型を抽象化することがあげられる。つまり、持ち上げられた要素の型と生の要素の型の双方で同じレコード型を用いることが出来るのである。カスタマイズしたポリモーフィックなレコード型を利用するには、適切な暗黙的[Shape](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.Shape)を用意してあげたら良い。
<!-- The distinguishing feature of a *polymorphic* record type is that it abstracts over its element types, so you can use the same record type for both, lifted and plain element types. You can add support for custom polymorphic record types using an appropriate implicit slick.lifted.Shape.  -->

`Pair`というクラスを使う例は以下のようになる。
<!-- Here is an example for a type `Pair`:  -->

```scala
// カスタマイズされたレコード型
case class Pair[A, B](a: A, b: B)
...
// PairのためのShape実装
final class PairShape[Level <: ShapeLevel, M <: Pair[_,_], U <: Pair[_,_] : ClassTag, P <: Pair[_,_]](
  val shapes: Seq[Shape[_, _, _, _]])
extends MappedScalaProductShape[Level, Pair[_,_], M, U, P] {
  def buildValue(elems: IndexedSeq[Any]) = Pair(elems(0), elems(1))
  def copy(shapes: Seq[Shape[_ <: ShapeLevel, _, _, _]]) = new PairShape(shapes)
}
...
implicit def pairShape[Level <: ShapeLevel, M1, M2, U1, U2, P1, P2](
  implicit s1: Shape[_ <: Level, M1, U1, P1], s2: Shape[_ <: Level, M2, U2, P2]
) = new PairShape[Level, Pair[M1, M2], Pair[U1, U2], Pair[P1, P2]](Seq(s1, s2))
```

この例における暗黙的なメソッドである`pairShape`は、個々の要素型のためのShapeをいつでも利用可能な2つの要素型の`Pair`に対し使われるShapeを提供するものである。
<!-- The implicit method `pairShape` in this example provides a Shape for a `Pair` of two element types whenever Shapes for the individual element types are available.  -->

これらの定義を用いれば、Slickを利用するどの場所においても`Pair`をレコード型として利用出来る。
<!-- With these definitions in place, we can use the `Pair` record type in every location in Slick where a tuple or `HList` would be acceptable:  -->

```scala
// テーブル定義にPairを利用する
class A(tag: Tag) extends Table[Pair[Int, String]](tag, "shape_a") {
  def id = column[Int]("id", O.PrimaryKey)
  def s = column[String]("s")
  def * = Pair(id, s)
}
val as = TableQuery[A]
...
// カスタマイズされた型のデータを挿入する
val insertAction = DBIO.seq(
  as += Pair(1, "a"),
  as += Pair(2, "c"),
  as += Pair(3, "b")
)
...
// クエリからPairを返却してもらう
val q2 = as
  .map { case a => Pair(a.id, (a.s ++ a.s)) }
  .filter { case Pair(id, _) => id =!= 1 }
  .sortBy { case Pair(_, ss) => ss }
  .map { case Pair(id, ss) => Pair(id, Pair(42 , ss)) }
// returns: Vector(Pair(3,Pair(42,"bb")), Pair(2,Pair(42,"cc")))
```

### Monomorphic Case Classes

カスタマイズされたケースクラスが単一的なレコード型としてしばしば用いられる（要素型が固定されたレコード型など）。Slickにおいてこのようなケースクラスを用いるためには、レコードの生の値を取り扱うケースクラスを定義するのに加えて、持ち上げられたレコードの値を取り扱うケースクラスを定義する必要がある。
<!-- Custom *case classes* are frequently used as monomorphic record types (i.e. record types where the element types are fixed). In order to use them in Slick, you need to define the case class for a record of plain values (as usual) plus an additional case class for a matching record of lifted values.  -->

カスタマイズしたケースクラスの[Shape](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.Shape)を提供するためには、[CaseClassShape](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.CaseClassShape)を用いると良い。
<!-- In order to provide a slick.lifted.Shape for a custom case class, you can use slick.lifted.CaseClassShape:  -->

```scala
// 2つのケースクラスを用意
case class LiftedB(a: Rep[Int], b: Rep[String])
case class B(a: Int, b: String)
...
// 定義したケースクラスに対するマッピング
implicit object BShape extends CaseClassShape(LiftedB.tupled, B.tupled)
...
class BRow(tag: Tag) extends Table[B](tag, "shape_b") {
  def id = column[Int]("id", O.PrimaryKey)
  def s = column[String]("s")
  def * = LiftedB(id, s)
}
val bs = TableQuery[BRow]
...
val insertActions = DBIO.seq(
  bs += B(1, "a"),
  bs.map(b => (b.id, b.s)) += ((2, "c")),
  bs += B(3, "b")
)
...
val q3 = bs
  .map { case b => LiftedB(b.id, (b.s ++ b.s)) }
  .filter { case LiftedB(id, _) => id =!= 1 }
  .sortBy { case LiftedB(_, ss) => ss }
...
// returns: Vector(B(3,"bb"), B(2,"cc"))
```

このメカニズムは、_<>_ オペレータを用いたクライアントサイドマッピングの代わりとして用いられている。これにはすこしばかりボイラープレートが必要になるが、生のレコードと持ち上げられたレコードの双方において同じフィールド名を持たせてくれる。
<!-- Note that this mechanism can be used as an alternative to client-side mappings with the \<\> operator. It requires a bit more boilerplate but allows you to use the same field names in both, plain and lifted records.  -->

### Combining Mapped Types

以下の例では、マッピングされたケースクラスと、他でマッピングされたケースクラスでマッピングされた`Pair`の2つを組み合わせている。
<!-- In the following example we are combining a mapped case class and the mapped `Pair` type in another mapped case class.  -->

```scala
// 複数のマッピングされた型を組み合わせている
case class LiftedC(p: Pair[Rep[Int],Rep[String]], b: LiftedB)
case class C(p: Pair[Int,String], b: B)
...
implicit object CShape extends CaseClassShape(LiftedC.tupled, C.tupled)
...
class CRow(tag: Tag) extends Table[C](tag, "shape_c") {
  def id = column[Int]("id")
  def s = column[String]("s")
  def projection = LiftedC(
    Pair(column("p1"),column("p2")), // (cols defined inline, type inferred)
    LiftedB(id,s)
  )
  def * = projection
}
val cs = TableQuery[CRow]
...
val insertActions2 = DBIO.seq(
  cs += C(Pair(7,"x"), B(1,"a")),
  cs += C(Pair(8,"y"), B(2,"c")),
  cs += C(Pair(9,"z"), B(3,"b"))
)
...
val q4 = cs
  .map { case c => LiftedC(c.projection.p, LiftedB(c.id,(c.s ++ c.s))) }
  .filter { case LiftedC(_, LiftedB(id,_)) => id =!= 1 }
  .sortBy { case LiftedC(Pair(_,p2), LiftedB(_,ss)) => ss++p2 }
...
// returns: Vector(C(Pair(9,"z"),B(3,"bb")), C(Pair(8,"y"),B(2,"cc")))
```

Slick 3.0.0 documentation - 10 Plain SQL Queries

[Permalink to Plain SQL Queries — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/sql.html)

Plain SQL Queries
=================

もしかすると、高レベルに抽象化されてサポートされたオペレーションに対し、SQLコードをそのまま書きたいといった要求があるかもしれない。低レベルな[JDBC](http://en.wikipedia.org/wiki/Java_Database_Connectivity)のAPIを用いるのではなく、Slickが提供するScalaベースの _Plain SQL_ を利用して欲しい。
<!-- Sometimes you may need to write your own SQL code for an operation which is not well supported at a higher level of abstraction. Instead of falling back to the low level of JDBC\_, you can use Slick's *Plain SQL* queries with a much nicer Scala-based API.  -->

> **Note**
>
> 本章の残りでは、[Slick Plain SQL Queries template](https://typesafe.com/activator/template/slick-plainsql-3.0)をベースに説明を行う。[Activator](https://typesafe.com/activator)からテンプレートを落としてきて、直接編集したり実行しながら読んでみて欲しい。
<!-- **note** The rest of this chapter is based on the Slick Plain SQL Queries template\_. The prefered way of reading this introduction is in Activator\_, where you can edit and run the code directly while reading the tutorial.  -->

Scaffolding
-----------

データベースのコネクションは、[同じように](http://slick.typesafe.com/doc/3.0.0/gettingstarted.html#gettingstarted-dbconnection)開かれる。全ての _Plain SQL_ [DBIOActions](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction)内で実行される。これは複数のアクションを組み合わせたものにもなりえる。
<!-- The database connection is opened in the usual way \<gettingstarted-dbconnection\>. All *Plain SQL* queries result in DBIOActions \<slick.dbio.DBIOAction\> that can be composed and run like any other action.  -->

String Interpolation
--------------------

Slickの _Plain SQL_ は`sql`、`sqlu`、`tsql`という文字列の補間（string interpolation）を通して組み立てることが出来る。これらはSlickドライバーから`api._`をインポートする事で利用可能となる。
<!-- *Plain SQL* queries in Slick are built via string interpolation using the `sql`, `sqlu` and `tsql` interpolators. They are available through the standard `api._` import from a Slick driver:  -->

```scala
import slick.driver.H2Driver.api._
```

最も簡単な使用法としては、以下のようなメソッドの中で利用しているように、`sqlu`の中にSQLコードをそのまま書いてしまうことだ。
<!-- You can see the simplest use case in the following methods where the `sqlu` interpolator is used with a literal SQL string:  -->

```scala
def createCoffees: DBIO[Int] =
  sqlu"""create table coffees(
    name varchar not null,
    sup_id int not null,
    price double not null,
    sales int not null,
    total int not null,
    foreign key(sup_id) references suppliers(id))"""
...
def createSuppliers: DBIO[Int] =
  sqlu"""create table suppliers(
    id int not null primary key,
    name varchar not null,
    street varchar not null,
    city varchar not null,
    state varchar not null,
    zip varchar not null)"""
...
def insertSuppliers: DBIO[Unit] = DBIO.seq(
  // Insert some suppliers
  sqlu"insert into suppliers values(101, 'Acme, Inc.', '99 Market Street', 'Groundsville', 'CA', '95199')",
  sqlu"insert into suppliers values(49, 'Superior Coffee', '1 Party Place', 'Mendocino', 'CA', '95460')",
  sqlu"insert into suppliers values(150, 'The High Ground', '100 Coffee Lane', 'Meadows', 'CA', '93966')"
)
```

`sqlu`補間子は、結果の代わり列の数を返すDMLステートメントとして用いられる。それゆえ、`sqlu`を用いた場合は返り値の型が`DBIO[Int]`となる。
<!-- The `sqlu` interpolator is used for DML statements which produce a row count instead of a result set. Therefore they are of type `DBIO[Int]`.  -->

クエリに注入される変数や表現は、クエリ文字列の中でバインド変数などで表される。クエリ文字列に直接変数を入れることはしない。このような対応は、SQLインジェクションをなくすためにある。以下の例を見て欲しい。
<!-- Any variable or expression injected into a query gets turned into a bind variable in the resulting query string. It is not inserted directly into a query string, so there is no danger of SQL injection attacks. You can see this used in here:  -->

```scala
def insert(c: Coffee): DBIO[Int] =
  sqlu"insert into coffees values (${c.name}, ${c.supID}, ${c.price}, ${c.sales}, ${c.total})"
```

このメソッドにより生成されるSQLステートメントは、常に同じものになる。
<!-- The SQL statement produced by this method is always the same: -->

```sql
insert into coffees values (?, ?, ?, ?, ?)
```

この種のコードに役立つ便利な[DBIO.sequence][DBIO.sequence]コンビネータは以下のように利用できる。
<!-- Note the use of the DBIO.sequence \<slick.dbio.DBIO$@sequence[R,M[+\_]\<:TraversableOnce[\_],E\<:Effect](M[DBIOAction[R,NoStream,E]])(CanBuildFrom[M[DBIOAction[R,NoStream,E]],R,M[R]]):DBIOAction[M[R],NoStream,E]\> combinator which is useful for this kind of code:  -->

```scala
val inserts: Seq[DBIO[Int]] = Seq(
  Coffee("Colombian", 101, 7.99, 0, 0),
  Coffee("French_Roast", 49, 8.99, 0, 0),
  Coffee("Espresso", 150, 9.99, 0, 0),
  Coffee("Colombian_Decaf", 101, 8.99, 0, 0),
  Coffee("French_Roast_Decaf", 49, 9.99, 0, 0)
).map(insert)
...
val combined: DBIO[Seq[Int]] = DBIO.sequence(inserts)
combined.map(_.sum)
```

与えられた順序でデータベースのI/Oアクションを直列に実行するシンプルな[DBIO.seq][DBIO.seq]とは異なり、[DBIO.sequence][DBIO.sequence]は個々のアクションの結果を保護するために、`Seq[DBIO[T]]`を`DBIO[Seq[T]]`へ変換する。これは挿入時に影響のあった列の数を数え上げる際などに用いられている。
<!-- Unlike the simpler DBIO.seq \<slick.dbio.DBIO$@seq[E\<:Effect](DBIOAction[\_,NoStream,E]\*):DBIOAction[Unit,NoStream,E]\> combinator which runs a (varargs) sequence of database I/O actions in the given order and discards the return values, DBIO.sequence \<slick.dbio.DBIO$@sequence[R,M[+\_]\<:TraversableOnce[\_],E\<:Effect](M[DBIOAction[R,NoStream,E]])(CanBuildFrom[M[DBIOAction[R,NoStream,E]],R,M[R]]):DBIOAction[M[R],NoStream,E]\> turns a `Seq[DBIO[T]]` into a `DBIO[Seq[T]]`, thus preserving the results of all individual actions. It is used here to sum up the affected row counts of all inserts.  -->

Result Sets
-----------

以下のコードでは、ステートメントにより得られた結果を返却する`sql`補間子を利用している。`sql`補間子自身は`DBIO`の値を生成したりはしない。これは、`.as`というメソッドを返り値となる型を組み合わせて呼び出す必要がある。
<!-- The following code uses tbe `sql` interpolator which returns a result set produced by a statement. The interpolator by itself does not produce a `DBIO` value. It needs to be followed by a call to `.as` to define the row type:  -->

```scala
sql"""select c.name, s.name
      from coffees c, suppliers s
      where c.price < $price and s.id = c.sup_id""".as[(String, String)]
```

この結果の型は、`DBIO[Seq[(String, String)]]`となる。`as`を呼び出す際には、結果から要求する型の値を抽出する[GetResult](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.GetResult)パラメータを暗黙的に必要としている。基本的なJDBCの型やOption、タプルなどに対する`GetResult`は予め定義されている。それ以外の型に対する`GetResult`は、各自で定義して欲しい。
<!-- This results in a `DBIO[Seq[(String, String)]]`. The call to `as` takes an implicit slick.jdbc.GetResult parameter which extracts data of the requested type from a result set. There are predefined `GetResult` implicits for the standard JDBC types, for Options of those (to represent nullable columns) and for tuples of types which have a `GetResult`. For non-standard return types you have to define your own converters:  -->

```scala
// 適当なケースクラス
case class Supplier(id: Int, name: String, street: String, city: String, state: String, zip: String)
case class Coffee(name: String, supID: Int, price: Double, sales: Int, total: Int)
...
// 結果を抽出するためにGetResult
implicit val getSupplierResult = GetResult(r => Supplier(r.nextInt, r.nextString, r.nextString,
  r.nextString, r.nextString, r.nextString))
implicit val getCoffeeResult = GetResult(r => Coffee(r.<<, r.<<, r.<<, r.<<, r.<<))
```

`GetResult[T]`は`PositionedResult => T`という関数の単なるラッパーにすぎない。`Supplier`のための暗黙的な`GetResult`は、列から`Int`か`String`の値を読み出すために明示的な`PositionedResult`を用いている。2個めの`Coffee`の例では、期待する型を自動的に導出しようと試みる`<<`というショートカットメソッドを利用している（コンストラクタの呼び出しに対して明らかに型が導出出来る場合にのみ利用可能）。
<!-- `GetResult[T]` is simply a wrapper for a function `PositionedResult => T`. The implicit val for `Supplier` uses the explicit `PositionedResult` methods `getInt` and `getString` to read the next `Int` or `String` value in the current row. The second one uses the shortcut method `<<` which returns a value of whatever type is expected at this place. (Of course you can only use it when the type is actually known like in this constructor call.  -->

Splicing Literal Values
-----------------------

パラメータはSQLステートメントに対してバインド変数を用いて挿入されるわけだが、動的に生成されたSQLコードを呼び出すために...といった場合など、もしかすると直接ステートメントの中にリテラルを書く必要が生じるかもしれない。このような場合には以下の例のように、全ての補間子の中で`$`の代わりに`#$`を用いて変数をバインドしてあげれば良い。
<!-- While most parameters should be inserted into SQL statements as bind variables, sometimes you need to splice literal values directly into the statement, for example to abstract over table names or to run dynamically generated SQL code. You can use `#$` instead of `$` in all interpolators for this purpose, as shown in the following piece of code:  -->

```scala
val table = "coffees"
sql"select * from #$table where name = $name".as[Coffee].headOption
```

Type-Checked SQL Statements
---------------------------

今まで見てきた補間子は、SQLステートメントを実行時に構築する。これはステートメントを構築する安全で簡単な方法となっている一方、単なる埋め込み文字列にしか過ぎない。もしステートメントにシンタックスエラーがあったり、データベースとScalaのコードに何かしら型の違いがあったする場合にも、コンパイル時に検出が出来なく、非常に残念である。そこで、`sql`補間子の代わりに`tsql`補間子を使う事を検討してみてはどうだろうか。
<!-- The interpolators you have seen so far only construct a SQL statement at runtime. This provides a safe and easy way of building statements but they are still just embedded strings. If you have a syntax error in a statement or the types don't match up between the database and your Scala code, this cannot be detected at compile-time. You can use the `tsql` interpolator instead of `sql` to get just that:  -->

```scala
def getSuppliers(id: Int): DBIO[Seq[(Int, String, String, String, String, String)]] =
  tsql"select * from suppliers where id > $id"
```

`tsql`は`.as`を呼び出す必要無しに、直接`DBIOAction`を生成する。
<!-- Note that `tsql` directly produces a `DBIOAction` of the correct type without requiring a call to `.as`.  -->

コンパイラをデータベースにアクセスさせるために、コンパイル時に解決できる設定を提供してあげる必要がある。これは[StaticDatabaseConfig](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.backend.StaticDatabaseConfig)アノテーションを利用して明示する。
<!-- In order to give the compiler access to the database, you have to provide a configuration that can be resolved at compile-time. This is done with the slick.backend.StaticDatabaseConfig annotation:  -->

```scala
@StaticDatabaseConfig("file:src/main/resources/application.conf#tsql")
```

上の例だと、`application.conf`というファイルにおける、`"tsql"`というパスを指し示しており、ここには`Database`の設定だけではなく、[StaticDatabaseConfig](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.backend.StaticDatabaseConfig)オブジェクトのための適切な設定を記述しなくてはならない。
<!-- In this case it points to the path "tsql" in a local `application.conf` file, which must contain an appropriate configiration for a slick.backend.StaticDatabaseConfig object, not just a `Database`.  -->

> **Note**
>
> パスを省いたり、URLのフラグメントのみを指定したりすると、クラスパスにある中から`application.conf`を見つけようとする。また、`resource:`というURLスキーマを利用しても良いが、いずれにしても実行時のクラスパスと異なり、コンパイラ時のクラスパスからそれらは見えるようにする必要がある。ビルドツールによっては設定が出来ないかもしれないため、基本的には`file:`のURLスキーマで相対パスを指定するのが良い。

<!-- **note** You can get `application.conf` resolved via the classpath (as usual) by omitting the path and only specifying a fragment in the URL, or you can use a `resource:` URL scheme for referencing an arbitrary classpath resouce, but in both cases, they have to be on the *compiler's* own classpath, not just the source path or the runtime classpath. Depending on the build tool this may not be possible, so it's usually better to use a relative `file:` URL.  -->

実行時に、設定のされた[DatabaseConfig](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.backend.DatabaseConfig)を取得させても構わない。
<!-- You can also retrieve the statically configured slick.backend.DatabaseConfig at runtime:  -->

```scala
val dc = DatabaseConfig.forAnnotation[JdbcProfile]
import dc.driver.api._
val db = dc.db
```

ここでは、基本的な`api._`というインポートと`Database`を利用している。同じ設定を用いさせることは特に強制しておらず、Slickドライバと`Database`を他の方法で実行時に渡しても良いし、コンパイル時のチェックのみに`StaticDatabaseConfig`を利用するといった方法も1つの選択肢として考えられる。
<!-- This gives you the Slick driver for the standard `api._` import and the `Database`. Note that it is not mandatory to use the same configuration. You can get a Slick driver and `Database` at runtime in any other way you like and only use the `StaticDatabaseConfig` for compile-time checking.  -->

[DBIO.sequence]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIO$@sequence[R,M[+_]<:TraversableOnce[_],E<:Effect](M[DBIOAction[R,NoStream,E]])(CanBuildFrom[M[DBIOAction[R,NoStream,E]],R,M[R]]):DBIOAction[M[R],NoStream,E])
[DBIO.seq]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIO$@seq[E<:Effect](DBIOAction[_,NoStream,E]*):DBIOAction[Unit,NoStream,E]

Slick 3.0.0 documentation - 11 Coming from ORM to Slick

[Permalink to Coming from ORM to Slick — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/orm-to-slick.html)

Coming from ORM to Slick
========================

Introduction
------------
Slickは、Hibernateや他の[JPA](http://en.wikipedia.org/wiki/Java_Persistence_API)ベースのプロダクトのようなORM（object-relational mapper）では無い。SlickはORMのようにデータを永続化させるソリューションの1つであり、いくつかのコンセプトは共有しつつも、大きな違いがいくつかある。本章ではSlickのメリットについての理解を手助けしつつ、ORMとの違いについて順に説明する。object-relationalなものに対して言及される様々な問題（object-relation-impedance mismatch）をSlickは上手く取り扱っていることについても説明したい。
<!-- Slick is not an object-relational mapper (ORM) like Hibernate or other JPA\_-based products. Slick is a data persistence solution like ORMs and naturally shares some concepts, but it also has significant differences. This chapter explains the differences in order to help you get the best out of Slick and avoid confusion for those familiar with ORMs. We explain how Slick manages to avoid many of the problems often referred to as the object-relational impedance mismatch.  -->

SlickはFRM（functional-relational mapper）である、と表現されるのが良い。Slickはイミュータブルなコレクションをもとにして関係データを取り扱っており、より自由なクエリ生成とうまくコントロールされた副作用に対し、特に焦点を当てた作りになっている。ORMでは一般的にミュータブルなオブジェクトグラフをむき出しにし、read-・write-cachesのような副作用や、ハードコードサポート（継承を利用したユースケースや関連テーブルを通した関連の取得など）を利用してしまっている事が多い。ORMではオブジェクトグラフの永続化に焦点を当てている一方、Slickは関連データストアにアクセスする最も良い方法に焦点を当てている。

<!-- A good term to describe Slick is functional-relational mapper. Slick allows working with relational data much like with immutable collections and focuses on flexible query composition and strongly controlled side-effects. ORMs usually expose mutable object-graphs, use side-effects like read- and write-caches and hard-code support for anticipated use-cases like inheritance or relationships via association tables. Slick focuses on getting the best out of accessing a relational data store. ORMs focus on persisting an object-graph.  -->

ORMはオブジェクト指向言語からデータベースを利用する際には、自然なアプローチをとっている。ORMではデータがメモリ内に残っていたとしても、オブジェクトグラフを部分的に永続化させようとする。オブジェクトは編集可能、関連も変更が可能であり、オブジェクトグラフは色々と状態が変化する。実のところ、このようなものに対して正確に保存をするのは簡単ではない。それゆえこの問題を object-relation impedance mismatchと呼んでいる。これはORMの実装をを難しくさせている所以であり、ほんの少し難しいケースに対しても複雑化してしまうこともある。一方でSlickはオブジェクトグラフをむき出しにしたりはしていない。SQLIによって
<!-- ORMs are a natural approach when using databases from object-oriented languages. They try to allow working with persisted object-graphs partly as if they were completely in memory. Objects can be modified, associations can be changed and the object graph can be traversed. In practice this is not exactly easy to achieve due to the so called object-relational impedance mismatch. It makes ORMs hard to implement and often complicated to use for more than simple cases and if performance matters. Slick in contrast does not expose an object-graph. It is inspired by SQL and the relational model and mostly just maps their concepts to the most closely corresponding, type-safe Scala features. Database queries are expressed using a restricted, immutable, purely-functional subset of Scala much like collections. Slick also offer first-class SQL support \<sql\> as an alternative.  -->

<!-- In practice, ORMs often suffer from conceptual problems of what they try to achieve, from mere problems of the implementations and from mis-use, because of their complexity. In the following we look at many features of ORMs and what you would use with Slick instead. We'll first look at how to work with the object graph. We then look at a series of particular features and use cases and how to handle them with Slick.  -->

Configuration
-------------

<!-- Some ORMs use extensive configuration files. Slick is configured using small amounts of Scala code. You have to provide information about how to connect to the database \<database\> and write or auto-generate a database-schema \<schemas\> description if you want Slick to type-check your queries. Everything else like relationship definitions \<orm-relationships\> beyond foreign keys are ordinary Scala code, which can use familiar abstraction methods for re-use.  -->

Mapping configuration.
----------------------

<!-- The later examples use the following database schema -->

![image](http://slick.typesafe.com/doc/3.0.0/_images/from-sql-to-slick.person-address.png)

<!-- mapped to Slick using the following code: -->

```scala
type Person = (Int,String,Int,Int)
class People(tag: Tag) extends Table[Person](tag, "PERSON") {
  def id = column[Int]("ID", O.PrimaryKey, O.AutoInc)
  def name = column[String]("NAME")
  def age = column[Int]("AGE")
  def addressId = column[Int]("ADDRESS_ID")
  def * = (id,name,age,addressId)
  def address = foreignKey("ADDRESS",addressId,addresses)(_.id)
}
lazy val people = TableQuery[People]
...
type Address = (Int,String,String)
class Addresses(tag: Tag) extends Table[Address](tag, "ADDRESS") {
  def id = column[Int]("ID", O.PrimaryKey, O.AutoInc)
  def street = column[String]("STREET")
  def city = column[String]("CITY")
  def * = (id,street,city)
}
lazy val addresses = TableQuery[Addresses]
```

<!-- Tables can alternatively be mapped to case classes. Similar code can be auto-generated \<code-generation\> or hand-written \<schemas\>.  -->

<!-- In ORMs you often provide your mapping specification in a configuration file. In Slick you provide it as Scala types like above, which are used to type-check Slick queries. A difference is that the Slick mapping is conceptually very simple. It only describes database tables and optionally maps rows to case classes or something else using arbitrary factories and extractors. It does contain information about foreign keys, but nothing else about relationships \<orm-relationships\> or other patterns. These are mapped using re-usable queries fragments instead.  -->

Navigating the object graph
---------------------------

### Using plain old method calls

<!-- This chapter could also be called strict vs. lazy or imperative vs. declarative. One common feature ORMs provide is using a persisted object graph just as if it was in-memory. And since it is not, artifacts like members or related objects are usually loaded ad-hoc only when they are needed. To make this happen, ORMs implement or intercept method calls, which look like they happen in-memory, but instead execute database queries as needed to return the desired results. Let's look at an example using a hypothetical ORM:  -->

```scala
val people: Seq[Person] = PeopleFinder.getByIds(Seq(2,99,17,234))
val addresses: Seq[Address] = people.map(_.address)
```

<!-- How many database round trips does this require? In fact reasoning about this question for different code is one of the things you need to devote the most time to when learning the collections-like API of an ORM. What usually happens is, that the ORM would do an immediate database round trip for `getByIds` and return the resulting people. Then `map` would be a Scala List method and `.map(_.address)` accesses the `address` of each person. An ORM would witness the `address` accesses one-by-one not knowing upfront that they happen in a loop. This often leads to an additional database round trip for each person, which is not ideal (n+1 problem), because database round trips are expensive. To solve the problem, ORMs often provide means to work around this, by basically telling them about the future, so they can aggregate multiple upcoming round trips into fewer more efficient ones.  -->

```scala
// tell the ORM to load all related addresses at once
val people: Seq[Person] = PeopleFinder.getByIds(Seq(2,99,17,234)).prefetch(_.address)
val addresses: Seq[Address] = people.map(_.address)
```

<!-- Here the prefetch method instructs the hypothetical ORM to load all addresses immediately with the people, often in only one or two database round trips. The addresses are then stored in a cache many ORMs maintain. The later `.map(_.address)` call could then be fully served from the cache. Of course this is redundant as you basically need to provide the mapping to addresses twice and if you forget to prefetch you will have poor performance. How you specify the pre-fetching rules depends on the ORM, often using external configuration or inline like here.  -->

<!-- Slick works differently. To do the same in Slick you would write the following. The type annotations are optional but shown here for clarity.  -->

```scala
val peopleQuery: Query[People,Person,Seq] = people.filter(_.id inSet(Set(2,99,17,234)))
val addressesQuery: Query[Addresses,Address,Seq] = peopleQuery.flatMap(_.address)
```

<!-- As we can see it looks very much like collection operations but the values we get are of type `Query`. They do not store results, only a plan of the operations that are needed to create a SQL query that produces the results when needed. No database round trips happen at all in our example. To actually fetch results, we can have to compile the query to a database Action \<database\> with `.result` and then `run` it on the Database.   -->

```scala
val addressesAction: DBIO[Seq[Address]] = addressesQuery.result
val addresses: Future[Seq[Address]] = db.run(addressesAction)
```

<!-- A single query is executed and the results returned. This makes database round trips very explicit and easy to reason about. Achieving few database round trips is easy.  -->

<!-- As you can see with Slick we do not navigate the object graph (i.e. results) directly. We navigate it by composing queries instead, which are just place-holder values for potential database round trip yet to happen. We can lazily compose queries until they describe exactly what we need and then use a single `Database.run` call for execution.  -->

<!-- Navigating the object graph directly in an ORM is problematic as explained earlier. Slick gets away without that feature. ORMs often solve the problem by offering a declarative query language as an alternative, which is similar to how you work with Slick. -->

### Query languages

<!-- ORMs often come with declarative query languages like JPA's JQL or Criteria API. Similar to SQL or Slick, they allow expressing queries yet to happen and make execution explicit.  -->

#### String based embeddings

<!-- Quite commonly, these languages, for example HQL, but also SQL are embedded into programs as Strings. Here is an example for HQL.  -->

```Scala
val hql: String = "FROM Person p WHERE p.id in (:ids)"
val q: Query = session.createQuery(hql)
q.setParameterList("ids", Array(2,99,17,234))
```

<!-- Strings are a very simple way to embed an arbitrary language and in many programming languages the only way without changing the compiler, for example in Java. While simple, this kind of embedding has significant limitations.  -->

<!-- One issue is that tools often have no knowledge about the embedded language and treat queries as ordinary Strings. The compilers or interpreters of the host languages do not detect syntactical mistakes upfront or if the query produces a different type of result than expected. Also IDEs often do not provide syntax highlighting, code completion, inline error hints, etc.  -->

<!-- More importantly, re-use is very hard. You would need to compose Strings in order to re-use certain parts of queries. As an exercise, try to make the id filtering part of our above HQL example re-useable, so we can use it for table person as well as address. It is really cumbersome.  -->

<!-- In Java and many other languages, strings are the only way to embed a concise query language. As we will see in the next sections, Scala is more flexible.  -->

#### Method based APIs

<!-- Instead of getting the ultimate flexibility for the embedded language, an alternative approach is to go with the extensibility features of the host language and use those. Object-oriented languages like Java and Scala allow extensibility through the definition of APIs consisting of objects and methods. JPA's Criteria API use this concept and so does Slick. This allows the host language tools to partially understand the embedded language and provide better support for the features mentioned earlier. Here is an example using Criteria Queries.  -->

```scala
val id = Property.forName("id")
val q = session.createCriteria(classOf[Person])
               .add( id in Array(2,99,17,234) )
```

<!-- A method based embedding makes queries compositional. Factoring out filtering by ids becomes easy:  -->

```scala
def byIds(c: Criteria, ids: Array[Int]) = c.add( id in ids )
...
val c = byIds(
  session.createCriteria(classOf[Person]),
  Array(2,99,17,234)
)
```

<!-- Of course ids are a trivial example, but this becomes very useful for more complex queries.  -->

<!-- Java APIs like JPA's Criteria API do not use Scala's operator overloading capabilities. This can lead to more cumbersome and less familiar code when expressing queries. Let's query for all people younger 5 or older than 65 for example.  -->

```scala
val age = Property.forName("age")
val q = session.createCriteria(classOf[Person])
               .add(
                 Restrictions.disjunction
                   .add(age lt 5)
                   .add(age gt 65)
               )
```

<!-- With Scala's operator overloading we can do better and that's what Slick uses. Queries are very concise. The same query in Slick would look like this:  -->

```scala
val q = people.filter(p => p.age < 5 || p.age > 65)
```

<!-- There are some limitations to Scala's overloading capabilities that affect Slick. In queries, one has to use `===` instead of `==`, `=!=` instead of `!=` and `++` for string concatenation instead of `+`. Also it is not possible to overload `if` expressions in Scala. Instead Slick comes with a small DSL for SQL case expressions \<case\>.  -->

<!-- As already mentioned, we are working with placeholder values, merely describing the query, not executing it. Here's the same expression again with added type annotations to allow us looking behind the scenes a bit:  -->

```scala
val q = (people: Query[People, Person, Seq]).filter(
  (p: People) =>
    (
      ((p.age: Rep[Int]) < 5 || p.age > 65)
      : Rep[Boolean]
  )
)
```

<!-- `Query` marks collection-like query expressions, e.g. a whole table. `People` is the Slick Table subclass defined for table person. In this context it may be confusing that the value is used rather as a prototype for a row here. It has members of type `Rep` representing the individual columns. Expressions based on these columns result in other expressions of type `Rep`. Here we are using several `Rep[Int]` to compute a `Rep[Boolean]`, which we are using as the filter expression. Internally, Slick builds a tree from this, which represents the operations and is used to produce the corresponding SQL code. We often call this process of building up expression trees encapsulated in place-holder values as lifting expressions, which is why we also call this query interface the *lifted embedding* in Slick.  -->

<!-- It is important to note that Scala allows to be very type-safe here. E.g. Slick supports a method `.substring` for `Rep[String]` but not for `Rep[Int]`. This is impossible in Java and Java APIs like Criteria Queries, but possible in Scala using type-parameter based method extensions via implicits. This allows tools like the Scala compiler and IDEs to understand the code much more precisely and offer better checking and support.  -->

<!-- A nice property of a Slick-like query language is, that it can be used with Scala's comprehension syntax, which is just Scala-builtin syntactic sugar for collections operations. The above example can alternatively be written as  -->

```scala
for( p <- people if p.age < 5 || p.age > 65 ) yield p
```

<!-- Scala's comprehension syntax looks much like SQL or ORM query languages. It however lacks syntactic support for some constructs like sorting and grouping, for which one has to use the method-based api, e.g.  -->

```scala
( for( p <- people if p.age < 5 || p.age > 65 ) yield p ).sortBy(_.name)
```

<!-- Despite the syntactic limitations, the comprehension syntax is convenient when dealing with multiple inner joins.  -->

<!-- It is important to note that the problems of method-based query apis like Criteria Queries described above are not a conceptual limitation of ORM query languages but merely an artifact of many ORMs being Java frameworks. In principle, a Scala ORMs could offer a query language just like Slick's and they should. Comfortably compositional queries allow for a high degree of code re-use. They seem to be Slick's favorite feature for many developers.  -->

#### Macro-based embeddings

<!-- Scala macros allow other approaches for embedding queries. They can be used to check queries embedded as Strings at compile time. They can also be used to translate Scala code written without Query and Rep place holder types to SQL. Both approaches are being prototyped and evaluated for Slick but are not ready for prime-time yet. There are other database libraries out there that already use macros for their query language.  -->

Query granularity
-----------------

<!-- With ORMs it is not uncommon to treat objects or complete rows as the smallest granularity when loading data. This is not necessarily a limitation of the frameworks, but a habit of using them. With Slick it is very much encouraged to only fetch the data you actually need. While you can map rows to classes with Slick, it is often more efficient to not use that feature, but to restrict your query to the data you actually need in that moment. If you only need a person's name and age, just map to those and return them as a tuple.  -->

```scala
people.map(p => (p.name, p.age))
```

<!-- This allows you to be very precise about what data is actually transferred.  -->

Read caching
------------

<!-- Slick doesn't cache query results. Working with Slick is like working with JDBC in this regard. Many ORMs come with read and write caches. Caches are side-effects. They can be hard to reason about. It can be tricky to manage cache consistency and lifetime.  -->

```scala
PeopleFinder.getById(5)
```

<!-- This call may be served from the database or from a cache. It is not clear at the call site what the performance is. With Slick it is very clear that executing a query leads to a database round trip and that Slick doesn't interfere with member accesses on objects.  -->

```scala
db.run(people.filter(_.id === 5).result)
```

<!-- Slick returns a consistent, immutable snapshot of a fraction of the database at that point in time. If you need consistency over multiple queries, use transactions.  -->

Writes (and caching)
--------------------

<!-- Writes in many ORMs require write caching to be performant. -->

```scala
val person = PeopleFinder.getById(5)
person.name = "C. Vogt"
person.age = 12345
session.save
```

<!-- Here our hypothetical ORM records changes to the object and the `.save` method syncs back changes into the database in a single round trip rather than one per member. In Slick you would do the following instead:  -->

```scala
val personQuery = people.filter(_.id === 5)
personQuery.map(p => (p.name,p.age)).update("C. Vogt", 12345)
```

<!-- Slick embraces declarative transformations. Rather than modifying individual members of objects one after the other, you state all modifications at once and Slick creates a single database round trip from it without using a cache. New Slick users seem to be often confused by this syntax, but it is actually very neat. Slick unifies the syntax for queries, inserts, updates and deletes. Here `personQuery` is just a query. We could use it to fetch data. But instead, we can also use it to update the columns specified by the query. Or we can use it do delete the rows.  -->

```scala
personQuery.delete // deletes person with id 5
```

<!-- For inserts, we insert into the query, that resembles the whole table and can select individual columns in the same way.  -->

```scala
people.map(p => (p.name,p.age)) += ("S. Zeiger", 54321)
```

Relationships
-------------

<!-- ORMs usually provide built-in, hard-coded support for 1-to-many and many-to-many relationships. They can be set up centrally in the configuration. In SQL on the other hand you would specify them using joins in every single query. You have a lot of flexibility what you join and how. With Slick you get the best of both worlds. Slick queries are as flexible as SQL, but also compositional. You can store fragements like join conditions in central places and use language-level abstraction. Relationships of any sort are just one thing you can naturally abstract over like in any Scala code. There is no need for Slick to hard-code support for certain use cases. You can easily implement arbitrary use cases yourself, e.g. the common 1-n or n-n relationships or even relationships spanning over multiple tables, relationships with additional discriminators, polymorphic relationships, etc.  -->

<!-- Here is an example for person and addresses. -->

```scala
implicit class PersonExtensions[C[_]](q: Query[People, Person, C]) {
// specify mapping of relationship to address
def withAddress = q.join(addresses).on(_.addressId === _.id)
}
...
val chrisQuery = people.filter(_.id === 2)
val stefanQuery = people.filter(_.id === 3)
...
val chrisWithAddress: Future[(Person, Address)] =
db.run(chrisQuery.withAddress.result.head)
val stefanWithAddress: Future[(Person, Address)] =
db.run(stefanQuery.withAddress.result.head)
```

<!-- A common question for new Slick users is how they can follow a relationships on a result. In an ORM you could do something like this:  -->

```scala
val chris: Person = PeopleFinder.getById(2)
val address: Address = chris.address
```

<!-- As explained earlier, Slick does not allow navigating the object-graph as if data was in memory, because of the problem that comes with it. Instead of navigating relationships on results you write new queries instead.  -->

```scala
val chrisQuery: Query[People,Person,Seq] = people.filter(_.id === 2)
val addressQuery: Query[Addresses,Address,Seq] = chrisQuery.withAddress.map(_._2)
val address = db.run(addressQuery.result.head)
```

<!-- If you leave out the optional type annotation and some intermediate vals it is very clean. And it is very clear where database round trips happen.  -->

<!-- A variant of this question Slick new comers often ask is how they can do something like this in Slick:  -->

```scala
case class Address( … )
case class Person( …, address: Address )
```

<!-- The problem is that this hard-codes that a Person requires an Address. It can not be loaded without it. This does't fit to Slick's philosophy of giving you fine-grained control over what you load exactly. With Slick it is advised to map one table to a tuple or case class without them having object references to related objects. Instead you can write a function that joins two tables and returns them as a tuple or association case class instance, providing an association externally, not strongly tied one of the classes.  -->

```scala
val tupledJoin: Query[(People,Addresses),(Person,Address), Seq]
      = people join addresses on (_.addressId === _.id)
...
case class PersonWithAddress(person: Person, address: Address)
val caseClassJoinResults = db.run(tupledJoin.result).map(_.map(PersonWithAddress.tupled))
```

<!-- An alternative approach is giving your classes Option-typed members referring to related objects, where None means that the related objects have not been loaded yet. However this is less type-safe then using a tuple or case class, because it cannot be statically checked, if the related object is loaded.  -->

### Modifying relationships

<!-- When manipulating relationships with ORMs you usually work on mutable collections of associated objects and inserts or remove related objects. Changes are written to the database immediately or recorded in a write cache and commited later. To avoid stateful caches and mutability, Slick handles relationship manipulations just like SQL - using foreign keys. Changing relationships means updating foreign key fields to new ids, just like updating any other field. As a bonus this allows establishing and removing associations with objects that have not been loaded into memory. Having their ids is sufficient.  -->

Inheritance
-----------

<!-- Slick does not persist arbitrary object-graphs. It rather exposes the relational data model nicely integrated into Scala. As the relational schema doesn't contain inheritance so doesn't Slick. This can be unfamiliar at first. Usually inheritance can be simply replaced by relationalships thinking along the lines of roles. Instead of foo is a bar think foo has role bar. As Slick allows query composition and abstraction, inheritance-like query-snippets can be easily implemented and put into functions for re-use. Slick doesn't provide any out of the box but allows you to flexibly come up with the ones that match your problem and use them in your queries.  -->

Code-generation
---------------

<!-- Many of the concepts described above can be abstracted over using Scala code to avoid repetition. There cases however, where you reach the limits of Scala's type system's abstraction capabilities. Code generation offers a solution to this. Slick comes with a very flexible and fully customizable code generator \<code-generation\>, which can be used to avoid repetition in these cases. The code generator operates on the meta data of the database. Combine it with your own extra meta data if needed and use it to generate Slick types, relationship accessors, association classes, etc. For more info see our Scala Days 2014 talk at <http://slick.typesafe.com/docs/> .  -->

Slick 3.0.0 documentation - 12 Coming from SQL to Slick

[Permalink to Coming from SQL to Slick — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/sql-to-slick.html)

Coming from SQL to Slick
========================

<!-- Coming from JDBC/SQL to Slick is pretty straight forward in many ways. Slick can be considered as a drop-in replacement with a nicer API for handling connections, fetching results and using a query language, which is integrated more nicely into Scala than writing queries as Strings. The main obstacle for developers coming from SQL to Slick seems to be the semantic differences of seemingly similar operations between SQL and Scala's collections API which Slick's API imitates. The following sections give a quick overview over the differences. They start with conceptual differences and then list examples of many SQL operators and their Slick equivalents \<sql-to-slick-operators\>. For a more detailed explanations of Slick's API please refer to chapter queries \<queries\> and the equivalent methods in the the Scala collections API \<scala.collection.immutable.Seq\>.  -->

Schema
------

<!-- The later examples use the following database schema -->

![image](http://slick.typesafe.com/doc/3.0.0/_images/from-sql-to-slick.person-address.png)

<!-- mapped to Slick using the following code: -->

```scala
type Person = (Int,String,Int,Int)
class People(tag: Tag) extends Table[Person](tag, "PERSON") {
  def id = column[Int]("ID", O.PrimaryKey, O.AutoInc)
  def name = column[String]("NAME")
  def age = column[Int]("AGE")
  def addressId = column[Int]("ADDRESS_ID")
  def * = (id,name,age,addressId)
  def address = foreignKey("ADDRESS",addressId,addresses)(_.id)
}
lazy val people = TableQuery[People]
...
type Address = (Int,String,String)
class Addresses(tag: Tag) extends Table[Address](tag, "ADDRESS") {
  def id = column[Int]("ID", O.PrimaryKey, O.AutoInc)
  def street = column[String]("STREET")
  def city = column[String]("CITY")
  def * = (id,street,city)
}
lazy val addresses = TableQuery[Addresses]
```

<!-- Tables can alternatively be mapped to case classes. Similar code can be auto-generated \<code-generation\> or hand-written \<schemas\>.  -->

Queries in comparison
---------------------

### JDBC Query

<!-- A JDBC query with error handling could look like this: -->

```scala
import java.sql._
Class.forName("org.h2.Driver")
val conn = DriverManager.getConnection("jdbc:h2:mem:test1")
val people = new scala.collection.mutable.MutableList[(Int,String,Int)]()
try{
  val stmt = conn.createStatement()
  try{
    val rs = stmt.executeQuery("select ID, NAME, AGE from PERSON")
    try{
      while(rs.next()){
        people += ((rs.getInt(1), rs.getString(2), rs.getInt(3)))
      }
    }finally{
      rs.close()
    }
  }finally{
    stmt.close()
  }
}finally{
  conn.close()
}
```

<!-- Slick gives us two choices how to write queries. One is SQL strings just like JDBC. The other are type-safe, composable queries.  -->

### Slick Plain SQL queries

<!-- This is useful if you either want to continue writing queries in SQL or if you need a feature not (yet) supported by Slick otherwise. Executing the same query using Slick Plain SQL, which has built-in error-handling and resource management optimized for asynchronous execution, looks like this:  -->

```scala
import slick.driver.H2Driver.api._
...
val db = Database.forConfig("h2mem1")
...
val action = sql"select ID, NAME, AGE from PERSON".as[(Int,String,Int)]
db.run(action)
```

<!-- `.list` returns a list of results. `.first` a single result. `.foreach` can be used to iterate over the results without ever materializing all results at once.  -->

### Slick type-safe, composable queries

<!-- Slick's key feature are type-safe, composable queries. Slick comes with a Scala-to-SQL compiler, which allows a (purely functional) sub-set of the Scala language to be compiled to SQL queries. Also available are a subset of the standard library and some extensions, e.g. for joins. The familiarity allows Scala developers to instantly write many queries against all supported relational databases with little learning required and without knowing SQL or remembering the particular dialect. Such Slick queries are composable, which means that you can write and re-use fragments and functions to avoid repetitive code like join conditions in a much more practical way than concatenating SQL strings. The fact that such queries are type-safe not only catches many mistakes early at compile time, but also eliminates the risk of SQL injection vulnerabilities.  -->
<!-- The same query written as a type-safe Slick query looks like this: -->

```scala
import slick.driver.H2Driver.api._
...
val db = Database.forConfig("h2mem1")
...
val query = people.map(p => (p.id,p.name,p.age))
db.run(query.result)
```

<!-- `.run` automatically returns a Seq for collection-like queries and a single value for scalar queries. `.list`, `.first` and `.foreach` are also available.  -->

<!-- A key benefit compared to SQL strings is, that you can easily transform the query by calling more methods on it. E.g. `query.filter(_.age > 18)` returns transformed query which further restricts the results. This allows to build libraries of queries, which re-use each other become much more maintainable. You can abstract over join conditions, pagination, filters, etc. -->

<!-- It is important to note that Slick needs the type-information to type-check these queries. This type information closely corresponds to the database schema and is provided to Slick in the form of Table sub classes and TableQuery values shown above.  -->

Main obstacle: Semantic API differences
---------------------------------------

<!-- Some methods of the Scala collections work a bit differently than their SQL counter parts. This seems to be one of the main causes of confusion for people newly coming from SQL to Slick. Especially groupBy\_ seems to be tricky.  -->

<!-- The best approach to write queries using Slick's type-safe api is thinking in terms of Scala collections. What would the code be if you had a Seq of tuples or case classes instead of a Slick TableQuery object. Use that exact code. If needed adapt it with workarounds where a Scala library feature is currently not supported by Slick or if Slick is slightly different. Some operations are more strongly typed in Slick than in Scala for example. Arithmetic operation in different types require explicit casts using `.asColumnOf[T]`. Also Slick uses 3-valued logic for Option inference.  -->

Scala-to-SQL compilation during runtime
---------------------------------------

<!-- Slick runs a Scala-to-SQL compiler to implement its type-safe query feature. The compiler runs at Scala run-time and it does take its time which can even go up to second or longer for complex queries. It can be very useful to run the compiler only once per defined query and upfront, e.g. at app startup instead of each execution over and over. Compiled queries \<compiled-queries\> allow you to cache the generated SQL for re-use.  -->

Limitations
-----------

<!-- When you use Slick extensively you will run into cases, where Slick's type-safe query language does not support a query operator or JDBC feature you may desire to use or produces non-optimal SQL code. There are several ways to deal with that.  -->

### Missing query operators

<!-- Slick is extensible to some degree, which means you can add some kinds of missing operators yourself.  -->

#### Definition in terms of others

<!-- If the operator you desire is expressible using existing Slick operations you can simply write a Scala function or implicit class that implements the operator as a method in terms of existing operators. Here we implement `squared` using multiplication.  -->

```scala
implicit class MyStringColumnExtensions(i: Rep[Int]){
  def squared = i * i
}
...
// usage:
people.map(p => p.age.squared)
```

#### Definition using a database function

<!-- If you need a fundamental operator, which is not supported out-of-the-box you can add it yourself if it operates on scalar values. For example Slick currently does not have a `power` method out of the box. Here we are mapping it to a database function.  -->

```scala
val power = SimpleFunction.binary[Int,Int,Int]("POWER")
...
// usage:
people.map(p => power(p.age,2))
```

<!-- More information can be found in the chapter about Scalar database functions \<scalar-db-functions\>.  -->

<!-- You can however not add operators operating on queries using database functions. The Slick Scala-to-SQL compiler requires knowledge about the structure of the query in order to compile it to the most simple SQL query it can produce. It currently couldn't handle custom query operators in that context. (There are some ideas how this restriction can be somewhat lifted in the future, but it needs more investigation). An example for such operator is a MySQL index hint, which is not supported by Slick's type-safe api and it cannot be added by users. If you require such an operator you have to write your whole query using Plain SQL. If the operator does not change the return type of the query you could alternatively use the workaround described in the following section.  -->

### Non-optimal SQL code

<!-- Slick generates SQL code and tries to make it as simple as possible. The algorithm doing that is not perfect and under continuous improvement. There are cases where the generated queries are more complicated than someone would write them by hand. This can lead to bad performance for certain queries with some optimizers and DBMS. For example, Slick occasionally generates unnecessary sub-queries. In MySQL \<= 5.5 this easily leads to unnecessary table scans or indices not being used. The Slick team is working towards generating code better factored to what the query optimizers can currently optimize, but that doesn't help you now. To work around it you have to write the more optimal SQL code by hand. You can either run it as a Slick Plain SQL query or you can [use a hack](https://gist.github.com/cvogt/d9049c63fc395654c4b4), which allows you to simply swap out the SQL code Slick uses for a type-safe query.  -->

```scala
people.map(p => (p.id,p.name,p.age))
      .result
      // inject hand-written SQL, see https://gist.github.com/cvogt/d9049c63fc395654c4b4
      .overrideSql("SELECT id, name, age FROM Person")
```

SQL vs. Slick examples
----------------------

<!-- This section shows an overview over the most important types of SQL queries and a corresponding type-safe Slick query.  -->

### SELECT \*

#### SQL

```scala
sql"select * from PERSON".as[Person]
```

#### Slick

<!-- The Slick equivalent of `SELECT *` is the `result` of the plain TableQuery:  -->

```scala
people.result
```

### SELECT

#### SQL

```scala
sql"""
  select AGE, concat(concat(concat(NAME,' ('),ID),')')
  from PERSON
""".as[(Int,String)]
```

#### Slick

<!-- Scala's equivalent for `SELECT` is `map`. Columns can be referenced similarly and functions operating on columns can be accessed using their Scala eqivalents (but allowing only `++` for String concatenation, not `+`).  -->

```scala
people.map(p => (p.age, p.name ++ " (" ++ p.id.asColumnOf[String] ++ ")")).result
```

### WHERE

#### SQL

```scala
sql"select * from PERSON where AGE >= 18 AND NAME = 'C. Vogt'".as[Person]
```

#### Slick

<!-- Scala's equivalent for `WHERE` is `filter`. Make sure to use `===` instead of `==` for comparison.  -->

```scala
people.filter(p => p.age >= 18 && p.name === "C. Vogt").result
```

### ORDER BY

#### SQL

```scala
sql"select * from PERSON order by AGE asc, NAME".as[Person]
```

#### Slick

<!-- Scala's equivalent for `ORDER BY` is `sortBy`. Provide a tuple to sort by multiple columns. Slick's `.asc` and `.desc` methods allow to affect the ordering. Be aware that a single `ORDER BY` with multiple columns is not equivalent to multiple `.sortBy` calls but to a single `.sortBy` call passing a tuple.  -->

```scala
people.sortBy(p => (p.age.asc, p.name)).result
```

### Aggregations (max, etc.)

#### SQL

```scala
sql"select max(AGE) from PERSON".as[Option[Int]].head
```

#### Slick

<!-- Aggregations are collection methods in Scala. In SQL they are called on a column, but in Slick they are called on a collection-like value e.g. a complete query, which people coming from SQL easily trip over. They return a scalar value, which can be run individually. Aggregation methods such as `max` that can return `NULL` return Options in Slick.  -->

```scala
people.map(_.age).max.result
```

### GROUP BY

<!-- People coming from SQL often seem to have trouble understanding Scala's and Slick's `groupBy`, because of the different signatures involved. SQL's `GROUP BY` can be seen as an operation that turns all columns that weren't part of the grouping key into collections of all the elements in a group. SQL requires the use of it's aggregation operations like `avg` to compute single values out of these collections.  -->

#### SQL

```scala
sql"""
  select ADDRESS_ID, AVG(AGE)
  from PERSON
  group by ADDRESS_ID
""".as[(Int,Option[Int])]
```

#### Slick

<!-- Scala's groupBy returns a Map of grouping keys to Lists of the rows for each group. There is no automatic conversion of individual columns into collections. This has to be done explicitly in Scala, by mapping from the group to the desired column, which then allows SQL-like aggregation.  -->

```scala
people.groupBy(p => p.addressId)
       .map{ case (addressId, group) => (addressId, group.map(_.age).avg) }
       .result
```

<!-- SQL requires to aggregate grouped values. We require the same in Slick for now. This means a `groupBy` call must be followed by a `map` call or will fail with an Exception. This makes Slick's grouping syntax a bit more complicated than SQL's.  -->

### HAVING

#### SQL

```scala
sql"""
  select ADDRESS_ID
  from PERSON
  group by ADDRESS_ID
  having avg(AGE) > 50
""".as[Int]
```

#### Slick

<!-- Slick does not have different methods for `WHERE` and `HAVING`. For achieving semantics equivalent to `HAVING`, just use `filter` after `groupBy` and the following `map`.  -->

```scala
people.groupBy(p => p.addressId)
       .map{ case (addressId, group) => (addressId, group.map(_.age).avg) }
       .filter{ case (addressId, avgAge) => avgAge > 50 }
       .map(_._1)
       .result
```

### Implicit inner joins

#### SQL

```scala
sql"""
  select P.NAME, A.CITY
  from PERSON P, ADDRESS A
  where P.ADDRESS_ID = a.id
""".as[(String,String)]
```

#### Slick

<!-- Slick generates SQL using implicit joins for `flatMap` and `map` or the corresponding for-expression syntax.  -->

```scala
people.flatMap(p =>
  addresses.filter(a => p.addressId === a.id)
           .map(a => (p.name, a.city))
).result
...
// or equivalent for-expression:
(for(p <- people;
    a <- addresses if p.addressId === a.id
  ) yield (p.name, a.city)
).result
```

### Explicit inner joins

#### SQL

```scala
sql"""
  select P.NAME, A.CITY
  from PERSON P
  join ADDRESS A on P.ADDRESS_ID = a.id
""".as[(String,String)]
```

#### Slick

<!-- Slick offers a small DSL for explicit joins. -->

```scala
(people join addresses on (_.addressId === _.id))
  .map{ case (p, a) => (p.name, a.city) }.result
```

### Outer joins (left/right/full)

#### SQL

```scala
sql"""
  select P.NAME,A.CITY
  from ADDRESS A
  left join PERSON P on P.ADDRESS_ID = a.id
""".as[(Option[String],String)]
```

#### Slick

<!-- Outer joins are done using Slick's explicit join DSL. Be aware that in case of an outer join SQL changes the type of outer joined, non-nullable columns into nullable columns. In order to represent this in a clean way even in the presence of mapped types, Slick lifts the whole side of the join into an `Option`. This goes a bit further than the SQL semantics because it allows you to distinguish a row which was not matched in the join from a row that was matched but already contained nothign but NULL values.  -->

```scala
(addresses joinLeft people on (_.id === _.addressId))
  .map{ case (a, p) => (p.map(_.name), a.city) }.result
```

### Subquery

#### SQL

```scala
sql"""
  select *
  from PERSON P
  where P.ID in (select ID
                 from ADDRESS
                 where CITY = 'New York City')
""".as[Person]
```

#### Slick

<!-- Slick queries are composable. Subqueries can be simply composed, where the types work out, just like any other Scala code.  -->

```scala
val address_ids = addresses.filter(_.city === "New York City").map(_.id)
people.filter(_.id in address_ids).result // <- run as one query
```

<!-- The method `.in` expects a sub query. For an in-memory Scala collection, the method `.inSet` can be used instead.  -->

### Scalar value subquery / custom function

#### SQL

```scala
sql"""
  select * from PERSON P,
                     (select rand() * MAX(ID) as ID from PERSON) RAND_ID
  where P.ID >= RAND_ID.ID
  order by P.ID asc
  limit 1
""".as[Person].head
```

#### Slick

<!-- This code shows a subquery computing a single value in combination with a user-defined database function \<userdefined\>.  -->

```scala
val rand = SimpleFunction.nullary[Double]("RAND")
...
val rndId = (people.map(_.id).max.asColumnOf[Double] * rand).asColumnOf[Int]
...
people.filter(_.id >= rndId)
      .sortBy(_.id)
      .result.head
```

### insert

#### SQL

```scala
sqlu"""
insert into PERSON (NAME, AGE, ADDRESS_ID) values ('M Odersky', 12345, 1)
"""
```

#### Slick

<!-- Inserts can be a bit surprising at first, when coming from SQL, because unlike SQL, Slick re-uses the same syntax that is used for querying to select which columns should be inserted into. So basically, you first write a query and instead of creating an Action that gets the result of this query, you call `+=` on with value to be inserted, which gives you an Action that performs the insert. `++=` allows insertion of a Seq of rows at once. Columns that are auto-incremented are automatically ignored, so inserting into them has no effect. Using `forceInsert` allows actual insertion into auto-incremented columns.  -->

```scala
people.map(p => (p.name, p.age, p.addressId)) += ("M Odersky",12345,1)
```

### update

#### SQL

```scala
sqlu"""
update PERSON set NAME='M. Odersky', AGE=54321 where NAME='M Odersky'
"""
```

#### Slick

<!-- Just like inserts, updates are based on queries that select and filter what should be updated and instead of running the query and fetching the data `.update` is used to replace it.  -->

```scala
people.filter(_.name === "M Odersky")
      .map(p => (p.name,p.age))
      .update(("M. Odersky",54321))
```

### delete

#### SQL

```scala
sqlu"""
delete PERSON where NAME='M. Odersky'
"""
```

#### Slick

<!-- Just like inserts, deletes are based on queries that filter what should be deleted. Instead of getting the query result of the query, `.delete` is used to obtain an Action that deletes the selected rows.  -->

```scala
people.filter(p => p.name === "M. Odersky")
      .delete
```

### CASE

#### SQL

```scala
sql"""
  select
    case
      when ADDRESS_ID = 1 then 'A'
      when ADDRESS_ID = 2 then 'B'
    end
  from PERSON P
""".as[Option[String]]
```

#### Slick

<!-- Slick uses a small DSL \<slick.lifted.Case$\> to allow `CASE` like case distinctions.  -->

```scala
people.map(p =>
  Case
    If(p.addressId === 1) Then "A"
    If(p.addressId === 2) Then "B"
).result
```

Slick 3.0.0 documentation - 13 Upgrade Guides

[Permalink to Upgrade Guides — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/upgrade.html)

Upgrade Guides
==============

Compatibility Policy
--------------------

<!-- Slick requires Scala 2.10 or 2.11. (For Scala 2.9 please use ScalaQuery\_, the predecessor of Slick).  -->

<!-- Slick version numbers consist of an epoch, a major and minor version, and possibly a qualifier (for milestone, RC and SNAPSHOT versions).  -->

<!-- For release versions (i.e. versions without a qualifier), backward binary compatibility is guaranteed between releases with the same epoch and major version (e.g. you could use 2.1.2 as a drop-in relacement for 2.1.0 but not for 2.0.0). Slick Extensions \<extensions\> requires at least the same minor version of Slick (e.g. Slick Extensions 2.1.2 can be used with Slick 2.1.2 but not with Slick 2.1.1). Binary compatibility is not preserved for slick-codegen, which is generally used at compile-time.  -->

<!-- We do not guarantee source compatibility but we try to preserve it within the same major release. Upgrading to a new major release may require some changes to your sources. We generally deprecate old features and keep them around for a full major release cycle (i.e. features which become deprecated in 2.1.0 will not be removed before 2.2.0) but this is not possible for all kinds of changes.  -->

<!-- Release candidates have the same compatibility guarantees as the final versions to which they lead. There are *no compatibility guarantees* whatsoever for milestones and snapshots.  -->

Upgrade from 2.1 to 3.0
-----------------------

### Package Structure

<!-- Slick has moved from package `scala.slick` to `slick`. A package object in `scala.slick` provides deprecated aliases for many common types and values.  -->

### Database I/O Actions

<!-- The `simple` and `Implicits` imports from drivers are deprecated and will be removed in Slick 3.1. You should use `api` instead, which will give you the same features, except for the old `Invoker` and `Executor` APIs for blocking execution of database calls. These have been replaced by a new monadic database I/O actions API. See Database I/O Actions \<dbio\> for details of the new API.  -->

### Join Operators

<!-- The old outer join operators did not handle `null` values correctly, requiring complicated mappings in user code, especially when using nested outer joins or outer joins over mapped entities. This is no longer necessary with the new outer join operators that lift one (left or right outer join) or both sides (full outer join) of the join into an `Option`. This is made possible by the new nested Options and non-primitive Options support in Slick.  -->

<!-- The old operators are deprecated but still available. Deprecation warnings will point you to the right replacement:  -->

-   leftJoin -\> joinLeft
-   rightJoin -\> joinRight
-   outerJoin -\> joinFull
-   innerJoin -\> join

<!-- Passing an explicit `JoinType` to the generic `join` operator does not make sense anymore with the new join semantics and is therefore deprecated, too. `join` is now used exclusively for inner joins.  -->

### first

<!-- The old Invoker API used the `first` and `firstOption` methods to get the first element of a collection-valued query. The same operations for streaming Actions in the new API are called `head` and `headOption` respectively, consistent with the names used by the Scala Collections API.  -->

### Column Type

<!-- The type `Column[T]` has been subsumed into its supertype `Rep[T]`. For operations which are only available for individual columns, an implicit `TypedType[T]` evidence is required. The more flexible handling of Option columns requires Option and non-Option columns to be treated differently when creating an implicit `Shape`. In this case the evidence needs to be of type `OptionTypedType[T]` or `BaseTypedType[T]`, respectively. If you want to abstract over both, it may be more convenient to pass the required `Shape` as an implicit parameter and let it be instantiated at the call site where the concrete type is known.  -->

<!-- `Column[T]` is still available as a deprecated alias for `Rep[T]`. Due to the required implicit evidence, it cannot provide complete backwards compatibility in all cases.  -->

### Closing Databases

<!-- Since a `Database` instance can now have an associated connection pool and thread pool, it is important to call `shutdown` or `close` when you are done using it, so that these pools can be shut down properly. You should take care to do this when you migrate to the new action-based API. As long as you exclusively use the deprecated synchronous API, it is not strictly necessary.  -->

<!-- **warning** Do not rely on the lazy initialization! Slick 3.1 will require `Database` objects to always be closed and may create connection and thread pool immediately.  -->

### Metadata API and Code Generator

<!-- The JDBC metadata API in package `slick.jdbc.meta` has been switched to the new API, producing Actions instead of Invokers. The code generator, which uses this API, has been completely rewritten for the asynchronous API. It still supports the same functionality and the same concepts but any customization of the code generator will have to be changed. See the code generator tests and the code-generation chapter for examples.  -->

### Inserting from Queries and Expressions

<!-- In Slick 2.0, soft inserts (where auto-incrementing columns are ignored) became the default for inserting raw values. Inserting from another query or a computed expression still uses force-insert semantics (i.e. trying to insert even into auto-incrementing columns, whether or not the database supports it). The new DBIO API properly reflects this by renaming `insert(Query)` to `forceInsertQuery(Query)` and `insertExpr` to `forceInsertExpr`.  -->

### Default String Types

<!-- The default type for `String` columns of unconstrained length in JdbcProfile has traditionally been `VARCHAR(254)`. Some drivers (like H2Driver) already changed it into an unconstrained string type. Slick 3.0 now also uses `VARCHAR` on PostgreSQL and `TEXT` on MySQL. The former should be harmless but MySQL's `TEXT` type is similar to `CLOB` and has some limitations (e.g. no default values and no index without a prefix length). You can use an explicit `O.Length(254)` column option to go back to the previous behavior or change the default in the application.conf key `slick.driver.MySQL.defaultStringType`.  -->

### JdbcDriver

<!-- The `JdbcDriver` object has been deprecated. You should always use the correct driver for your database system.  -->

Upgrade from 2.0 to 2.1
-----------------------

### Query type parameters

<!-- Query \<slick.lifted.Query\> now takes 3 type parameters instead of two. 2.0's `Query[T,E]` is equivalent to Slick 2.1's `Query[T,E,Seq]`. The third parameter is the collection type to be returned when executing the query using `.run`, which always returned a `Seq` in Slick 2.0. This is the only place where it is used right now. In the future we will work on making queries correspond to the behavior of the corresponding Scala collection types, i.e. `Query[_,_,Set]` having the uniqueness property, `Query[_,_,List]` being order preserving, etc. The collecton type can be changed to `C` by calling `.to[C]` on a query.  -->

<!-- To upgrade your code to 2.1 you can either rename the new Query type to something else in the import, i.e. `import ....simple.{Query=>NewQuery,_}` and then write a type alias `type Query[T,E] = NewQuery[T,E,Seq]`. Or you can add `Seq` as the third type argument in your code. This regex should work for most places: replace `([^a-zA-Z])Query\[([^\]]+), ?([^\]]+)\]` with `\1Query[\2, \3, Seq]`.  -->

### `.list` and `.first`

<!-- These methods had an empty argument list before the implicit argument list in 2.0. This has been dropped for uniformity. Calls like `.list()` need to be replaced with `.list` and `.first()` by `.first`.  -->

### `.where`

<!-- This method has been deprecated in favor of the Scala collections conformant `.filter` method.  -->

### `.isNull` and `.isNotNull`

<!-- These methods have been deprecated in favor of new Scala standard library conformant `isEmpty` and `isDefined` methods. They can now only be used on Option columns. Otherwise you get a type error. A quick workaround for using them on non-Option columns is casting them into Option columns using `.?`, e.g. `someCol.?.isDefined`. The reason that you have to do this points to using a wrong type for your column however, i.e. non-Option for a nullable column and should really be fixed in your Table definition.  -->

### Static Plain SQL Queries

<!-- The interface for using argument placeholders has been changed. Where in 2.0 you could write  -->

`StaticQuery.query[T,…]("select ...").list(someT)`

<!-- you now have to write -->

`StaticQuery.query[T,…]("select ...").apply(someT).list`

### Slick code generator / Slick model

<!-- The code generator has been moved into a separate artifact in order to evolve it faster than Slick core. it moved from package `slick.model.codegen` to package `slick.codegen`. Binary compatibility will not be guaranteed, as it is supposed to be used before compile time. Add  -->

```scala
"com.typesafe.slick" %% "slick-codegen" % "3.0.0"
```

<!-- to the dependencies of your code generator sbt project. -->

<!-- Method `SourceCodeGenerator#Table#compound` has been replaced by two methods `compoundValue` and `compoundType` generating potentially differently shaped code for values and types of compound values.  -->

<!-- Method `getTables` of the Slick drivers, which returns an Invoker for listing all default database tables has been deprecated in favor of new method `defautTables`, which returns the tables directly in order to allow Slick to exclude meta tables at this point.  -->

<!-- Method `slick.jdbc.meta.createModel(tables)` has been moved into the drivers and can now be invoked using e.g. `H2Driver.createModel(Some(tables))`  -->

<!-- The model generated by Slick now contains improved information like the database column type, length of string columns, default values for strings in MySQL. The code generator will embed the portable length into generated code and can optionally embed the non-portable database column type into generated code when overriding `SlickCodeGenerator#Table#Column#dbType` with `true`.  -->

<!-- The new `ModelBuilder` can be extended to customize model creation from jdbc meta data, similar to how the code generator can be customized. This allows working around differences and bugs in jdbc drivers, when creating the model or making up for missing features in Slick, e.g supporting specific types of your dbms of choice.  -->

Upgrade from 1.0 to 2.0
-----------------------

<!-- Slick 2.0 contains some improvements which are not source compatible with Slick 1.0. When migrating your application from 1.0 to 2.0, you will likely need to perform changes in the following areas.  -->

### Code Generation

<!-- Instead of writing your table descriptions or plain SQL mappers by hand, in 2.0 you can now automatically generate them from your database schema. The code-generator is flexible enough to customize it's output to fit exactly what you need. More info on code generation \<code-generation\>.  -->

### Table Descriptions

<!-- In Slick 1.0 tables were defined by a single `val` or `object` (called the *table object*) and the `*` projection was limited to a flat tuple of columns that had to be constructed with the special `~` operator:  -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
object Suppliers extends Table[(Int, String, String)]("SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey)
  def name = column[String]("SUP_NAME")
  def street = column[String]("STREET")
  def * = id ~ name ~ street
}
```

<!-- In Slick 2.0 you need to define your table as a class that takes an extra `Tag` argument (the *table row class*) plus an instance of a `TableQuery` of that class (representing the actual database table). Tuples for the `*` projection can use the standard tuple syntax:  -->

```scala
class Suppliers(tag: Tag) extends Table[(Int, String, String)](tag, "SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey)
  def name = column[String]("SUP_NAME")
  def street = column[String]("STREET")
  def * = (id, name, street)
}
val suppliers = TableQuery[Suppliers]
```

<!-- You can import TupleMethods \<slick.util.TupleMethods$\>.\_ to get support for the old \~ syntax. The simple `TableQuery[T]` syntax is a macro which expands to a proper TableQuery instance that calls the table's constructor (`new TableQuery(new T(_))`). In Slick 1.0 it was common practice to place extra static methods associated with a table into that table's object. You can do the same in 2.0 with a custom `TableQuery` object:  -->

```scala
object suppliers extends TableQuery(new Suppliers(_)) {
  // put extra methods here, e.g.:
  val findByID = this.findBy(_.id)
}
```

<!-- Note that a `TableQuery` is a `Query` for the table. The implicit conversion from a table row object to a `Query` that could be applied in unexpected places is no longer needed or available. All the places where you had to use the raw *table object* in Slick 1.0 have been changed to use the *table query* instead, e.g. inserting (see below) or foreign key references.  -->

<!-- The method for creating simple finders has been renamed from `createFinderBy` to `findBy`. It is defined as an *extension method* for `TableQuery`, so you have to prefix the call with `this.` (see code snippet above).  -->

### Mapped Tables

<!-- In 1.0 the `<>` method for bidirectional mappings was overloaded for different arities so you could directly pass a case class's `apply` method to it:  -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
def * = id ~ name ~ street <> (Supplier _, Supplier.unapply)
```

<!-- This is no longer supported in 2.0. One of the reasons is that the overloading led to complicated error messages. You now have to use a function with an appropriate tuple type. If you map to a case class you can simply use `.tupled` on its companion object:  -->

```scala
def * = (id, name, street) <> (Supplier.tupled, Supplier.unapply)
```

<!-- Note that `.tupled` is only available for proper Scala *functions*. In 1.0 it was sufficient to have a *method* like `apply` that could be converted to a function on demand (`<> (Supplier.apply _, Supplier.unapply)`).  -->

<!-- When using a case class, the companion object extends the correct function type by default, but only if you do not define the object yourself. In that case you should provide the right supertype manually, e.g.:  -->

```scala
case class Supplier(id: Int, name: String, street: String)
object Supplier // overriding the default companion object
  extends ((Int, String, String) => Supplier) { // manually extending the correct function type
  //...
}
```

<!-- Alternatively, you can have the Scala compiler first do the lifting to a function and then call `.tupled`:  -->

```scala
def * = (id, name, street) <> ((Supplier.apply _).tupled, Supplier.unapply)
```

### Profile Hierarchy

<!-- Slick 1.0 provided two *profiles*, `BasicProfile` and `ExtendedProfile`. These two have been unified in 2.0 as `JdbcProfile`. Slick now provides more abstract profiles, in particular `RelationalProfile` which does not have all the features of `JdbcProfile` but is supported by the new `HeapDriver` and `DistributedDriver`. When porting code from Slick 1.0, you generally want to switch to `JdbcProfile` when abstracting over drivers. In particular, pay attention to the fact that `BasicProfile` in 2.0 is very different from `BasicProfile` in 1.0.  -->

### Inserting

<!-- In Slick 1.0 you used to construct a projection for inserting from the *table object*:  -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
(Suppliers.name ~ Suppliers.street) insert ("foo", "bar")
```

<!-- Since there is no raw table object any more in 2.0 you have to use a projection from the table query:  -->

```scala
suppliers.map(s => (s.name, s.street)) += ("foo", "bar")
```

<!-- Note the use of the new `+=` operator for API compatibility with Scala collections. The old name `insert` is still available as an alias.  -->

<!-- Slick 2.0 will now automatically exclude `AutoInc` fields by default when inserting data. In 1.0 it was common to have a separate projection for inserts in order to exclude these fields manually:  -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
case class Supplier(id: Int, name: String, street: String)
object Suppliers extends Table[Supplier]("SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey, O.AutoInc)
  def name = column[String]("SUP_NAME")
  def street = column[String]("STREET")
  // Map a Supplier case class:
  def * = id ~ name ~ street <> (Supplier.tupled, Supplier.unapply)
  // Special mapping without the 'id' field:
  def forInsert = name ~ street <> (
    { case (name, street) => Supplier(-1, name, street) },
    { sup => (sup.name, sup.street) }
  )
}
Suppliers.forInsert.insert(mySupplier)
```

<!-- This is no longer necessary in 2.0. You can simply insert using the default projection and Slick will skip the auto-incrementing `id` column:  -->

```scala
case class Supplier(id: Int, name: String, street: String)
class Suppliers(tag: Tag) extends Table[Supplier](tag, "SUPPLIERS") {
def id = column[Int]("SUP_ID", O.PrimaryKey, O.AutoInc)
def name = column[String]("SUP_NAME")
def street = column[String]("STREET")
def * = (id, name, street) <> (Supplier.tupled, Supplier.unapply)
}
val suppliers = TableQuery[Suppliers]
suppliers += mySupplier
```

<!-- If you really want to insert into an `AutoInc` field, you can use the new methods `forceInsert` and `forceInsertAll`.  -->

### Pre-compiled Updates

<!-- Slick now supports pre-compilation of updates in the same manner like selects, see compiled-queries.  -->

### Database and Session Handling

<!-- In Slick 1.0, the common JDBC-based `Database` and `Session` types, as well as the `Database` factory object, could be found in the package `slick.session`. Since Slick 2.0 is no longer restricted to JDBC-based databases, this package has been replaced by the new slick.backend.DatabaseComponent (a.k.a. *backend*) hierarchy. If you work at the slick.driver.JdbcProfile abstraction level, you will always use a slick.jdbc.JdbcBackend from which you can import the types that were previously found in `slick.session`. Note that importing `simple._` from a driver will automatically bring these types into scope.  -->

### Dynamically and Statically Scoped Sessions

<!-- Slick 2.0 still supports both, thread-local dynamic sessions and statically scoped sessions, but the syntax has changed to make the recommended way of using statically scoped sessions more concise. The old `threadLocalSession` is now called `dynamicSession` and the overloads of the associated session handling methods `withSession` and `withTransaction` have been renamed to `withDynSession` and `withDynTransaction` respectively. If you used this pattern in Slick 1.0:  -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
import scala.slick.session.Database.threadLocalSession
myDB withSession {
  // use the implicit threadLocalSession here
}
```

<!-- You have to change it for Slick 2.0 to: -->

```scala
import slick.jdbc.JdbcBackend.Database.dynamicSession
myDB withDynSession {
  // use the implicit dynamicSession here
}
```

<!-- On the other hand, due to the overloaded methods, Slick 1.0 required an explicit type annotation when using the statically scoped session:  -->

```scala
myDB withSession { implicit session: Session =>
  // use the implicit session here
}
```

<!-- This is no longer necessary in 2.0: -->

```scala
myDB withSession { implicit session =>
  // use the implicit session here
}
```

<!-- Again, the recommended practice is NOT to use dynamic sessions. If you are uncertain if you need them the answer is most probably no. Static sessions are safer.  -->

### Mapped Column Types

<!-- Slick 1.0's `MappedTypeMapper` has been renamed to MappedColumnType \<slick.driver.JdbcTypesComponent@MappedColumnType:JdbcDriver.MappedColumnTypeFactory\>. Its basic form (using MappedColumnType.base \<slick.profile.RelationalTypesComponent$MappedColumnTypeFactory@base[T,U]((T)⇒U,(U)⇒T)(ClassTag[T],RelationalDriver.BaseColumnType[U]):RelationalDriver.BaseColumnType[T]\>) is now available at the slick.profile.RelationalProfile level (with more advanced uses still requiring slick.driver.JdbcProfile). The idiomatic use in Slick 1.0 was:  -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
case class MyID(value: Int)
implicit val myIDTypeMapper =
  MappedTypeMapper.base[MyID, Int](_.value, new MyID(_))
```

<!-- This has changed to: -->

```scala
case class MyID(value: Int)
implicit val myIDColumnType =
  MappedColumnType.base[MyID, Int](_.value, new MyID(_))
```

<!-- If you need to map a simple wrapper type (as shown in this example), you can now do that in an easier way by extending slick.lifted.MappedTo:  -->

```scala
case class MyID(value: Int) extends MappedTo[Int]
// No extra implicit required any more
```


Slick 3.0.0 documentation - 14 Slick Extensions

[Permalink to Slick Extensions — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/extensions.html)

Slick Extensions
================

<!-- Slick Extensions, a closed-source package with commercial support provided by Typesafe, Inc contains Slick drivers for:  -->

-   Oracle (`com.typesafe.slick.driver.oracle.OracleDriver`)
-   IBM DB2 (`com.typesafe.slick.driver.db2.DB2Driver`)
-   Microsoft SQL Server
    (`com.typesafe.slick.driver.ms.SQLServerDriver`)

<!-- **note** You may use it for development and testing purposes under the terms and conditions of the Typesafe Subscription Agreement\_ (PDF). Production use requires a Typesafe Subscription\_.  -->

<!-- If you are using sbt\_, you can add *slick-extensions* and the Typesafe repository (which contains the required artifacts) to your build definition like this:  -->

```scala
libraryDependencies += "com.typesafe.slick" %% "slick-extensions" % "3.0.0"
resolvers += "Typesafe Releases" at "<http://repo.typesafe.com/typesafe/maven-releases/>"
```

Slick 3.0.0 documentation - 15 Direct Embedding (Deprecated)

[Permalink to Direct Embedding (Deprecated) — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/direct-embedding.html)

Direct Embedding (Deprecated)
=============================

> DirectEmbeddingはSlick1.0の頃に加えられた、実験的なクエリAPIであったが、バージョン3.0より非推奨となった。この機能はバージョン3.1に削除される予定だ。プロダクション環境などでは、Slickの標準的なクエリAPIを利用して欲しい。
<!-- Deprecated since version 3.0: The direct embedding is an experimental Query API that was added in Slick 1.0. It is deprecated in 3.0 and will be removed in 3.1. You should only use Slick’s standard Scala query API for any kind of production use. -->

（非推奨のAPIについての説明となるため、本章は翻訳していない。）

Unlike the standard API, the direct embedding uses macros instead of operator overloading and implicit conversions for its implementation. For a user the difference in the code is small, but queries using the direct embedding work with ordinary Scala types, which can make error messages easier to understand.

Dependencies
------------

The direct embedding requires access to the Scala compiler at runtime for typechecking. Slick only declares an *optional* dependency on scala-compiler in order to avoid bringing it (along with all transitive dependencies) into your application if you don't need it. You must add it explicitly to your own project's `build.sbt` file if you want to use the direct embedding:

```scala
libraryDependencies <+= (scalaVersion)("org.scala-lang" % "scala-compiler" % _)
```

Imports
-------

```scala
import slick.driver.H2Driver
import H2Driver.api.{Database, DBIO}
import slick.direct._
import slick.direct.AnnotationMapper._
```

Row class and schema
--------------------

The schema description is currently provided as annotations on a case class which is used for holding rows. We will later provide more flexible and customizable means of providing the schema information.

```scala
// describe schema for direct embedding
@table(name="COFFEES")
case class Coffee(
  @column(name="NAME")
  name : String,
  @column(name="PRICE")
  price : Double
)
```

Query
-----

Queryable takes an annotated case class as its type argument to formulate queries agains the corresponding table.

`_.price` is of type Int here. The underlying, macro-based implementation takes care of that the shown arguments to map and filter are not executed on the JVM but translated to database queries instead.

```scala
// query database using direct embedding
val q1 = Queryable[Coffee]
val q2 = q1.filter( _.price > 3.0 ).map( _ .name )
```

Execution
---------

To execute the queries we need to create a SlickBackend instance passing in the chosen database backend driver.

```scala
val db = Database.forConfig("h2mem1")
try {
  // execute query using a chosen db backend
  val backend = new SlickBackend( H2Driver, AnnotationMapper )
  println( Await.result(db.run(backend.result(q2)), Duration.Inf) )
  println( Await.result(db.run(backend.result(q2.length)), Duration.Inf) )
} finally db.close
```

Alternative direct embedding bound to a driver and session
----------------------------------------------------------

Using ImplicitQueryable, a queryable can be bound to a backend and session. The query can be further adapted and easily executed this way.

```scala
//
val iq1 = ImplicitQueryable( q1, backend, db )
val iq2 = iq1.filter( c => c.price > 3.0 )
println( iq2.toSeq ) //  <- triggers execution
println( iq2.length ) // <- triggers execution
```

Features
--------

The direct embedding currently only supports database columns, which can be mapped to either `String, Int, Double`.

Queryable and ImplicitQueryable currently support the following methods:

`map, flatMap, filter, length`

The methods are all immutable meaning they leave the left-hand-side Queryable unmodified, but return a new Queryable incorporating the changes by the method call.

Within the expressions passed to the above methods, the following operators may be used:

`Any: ==`

`Int, Double: + < >`

`String: +`

`Boolean: || &&`

Other operators may type check and compile ok, if they are defined for the corresponding types. They can however currently not be translated to SQL, which makes the query fail at runtime, for example: `( coffees.map( c => c.name.repr ) )`. We are evaluating ways to catch those cases at compile time in the future

Queries may result in sequences of arbitrarily nested tuples, which may also contain objects representing complete rows. E.g.

```scala
q1.map( c => (c.name, (c, c.price)) )
```

Slick 3.0.0 documentation - 16 Slick TestKit

[Permalink to Slick TestKit — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/testkit.html)

Slick TestKit
=============

<!-- **note** This chapter is based on the Slick TestKit Example template\_. The prefered way of reading this introduction is in Activator\_, where you can edit and run the code directly while reading the tutorial.  -->

<!-- When you write your own database driver for Slick, you need a way to run all the standard unit tests on it (in addition to any custom tests you may want to add) to ensure that it works correctly and does not claim to support any capabilities which are not actually implemented. For this purpose the Slick unit tests have been factored out into a separate Slick TestKit project.  -->

<!-- To get started, you can clone the Slick TestKit Example template\_ which contains a copy of Slick's standard PostgreSQL driver and all the infrastructure required to build and test it.  -->

Scaffolding
-----------

<!-- Its `build.sbt` file is straight-forward. Apart from the usual name and version settings, it adds the dependencies for Slick, the TestKit, junit-interface, Logback and the PostgreSQL JDBC driver, and it sets some options for the test runs:  -->

```scala
libraryDependencies ++= Seq(
  "com.typesafe.slick" %% "slick" % "|release|",
  "com.typesafe.slick" %% "slick-testkit" % "|release|" % "test",
  "com.novocode" % "junit-interface" % "0.10" % "test",
  "ch.qos.logback" % "logback-classic" % "0.9.28" % "test",
  "postgresql" % "postgresql" % "9.1-901.jdbc4" % "test"
)
...
testOptions += Tests.Argument(TestFrameworks.JUnit, "-q", "-v", "-s",
"-a")
...
parallelExecution in Test := false
...
logBuffered := false
```

<!-- There is a copy of Slick's logback configuration in `src/test/resources/logback-test.xml` but you can swap out the logging framework if you prefer a different one.  -->

Driver
------

<!-- The actual driver implementation can be found under `src/main/scala`. -->

Test Harness
------------

<!-- In order to run the TestKit tests, you need to add a class that extends `DriverTest`, plus an implementation of `TestDB` which tells the TestKit how to connect to a test database, get a list of tables, clean up between tests, etc.  -->

<!-- In the case of the PostgreSQL test harness (in `src/test/slick/driver/test/MyPostgresTest.scala`) most of the default implementations can be used out of the box. Only `localTables` and `getLocalSequences` require custom implementations. We also modify the driver's `capabilities` to indicate that our driver does not support the JDBC `getFunctions` call:  -->

```scala
@RunWith(classOf[Testkit])
class MyPostgresTest extends DriverTest(MyPostgresTest.tdb)
object MyPostgresTest {
  def tdb = new ExternalJdbcTestDB("mypostgres") {
    val driver = MyPostgresDriver
    override def localTables(implicit ec: ExecutionContext): DBIO[Vector[String]] =
      ResultSetAction[(String,String,String, String)](_.conn.getMetaData().getTables("", "public", null, null)).map { ts =>
        ts.filter(_._4.toUpperCase == "TABLE").map(_._3).sorted
      }
    override def getLocalSequences(implicit session: profile.Backend#Session) = {
      val tables = ResultSetInvoker[(String,String,String, String)](_.conn.getMetaData().getTables("", "public", null, null))
      tables.buildColl[List].filter(_._4.toUpperCase == "SEQUENCE").map(_._3).sorted
    }
    override def capabilities = super.capabilities - TestDB.capabilities.jdbcMetaGetFunctions
  }
}
```

<!-- The name of a configuration prefix, in this case `mypostgres`, is passed to `ExternalJdbcTestDB`:  -->

```scala
def tdb =
  new ExternalJdbcTestDB("mypostgres") ...
```

Database Configuration
----------------------

<!-- Since the PostgreSQL test harness is based on `ExternalJdbcTestDB`, it needs to be configured in `test-dbs/testkit.conf`:  -->

```scala
mypostgres.enabled = true
mypostgres.user = myuser
mypostgres.password = secret
```

<!-- There are several other configuration options that need to be set for an `ExternalJdbcTestDB`. These are defined with suitable defaults in `testkit-reference.conf` so that `testkit.conf` can be kept very simple in most cases.  -->

Testing
-------

<!-- Running `sbt test` discovers `MyPostgresTest` and runs it with TestKit's JUnit runner. This in turn causes the database to be set up through the test harness and all tests which are applicable for the driver (as determined by the `capabilities` setting in the test harness) to be run.  -->
