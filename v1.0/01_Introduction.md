Slick 1.0.0 documentation - 01 導入
<!-- Introduction -->
[Permalink to Introduction — Slick 1.0.0 documentation](http://slick.typesafe.com/doc/1.0.0/introduction.html)

導入
=======

Slickとは
-------
<!-- What is Slick -->

Slickは[Typesafe社](http://www.typesafe.com)によって開発が行われている，Scalaのためのモダンなデータベースラッパーである．データベースにアクセスしながらScalaのコレクションを扱うかのようにデータを操作する事が出来る．また，SQLを直接書く事も可能である．

<!--Slick is Typesafe‘s modern database query and access library for Scala. It allows you to work with stored data almost as if you were using Scala collections while at the same time giving you full control over when a database access happens and which data is transferred. You can also use SQL directly.-->

```scala
val limit = 10.0
// クエリはこのように書く事が出来る
( for( c <- Coffees; if c.price < limit ) yield c.name ).list
// SQLを直接書いた例
sql"select name from coffees where price < $limit".as[String].list
```

クエリをSQLを用いて書く代わりにScalaを用いるとコンパイル時に合成が安全に行われ，より良い形で利用する事が出来る．Slickは独自のクエリコンパイラを用いてDBに対しクエリを発行する．

<!--When using Scala instead of SQL for your queries you profit from the compile-time safety(何これ) and compositionality. Slick can generate queries for different backends including your own, using its extensible query compiler. -->

Slickの特徴
-----------
<!-- Why Slick?/Feature -->


Slickは以下のような特徴を持っている:

<!-- Slick offers a unique combination of features: -->

### Easy
- Scalaコレクションを扱うかのようにデータを操作出来る
- JDBCコネクションをもとに，統合されたセッション管理を行える
- 必要な際にはSQLもサポートする
- セットアップが簡単

<!--- Access stored data just like Scala collections
- Unified session management based on JDBC Connections
- Supports SQL if you need it
- Simple setup-->

### Concise

- Scala構文
- 簡単に結果を取り出せる (ResultSet.getXなどの処理は必要無い)
- Scales naturally
- 状態を持たない
- 実行時間や移動されるデータの明示的な管理

<!--- Scala syntax
- Fetch results without pain (no ResultSet.getX)
- Scales naturally
- Stateless (like the web)
- Explicit control of execution time and transferred data-->

### Safe
- SQLインジェクションを防止する
- Compile-time safety (types, names, no typos, etc.)
- 型安全なストアドプロシージャのサポート

<!--- No SQL-injections
- Compile-time safety (types, names, no typos, etc.)
- Type-safe support of stored procedures-->

### Composable

- Scalaによる実装：抽象化された，再利用が簡単に行える設計

<!--- It‘s Scala code: abstract and re-use with ease-->

SlickはScala2.10を必要とします．
（Scala2.9を利用する際にはSlickの前身である，[ScalaQuery](http://scalaquery.org)を利用してください．）

<!--Slick requires Scala 2.10. (For Scala 2.9 please use [ScalaQuery](http://scalaquery.org), the predecessor of Slick).-->

サポートするデータベース
-----------------------

- DB2 (via [slick-extensions](http://slick.typesafe.com/doc/1.0.0/extensions.html))
- Derby/JavaDB
- H2
- HSQLDB/HyperSQL
- Microsoft Access
- Microsoft SQL Server
- MySQL
- Oracle (via [slick-extensions](http://slick.typesafe.com/doc/1.0.0/extensions.html))
- PostgreSQL
- SQLite

他のSQLデータベースもSlickなら簡単にアクセスする事が出来るでしょう．独自のSQLベースのバックエンドを持つデータベースも，プラグインを作成する事でSlickを利用することが出来ます．そのようなプラグインの作成は大きな貢献となるでしょう．
NoSQLのような他のバックエンドを持つようなデータベースに関しては現在開発中であるため，まだ利用する事はできません．．

<!--Other SQL databases can be accessed right away with a reduced feature set. Writing a fully featured plugin for your own SQL-based backend can be achieved with a reasonable amount of work. Support for other backends (like NoSQL) is under development but not yet available.-->

簡単な概説
----------

SlickのLiftedEmbeddingによるデータベースへのアクセスは以下のステップで行う事ができます．

<!--Accessing databases using Slick’s lifted embedding requires the following steps.-->

1．Slickのjarファイルをプロジェクトのdependenciesへ追加する

<!--Add the Slick jar and its dependencies to your project-->

2．利用するDBに応じたDriverをimportし，セッションを作成する（もしくは単純にthreadLocalSessionをimportする）．

<!--Pick a driver for a particular db and create a session (or simply pick threadLocalSession)-->

```scala
import scala.slick.driver.H2Driver.simple._
import Database.threadLocalSession
```

3．データベーススキーマを記述する

<!--Describe your Database schema-->

```scala
object Coffees extends Table[(String, Double)]("COFFEES") {
  def name = column[String]("COF_NAME", O.PrimaryKey)
  def price = column[Double]("PRICE")
  def * = name ~ price
}
```

4．セッションスコープ内にて，for式かmap/flatMapを用いてクエリを記述する

<!--Write queries using for-comprehensions or map/flatMap wrapped in a session scope-->

```scala
Database.forURL("jdbc:h2:mem:test1", driver = "org.h2.Driver") withSession {
  ( for( c <- Coffees; if c.price < 10.0 ) yield c.name ).list
  // or
  Coffees.filter(_.price < 10.0).map(_.name).list
}
```

[次の章](http://slick.typesafe.com/doc/1.0.0/gettingstarted.html)では，より詳細な扱い方や機能について説明します．

<!--The [next chapter](http://slick.typesafe.com/doc/1.0.0/gettingstarted.html) explains these steps and further aspects in more detail.-->

License
--------

Slick is released under a BSD-Style free and open source software [license](https://github.com/slick/slick/blob/1.0.0/LICENSE.txt).
