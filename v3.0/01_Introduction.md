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
sql"select COF_NAME from COFFEES where PRICE < \$limit".as[String]
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

