Slick 2.0.0 documentation - 01 導入(Introduction)
<!-- Introduction -->
[Permalink to Introduction — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/introduction.html)

導入
============

Slickとは
--------------
<!-- What is Slick -->

Slickは[Typesafe社](http://www.typesafe.com)によって開発が行われている、Scalaのためのモダンなデータベースラッパーである。データベースにアクセスしながらScalaのコレクションを扱うかのようにデータを操作する事が出来る。また、SQLを直接書く事も可能である。

<!--Slick is Typesafe‘s modern database query and access library for Scala. It allows you to work with stored data almost as if you were using Scala collections while at the same time giving you full control over when a database access happens and which data is transferred. You can also use SQL directly.-->

```scala
val limit = 10.0
// クエリはこのように書く事が出来る
( for( c <- Coffees; if c.price < limit ) yield c.name ).list
// SQLを直接書いた例
sql"select name from coffees where price < $limit".as[String].list
```

SQLを直接書くのに比べ、Scalaを通してSQLを発行すると、コンパイル時により良いクエリを型安全に提供する事が出来る。Slickは独自のクエリコンパイラを用いてDBに対するクエリを発行する。

<!--When using Scala instead of SQL for your queries you profit from the compile-time safety(何これ) and compositionality. Slick can generate queries for different backends including your own, using its extensible query compiler. -->

すぐにSlickを試したいのなら、[Typesafe Activator](http://typesafe.com/activator)にある[Hello Slick](http://typesafe.com/activator/template/hello-slick)テンプレートを使うと良い。

<!-- Get started learning Slick in minutes using the [Hello Slick](http://typesafe.com/activator/template/hello-slick) template in[Typesafe Activator](http://typesafe.com/activator).-->

Slickの特徴
--------
<!-- Features -->

### Scala

- クエリ、テーブル、カラムの定義は全てScalaで記述する
<!-- -   Queries, Table & Column Mappings, and types are plain Scala-->

```scala
class Coffees(tag: Tag) extends Table[(String, Double)](tag, "COFFEES") {
  def name = column[String]("COF_NAME", O.PrimaryKey)
  def price = column[Double]("PRICE")
  def * = (name, price)
}
val coffees = TableQuery[Coffees]
```

- Scalaのコレクションを扱うかのようにデータリソースを扱う事が出来る
<!-- -   Data access APIs similar to Scala collections-->

```scala
// name というカラムを返すクエリ
coffees.map(_.name)
// 価格が 10.0 未満という条件を用いたクエリ
coffees.filter(_.price < 10.0)
```

### Type Safe

- IDEがコードを書く手助けをしてくれる
<!-- -   Let your IDE help you write your code-->

- 実行時でなくコンパイル時に問題を発見出来る
<!-- -   Find problems at compile-time instead of at runtime-->

```scala
// `select PRICE from COFFEES` の結果はSeq[Double]になる
// これは型安全な処理が行なわれるためである
val coffeeNames: Seq[Double] = coffees.map(_.price).list
// クエリを作るのも型安全に行なわれる
coffees.filter(_.price < 10.0)
// もし条件の中で異なる型が比較されていたのなら、コンパイルエラーになる
```

### Composable

- クエリは合成・再利用可能な関数となる
<!-- -   Queries are functions that can be composed and reused-->

```scala
// 10.0 未満の価格で、名前順にソートしたコーヒーの名前を取り出すクエリを作る
coffees.filter(_.price < 10.0).sortBy(_.name).map(_.name)
// ここで作られるSQLは次のものと等価になる
// select name from COFFEES where PRICE < 10.0 order by NAME
```

Compatibility
-------------

SlickはScalaのバージョン2.10が必要になる。（もし2.9以下で使いたいなら[ScalaQuery](http://scalaquery.org/)を使うと良い）

<!-- Slick requires Scala 2.10. (For Scala 2.9 please use ScalaQuery, thepredecessor of Slick).-->

サポートするデータベース
--------------------------

- DB2 (via [slick-extensions](http://slick.typesafe.com/doc/2.0.0/extensions.html))
- Derby/JavaDB
- H2
- HSQLDB/HyperSQL
- Microsoft Access
- Microsoft SQL Server (via [slick-extensions](http://slick.typesafe.com/doc/2.0.0/extensions.html))
- MySQL
- Oracle (via [slick-extensions](http://slick.typesafe.com/doc/2.0.0/extensions.html))
- PostgreSQL
- SQLite

他のSQLデータベースもSlickなら簡単にアクセスする事が出来る。独自のSQLベースのバックエンドを持つデータベースも、プラグインを作成する事でSlickを利用することが出来ます。そのようなプラグインの作成は大きな貢献となる。
NoSQLのような他のバックエンドを持つようなデータベースに関しては現在開発中であるため、まだ利用する事はできません。

<!--Other SQL databases can be accessed right away with a reduced feature set. Writing a fully featured plugin for your own SQL-based backend can be achieved with a reasonable amount of work. Support for other backends (like NoSQL) is under development but not yet available.-->

License
-------

> Slick is released under a BSD-Style free and open source software
> [license](https://github.com/slick/slick/blob/2.0.0/LICENSE.txt). See the chapter on the commercial
> [Slick Extensions](http://slick.typesafe.com/doc/2.0.0/extensions.html) add-on package for details on licensing
> the Slick drivers for the big commercial database systems.

Query APIs
----------

*Lifted Embedding* は型安全なクエリや更新が行えるSlickの基本的なAPIである。[Getting Started](http://slick.typesafe.com/doc/2.0.0/gettingstarted.html)では *Lifted Embedding* を用いた例を紹介する。

<!-- The *Lifted Embedding* is the standard API for type-safe queries and updates in Slick. Please see gettingstarted for an introduction. Most of this user manual focuses on the *Lifted Embedding*.-->

SQL文を直接発行したい場合には、[Plain SQL](http://slick.typesafe.com/doc/2.0.0/sql.html) API を利用することが出来る。

<!-- For writing your own SQL statements you can use the Plain SQL\<sql\> API.-->

[*Direct Embedding*](http://slick.typesafe.com/doc/2.0.0/direct-embedding.html)はまだ実験的なものではあるが、*Lifted Embedding*に替わりとして利用出来る。

<!-- The experimental Direct Embedding \<direct-embedding\> is available as an alternative to the *Lifted Embedding*.-->

Lifted Embedding
----------------

*Lifted Embedding*という名前は基本的なScalaの型を用いるのではなく、 [Rep](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.Rep)型へと*持ち上げ(lifted)*されたものを用いるという事に基づいている。これはScalaのコレクションを操作する例と比べると明らかだろう。

<!-- The name *Lifted Embedding* refers to the fact that you are not working with standard Scala types (as in the direct embedding \<direct-embedding\>) but with types that are *lifted* into a scala.slick.lifted.Rep type constructor. This becomes clear when you compare the types of a simple Scala collections example -->

```scala
case class Coffee(name: String, price: Double)
val coffees: List[Coffee] = //...
...
val l = coffees.filter(_.price > 8.0).map(_.name)
//                       ^       ^          ^
//                       Double  Double     String
```

... Lifted Embeddingを用いる際には次のように書ける

<!-- ... with the types of similar code using the lifted embedding:-->

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

全ての型は**Rep**へと持ち上げられる。カラムの型である**Coffees**も同様に`Rep[(String, Double)]`へと持ち上げられる。数値リテラルである`8.0`も自動的に`Rep[Double]`へと持ち上げられる。これは条件式`>`の左辺が`Rep[Double]`であることから、右辺には暗黙的な変換が行われるためである。生のScalaの型や値を用いることは、SQLへの変換を行う上で充分な情報を提供しない。これらの変換はそのために行なわれるのである。

<!-- All plain types are lifted into **Rep**. The same is true for the table -->
<!-- row type **Coffees** which is a subtype of `Rep[(String, Double)]`. Even -->
<!-- the literal `8.0` is automatically lifted to a `Rep[Double]` by an -->
<!-- implicit conversion because that is what the `>` operator on -->
<!-- `Rep[Double]` expects for the right-hand side. This lifting is necessary -->
<!-- because the lifted types allow us to generate a syntax tree that -->
<!-- captures the query computations. Getting plain Scala functions and -->
<!-- values would not give us enough information for translating those -->
<!-- computations to SQL. -->
