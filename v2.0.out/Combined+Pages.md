slick-doc-ja 2.0
================

[Slick 2.0 documentation](http://slick.typesafe.com/doc/2.0.0/)の日本語訳です。

- 編集先: [GitHub - krrrr38/slick-doc-ja](https://github.com/krrrr38/slick-doc-ja)
- 連絡先: [@krrrr38](https://twitter.com/krrrr38)


他のバージョンのドキュメント
---------------------------
- [Slick 1.0 翻訳](http://krrrr38.github.io/slick-doc-ja/v1.0.out/slick-doc-ja+1.0.html)
- Slick 2.0 翻訳
- [Slick 3.0 翻訳](http://krrrr38.github.io/slick-doc-ja/v3.0.out/slick-doc-ja+3.0.html)

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

Slick 2.0.0 documentation - 02 始めよう(Getting Started)
<!--Getting Started — Slick 2.0.0 documentation-->

[Permalink to Getting Started — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/gettingstarted.html)

始めよう
===============
<!-- Getting Started-->

軽くSlickを試すのなら、[Typesafe Activator](http://typesafe.com/activator)を使うのが良い。Slickの基本を学びたいのなら、[Hello Slick](http://typesafe.com/activator/template/hello-slick)テンプレートを使うと良い。Slickを使ったPlay Frameworkアプリケーションを使いたいのなら、[Play Slick with Typesafe IDs](http://typesafe.com/activator/template/play-slick-advanced)テンプレートを試すと良いだろう。

<!-- The easiest way to get started is with a working application in -->
<!-- [Typesafe Activator](http://typesafe.com/activator). To learn the basics -->
<!-- of Slick start with the [Hello -->
<!-- Slick](http://typesafe.com/activator/template/hello-slick) template. To -->
<!-- learn how to integrate Slick with Play Framework check out the [Play -->
<!-- Slick with Typesafe -->
<!-- IDs](http://typesafe.com/activator/template/play-slick-advanced) -->
<!-- template. -->

Slickを既存のプロジェクトに導入するには各プロジェクトに応じた依存関係を記述する。
sbtプロジェクトには`libraryDependencies`に次のように書き加える。

<!-- To include Slick into an existing project use the library published on -->
<!-- Maven Central. For sbt projects add the following to your -->
<!-- **libraryDependencies**: -->

```scala
"com.typesafe.slick" %% "slick" % "2.0.0",
"org.slf4j" % "slf4j-nop" % "1.6.4"
```

Mavenプロジェクトには以下の様な依存を書き加える。

<!-- For Maven projects add the following to your **<dependencies>**: -->

```
<dependency>
  <groupId>com.typesafe.slick</groupId>
  <artifactId>slick_2.10</artifactId>
  <version>2.0.0</version>
</dependency>
<dependency>
  <groupId>org.slf4j</groupId>
  <artifactId>slf4j-nop</artifactId>
  <version>1.6.4</version>
</dependency>
```

Slickはデバッグログに[SLF4J](http://www.slf4j.org/)を用いている。そのためSLF4Jについても追加する必要がある。ここではロギングを無効にするために `slf4j-nop` を用いている。もしログの出力を見たいのならば[Logback](http://logback.qos.ch/)のようなロギング用のフレームワークに替えなくてはならない。

<!--Slick uses [SLF4J][3] for its own debug logging so you also need to add an SLF4J implementation. Here we are using slf4j-nop to disable logging. You have to replace this with a real logging framework like [Logback][4] if you want to see log output.-->

Slick Examples
--------------

[Slick Examples](https://github.com/slick/slick-examples/tree/2.0.0)では、複数のデータベースを使ったり、生のクエリを発行したりといったサンプルを公開している。

<!-- Check out the Slick Examples\_ project for more examples like using multiple databases, using native queries, and advanced invoker usage. -->

Quick Introduction
------------------

Slickを使う際、まず初めに、利用するデータベースに応じたAPIを以下のようにインポートする必要がある。

<!-- To use Slick you first need to import the API for the database you will be using, like: -->

```scala
// H2 databaseへ接続するためにH2Driverをimport
import scala.slick.driver.H2Driver.simple._
```

[H2 Database](http://h2database.com/)を用いているため、Slickの `H2Driver` をimportする必要がある。このdriverに含まれる `simple` オブジェクトには[session handling](http://slick.typesafe.com/doc/2.0.0/connection.html)といったSlickに必要な共通の機能が含まれている。

<!--Since we are using [H2][6] as our database system, we need to import features from Slick’s H2Driver. A driver’s simple object contains all commonly needed imports from the driver and other parts of Slick such as [*session handling*][7]. -->

Databaseへの接続
----------------

アプリケーションの中では、どのようにデータベースに接続するのかを明示する `Database` オブジェクトを初めに作る。そしてセッションを開き、続くブロック内に処理を記述する。

<!--In the body of the application we create a Database object which specifies how to connect to a database, and then immediately open a session, running all code within the following block inside that session:-->

```scala
Database.forURL("jdbc:h2:mem:test1", driver = "org.h2.Driver") withSession {
  implicit session =>
  // <- クエリはここへ書こう
}
```

Java SEの環境においては、データベースセッションはJDBCドライバークラスを用いてJDBC URLへ接続する事で作られる（正しいURLの記述法はJDBCドライバーのドキュメントを見て欲しい）。もし[plain SQL queries](http://slick.typesafe.com/doc/2.0.0/sql.html)のみを用いるのであれば、それ以上何もする必要はない。一方で、もし[direct embedding](http://slick.typesafe.com/doc/2.0.0/direct-embedding.html)や[lifted embedding](http://slick.typesafe.com/doc/2.0.0/introduction.html#lifted-embedding)を用いるのであれば、SlickがSQL文を作成する事になるため、 `H2Driver` のようなSlickのdriverを適宜importして欲しい。

<!--In a Java SE environment, database sessions are usually created by connecting to a JDBC URL using a JDBC driver class (see the JDBC driver’s documentation for the correct URL syntax). If you are only using [*plain SQL queries*][8], nothing more is required, but when Slick is generating SQL code for you (using the [*direct embedding*][9] or the [*lifted embedding*][10]), you need to make sure to use a matching Slick driver (in our case the H2Driver import above).-->

スキーマ
--------

ここでは [lifted embedding](http://slick.typesafe.com/doc/2.0.0/introduction.html#lifted-embedding)を用いたアプリケーションを書いてみる。初めに、データベースのテーブル毎に`Table`型を継承させたクラスと、`TableQuery`型の値を定義する。これらは、[code generator](http://slick.typesafe.com/doc/2.0.0/code-generation.html)を使うとデータベーススキーマから自動的に作成することができるし、直接手で書いても良い。

<!-- We are using the lifted embedding \<lifted-embedding\> in this -->
<!-- application, so we need `Table` row classes and `TableQuery` values for -->
<!-- our database tables. You can either use the -->
<!-- code generator \<code-generation\> to automatically create them for your -->
<!-- database schema or you can write them by hand: -->

```scala
// SUPPLIERSテーブルの定義
class Suppliers(tag: Tag) extends Table[(Int, String, String, String, String, String)](tag, "SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey) // 主キー
  def name = column[String]("SUP_NAME")
  def street = column[String]("STREET")
  def city = column[String]("CITY")
  def state = column[String]("STATE")
  def zip = column[String]("ZIP")
  // 全てのテーブルではテーブルの型パラメータと同じタイプの射影*を定義する必要がある。
  def * = (id, name, street, city, state, zip)
}
val suppliers = TableQuery[Suppliers]
...
class Coffees(tag: Tag) extends Table[(String, Int, Double, Int, Int)](tag, "COFFEES") {
  def name = column[String]("COF_NAME", O.PrimaryKey)
  def supID = column[Int]("SUP_ID")
  def price = column[Double]("PRICE")
  def sales = column[Int]("SALES")
  def total = column[Int]("TOTAL")
  def * = (name, supID, price, sales, total)
  // 全てのテーブルではテーブルの型パラメタと同じタイプの射影*を定義する必要がある。?
  // A reified foreign key relation that can be navigated to create a join
  def supplier = foreignKey("SUP_FK", supID, suppliers)(_.id)
}
val coffees = TableQuery[Coffees]
```

全ての列は名前（ScalaにおけるキャメルケースやSQLにおける大文字とアンダースコアの組み合わせ）とScalaの型（SQLの型はScalaの型から自動的に推測される）を持つ。これらは `val` ではなく `def` を用いて定義しなくてはならない。テーブルオブジェクトもScalaでの名前とSQLでの名前と型を持つ必要がある。テーブルの型引数は射影*と一致してなくてはならない。全ての列をタプルで取り出すといった簡単な処理だけでなく、射影にはより複雑なオブジェクトへのマッピングを行う事も出来る。

<!--All columns get a name (usually in camel case for Scala and upper case with underscores for SQL) and a Scala type (from which the SQL type can be derived automatically). Make sure to define them with def and not with val. The table object also needs a Scala name, SQL name and type. The type argument of the table must match the type of the special * projection. In simple cases this is a tuple of all columns but more complex mappings are possible.-->

`Coffees` テーブルで定義した `外部キー` は、 `Coffees` テーブルの `supID` のフィールドが、 `Suppliers` テーブルで存在している `id` と同じ値を持っている事を保証している。要するに、ここでは *多:1* の関係を作成しているのである。ある `Coffees` の列は特定の `Suppliers` の列を指すが、複数のCoffeeが同じSupplierを指していたりする。この構成はデータベースレベルで強制されている。

<!--The foreignKey definition in the Coffees table ensures that the supID field can only contain values for which a corresponding id exists in the Suppliers table, thus creating an *n to one* relationship: A Coffees row points to exactly one Suppliers row but any number of coffees can point to the same supplier. This constraint is enforced at the database level.-->

Populating the Database
------------------------

組み込みのH2データベースエンジンへ接続すると、空のデータベースが作られる。クエリを実行する前に、データベーススキーマ（ `Coffees` テーブルと `Suppliers` テーブルから成るもの）を作成し、いくつかのテストデータを挿入してみる。

<!--The connection to the embedded H2 database engine provides us with an empty database. Before we can execute queries, we need to create the database schema (consisting of the Coffees and Suppliers tables) and insert some test data:-->

```scala
// 主キーと外部キーを含むテーブルを作成する
(Suppliers.ddl ++ Coffees.ddl).create
...
// supplierをいくつか挿入する
Suppliers.insert(101, "Acme, Inc.",      "99 Market Street", "Groundsville", "CA", "95199")
Suppliers.insert( 49, "Superior Coffee", "1 Party Place",    "Mendocino",    "CA", "95460")
Suppliers.insert(150, "The High Ground", "100 Coffee Lane",  "Meadows",      "CA", "93966")
...
// coffeeをいくつか挿入する（DBがサポートしている場合には、JDBCのバッチ処理を用いる）
Coffees.insertAll(
  ("Colombian",         101, 7.99, , ),
  ("French_Roast",       49, 8.99, , ),
  ("Espresso",          150, 9.99, , ),
  ("Colombian_Decaf",   101, 8.99, , ),
  ("French_Roast_Decaf", 49, 9.99, , )
)
```

`TableQuery` の `ddl` 関数は、テーブルやその他データベースのエンティティを作成したり削除したりするための、データベース特有のコードを用いて `DDL` （data definition language）オブジェクトを作成する。複数の `DDL` は `++` を用いる事で、お互いが依存し合っていたとしても、全てのエンティティに対し正しい順序で作成と削除を行う。

<!--The `TableQuery`'s `ddl` methods create `DDL` (data definition language) objects with the database-specific code for creating and dropping tables and other database entities. Multiple `DDL` values can be combined with `++` to allow all entities to be created and dropped in the correct order, even when they have circular dependencies on each other.-->

複数のデータを挿入する際は `insert` や `insertAll` といった関数を用いる。デフォルトではデータベースの `Session` は *auto-commit* モードになっている事に注意して欲しい。 `insert` や `insertAll` のようなデータベースへの呼び出しはトランザクションにおいて、原子性が保たれるよう実行される（つまり、それらの処理は完全に実行するか全く実行しないかのいずれかが保証される）。このモードにおいては、 `Coffee` が対応するSupplierのIDのみを参照するため、 `Supplier` テーブルに対し先にデータを挿入しなくてはならない。

<!--Inserting the tuples of data is done with the `insert` and `insertAll` methods. Note that by default a database Session is in *auto-commit* mode. Each call to the database like insert or insertAll executes atomically in its own transaction (i.e. it succeeds or fails completely but can never leave the database in an inconsistent state somewhere in between). In this mode we we have to populate the Suppliers table first because the Coffees data can only refer to valid supplier IDs.-->

これらの記述を全て包括した明示的なトランザクションのブラケットを用いることも可能である。その際、トランザクションによって処理が強制されるため、順序は重要視されない。

<!--We could also use an explicit transaction bracket encompassing all these statements. Then the order would not matter because the constraints are only enforced at the end when the transaction is committed.-->

Querying
--------

最も簡単なクエリ例として、テーブルのデータを全て順々に取り出す処理を考える。

<!--The simplest kind of query iterates over all the data in a table:-->

```scala
// coffeeのデータを全て取り出し、順に出力する
Query(Coffees) foreach { case (name, supID, price, sales, total) =>
  println("  " + name + "t" + supID + "t" + price + "t" + sales + "t" + total)
}
```

この処理はSQLに `SELECT * FROM COFFEES` を投げた結果と同じである（ただし射影関数\*を異なる形式で作成した場合には、少し違う結果となる）。ループの中で得られる値の型は当然 `Coffees` の型引数と一致する。

<!--This corresponds to a SELECT * FROM COFFEES in SQL (except that the * is the table’s * projection we defined earlier and not whatever the database sees as *). The type of the values we get in the loop is, unsurprisingly, the type parameter of Coffees.-->

上記の例に射影処理を追加してみよう。これはScalaで `map` や *for式* を用いる事で実装出来る。

<!--Let’s add a *projection* to this basic query. This is written in Scala with the map method or a *for comprehension*:-->

```scala
// なぜデータベースでは文字列の変換や連結が出来ないんだろう...?
val q1 = for(c <- Coffees) // Coffeesは自動的にQueryへとなる
  yield ConstColumn("  ") ++ c.name ++ "\t" ++ c.supID.asColumnOf[String] ++
    "\t" ++ c.price.asColumnOf[String] ++ "\t" ++ c.sales.asColumnOf[String] ++
    "\t" ++ c.total.asColumnOf[String]
// 初めの文字定数はConstColumへ手動で変換する必要がある。
// その後++オペレータにより結合させる
q1 foreach println
```

全ての行がタブによって区切られた文字列として連結した結果が得られるだろう。違いはデータベースの内側で処理が行われた事であり、結果として得られる連結した文字列は同様に取得出来る。Scalaの `+` オペレータはしばしばオーバーライドされてしまうため、seqの結合で一般的に用いられている `++` の方を利用すべきだ。また、他の引数型から文字列への自動的な型変換は存在しない。この処理は型変換関数である `asColumnOf` により明示的に行うべきである。

<!--The output will be the same: For each row of the table, all columns get converted to strings and concatenated into one tab-separated string. The difference is that all of this now happens inside the database engine, and only the resulting concatenated string is shipped to the client. Note that we avoid Scala’s + operator (which is already heavily overloaded) in favor of ++ (commonly used for sequence concatenation). Also, there is no automatic conversion of other argument types to strings. This has to be done explicitly with the type conversion method asColumnOf.-->

テーブルの結合やフィルタリングはScalaのコレクションと同じように処理する事が出来る。

<!--Joining and filtering tables is done the same way as when working with Scala collections:-->

```scala
// 2つのテーブルを結合し、coffeeの値段が$9より安いもののうち、
// coffeeの名前とsupplierの名前の組みを検索
val q2 = for {
  c <- Coffees if c.price < 9.0
  s <- Suppliers if s.id === c.supID
} yield (c.name, s.name)
```

2つの値が等しいかを比較する際に、 `==` の代わりに `===` を用いている事に注意して欲しい。同様に、LiftedEmbeddingでは `!=` の代わりに `=!=` を用いている。それ以外の比較に関するオペレータ（ `<` , `<=` , `>=` , `>` ）はScalaで用いているものと同じである

<!--Note the use of === instead of == for comparing two values for equality. Similarly, the lifted embedding uses =!= instead of != for inequality. (The other comparison operators are the same as in Scala: `<`, `<=`, `>=`, `>`)-->

`Suppliers if s.id === c.supID` という表現は `Coffees.supplier` という外部キーにより作成された関係に基いている。joinの条件を繰り返す代わりに、このような方法で直接的に外部キーを用いた結合が行える。

<!--The generator expression Suppliers if s.id === c.supID follows the relationship established by the foreign key Coffees.supplier. Instead of repeating the join condition here we can use the foreign key directly:-->

```scala
val q3 = for {
  c <- Coffees if c.price < 9.0
  s <- c.supplier
} yield (c.name, s.name)
```

Slick 2.0.0 documentation - 03 v2.0 移行ガイド

[Permalink to Migration Guide from Slick 1.0 to 2.0 — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/migration.html)

Slick v2.0 Migration Guide
=====================================
<!-- Migration Guide from Slick 1.0 to 2.0 -->
<!-- ===================================== -->

Slick2.0はSlick1.0に互換性のない拡張が含まれている。アプリケーションを1.0から2.0へ移行する際には、以下のような変更が必要になるだろう。

<!-- Slick 2.0 contains some improvements which are not source compatible -->
<!-- with Slick 1.0. When migrating your application from 1.0 to 2.0, you -->
<!-- will likely need to perform changes in the following areas. -->

Code generation
---------------

以前は手で書いていたテーブルへのマッピングを、2.0ではデータベーススキーマを用いて自動的に生成出来るようになった。code-generaterは柔軟にカスタマイズすることも出来るため、より最適化されたものに変更する事も出来る。詳細については、[code-generation](http://slick.typesafe.com/doc/2.0.0/code-generation.html)を参考にして欲しい。

<!-- Instead of writing your table descriptions or plain SQL mappers by hand, -->
<!-- in 2.0 you can now automatically generate them from your database -->
<!-- schema. The code-generator is flexible enough to customize it's output -->
<!-- to fit exactly what you need. -->
<!-- More info on code generation \<code-generation\>. -->

Table descriptions
------------------

Slick1.0では、テーブルは`val`や*table object*と呼ばれる`object`によって定義がなされ、射影`*`では`~`オペレータを用いてタプルを表していた。

<!-- In Slick 1.0 tables were defined by a single `val` or `object` (called -->
<!-- the *table object*) and the `*` projection was limited to a flat tuple -->
<!-- of columns that had to be constructed with the special `~` operator: -->

```scala
// --------------------- Slick 1.0 code -- v2.0では動かない ---------------------
object Suppliers extends Table[(Int, String, String)]("SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey)
  def name = column[String]("SUP_NAME")
  def street = column[String]("STREET")
  def * = id ~ name ~ street
}
```

Slick2.0では`Tag`を引数にテーブルクラスの定義を行い、実際のデータベーステーブルを表す`TableQuery`のインスタンスを定義する。射影`*`に対し、基本的なタプルを用いて定義を行うことも出来る。

<!-- In Slick 2.0 you need to define your table as a class that takes an -->
<!-- extra `Tag` argument (the *table row class*) plus an instance of a -->
<!-- `TableQuery` of that class (representing the actual database table). -->
<!-- Tuples for the `*` projection can use the standard tuple syntax: -->

```scala
class Suppliers(tag: Tag) extends Table[(Int, String, String)](tag, "SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey)
  def name = column[String]("SUP_NAME")
  def street = column[String]("STREET")
  def * = (id, name, street)
}
val suppliers = TableQuery[Suppliers]
```

以前に用いていた`~`シンタックスをそのまま使いたい場合には、[TupleMethod._](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.util.TupleMethods$)をインポートすれば良い。`TableQuery[T]`を用いると、内部的には`new TableQuery(new T(_))`のような処理が行われ、適切なTableQueryインスタンスが作成される。Slick1.0では共通処理に関して、静的メソッドでテーブルオブジェクトに定義がなされていた。2.0においても以下のようにカスタムされた`TableQuery`オブジェクトを用いて、同様の事が出来る。

<!-- You can import TupleMethods \<scala.slick.util.TupleMethods$\>.\_ to -->
<!-- get support for the old \~ syntax. The simple `TableQuery[T]` syntax is -->
<!-- a macro which expands to a proper TableQuery instance that calls the -->
<!-- table's constructor (`new TableQuery(new T(_))`). In Slick 1.0 it was -->
<!-- common practice to place extra static methods associated with a table -->
<!-- into that table's object. You can do the same in 2.0 with a custon -->
<!-- `TableQuery` object: -->

```scala
object suppliers extends TableQuery(new Suppliers(_)) {
  // put extra methods here
  val findByID = this.findBy(_.id)
}
```

`TableQuery`はデータベーステーブルのための`Query`オブジェクトのことである。予期せぬ場所で適用される`Query`への暗黙的な変換はもはや必要無い。Slick 1.0において生身の *table object* を扱っていた場所は、全て *table query* が代わりに用いられることになる。例として、以下に挙げられる挿入(inserting)や、外部キー関連などがある。

<!-- Note that a `TableQuery` is a `Query` for the table. The implicit -->
<!-- conversion from a table row object to a `Query` that could be applied in -->
<!-- unexpected places is no longer needed or available. All the places where -->
<!-- you had to use the raw *table object* in Slick 1.0 have been changed to -->
<!-- use the *table query* instead, e.g. inserting (see below) or foreign key -->
<!-- references. -->

Profile Hierarchy
-----------------

Slick 1.0では`BasicProfile`と`ExtendedProfile`の2つのプロファイルを提供していた。Slick 2.0ではこれら2つのプロファイルを`JdbcProfile`として統合している。今では`RelationalProfile`に挙げられるようなより抽象的なプロファイルを提供している。`RelationalProfile`は`JdbcProfile`の全ての特徴を持っているわけではないが、新しく出来た`HeapDriver`や`DistributedDriber`といった機能を支えている。Slick 1.0からコードを移植する際、`JdbcProfile`へとプロファイルを変更して欲しい。特にSlick 2.0における`BasicProfile`は1.0における`BasicProfil`と非常に異なったものになっているので注意して欲しい。

<!-- Slick 1.0 provided two *profiles*, `BasicProfile` and `ExtendedProfile`. -->
<!-- These two have been unified in 2.0 as `JdbcProfile`. Slick now provides -->
<!-- more abstract profiles, in particular `RelationalProfile` which does not -->
<!-- have all the features of `JdbcProfile` but is supported by the new -->
<!-- `HeapDriver` and `DistributedDriver`. When porting code from Slick 1.0, -->
<!-- you generally want to switch to `JdbcProfile` when abstracting over -->
<!-- drivers. In particular, pay attention to the fact that `BasicProfile` in -->
<!-- 2.0 is very different from `BasicProfile` in 1.0. -->

Inserting
---------

Slick1.0では挿入時に*table object*の一部を射影していた。

<!-- In Slick 1.0 you used to construct a projection for inserting from the -->
<!-- *table object*: -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
(Suppliers.name ~ Suppliers.street) insert ("foo", "bar")
```

2.0において生身の*table object*は存在していないため、*table query*から射影しなくてはならない。

<!-- Since there is no raw table object any more in 2.0 you have to use a -->
<!-- projection from the table query: -->

```scala
suppliers.map(s => (s.name, s.street)) += ("foo", "bar")
```

`+=`オペレータはScalaコレクションとの互換性のために用いられており、`insert`という古い名前の関数はエイリアスとして依然用いる事が出来る。

<!-- Note the use of the new `+=` operator for API compatibility with Scala -->
<!-- collections. The old name `insert` is still available as an alias. -->

Slick 2.0ではデータを挿入する際自動的にデフォルトで`AutoInc`のついたカラムを除外する。1.0では、そのようなカラムについて手動で除外した射影関数を別に用意しなくてはならなかった。

<!-- Slick 2.0 will now automatically exclude `AutoInc` fields by default -->
<!-- when inserting data. In 1.0 it was common to have a separate projection -->
<!-- for inserts in order to exclude these fields manually: -->

``` scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
case class Supplier(id: Int, name: String, street: String)
...
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
...
Suppliers.forInsert.insert(mySupplier)
```

2.0においてこのような冗長な記述は必要無くなる。デフォルトの射影関数を挿入時に用いる事で、自動インクリメントのついた`id`というカラムをSlickが除外してくれる。

<!-- This is no longer necessary in 2.0. You can simply insert using the -->
<!-- default projection and Slick will skip the auto-incrementing `id` -->
<!-- column: -->

逆に`AutoInc`のついたカラムに対し値を挿入したいのならば、新しく出来た`forceInsert`や`forceInsertAll`といった関数を用いれば良い。

<!-- If you really want to insert into an `AutoInc` field, you can use the -->
<!-- new methods `forceInsert` and `forceInsertAll`. -->

1.0において双方向マッピングを行っていた`<>`関数はオーバーロードされ、今やケースクラスの`apply`関数を直接渡す事が出来る。

<!-- In 1.0 the `<>` method for bidirectional mappings was overloaded for -->
<!-- different arities so you could directly pass a case class's `apply` -->
<!-- method to it: -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
def * = id ~ name ~ street <> (Supplier _, Supplier.unapply)
```

上記のような記述はもはや2.0ではサポートされていない。その理由の1つとして、このようなオーバーロードはエラーメッセージを複雑にしすぎるためである。現在では適切なタプル型を用いて関数を定義する事が出来る。もしケースクラスをマッピングしたいのならば、コンパニオンオブジェクトの`.tupled`を単純に用いれば良いのである。

<!-- This is no longer supported in 2.0. One of the reasons is that the -->
<!-- overloading lead to complicated error messages. You now have to use a -->
<!-- function with an appropriate tuple type. If you map to a case class you -->
<!-- can simply use `.tupled` on its companion object: -->

```scala
def * = (id, name, street) <> (Supplier.tupled, Supplier.unapply)
```

Pre-compiled updates
--------------------

Slickはselect文において用いられるのと同じ方法で、update文における事前コンパイルもサポートしている。これについては、[Compliled-Queries](http://slick.typesafe.com/doc/2.0.0/queries.html#compiled-queries)のセクションを見て欲しい。

<!-- Slick now supports pre-compilation of updates in the same manner like -->
<!-- selects, see compiled-queries. -->

Database and Session Handling
-----------------------------

Slick 1.0では`Database`のファクトリオブジェクトとして標準的なJDBCベースな`Database`と`Session`といった型が`scala.slick.session`パッケージにある。Slick 2.0からはJDBCベースなデータベースに制限せず、このパッケージは(*backend*としても知られる)[`DatabaseComponent`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.backend.DatabaseComponent)階層
によって置き換えられている。もし[`JdbcProfile`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcProfile)抽象レベルで動かしたいのならば、以前に`scala.slick.session`にあったものをインポートし、常に[`JdbcBackend`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend)を用いれば良い。ただし、`simple._`といったインポートを行うと自動的にスコープ内にこれらの型が持ち込まれてしまうので注意して欲しい。

<!-- In Slick 1.0, the common JDBC-based `Database` and `Session` types, as -->
<!-- well as the `Database` factory object, could be found in the package -->
<!-- `scala.slick.session`. Since Slick 2.0 is no longer restricted to -->
<!-- JDBC-based databases, this package has been replaced by the new -->
<!-- scala.slick.backend.DatabaseComponent (a.k.a. *backend*) hierarchy. If -->
<!-- you work at the scala.slick.driver.JdbcProfile abstraction level, you -->
<!-- will always use a scala.slick.jdbc.JdbcBackend from which you can import -->
<!-- the types that were previously found in `scala.slick.session`. Note that -->
<!-- importing `simple._` from a driver will automatically bring these types -->
<!-- into scope. -->

Dynamically and Statically Scoped Sessions
------------------------------------------

Slick 2.0では依然としてスレッドローカルな動的セッションと静的スコープセッションを提供している。しかしシンタックスが変わっており、静的スコープセッションを用いる際にはより簡潔な記述が推奨される。以前の`threadLocalSession`は`dynamicSession`という名前に変わっており、関連する`withSession`や`withTransaction`といった関数も`withDynSession`と`withDynTransaction`という名前にそれぞれ変わっている。Slick 1.0で記述されていた以下のようなシンタックスは、

<!-- Slick 2.0 still supports both, thread-local dynamic sessions and -->
<!-- statically scoped sessions, but the syntax has changed to make the -->
<!-- recommended way of using statically scoped sessions more concise. The -->
<!-- old `threadLocalSession` is now called `dynamicSession` and the -->
<!-- overloads of the associated session handling methods `withSession` and -->
<!-- `withTransaction` have been renamed to `withDynSession` and -->
<!-- `withDynTransaction` respectively. If you used this pattern in Slick -->
<!-- 1.0: -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
import scala.slick.session.Database.threadLocalSession
...
myDB withSession {
  // use the implicit threadLocalSession here
}
```

Slick 2.0で以下のようなシンタックスへ変わる。

```scala
import scala.slick.jdbc.JdbcBackend.Database.dynamicSession
...
myDB withDynSession {
  // use the implicit dynamicSession here
}
```

一方で、Slick 1.0で必要になっていた静的スコープセッションにおける明示的な型宣言は

<!-- On the other hand, due to the overloaded methods, Slick 1.0 required an -->
<!-- explicit type annotation when using the statically scoped session: -->

```scala
myDB withSession { implicit session: Session =>
  // use the implicit session here
}
```

2.0においてもはや必要なくなる。

<!-- This is no longer necessary in 2.0: -->

```scala
myDB withSession { implicit session =>
  // use the implicit session here
}
```

また、動的セッションを使うことは確かな情報を取得できるか分からない事から推奨されていない。静的セッションを用いる方がより安全である。

<!-- Again, the recommended practice is NOT to use dynamic sessions. If you -->
<!-- are uncertain if you need them the answer is most probably no. Static -->
<!-- sessions are safer. -->

Mapped Column Types
-------------------

Slick 1.0の`MappedTypeMapper`は[`MappedColumnType`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcTypesComponent@MappedColumnType:JdbcDriver.MappedColumnTypeFactory)へと名前が変わった。[`MappedColumnType.base`][1]を用いるような基本的な操作は[`RelationalProfile`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.profile.RelationalProfile)レベル(高度な利用法をするのならば依然として[`JdbcProfile`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcProfile)が必要)において現在も利用できる。

<!-- Slick 1.0’s `MappedTypeMapper` has been renamed to MappedColumnType. Its basic form (using MappedColumnType.base) is now available at the RelationalProfile level (with more advanced uses still requiring JdbcProfile). The idiomatic use in Slick 1.0 was: -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
case class MyID(value: Int)
...
implicit val myIDTypeMapper =
  MappedTypeMapper.base[MyID, Int](_.value, new MyID(_))
```

この記述は、次のように変わる。

<!-- This has changed to: -->

```scala
case class MyID(value: Int)
...
implicit val myIDColumnType =
  MappedColumnType.base[MyID, Int](_.value, new MyID(_))
```

もしこの例のように単純なラッパー型へマッピングするのなら、[`MappedTo`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.MappedTo)を用いてもっと簡単に書くことが出来る。

<!-- If you need to map a simple wrapper type (as shown in this example), you -->
<!-- can now do that in an easier way by extending -->
<!-- scala.slick.lifted.MappedTo: -->

```scala
case class MyID(value: Int) extends MappedTo[Int]
// No extra implicit required any more
```

[1]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.profile.RelationalTypesComponent$MappedColumnTypeFactory@base[T,U](T)=>U,(U)=>T)(ClassTag[T],(RelationalTypesComponent.this)#BaseColumnType[U]):(RelationalTypesComponent.this)#BaseColumnType[T])

Slick 2.0.0 documentation - 04 Connection/Transactions

[Permalink to Connections/Transactions - Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/connection.html)

Connections / Transactions
==========================

クエリはプログラムのどこにでも書くことが出来る。クエリを実行する際には、データベースコネクションが必要になる。

<!-- You can write queries anywhere in your program. When you want to execute -->
<!-- them you need a database connection. -->

Database connection
-------------------

用いるJDBCデータベースに対してどのように接続するのかを、それらの情報をカプセル化した[`Database`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Database:Database)オブジェクトを作成することで、Slickへ伝える事が出来る。`Database`オブジェクトを作成するには`scala.slick.jdbc.JdbcBackend.Database`にいくつかの[ファクトリメソッド](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef)が用意されており、どのような方法で接続するかによって使い分ける事が出来る。

<!-- You can tell Slick how to connect to the JDBC database of your choice by -->
<!-- creating a Database \<scala.slick.jdbc.JdbcBackend@Database:Database\> -->
<!-- object, which encapsulates the information. There are several -->
<!-- factory methods \<scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef\> on -->
<!-- scala.slick.jdbc.JdbcBackend.Database that you can use depending on what -->
<!-- connection data you have available. -->

### Using a JDBC URL

JDBC URLを用いて接続を行う際には、[`forURL`][1]を用いる事が出来る。(正しいURLを記述する際には、データベースのJDBCドライバー用ドキュメントを参照して欲しい)

<!-- You can provide a JDBC URL to -->
<!-- forURL \<scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@forURL(String,String,String,Properties,String):DatabaseDef\>. -->
<!-- (see your database's JDBC driver's documentation for the correct URL -->
<!-- syntax). -->

```scala
val db = Database.forURL("jdbc:h2:mem:test1;DB_CLOSE_DELAY=-1", driver="org.h2.Driver")
```

ここでは例として、新しく空のデータベースへと接続をしてみる。用いるのはインメモリ型のH2データベースであり、データベース名が`test1`、そしてJVMが終了するまで残り続けるような(`DB_CLOSE_DELAY=-1`はH2データベース特有のオプション)データベースとなっている。

<!-- Here we are connecting to a new, empty, in-memory H2 database called -->
<!-- `test1` and keep it resident until the JVM ends (`DB_CLOSE_DELAY=-1`, -->
<!-- which is H2 specific). -->

### Using a DataSource

[`DataSource`](http://docs.oracle.com/javase/7/docs/api/javax/sql/DataSource.html)オブジェクトを既に持っているのなら、[`forDataSource`][2]を用いて`Database`オブジェクトを作成出来る。もしアプリケーションフレームワークのコネクションプールから`DataSource`オブジェクトを取得出来るのなら、Slickのプールへと繋いで欲しい。

<!-- You can provide a DataSource \<javax/sql/DataSource\> object to -->
<!-- forDataSource \<scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@forDataSource(DataSource):DatabaseDef\>. -->
<!-- If you got it from the connection pool of your application framework, -->
<!-- this plugs the pool into Slick. -->

```scala
val db = Database.forDataSource(dataSource: javax.sql.DataSource)
```

後でセッションを作成する時には、コネクションはプールから取得出来るし、セッションが閉じた時に、コネクションはプールへ返却される。

<!-- When you later create a Session \<session-handling\>, a connection is -->
<!-- acquired from the pool and when the Session is closed it is returned to -->
<!-- the pool. -->

### Using a JNDI Name

もし[JNDI](http://en.wikipedia.org/wiki/JNDI)を用いているのなら、[DataSource](http://docs.oracle.com/javase/7/docs/api/javax/sql/DataSource.html)オブジェクトが見つかるJNDIの名前を[forName][3]に渡してあげたら良い。

<!-- If you are using JNDI you can provide a JNDI name to -->
<!-- forName \<scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@forName(String):DatabaseDef\> -->
<!-- under which a DataSource \<javax/sql/DataSource\> object can be looked -->
<!-- up. -->

Session handling
----------------

[Database](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Database:Database)オブジェクトを持っているのなら、[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)オブジェクトにSlickがカプセル化したデータベースコネクションを開く事が出来る。

<!-- Now you have a -->
<!-- Database \<scala.slick.jdbc.JdbcBackend@Database:Database\> object and -->
<!-- you can use it to open database connections, which Slick encapsulates in -->
<!-- Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> objects. -->

### Automatically closing Session scope

[Database](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Database:Database)オブジェクトの[withSession][4])関数は、関数を引数に、実行後に接続の閉じる[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)を作る。もしコネクションプールを用いたのならば、[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)を閉じるとコネクションはプールへと返却される。

<!-- The Database \<scala.slick.jdbc.JdbcBackend@Database:Database\> object's -->
<!-- withSession \<scala.slick.jdbc.JdbcBackend$DatabaseDef@withSession[T]((Session)=>T):T\> -->
<!-- method creates a -->
<!-- Session \<scala.slick.jdbc.JdbcBackend@Session:Session\>, passes it to a -->
<!-- given function and closes it afterwards. If you use a connection pool, -->
<!-- closing the Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> -->
<!-- returns the connection to the pool. -->

```scala
val query = for (c <- coffees) yield c.name
val result = db.withSession {
  session =>
    query.list()( session )
}
```

[withSession][5]のスコープの外側で定義されたクエリが使われている事を上の例から確認出来る。データベースに対してクエリを実行する関数は[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)を必要とする。先ほどの例では[list][6]関数を用いてクエリを実行し、[List](http://www.scala-lang.org/api/2.10.0/#scala.collection.immutable.List)として結果を取得している。(クエリを実行する関数は暗黙的な変換を通して作られる)

<!-- You can see how we are able to already define the query outside of the -->
<!-- withSession \<scala.slick.jdbc.JdbcBackend$DatabaseDef@withSession[T]((Session)=>T):T\> -->
<!-- scope. Only the methods actually executing the query in the database -->
<!-- require a Session \<scala.slick.jdbc.JdbcBackend@Session:Session\>. Here -->
<!-- we use the list \<scala.slick.jdbc.Invoker@list(P)(SessionDef):List[R]\> -->
<!-- method to execute the query and return the results as a -->
<!-- scala.collection.immutable.List. (The executing methods are made -->
<!-- available via implicit conversions). -->

ただし、デフォルトの設定ではデータベースセッションは*auto-commit*モードになっている。[insert][7]や[insertAll][8]のようなデータベースへの呼び出しは原子的(必ず成功するか失敗するかのいずれかが保証されている)に実行される。いくつかの状態を包括するには[Transactions](http://slick.typesafe.com/doc/2.0.0/connection.html#transactions)を用いる。

<!-- Note that by default a database session is in **auto-commit** mode. Each -->
<!-- call to the database like -->
<!-- insert \<scala.slick.driver.JdbcInvokerComponent$BaseInsertInvoker@insert(U)(SessionDef):SingleInsertResult\> -->
<!-- or -->
<!-- insertAll \<scala.slick.driver.JdbcInvokerComponent$BaseInsertInvoker@insertAll(U\*)(SessionDef):MultiInsertResult\> -->
<!-- executes atomically (i.e. it succeeds or fails completely). To bundle -->
<!-- several statements use transactions. -->

**注意:** もし[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)オブジェクトが[withSession][9]のスコープ以外で用いられていたのなら、その接続は既に閉じられており、妥当な利用法にはなっていない。利用を避けるべきではあるば、このような状態を避ける方法がいくつかあり、例としてクロージャを用いる([withSession][9]スコープ内にて[Future][10]を用いるなど)、varへセッションを割り当てる、withSessionスコープの返り値としてセッションを返却するといった方法がある。

<!-- **Be careful:** If the -->
<!-- Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> object escapes -->
<!-- the -->
<!-- withSession \<scala.slick.jdbc.JdbcBackend$DatabaseDef@withSession[T]((Session)=>T):T\> -->
<!-- scope, it has already been closed and is invalid. It can escape in -->
<!-- several ways, which should be avoided, e.g. as state of a closure (if -->
<!-- you use a -->
<!-- Future \<scala.concurrent.package@Future[T](=>T)(ExecutionContext):Future[T]\> -->
<!-- inside a -->
<!-- withSession \<scala.slick.jdbc.JdbcBackend$DatabaseDef@withSession[T]((Session)=>T):T\> -->
<!-- scope for example), by assigning the session to a var, by returning the -->
<!-- session as the return value of the withSession scope or else. -->

### Implicit Session

[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)を暗黙的なものとしてマークすると、データベースに対する呼び出しを行う関数に対して明示的にSessionを渡す必要がなくなる。

<!-- By marking the Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> -->
<!-- as implicit you can avoid having to pass it to the executing methods -->
<!-- explicitly. -->

```scala
val query = for (c <- coffees) yield c.name
val result = db.withSession {
  implicit session =>
    query.list // <- takes session implicitly
}
// query.list // <- would not compile, no implicit value of type Session
```

これはオプショナルな使い方ではあるが、用いるとよりコードを綺麗にする事が出来る。

<!-- This is optional of course. Use it if you think it makes your code -->
<!-- cleaner. -->

### Transactions

[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)オブジェクトの[withTransaction][11]関数をトランザクションを作成するために使う事が出来る。そのブロックにおいて、1つのトランザクション処理が実行されることになる。もし例外が発生したのなら、Slickはトランザクションをブロックの終了箇所までロールバックさせる。ブロック内のどこからでも[rollback][12]関数を呼び出すことでブロックの末尾までロールバックを強制して起こさせる事も出来る。注意して欲しいのは、Slickはデータベースのオペレーションとしてのロールバックを行うのであり、他のScalaコードの影響を引き起こさない。

<!-- You can use the Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> -->
<!-- object's -->
<!-- withTransaction \<scala.slick.jdbc.JdbcBackend$SessionDef@withTransaction[T](=>T):T\> -->
<!-- method to create a transaction when you need one. The block passed to it -->
<!-- is executed in a single transaction. If an exception is thrown, Slick -->
<!-- rolls back the transaction at the end of the block. You can force the -->
<!-- rollback at the end by calling -->
<!-- rollback \<scala.slick.jdbc.JdbcBackend$SessionDef@rollback():Unit\> -->
<!-- anywhere within the block. Be aware that Slick only rolls back database -->
<!-- operations, not the effects of other Scala code. -->

```scala
session.withTransaction {
  // your queries go here
  if (/* some failure */ false){
    session.rollback // signals Slick to rollback later
  }
} // <- rollback happens here, if an exception was thrown or session.rollback was called
```

もし[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)オブジェクトをまだ持っていないのなら、[Database](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Database:Database)オブジェクトの[withTransaciton][13]関数を直接呼ぶ事が出来る。

<!-- If you don't have a -->
<!-- Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> yet you can use -->
<!-- the Database \<scala.slick.jdbc.JdbcBackend@Database:Database\> object's -->
<!-- withTransaction \<scala.slick.jdbc.JdbcBackend$DatabaseDef@withTransaction[T]((Session)=>T):T\> -->
<!-- method as a shortcut. -->

```scala
db.withTransaction{
  implicit session =>
    // your queries go here
}
```

### Manual Session handling

この方法は推奨されない。もししなければならない場面があるのなら、[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)を手動で取り扱うことも出来る。

<!-- This is not recommended, but if you have to, you can handle the lifetime -->
<!-- of a Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> manually. -->

```scala
val query = for (c <- coffees) yield c.name
val session : Session = db.createSession
val result  = query.list()( session )
session.close
```

### Passing sessions around

Slickのクエリに対し、再利用可能な関数を書くことが出来る。これらの関数はSessionを必要としないものであり、クエリのフラグメントやアセンブリ化されたクエリを生成する。もしこれらの関数内でクエリを実行したいのなら、Sessionが必要になる。その際は、関数のシグネチャにおいて(出来れば暗黙的なものとして)引数にあたえてあげるか、もしくはいくつかの同様の関数を包括して、共通化したコードを削除するためにセッションを保持したクラスにする。

<!-- You can write re-useable functions to help with Slick queries. They -->
<!-- mostly do not need a -->
<!-- Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> as they just -->
<!-- produce query fragments or assemble queries. If you want to execute -->
<!-- queries inside of them however, they need a -->
<!-- Session \<scala.slick.jdbc.JdbcBackend@Session:Session\>. You can either -->
<!-- put it into the function signature and pass it as a (possibly implicit) -->
<!-- argument. Or you can bundle several such methods into a class, which -->
<!-- stores the session to reduce boilerplate code: -->

```scala
class Helpers(implicit session: Session){
  def execute[T](query: Query[T,_]) = query.list
  // ... place further helpers methods here
}
val query = for (c <- coffees) yield c.name
db.withSession {
  implicit session =>
  val helpers = (new Helpers)
  import helpers._
  execute(query)
}
// (new Helpers).execute(query) // <- Would not compile here (no implicit session)
```

### Dynamically scoped sessions

セッションは長い間開きっぱなしにはしたくないが、必要な時にはすぐに開いたり閉じたりしたいと考えるだろう。上記の例では、クエリを実行するために必要な時に暗黙的なセッション引数を用いて[セッションスコープ](http://slick.typesafe.com/doc/2.0.0/connection.html#session-scope)や[トランザクションスコープ](http://slick.typesafe.com/doc/2.0.0/connection.html#transactions)を使っていた。

<!-- You usually do not want to keep sessions open for very long but open and -->
<!-- close them quickly when needed. As shown above you may use a -->
<!-- session scope \<session-scope\> or transaction scope \<transactions\> -->
<!-- with an implicit session argument every time you need to execute some -->
<!-- queries. -->

別の方法として、共通化したコードの部分的なものを保存する、ということが、ファイルの先頭に追加に次の行を追加する事で行える。これにより、セッション引数無しのセッションスコープやトランザクションスコープを利用する事が出来る。

<!-- Alternatively you can save a bit of boilerplate code by putting -->
<!-- at the top of your file and then using a session scope or transaction -->
<!-- scope without a session argument. -->

```scala
import Database.dynamicSession // <- implicit def dynamicSession : Session
```

現在のコールスタック内のどこかで[withDynSession][14]か[withDynTransaction][15]スコープが開かれていた場合において、[dynamicSession](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@dynamicSession:Session)は適切な[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)を返却する暗黙的な関数となる。

<!-- dynamicSession \<scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@dynamicSession:Session\> -->
<!-- is an implicit def that returns a valid -->
<!-- Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> if a -->
<!-- withDynSession \<scala.slick.jdbc.JdbcBackend$DatabaseDef@withDynSession[T](=>T):T\> -->
<!-- or -->
<!-- withDynTransaction :\<scala.slick.jdbc.JdbcBackend$DatabaseDef@withDynTransaction[T](=>T):T\> -->
<!-- scope is open somewhere on the current call stack. -->

```scala
db.withDynSession {
  // your queries go here
}
```

注意して欲しいのは、もし[dynamicSession](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@dynamicSession:Session)がインポートさあれ、[withDynSession][14]や[withDynTransaction][15]スコープの外側でクエリが実行されようとしているのならば、実行時例外を吐いてしまう事である。つまり、静的な安全性を犠牲にしているのである。[dynamicSession](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@dynamicSession:Session)は内部的に[DynamicVariable](http://www.scala-lang.org/api/2.10.0/#scala.util.DynamicVariable)を用いる。これは動的にスコープのある変数を作成し、Javaの[InheritableThreadLocal](http://docs.oracle.com/javase/7/docs/api/java/lang/InheritableThreadLocal.html)を順々に用いるものである。静的であることの安全性とスレッドの安全性に配慮して欲しい。

<!-- Be careful, if you import -->
<!-- dynamicSession \<scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@dynamicSession:Session\> -->
<!-- and try to execute a query outside of a -->
<!-- withDynSession \<scala.slick.jdbc.JdbcBackend$DatabaseDef@withDynSession[T](=>T):T\> -->
<!-- or -->
<!-- withDynTransaction \<scala.slick.jdbc.JdbcBackend$DatabaseDef@withDynTransaction[T](=>T):T\> -->
<!-- scope, you will get a runtime exception. So you sacrifice some static -->
<!-- safety for less boilerplate. -->
<!-- dynamicSession \<scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@dynamicSession:Session\> -->
<!-- internally uses scala.util.DynamicVariable, which implements dynamically -->
<!-- scoped variables and in turn uses Java's -->
<!-- InheritableThreadLocal \<java/lang/InheritableThreadLocal\>. Be aware of -->
<!-- the consequences regarding static safety and thread safety. -->

Connection Pools
----------------

Slickは独自のコネクションプール実装を持っていない。JEEやSpringのようなある種のコンテナにおけるアプリケーションを動かす際、一般的にコンテナに提供されたコネクションプールを用いる事になるだろう。スタンドアローンなアプリケションにおいては[DBCP](http://commons.apache.org/proper/commons-dbcp/)や[c3p0](http://sourceforge.net/projects/c3p0/)、[BoneCP](http://jolbox.com/)のような外部のコネクションプールの実装を用いる事が出来る。

<!-- Slick does not provide a connection pool implementation of its own. When -->
<!-- you run a managed application in some container (e.g. JEE or Spring), -->
<!-- you should generally use the connection pool provided by the container. -->
<!-- For stand-alone applications you can use an external pool implementation -->
<!-- like DBCP\_, c3p0\_ or BoneCP\_. -->

ちなみに、Slickはどこでも利用可能なプリペアドステートメントを持ってはいるが、独自でキャッシュをしたりはしない。よって、コネクションプールの設定において、プレペア度ステートメントのキャッシュを有効にすべきであるし、充分に大きなプールサイズを用意すべきだ。

<!-- Note that Slick uses *prepared* statements wherever possible but it does -->
<!-- not cache them on its own. You should therefore enable prepared -->
<!-- statement caching in the connection pool's configuration and select a -->
<!-- sufficiently large pool size. -->

[1]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@forURL(String,String,String,Properties,String):DatabaseDef
[2]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@forDataSource(DataSource):DatabaseDef
[3]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@forName(String):DatabaseDef
[4]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseDef@withSession[T]((Session)=>T):T
[5]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseDef@withSession[T](Session)=>T):T
[6]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.Invoker@list(P)(SessionDef):List[R]
[7]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcInvokerComponent$BaseInsertInvoker@insert(U)(SessionDef):SingleInsertResult
[8]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcInvokerComponent$BaseInsertInvoker@insertAll(U*)(SessionDef):MultiInsertResult
[9]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseDef@withSession[T](Session)=>T):T)
[10]: http://www.scala-lang.org/api/2.10.0/#scala.concurrent.package@Future[T](=>T)(ExecutionContext):Future[T]
[11]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$SessionDef@withTransaction[T](=>T):T
[12]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$SessionDef@rollback():Unit
[13]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseDef@withTransaction[T]((Session)=>T):T
[14]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseDef@withDynSession[T](=>T):T
[15]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseDef@withDynTransaction[T](=>T):T

Slick 2.0.0 documentation - 05 Schema code generation

[Permalink to Schema Code Generation — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/code-generation.html)


Schema code generation
======================

Slickコードジェネレータは既存のデータベーススキーマをそのまま動かす上で便利なツールとなっている。スタンドアローン形式で動かしたり、sbtのbuildに対し統合したり出来る。

<!-- The Slick code generator is a convenient tool for working with an -->
<!-- existing or evolving database schema. It can be run as stand-alone or -->
<!-- integrated into you sbt build for creating all code Slick needs to work -->
<!-- with it. -->

Overview
--------

デフォルトでコードジェネレータは、TableQueryの値に対応するTableクラスを生成する。これらの値は、個々は行の値を包括するケースクラスとなり、全体としてコレクション操作関数が呼び出せるようなものになっている。もしScalaのタプルの限界数である22個より多いカラムが存在していたのなら、自動的にSlickの実験的な実装であるHListを用いた実装を出力する。(ちなみに、25カラムより多い場合には非常にコンパイルに時間がかかる事が分かっており、可能な限り早く修正する予定だ)

<!-- By default the code generator generates Table classes, corresponding -->
<!-- TableQuery values, which can be used in a collection-like manner as well -->
<!-- as case classes for holding complete rows of values. For Tables with -->
<!-- more than 22 columns the generator automatically switches to Slick's -->
<!-- experimental HList implementation for overcoming Scala's tuple size -->
<!-- limit. (Note that compilation times currently get extremely long for -->
<!-- more than 25 columns. We are hoping to fix this as soon as possible). -->

実装は実用的なものになってはいるが、コードジェネレータはSlick 2.0における新しい機能となっており、依然として実験的なものも含んでいる。必要なものを摘出し、必要のない機能を取り除いていく予定だ。将来的なバージョンにおけるコードジェネレータに対する修正は小さくする予定だ。もし必要ならば、Slickの他の部分から独立した実装にしても良い。我々はこの機能を用いた人々の挑戦に対する声に非常に関心がある。

<!-- The implementation is ready for practical use, but since it is new in -->
<!-- Slick 2.0 we consider it experimental and reserve the right to remove -->
<!-- features without a deprecation cycle if we think that it is necessary. -->
<!-- It would be only a small effort to run an old generator against a future -->
<!-- version of Slick though, if necessary, as it's implementation is rather -->
<!-- isolated from the rest of Slick. We are interested in hearing about -->
<!-- people's experiences with using it in practice. -->

ジェネレータについて、[talk at Scala eXchange2013](http://slick.typesafe.com/docs/#20131203_patterns_for_slick_database_applications_at_scala_exchange_2013)で軽く説明も行っている。

<!-- Parts of the generator are also explained in our [talk at Scala eXchange -->
<!-- 2013](http://slick.typesafe.com/docs/#20131203_patterns_for_slick_database_applications_at_scala_exchange_2013). -->

Run from the command line or Java/Scala
---------------------------------------

Slickのコードジェネレータは以下のようにして手軽に動かすことが出来る。

<!-- Slick's code generator comes with a default runner. You can simply -->
<!-- execute -->

```scala
scala.slick.model.codegen.SourceCodeGenerator.main(
  Array(slickDriver, jdbcDriver, url, outputFolder, pkg)
)
```

必要な引数は以下の通りである

<!-- and provide the following values -->

-   **slickDriver** *"scala.slick.driver.H2Driver"* のようなSlickのドライバークラス名
-   **jdbcDriver** *"org.h2.Driver"* のようなjdbcドライバークラス名
-   **url** *"jdbc:postgresql://localhost/test"* のようなjdbcのURL
-   **outputFolder** 出力先フォルダ
-   **pkg** 生成されるコードが属するScalaパッケージ

<!-- -   **slickDriver** Fully qualified name of Slick driver class, e.g. -->
<!--     *"scala.slick.driver.H2Driver"* -->
<!-- -   **jdbcDriver** Fully qualified name of jdbc driver class, e.g. -->
<!--     *"org.h2.Driver"* -->
<!-- -   **url** jdbc url, e.g. *"jdbc:postgresql://localhost/test"* -->
<!-- -   **outputFolder** Place where the package folder structure should be -->
<!--     put -->
<!-- -   **pkg** Scala package the generated code should be places in -->

コードジェネレータは指定されたパッケージ名に一致するサブフォルダを、指定された出力先フォルダの中に作成し、そこの"Tables.scala"というファイルへ結果を出力する。そのファイルには"Tables"オブジェクトが生成される。引数に与えたSlickドライバーと同じものが用いられているかを確認して欲しい。このファイルには同様に"Tables"トレイトがふくまれ、これはCakeパターンに用いられたものになっている。

<!-- The code generator places a file "Tables.scala" in the given folder in a -->
<!-- subfolder corresponding to the package. The file contains an object -->
<!-- "Tables" from which the code can be imported for use right away. Make -->
<!-- sure you use the same Slick driver. The file also contains a trait -->
<!-- "Tables" which can be used in the cake pattern. -->

Integrated into sbt
-------------------

コードジェネレータをコンパイル毎に事前に実行することも出来るし、手動で実行することも出来る。実際に使ってみた例が[こちら](https://github.com/slick/slick-codegen-example/tree/master)にあるので見て欲しい。

<!-- The code generator can be run before every compilation or manually. An -->
<!-- example project showing both can be [found -->
<!-- here](https://github.com/slick/slick-codegen-example/tree/master). -->

Customization
-------------

コードジェネレータはモデルデータに基づきコードを自動生成する関数をオーバーライドする事で、柔軟にカスタマイズ出来る。小さなカスタマイズであっても大きなカスタマイズであっても、このようなモデルドリブンなコードジェネレーションが同じように扱われる。例えば、とあるフレームワークにおけるバインディングや、その他のデータに関連するアプリケーションの繰り返しセクションにおいて用いられる。

<!-- The generator can be flexibly customized by overriding methods to -->
<!-- programmatically generate any code based on the data model. This can be -->
<!-- used for minor customizations as well as heavy, model driven code -->
<!-- generation, e.g. for framework bindings (Play,...), other data-related, -->
<!-- repetetive sections of applications, etc. -->

[この例](https://github.com/slick/slick-codegen-customization-example/tree/master)ではカスタマイズされたコードジェネレータを用いており、メインリソースをコンパイルする前にコードジェネレータを走らせるマルチプロジェクトのsbtビルドに対しどのように設定を行うのかを示している。

<!-- [This example](https://github.com/slick/slick-codegen-customization-example/tree/master) -->
<!-- shows a customized code-generator and how to setup up a multi-project -->
<!-- sbt build, which compiles and runs it before compiling the main sources. -->

コードジェネレータの実装は構造化されており、いくつかの階層化されたサブジェネレータに責務を委譲している。つまり完全なる出力を出す際に、部分化した結果を各ジェネレータにおいて出力している。各サブジェネレータの実装は、対応するファクトリメソッドをオーバーライドすることで、カスタマイズしたものへ変更する事が出来る。`SourceCodeGenerator`はファクトリメソッドである`Table`を持っており、これは各テーブルのためのサブジェネレータを生成するために用いられるものである。サブジェネレータである`Table`は、`Table`クラス、エンティティケースクラス、カラム、キー、インデックス、といった情報のための、別個複数のサブジェネレータを持っている。

<!-- The implementation of the code generator is structured into a small -->
<!-- hierarchy of sub-generators responsible for different fragments of the -->
<!-- complete output. The implementation of each sub-generator can be swapped -->
<!-- out for a customized one by overriding the corresponding factory method. -->
<!-- SourceCodeGenerator contains a factory method Table, which it uses to -->
<!-- generate a sub-generator for each table. The sub-generator Table in turn -->
<!-- contains sub-generators for Table classes, entity case classes, columns, -->
<!-- key, indices, etc. Custom sub-generators can easily be added as well. -->

Slickに部分的に関連するサブジェネレータにおいて、データモデルはコード生成のために用いられる。

<!-- Within the sub-generators the relevant part of the Slick data model can -->
<!-- be accessed to drive the code generation. -->

カスタマイズする際にオーバーライドする関数については、[APIドキュメント](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.model.codegen.SourceCodeGenerator)を是非見てもらいたい。

<!-- Please see the -->
<!-- api documentation \<scala.slick.model.codegen.SourceCodeGenerator\> for -->
<!-- info on all of the methods that can be overridden for customization. -->

コードジェネレータをカスタマイズする例として、以下のようなものがある。

<!-- Here is an example for customizing the generator: -->

```scala
import scala.slick.jdbc.meta.createModel
import scala.slick.model.codegen.SourceCodeGenerator
// fetch data model
val model = db.withSession{ implicit session =>
  createModel(H2Driver.getTables.list,H2Driver) // you can filter specific tables here
}
// customize code generator
val codegen = new SourceCodeGenerator(model){
  // override mapped table and class name
  override def entityName =
    dbTableName => dbTableName.dropRight(1).toLowerCase.toCamelCase
  override def tableName =
    dbTableName => dbTableName.toLowerCase.toCamelCase
  // add some custom import
  override def code = "import foo.{MyCustomType,MyCustomTypeMapper}" + "\n" + super.code
  // override table generator
  override def Table = new Table(_){
    // disable entity class generation and mapping
    override def EntityType = new EntityType{
      override def classEnabled = false
    }
    // override contained column generator
    override def Column = new Column(_){
      // use the data model member of this column to change the Scala type, e.g. to a custom enum or anything else
      override def rawType =
        if(model.name == "SOME_SPECIAL_COLUMN_NAME") "MyCustomType" else super.rawType
    }
  }
}
codegen.writeToFile(
  "scala.slick.driver.H2Driver","some/folder/","some.packag","Tables","Tables.scala"
)
```

Slick 2.0.0 documentation - 06 Schemas

[Permalink to Schemas — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/schemas.html)

Schemas
=======

ここでは、[Lifted Emebedding API](http://slick.typesafe.com/doc/2.0.0/introduction.html#lifted-embedding)において、データベーススキーマをどのようにして取り扱うのかということについて説明する。初めに、手でスキーマを記述する方法についての説明を行う。手で書く以外にも[コードジェネレータ](http://slick.typesafe.com/doc/2.0.0/code-generation.html)を使うこともできる。

<!-- This chapter describes how to work with database schemas in the -->
<!-- Lifted Embedding \<lifted-embedding\> API. This explains how you can -->
<!-- write schema descriptions by hand. Instead you can also use the -->
<!-- code generator \<code-generation\> to take this work off your hands. -->

Tables
------

型安全なクエリを扱う*Lifted Embedding* APIを用いるには、データベーススキーマに対応する`Table`クラスと、`TableQuery`値を定義する必要がある。

<!-- In order to use the *Lifted Embedding* API for type-safe queries, you -->
<!-- need to define `Table` row classes and corresponding `TableQuery` values -->
<!-- for your database schema: -->

```scala
class Coffees(tag: Tag) extends Table[(String, Int, Double, Int, Int)](tag, "COFFEES") {
  def name = column[String]("COF_NAME", O.PrimaryKey)
  def supID = column[Int]("SUP_ID")
  def price = column[Double]("PRICE")
  def sales = column[Int]("SALES", O.Default(0))
  def total = column[Int]("TOTAL", O.Default(0))
  def * = (name, supID, price, sales, total)
}
val coffees = TableQuery[Coffees]
```

全てのカラムは`column`関数を通して定義される。各カラムはScalaの型を持っており、アッパーケースで通常記述されるデータベース用のカラム名を持つ。以下に挙げるようなプリミティブ型は`JdbcProfile`において、JDBCベースなデータベースのためにボクシングされた型が適応される。(各種データベースドライバーによって恣意的に割り当てられているものもある)

<!-- All columns are defined through the `column` method. Each column has a -->
<!-- Scala type and a column name for the database (usually in upper-case). -->
<!-- The following primitive types are supported out of the box for -->
<!-- JDBC-based databases in `JdbcProfile` (with certain limitations imposed -->
<!-- by the individual database drivers): -->

-   *Numeric types*: Byte, Short, Int, Long, BigDecimal, Float, Double
-   *LOB types*: java.sql.Blob, java.sql.Clob, Array[Byte]
-   *Date types*: java.sql.Date, java.sql.Time, java.sql.Timestamp
-   Boolean
-   String
-   Unit
-   java.util.UUID

<!-- -   *Numeric types*: Byte, Short, Int, Long, BigDecimal, Float, Double -->
<!-- -   *LOB types*: java.sql.Blob, java.sql.Clob, Array[Byte] -->
<!-- -   *Date types*: java.sql.Date, java.sql.Time, java.sql.Timestamp -->
<!-- -   Boolean -->
<!-- -   String -->
<!-- -   Unit -->
<!-- -   java.util.UUID -->

nullを許容するカラムは`T`がサポートされたプリミティブ型である際に、`Option[T]`を用いて表せば良い。ただし、このOptionに対する全ての操作は、ScalaのOption操作と異なり、データベースのnullプロパゲーションセマンティクスを用いてしまう事に注意して欲しい。特に、`None === None`という式は`None`になる。これはSlickのメジャーリリースで将来的に変更されるかもしれない。

<!-- Nullable columns are represented by `Option[T]` where `T` is one of the -->
<!-- supported primitive types. Note that all operations on Option values are -->
<!-- currently using the database's null propagation semantics which may -->
<!-- differ from Scala's Option semantics. In particular, `None === None` -->
<!-- evaluates to `None`. This behaviour may change in a future major release -->
<!-- of Slick. -->

column関数には、カラム名の後にカラムのオプションを追加する事が出来る。適用出来るオブションはテーブルの`O`オブジェクトを通して利用出来る。以下のようなオプションが`JdbcProfile`において定義されている。

<!-- After the column name, you can add optional column options to a `column` -->
<!-- definition. The applicable options are available through the table's `O` -->
<!-- object. The following ones are defined for `JdbcProfile`: -->

- `PrimaryKey`
	- DDLステートメントを作成する際に、このカラムが主キーである(ただし複合主キーでは無い)ことをマークする

<!-- :   Mark the column as a (non-compound) primary key when creating the -->
<!--     DDL statements. -->

- `Default[T](defaultValue: T)`
	- このカラムに対する値無しにデータを挿入する際のデフォルト値を指定する。この情報はDDLステートメントが作られる際にのみ用いられる。

<!-- :   Specify a default value for inserting data into the table without -->
<!--     this column. This information is only used for creating DDL -->
<!--     statements so that the database can fill in the missing information. -->

- `DBType(dbType: String)`
	- 基本的なデータ型以外の型をDDLステートメントに与える(例として`String`型のカラムに対して`DBType("VARCHAR(20")`を用いるなど)。
<!-- :   Use a non-standard database-specific type for the DDL statements -->
<!--     (e.g. `DBType("VARCHAR(20)")` for a `String` column). -->

- `AutoInc`
	- DDLステートメントを作成する際に、自動インクリメントなキーとしてカラムをマークする。他のカラムのオプションと違い、このオプションはDDLの作成時以外にも意味を持つ。多くのデータベースでは自動インクリメントでないカラムがデータ挿入時に返却されるのを許可しない(しばしば暗黙的に他のカラムは無視される)。そのため、Slickでは返却されるカラムが`AutoInc`として適切にマークされているのかどうかをチェックする。
<!-- :   Mark the column as an auto-incrementing key when creating the DDL -->
<!--     statements. Unlike the other column options, this one also has a -->
<!--     meaning outside of DDL creation: Many databases do not allow -->
<!--     non-AutoInc columns to be returned when inserting data (often -->
<!--     silently ignoring other columns), so Slick will check if the return -->
<!--     column is properly marked as AutoInc where needed. -->

- `NotNull`, `Nullable`
	- DDLステートメントを作成する際に、カラムに明示的にnullを許容するか許容しないかをマークする。nullに出来るかは`Option`型が`Option`型でないかといった違いからも決定される。一般的にこれらのオプションを使う理由は無い。
<!-- :   Explicitly mark the column as nullable or non-nullable when creating -->
<!--     the DDL statements for the table. Nullability is otherwise -->
<!--     determined from the type (Option or non-Option). There is usually no -->
<!--     reason to specify these options. -->

全てのテーブルではデフォルトの射影を表す`*`関数が必要になる。これはクエリを通して行を取り出す際に戻ってくるものが何になるべきかを示すものである。Slickの`*`射影はデータベースの`*`とは一致したものになる必要は無い。何かしらの計算を行った新たなカラムを足してもいいし、特定のカラムを省いても良いし好きにして良い。`*`射影と一致するような持ち上げられていない(non-lifted)型は`Table`へと型パラメータとして与えられる。例えば、マッピングのないテーブルにおいて、これは単一のカラム型もしくはカラムのタプル型になるだろう。

<!-- Every table requires a `*` method contatining a default projection. This -->
<!-- describes what you get back when you return rows (in the form of a table -->
<!-- row object) from a query. Slick's `*` projection does not have to match -->
<!-- the one in the database. You can add new columns (e.g. with computed -->
<!-- values) or omit some columns as you like. The non-lifted type -->
<!-- corresponding to the `*` projection is given as a type parameter to -->
<!-- `Table`. For simple, non-mapped tables, this will be a single column -->
<!-- type or a tuple of column types. -->

Mapped Tables
-------------

両方向マッピングを行う`<>`オペレータを用いる事で、`*`射影に対し、自由な型をテーブルへマッピングする事が出来る。

<!-- It is possible to define a mapped table that uses a custom type for its -->
<!-- `*` projection by adding a bi-directional mapping with the `<>` -->
<!-- operator: -->

```scala
case class User(id: Option[Int], first: String, last: String)
...
class Users(tag: Tag) extends Table[User](tag, "users") {
  def id = column[Int]("id", O.PrimaryKey, O.AutoInc)
  def first = column[String]("first")
  def last = column[String]("last")
  def * = (id.?, first, last) <> (User.tupled, User.unapply)
}
val users = TableQuery[Users]
```

(`Option`型を返すシンプルな`apply`や`unapply`関数のある)ケースクラスを用いる事で最適化されるが、自由なマッピング関数を用いても良い。この場合、適切な型を推測するのにタプルの`.shaped`を呼ぶのが役に立つ。一方で、マッピング関数に充分な型アノテーションを付与しても良いだろう。

<!-- It is optimized for case classes (with a simple `apply` method and an -->
<!-- `unapply` method that wraps its result in an `Option`) but it can also -->
<!-- be used with arbitrary mapping functions. In these cases it can be -->
<!-- useful to call `.shaped` on a tuple on the left-hand side in order to -->
<!-- get its type inferred properly. Otherwise you may have to add full type -->
<!-- annotations to the mapping functions. -->

Constraints
-----------

外部キー制約はテーブルの`foreignKey`関数を用いて定義出来る。この関数は制約のための名前、ローカルカラム(もしくは射影、つまりここでは複合外部キーを定義出来る)、関連するテーブル、そしてテーブルから一致するカラムに対する関数を引数に取る。テーブルのためのDDLステートメントが作成される際、外部キー定義が追加される。

<!-- A foreign key constraint can be defined with a table's `foreignKey` -->
<!-- method. It takes a name for the constraint, the local column (or -->
<!-- projection, so you can define compound foreign keys), the linked table, -->
<!-- and a function from that table to the corresponding column(s). When -->
<!-- creating the DDL statements for the table, the foreign key definition is -->
<!-- added to it. -->

```scala
class Suppliers(tag: Tag) extends Table[(Int, String, String, String, String, String)](tag, "SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey)
  //...
}
val suppliers = TableQuery[Suppliers]
...
class Coffees(tag: Tag) extends Table[(String, Int, Double, Int, Int)](tag, "COFFEES") {
  def supID = column[Int]("SUP_ID")
  //...
  def supplier = foreignKey("SUP_FK", supID, suppliers)(_.id)
  // compiles to SQL:
  //   alter table "COFFEES" add constraint "SUP_FK" foreign key("SUP_ID")
  //     references "SUPPLIERS"("SUP_ID")
  //     on update NO ACTION on delete NO ACTION
}
val coffees = TableQuery[Coffees]
```

データベースに定義された実際の制約とは独立して、*join*などで用いられるような関連データについてのナビゲーションとしても外部キーは用いる事が出来る。この目的において、結合されるデータを探すための便利関数を手動で定義させる。

<!-- Independent of the actual constraint defined in the database, such a -->
<!-- foreign key can be used to navigate to the linked data with a *join*. -->
<!-- For this purpose, it behaves the same as a manually defined utility -->
<!-- method for finding the joined data: -->

```scala
def supplier = foreignKey("SUP_FK", supID, suppliers)(_.id)
def supplier2 = suppliers.filter(_.id === supID)
```

主キー制約は外部キーと同じように、`primaryKey`関数を用いる事で定義出来る。これは複合主キーを定義するのに便利なものとなっている。(`column`関数のオプションである`O.PrimaryKey`では複合主キーは定義出来ない)

<!-- A primary key constraint can be defined in a similar fashion by adding a -->
<!-- method that calls `primaryKey`. This is useful for defining compound -->
<!-- primary keys (which cannot be done with the `O.PrimaryKey` column -->
<!-- option): -->

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

またインデックスについても同様に`index`関数を用いて定義出来る。`unique`パラメータが内場合にはユニークなものではない、として定義される。

<!-- Other indexes are defined in a similar way with the `index` method. They -->
<!-- are non-unique by default unless you set the `unique` parameter: -->

```Scala
class A(tag: Tag) extends Table[(Int, Int)](tag, "a") {
  def k1 = column[Int]("k1")
  def k2 = column[Int]("k2")
  def * = (k1, k2)
  def idx = index("idx_a", (k1, k2), unique = true)
  // compiles to SQL:
  //   create unique index "idx_a" on "a" ("k1","k2")
}
```

全ての制約は、テーブルにおいて定義された適切な返却型を用いて、反射的に探索が行なわれる。このような挙動に対して、`tableConstraints`関数をオーバーライドする事でカスタマイズ出来る。

<!-- All constraints are discovered reflectively by searching for methods -->
<!-- with the appropriate return types which are defined in the table. This -->
<!-- behavior can be customized by overriding the `tableConstraints` method. -->

Data Definition Language
------------------------

テーブルのDDLステートメントは、`TableQuery`の`ddl`関数を用いて作成される。複数の`DDL`オブジェクトは`++`関数を用いて連結する事ができ、テーブル間にサイクルした依存関係が存在していたとしても、適切な順序で全てのテーブルを作成、削除する事が出来る。ステートメントは`create`と`drop`関数を用いて実行される。

<!-- DDL statements for a table can be created with its `TableQuery`"s `ddl` -->
<!-- method. Multiple `DDL` objects can be concatenated with `++` to get a -->
<!-- compound `DDL` object which can create and drop all entities in the -->
<!-- correct order, even in the presence of cyclic dependencies between -->
<!-- tables. The statements are executed with the `create` and `drop` -->
<!-- methods: -->

```scala
val ddl = coffees.ddl ++ suppliers.ddl
db withDynSession {
  ddl.create
  //...
  ddl.drop
}
```

`createStatements`や`dropStatements`関数を用いると、実際に吐かれるSQLについて確認する事が出来る。

<!-- You can use the `createStatements` and `dropStatements` methods to get -->
<!-- the SQL code: -->

```scala
ddl.createStatements.foreach(println)
ddl.dropStatements.foreach(println)
```

Slick 2.0.0 documentation - 07 Queries

[Permalink to Queries — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/queries.html)

Queries
=======

ここでは、[Lifted Embedding](http://slick.typesafe.com/doc/2.0.0/introduction.html#lifted-embedding) APIを用いたデータの選択、挿入、更新、削除について、どのようにして型安全なクエリを書くか、ということについて説明を行う

<!-- This chapter describes how to write type-safe queries for selecting, -->
<!-- inserting, updating and deleting data with the -->
<!-- Lifted Embedding \<lifted-embedding\> API. -->

Expressions
-----------

(レコードでもコレクションでもない)スカラー値は、`TypedType[T]`が必ず存在しているという条件の元、(`Rep[T]`のサブタイプである)`Column[T]`によって表される。内部的な利用のために、`Column`クラスにおいて、いくつかの特別な関数が直接定義されている。

<!-- Scalar (non-record, non-collection) values are representend by type -->
<!-- `Column[T]` (a sub-type of `Rep[T]`) where a `TypedType[T]` must exist. -->
<!-- Only some special methods for internal use are defined directly in the -->
<!-- `Column` class. -->

それらのオペレータやlifted embeddingにおいて一般的に用いられる他の関数は、`ExtensionMethodConversions`において定義された暗黙的な変換を通して追加されている。実際に用いる関数については`AnyExtensionMethods`、`ColumnExtensionMethods`、`NumericColumnExtensionMethods`、`BooleanColumnExtensionMethods`、`StringColumnExtensionMethods`といったクラスにおいて定義がなされている(参照: [ExtensionMethods](https://github.com/slick/slick/blob/2.0.0/src/main/scala/scala/slick/lifted/ExtensionMethods.scala))。

<!-- The operators and other methods which are commonly used in the lifted -->
<!-- embedding are added through implicit conversions defined in -->
<!-- `ExtensionMethodConversions`. The actual methods can be found in the -->
<!-- classes `AnyExtensionMethods`, `ColumnExtensionMethods`, -->
<!-- `NumericColumnExtensionMethods`, `BooleanColumnExtensionMethods` and -->
<!-- `StringColumnExtensionMethods` (cf. -->
<!-- ExtensionMethods \<src/main/scala/scala/slick/lifted/ExtensionMethods.scala\>). -->

コレクション値は`Query`(`Rep[Seq[T]]`)クラスによって表される。これは、`flatMap`、`filter`、`take`、`groupBy`のような多くの標準的なコレクション関数を持っている。2つの異なる`Query`の複合型により、これらの関数のシグネチャは非常に複雑なものになっているが、本質的にはScalaのコレクションと同様の意味合いを持つ。

<!-- Collection values are represented by the `Query` class (a `Rep[Seq[T]]`) -->
<!-- which contains many standard collection methods like `flatMap`, -->
<!-- `filter`, `take` and `groupBy`. Due to the two different component types -->
<!-- of a `Query` (lifted and plain), the signatures for these methods are -->
<!-- very complex but the semantics are essentially the same as for Scala -->
<!-- collections. -->

他にも、スカラー値のクエリに対しいくつかの関数が`SingleColumnQueryExtensionMethods`への暗黙的な変換を通して存在する。

<!-- Additional methods for queries of scalar values are added via an -->
<!-- implicit conversion to `SingleColumnQueryExtensionMethods`. -->

Sorting and Filtering
---------------------

ソートやフィルタリングのための関数がいくつか用意されている(`Query`を取り、新しい同じ型の`Query`を返す)。例として、以下のようなものがある。

<!-- There are various methods with sorting/filtering semantics (i.e. they -->
<!-- take a `Query` and return a new `Query` of the same type), for example: -->

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
```

Joining and Zipping
-------------------

結合(join)は2つの異なるテーブルを結合し、何らかのクエリ処理を1つのクエリで実行するために用いられる。

<!-- Joins are used to combine two different tables or queries into a single -->
<!-- query. -->

結合を行うには2つの方法がある。*明示的な結合*では、2つのクエリを1つのクエリへと結合させる関数(`innerJoin`など)を呼び出すことにより処理を実行させる。*暗黙的な結合*では、そのような関数を呼び出す事はせず、特有の記述を行うことで結合を行わさせる。

<!-- There are two different ways of writing joins: *Explicit* joins are -->
<!-- performed by calling a method that joins two queries into a single query -->
<!-- of a tuple of the individual results. *Implicit* joins arise from a -->
<!-- specific shape of a query without calling a special method. -->

*暗黙的な交差結合(cross join)*は`Query`に対し`flatMap`操作を行うことで実行させる事が出来る(すなわち、for式を用いる事で同様の記述が行える)。

<!-- An *implicit cross-join* is created with a `flatMap` operation on a -->
<!-- `Query` (i.e. by introducing more than one generator in a -->
<!-- for-comprehension): -->

```scala
val implicitCrossJoin = for {
  c <- coffees
  s <- suppliers
} yield (c.name, s.name)
// compiles to SQL:
//   select x2."COF_NAME", x3."SUP_NAME"
//     from "COFFEES" x2, "SUPPLIERS" x3
```

もし結合の際にフィルタリングを行ったのなら、これは*暗黙的な内部結合(inner join)*となる。

<!-- If you add a filter expression, it becomes an *implicit inner join*: -->

```scala
val implicitInnerJoin = for {
  c <- coffees
  s <- suppliers if c.supID === s.id
} yield (c.name, s.name)
// compiles to SQL:
//   select x2."COF_NAME", x3."SUP_NAME"
//     from "COFFEES" x2, "SUPPLIERS" x3
//     where x2."SUP_ID" = x3."SUP_ID"
```

このような暗黙的結合は、Scalaコレクションの`flatMap`を扱うのと同様の意味合いを持つ。

<!-- The semantics of these implicit joins are the same as when you are using -->
<!-- `flatMap` on Scala collections. -->

明示的結合は適切なjoin関数を呼び出す事で実行出来る。

<!-- Explicit joins are created by calling one of the available join methods: -->

```scala
val explicitCrossJoin = for {
  (c, s) <- coffees innerJoin suppliers
} yield (c.name, s.name)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     inner join "SUPPLIERS" x3
...
val explicitInnerJoin = for {
  (c, s) <- coffees innerJoin suppliers on (_.supID === _.id)
} yield (c.name, s.name)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     inner join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
...
val explicitLeftOuterJoin = for {
  (c, s) <- coffees leftJoin suppliers on (_.supID === _.id)
} yield (c.name, s.name.?)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     left outer join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
...
val explicitRightOuterJoin = for {
  (c, s) <- coffees rightJoin suppliers on (_.supID === _.id)
} yield (c.name.?, s.name)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     right outer join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
...
val explicitFullOuterJoin = for {
  (c, s) <- coffees outerJoin suppliers on (_.supID === _.id)
} yield (c.name.?, s.name.?)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     full outer join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
```

ここでは外部結合において`.?`といったものを用いている。これは、このような結合ではnull値が新たに追加されてしまうため、そのような値に対し`Option`値が取得される事を保証するためである。(左外部結合、右外部結合においても同様である)

<!-- Note the use of `.?` in the outer joins. Since these joins can introduce -->
<!-- additional NULL values (on the right-hand side for a left outer join, on -->
<!-- the left-hand sides for a right outer join, and on both sides for a full -->
<!-- outer join), you have to make sure to retrieve `Option` values from -->
<!-- them. -->

リレーショナルデータベースによってサポートされた一般的な結合処理に加えて、Slickでは2つのクエリのペアワイズ結合を作成する*zip結合*というものを提供している。これはScalaコレクションにおいて`zip`や`zipWith`関数を用いた処理と同様の意味合いを持つものである。

<!-- In addition to the usual join operators supported by relational -->
<!-- databases (which are based off a cross join or outer join), Slick also -->
<!-- has *zip joins* which create a pairwise join of two queries. The -->
<!-- semantics are again the same as for Scala collections, using the `zip` -->
<!-- and `zipWith` methods: -->

```scala
val zipJoinQuery = for {
  (c, s) <- coffees zip suppliers
  } yield (c.name, s.name)
...
val zipWithJoin = for {
  res <- coffees.zipWith(suppliers, (c: Coffees, s: Suppliers) => (c.name, s.name))
} yield res
```

ある種のzip結合は`zipWithIndex`により提供される。これはクエリの結果を0から始まる無限数列とzipしたものとなる。そのような数列についてはSQLデータベースでは表す事が出来ず、Slickでも現在ではサポートしていない。しかし、行番号(*row number*)関数を利用する事でSQLにおいてzipクエリの結果については表す事が出来る。ゆえに`zipWithIndex`は原子的なオペレータとしてサポートされているのである。

<!-- A particular kind of zip join is provided by `zipWithIndex`. It zips a -->
<!-- query result with an infinite sequence starting at 0. Such a sequence -->
<!-- cannot be represented by an SQL database and Slick does not currently -->
<!-- support it, either. The resulting zipped query, however, can be -->
<!-- represented in SQL with the use of a *row number* function, so -->
<!-- `zipWithIndex` is supported as a primitive operator: -->

```scala
val zipWithIndexJoin = for {
  (c, idx) <- coffees.zipWithIndex
} yield (c.name, idx)
```

Unions
------

両立可能な2つのクエリは、`++`(もしくは`unionAll`)や`union`オペレータを用いる事で連結する事が出来る。

<!-- Two queries can be concatenated with the `++` (or `unionAll`) and -->
<!-- `union` operators if they have compatible types: -->

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

重複した値を弾く`union`と違って、`++`は、より効率的な個々のクエリの結果を、単純に連結させる。

<!-- Unlike `union` which filters out duplicate values, `++` simply -->
<!-- concatenates the results of the individual queries, which is usually -->
<!-- more efficient. -->

Aggregation
-----------

最も単純な集合操作は、単一カラムを返却する`Query`からプリミティブな値(大抵は数値型)を計算させる事で取得を行う。

<!-- The simplest form of aggregation consists of computing a primitive value -->
<!-- from a Query that returns a single column, usually with a numeric type, -->
<!-- e.g.: -->

```scala
val q = coffees.map(_.price)
...
val q1 = q.min
// compiles to SQL (simplified):
//   select min(x4."PRICE") from "COFFEES" x4
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

これらの集合クエリはコレクションではなく、スカラー値を返却する事に注意して欲しい。いくつかの集合関数は恣意的なクエリにより定義がなされている。

<!-- Note that these aggregate queries return a scalar result, not a -->
<!-- collection. Some aggregation functions are defined for arbitrary queries -->
<!-- (of more than one column): -->

```scala
val q1 = coffees.length
// compiles to SQL (simplified):
//   select count(1) from "COFFEES"
...
val q2 = coffees.exists
// compiles to SQL (simplified):
//   select exists(select * from "COFFEES")
```

`groupBy`関数によりグルーピングは行なわれる。これはScalaコレクションに対する操作と同じ意味を持つ。

<!-- Grouping is done with the `groupBy` method. It has the same semantics as -->
<!-- for Scala collections: -->

```scala
val q = (for {
  c <- coffees
  s <- c.supplier
} yield (c, s)).groupBy(_._1.supID)
...
val q2 = q.map { case (supID, css) =>
  (supID, css.length, css.map(_._1.price).avg)
}
// compiles to SQL:
//   select x2."SUP_ID", count(1), avg(x2."PRICE")
//     from "COFFEES" x2, "SUPPLIERS" x3
//     where x3."SUP_ID" = x2."SUP_ID"
//     group by x2."SUP_ID"
```

ここで、中間クエリである`q`はネストされた型`Query`の値を保持している。つまり、クエリを実行する際にはネストされたコレクションが現れる。これは現在サポートがされていない。それゆえ、`q2`において行なわれるようにそれらの値(もしくは個々のカラム)をまとめることで、ネストされたクエリを即座に平滑化する必要がある。

<!-- Note that the intermediate query `q` contains nested values of type -->
<!-- `Query`. These would turn into nested collections when executing the -->
<!-- query, which is not supported at the moment. Therefore it is necessary -->
<!-- to flatten the nested queries immediately by aggregating their values -->
<!-- (or individual columns) as done in `q2`. -->

Querying
--------

クエリは[Invoker](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.Invoker)トレイト(もしくはパラメータが無い場合には[UnitInvoker](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.UnitInvoker))において定義された関数を用いて実行される。`Query`に対する暗黙的な変換が存在しているため、直接的に`Query`を実行できるのである。最も一般的な利用法として、`list`や`to`のような特定の関数を用いて、適切にコレクションの値を結果として読み込み事がある。

<!-- Queries are executed using methods defined in the -->
<!-- scala.slick.jdbc.Invoker trait (or scala.slick.jdbc.UnitInvoker for the -->
<!-- parameterless versions). There is an implicit conversion from `Query`, -->
<!-- so you can execute any `Query` directly. The most common usage scenario -->
<!-- is reading a complete result set into a strict collection with a -->
<!-- specialized method such as `list` or the generic method `to` which can -->
<!-- build any kind of collection: -->

```scala
val l = q.list
val v = q.buildColl[Vector]
val invoker = q.invoker
val statement = q.selectStatement
```

このスニペットは暗黙的な変換関数を呼び出す事無しに、どのようにして手動でinvokerに対する参照を取得するのかを示している。

<!-- This snippet also shows how you can get a reference to the invoker -->
<!-- without having to call the implicit conversion method manually. -->

クエリを実行する全ての関数は暗黙的な`Session`を必要とする。もちろん明示的に`Session`を渡してあげてもよい。

<!-- All methods that execute a query take an implicit `Session` value. Of -->
<!-- course, you can also pass a session explicitly if you prefer: -->

```scala
val l = q.list()(session)
```

もし単一の結果値が欲しいのなら、`first`や`firstOption`といった関数を用いる事が出来る。`foreach`、`foldLeft`、`elements`といった関数はScalaコレクションに全てのデータをコピーしたりせずに、結果をイテレートさせる事が出来る。

<!-- If you only want a single result value, you can use `first` or -->
<!-- `firstOption`. The methods `foreach`, `foldLeft` and `elements` can be -->
<!-- used to iterate over the result set without first copying all data into -->
<!-- a Scala collection. -->

Deleting
--------

データの削除はクエリの実行と同じように処理させる。削除したいデータを取得するクエリを書いた後に、`delete`関数を呼び出せば良い。`Query`から`delete`関数と自己参照用の`deleteInvoker`を提供する[DeleteInvoker](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcInvokerComponent@DeleteInvoker:JdbcDriver.DeleteInvoker)への暗黙的な変換が存在している。

<!-- Deleting works very similarly to querying. You write a query which -->
<!-- selects the rows to delete and then call the `delete` method on it. -->
<!-- There is again an implicit conversion from `Query` to the special -->
<!-- DeleteInvoker \<scala.slick.driver.JdbcInvokerComponent@DeleteInvoker:JdbcDriver.DeleteInvoker\> -->
<!-- which provides the `delete` method and a self-reference `deleteInvoker`: -->

```scala
val affectedRowsCount = q.delete
val invoker = q.deleteInvoker
val statement = q.deleteStatement
```

削除のためのクエリは単一のテーブルからデータを取得すべきだ。どんな射影も無視されるだろう(常に行を丸々削除する)。

<!-- A query for deleting must only select from a single table. Any -->
<!-- projection is ignored (it always deletes full rows). -->

Inserting
---------

データの挿入は単一のテーブルに対し、カラムの射影に基づいて実行される。テーブルを直接用いる際には、挿入はテーブルの`*`射影関数を用いて実行する。挿入時にテーブルのカラムをいくつか省くと、データベースはテーブル定義に基づき、デフォルト値を利用する。明示的なデフォルト値が無い場合には、型特有なデフォルト値を用いる。挿入に対する全ての関数は[InsertInvoker](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcInvokerComponent@InsertInvoker[T]:JdbcDriver.InsertInvoker[T])と[FullInsertInvoker](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcInvokerComponent@FullInsertInvoker[U]:JdbcDriver.FullInsertInvoker[U])において定義がなされている。

<!-- Inserts are done based on a projection of columns from a single table. -->
<!-- When you use the table directly, the insert is performed against its `*` -->
<!-- projection. Omitting some of a table's columns when inserting causes the -->
<!-- database to use the default values specified in the table definition, or -->
<!-- a type-specific default in case no explicit default was given. All -->
<!-- methods for inserting are defined in -->
<!-- InsertInvoker \<scala.slick.driver.JdbcInvokerComponent@InsertInvoker[T]:JdbcDriver.InsertInvoker[T]\> -->
<!-- and -->
<!-- FullInsertInvoker \<scala.slick.driver.JdbcInvokerComponent@FullInsertInvoker[U]:JdbcDriver.FullInsertInvoker[U]\>. -->

```scala
coffees += ("Colombian", 101, 7.99, 0, 0)
coffees ++= Seq(
  ("French_Roast", 49, 8.99, 0, 0),
  ("Espresso",    150, 9.99, 0, 0)
)
...
// "sales" and "total" will use the default value 0:
coffees.map(c => (c.name, c.supID, c.price)) += ("Colombian_Decaf", 101, 8.99)
val statement = coffees.insertStatement
val invoker = coffees.insertInvoker
// compiles to SQL:
//   INSERT INTO "COFFEES" ("COF_NAME","SUP_ID","PRICE","SALES","TOTAL") VALUES (?,?,?,?,?)
```

もし`AutoInc`なカラムが挿入操作において含まれていたなら、暗黙的に無視され、データベースは適切な値を生成しようとする。このような場合において、自動生成された主キーのカラムを返却して欲しいと思うだろう。デフォルトでは、`+=`関数は変更の合った行数(通常は1)を返却し、`++=`関数は蓄積したOptionの数を返却する(もしデータベースシステムがカウントを提供しなければ、Noneになるため)。もし特定のカラムを返却させたいのなら、`returning`関数を用いて変更する事が出来る。`+=`からは単一値もしくはタプルを、`+==`からはそれらの値の`Seq`を返す事が出来る。

<!-- When you include an `AutoInc` column in an insert operation, it is -->
<!-- silently ignored, so that the database can generate the proper value. In -->
<!-- this case you usually want to get back the auto-generated primary key -->
<!-- column. By default, `+=` gives you a count of the number of affected -->
<!-- rows (which will usually be 1) and `++=` gives you an accumulated count -->
<!-- in an `Option` (which can be `None` if the database system does not -->
<!-- provide counts for all rows). This can be changed with the `returning` -->
<!-- method where you specify the columns to be returned (as a single value -->
<!-- or tuple from `+=` and a `Seq` of such values from `++=`): -->

```scala
val userId =
  (users returning users.map(_.id)) += User(None, "Stefan", "Zeiger")
```

ちなみに、多くのデータベースシステムではテーブルの自動インクリメントされる主キーを返却する事を許可している。もし他のカラムを返却しようとしたなら、(データベースがサポートしていない場合にも)`SlickException`が実行時(at runtime)に投げられる。

<!-- Note that many database systems only allow a single column to be -->
<!-- returned which must be the table's auto-incrementing primary key. If you -->
<!-- ask for other columns a `SlickException` is thrown at runtime (unless -->
<!-- the database actually supports it). -->

クライアント側から挿入されるデータの代わりに、`Query`によって作成されたデータもしくはデータベースサーバにおいて実行されたスカラー表現を挿入する事もできる。

<!-- Instead of inserting data from the client side you can also insert data -->
<!-- created by a `Query` or a scalar expression that is executed in the -->
<!-- database server: -->

```scala
class Users2(tag: Tag) extends Table[(Int, String)](tag, "users2") {
  def id = column[Int]("id", O.PrimaryKey)
  def name = column[String]("name")
  def * = (id, name)
}
val users2 = TableQuery[Users2]
users2.ddl.create
users2 insert (users.map { u => (u.id, u.first ++ " " ++ u.last) })
users2 insertExpr (users.length + 1, "admin")
```

このような場合では、`AutoInc`カラムは無視されない。

<!-- In these cases, `AutoInc` columns are *not* ignored. -->

Updating
--------

データの更新は、更新するデータを取得し、新たなデータに差し替えるクエリを記述する事で行える。クエリは単一のテーブルから選択された(計算のされていない)カラムが返却されるべきである。更新に関連する関数は[UpdateInvoker](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcInvokerComponent@UpdateInvoker[T]:JdbcDriver.UpdateInvoker[T])において定義がなされている。

<!-- Updates are performed by writing a query that selects the data to update -->
<!-- and then replacing it with new data. The query must only return raw -->
<!-- columns (no computed values) selected from a single table. The relevant -->
<!-- methods for updating are defined in -->
<!-- UpdateInvoker \<scala.slick.driver.JdbcInvokerComponent@UpdateInvoker[T]:JdbcDriver.UpdateInvoker[T]\>. -->

```scala
val q = for { c <- coffees if c.name === "Espresso" } yield c.price
q.update(10.49)
...
val statement = q.updateStatement
val invoker = q.updateInvoker
...
// compiles to SQL:
//   update "COFFEES" set "PRICE" = ? where "COFFEES"."COF_NAME" = 'Espresso'
```

今現在、スカラー表現やデータベースに存在するデータを変換して用いる更新処理を行う方法は無い。

<!-- There is currently no way to use scalar expressions or transformations -->
<!-- of the existing data in the database for updates. -->

Compiled Queries
----------------

データベースに対する処理は基本的にいくつかのパラメータに依存している(これはデータベースから探索を行いたいデータのIDの事などである)。クエリを実行するたびに、パラメータを入れた`Query`オブジェクトを作成するような関数をしばしば記述する。しかし、これはSlickにおいてクエリをコンパイルしなおすコストを増長させる。そこで、このようなパラメータが固定されたクエリについて、事前コンパイルを行うことでより効率化する事が出来る。

<!-- Database queries typically depend on some parameters, e.g. an ID for -->
<!-- which you want to retrieve a matching database row. You can write a -->
<!-- regular Scala function to create a parameterized `Query` object each -->
<!-- time you need to execute that query but this will incur the cost of -->
<!-- recompiling the query in Slick (and possibly also on the database if you -->
<!-- don't use bind variables for all parameters). It is more efficient to -->
<!-- pre-compile such parameterized query functions: -->

```scala
def userNameByIDRange(min: Column[Int], max: Column[Int]) =
  for {
    u <- users if u.id >= min && u.id < max
  } yield u.first

val userNameByIDRangeCompiled = Compiled(userNameByIDRange _)
...
// The query will be compiled only once:
val names1 = userNameByIDRangeCompiled(2, 5).run
val names2 = userNameByIDRangeCompiled(1, 3).run
// Also works for .update and .delete
```

これは`Column`パラメータ(もしくはカラムの[レコード](http://slick.typesafe.com/doc/2.0.0/userdefined.html#record-types))を取ったり、`Query`オブジェクトやクエリを返却する全ての関数において上手く機能する。[Compiled](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.Compiled)やそのサブクラスのAPIドキュメントを見ると、コンパイルされたクエリの構成についての詳細を知ることが出来る。

<!-- This works for all functions that take `Column` parameters (or -->
<!-- records \<record-types\> of Columns) and return a `Query` object or a -->
<!-- scalar query. See the API documentation for scala.slick.lifted.Compiled -->
<!-- and its subclasses for details on composing compiled queries. -->

コンパイルされたクエリをクエリ処理、更新、削除といった処理に対して用いる事ができる。

<!-- You can use a compiled query for querying, updating and deleting data. -->

Slick 1.0の後方互換のために、`Parameters`オブジェクトの`flatMap`を呼ぶことで依然コンパイルされたクエリを作る事が出来る。多くの場合において、単一のfor式を書くことでコンパイルされたクエリを作る事が出来るだろう。

<!-- For backwards-compatibility with Slick 1.0 you can still create a -->
<!-- compiled query by calling `flatMap` on a scala.slick.lifted.Parameters -->
<!-- object. In many cases this enables you to write a single *for -->
<!-- comprehension* for a compiled query: -->

```scala
val userNameByID = for {
  id <- Parameters[Int]
  u <- users if u.id is id
} yield u.first
...
val name = userNameByID(2).first
...
val userNameByIDRange = for {
  (min, max) <- Parameters[(Int, Int)]
  u <- users if u.id >= min && u.id < max
} yield u.first
...
val names = userNameByIDRange(2, 5).list
```

Slick 2.0.0 documentation - 08 User-Defined Features

[Permalink to User-Defined Features — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/userdefined.html)

User-Defined Features
=====================

ここでは[Lifted Embedding](http://slick.typesafe.com/doc/2.0.0/introduction.html#lifted-embedding) APIにおいて、カスタムしたデータ型やデータベース関数をどのようにして用いるのか、についての説明を行う。

<!-- This chapter describes how to use custom data types and database -->
<!-- functions in the Lifted Embedding \<lifted-embedding\> API. -->

Scala Database functions
------------------------

もしデータベースシステムがSlickにおける関数として利用できないスカラー関数をサポートしていたのならば、それは`SimpleFunction`として別途定義する事が出来る。パラメータや返却型が固定されたunary, binary, ternaryな関数を生成するための関数が事前に用意されている。

<!-- If your database system supports a scalar function that is not available -->
<!-- as a method in Slick you can define it as a -->
<!-- scala.slick.lifted.SimpleFunction. There are predefined methods for -->
<!-- creating unary, binary and ternary functions with fixed parameter and -->
<!-- return types. -->

```scala
// H2 has a day_of_week() function which extracts the day of week from a timestamp
val dayOfWeek = SimpleFunction.unary[Date, Int]("day_of_week")
...
// Use the lifted function in a query to group by day of week
val q1 = for {
  (dow, q) <- salesPerDay.map(s => (dayOfWeek(s.day), s.count)).groupBy(_._1)
} yield (dow, q.map(_._2).sum)
```

より柔軟に型を取り扱いたいのなら、型の不定なインスタンスを取得し、適切な型チェックを行う独自のラッパー関数を書くために`SimpleFunction.apply`を用いる事ができる。

<!-- If you need more flexibility regarding the types (e.g. for varargs, -->
<!-- polymorphic functions, or to support Option and non-Option types in a -->
<!-- single function), you can use `SimpleFunction.apply` to get an untyped -->
<!-- instance and write your own wrapper function with the proper -->
<!-- type-checking: -->

```scala
def dayOfWeek2(c: Column[Date]) =
  SimpleFunction[Int]("day_of_week").apply(Seq(c))
```

[SimpleBinaryOperator](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.SimpleBinaryOperator)や[SimpleLiteral](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.SimpleLiteral)も同様に扱う事ができる。より柔軟なものを求めるのならば、[SimpleExpression](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.SimpleExpression)を使うと良い。

<!-- scala.slick.lifted.SimpleBinaryOperator and -->
<!-- scala.slick.lifted.SimpleLiteral work in a similar way. For even more -->
<!-- flexibility (e.g. function-like expressions with unusual syntax), you -->
<!-- can use scala.slick.lifted.SimpleExpression. -->

Other Database functions and stored procedures
----------------------------------------------

完全なテーブル(complete tables)やストアドプロシージャを返却するデータベース関数を扱うのならば、[Plain SQL Queries](http://slick.typesafe.com/doc/2.0.0/sql.html)を使えば良い。複数の結果を返却するストアドプロシージャは現在サポートしていない。

<!-- For database functions that return complete tables or stored procedures -->
<!-- please use sql. Stored procedures that return multiple result sets are -->
<!-- currently not supported. -->

Scalar Types
------------

もしカスタムされたカラムが必要ならば、[ColumnType](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcProfile@ColumnType[T]:JdbcDriver.ColumnType[T])を実装する事で扱える。最も一般的な利用法として、アプリケーション固有な型をデータベースに存在している型へとマッピングする事などが挙げられる。これは[MappedColumnType](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcProfile@MappedColumnType:JdbcDriver.MappedJdbcType.type)を用いることでよりシンプルに書ける。

<!-- If you need a custom column type you can implement -->
<!-- ColumnType \<scala.slick.driver.JdbcProfile@ColumnType[T]:JdbcDriver.ColumnType[T]\>. -->
<!-- The most common scenario is mapping an application-specific type to an -->
<!-- already supported type in the database. This can be done much simpler by -->
<!-- using -->
<!-- MappedColumnType \<scala.slick.driver.JdbcProfile@MappedColumnType:JdbcDriver.MappedJdbcType.type\> -->
<!-- which takes care of all the boilerplate: -->

```scala
// An algebraic data type for booleans
sealed trait Bool
case object True extends Bool
case object False extends Bool
...
// And a ColumnType that maps it to Int values 1 and 0
implicit val boolColumnType = MappedColumnType.base[Bool, Int](
  { b => if(b == True) 1 else 0 },    // map Bool to Int
  { i => if(i == 1) True else False } // map Int to Bool
)
...
// You can now use Bool like any built-in column type (in tables, queries, etc.)
```

より柔軟なものを用いたいのならば、[MappedjdbcType](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcProfile@MappedJdbcType)のサブクラスを用いれば良い。

<!-- You can also subclass -->
<!-- MappedJdbcType \<scala.slick.driver.JdbcProfile@MappedJdbcType\> for a -->
<!-- bit more flexibility. -->

もしある型を基礎とした独自のラッパークラスを持っているなら、マクロで生成された暗黙的な`ColumnType`を自由に取得するために、そのクラスを[MappedTo](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.MappedTo)へと拡張させれる。そのようなラッパークラスは一般的に型安全でテーブル固有な主キー型のために用いられる。

<!-- If you have a wrapper class (which can optionally be a case class and/or -->
<!-- value class) for an underlying value of some supported type, you can -->
<!-- make it extend scala.slick.lifted.MappedTo to get a macro-generated -->
<!-- implicit `ColumnType` for free. Such wrapper classes are commonly used -->
<!-- for type-safe table-specific primary key types: -->

```scala
// A custom ID type for a table
case class MyID(value: Long) extends MappedTo[Long]
...
// Use it directly for this table's ID -- No extra boilerplate needed
class MyTable(tag: Tag) extends Table[(MyID, String)](tag, "MY_TABLE") {
  def id = column[MyID]("ID")
  def data = column[String]("DATA")
  def * = (id, data)
}
```

Record Types
------------

レコード型は個別に宣言された型を持つ複数の混合物を含んだデータ構造となっている。 Slickは(引数限度が22の)ScalaタプルとSLick独自の実験的な実装である*HList*(引数制限が無いが、25個の引数を超えると異様にコンパイルが遅くなるもの)をサポートしている。レコード型はSlickにおいて恣意的にネストされ、混合されたものとして扱われている。

<!-- Record types are data structures containing a statically known number of -->
<!-- components with individually declared types. Out of the box, Slick -->
<!-- supports Scala tuples (up to arity 22) and Slick's own experimental -->
<!-- scala.slick.collection.heterogenous.HList implementation (without any -->
<!-- size limit, but currently suffering from long compilation times for -->
<!-- arities \> 25). Record types can be nested and mixed arbitrarily in -->
<!-- Slick. -->

もし柔軟性を必要とするなら、暗黙的な[Shape](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.Shape)定義を行う事で、独自のものをサポートする事が出来る。`Pair`を用いた例は以下のようになる。

<!-- If you need more flexibility, you can add support for your own by -->
<!-- defining an implicit scala.slick.lifted.Shape definition. Here is an -->
<!-- example for a type `Pair`: -->

```scala
// A custom record class
case class Pair[A, B](a: A, b: B)
```

レコード型のための`Scape`の実装は[MappedScaleProductShape](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.MappedScalaProductShape)を拡張する事で行う。一般的にこの実装はシンプルになるが、全ての型に関連するボイラープレートをいくつか必要とする。`MappedScaleProductShape`は要素に対するShapeの配列を引数に取り、`buildValue`(与えられた要素からレコード型のインスタンスを作成するもの)や`copy`(この`Shape`をコピーして新しい`Shape`を作るもの)オペレーションを提供する。

<!-- `Shape` implementations for record types extend -->
<!-- scala.slick.lifted.MappedScalaProductShape. They are are generally very -->
<!-- simple but they require some boilerplate for all the types involved. A -->
<!-- `MappedScalaProductShape` takes a sequence of Shapes for its elements -->
<!-- and provides the operations `buildValue` (for creating an instance of -->
<!-- the record type given its elements) and `copy` (for creating a copy of -->
<!-- this `Shape` with new element Shapes): -->

```scala
// A Shape implementation for Pair
final class PairShape[Level <: ShapeLevel, M <: Pair[_,_], U <: Pair[_,_], P <: Pair[_,_]](
  val shapes: Seq[Shape[_, _, _, _]])
extends MappedScalaProductShape[Level, Pair[_,_], M, U, P] {
  def buildValue(elems: IndexedSeq[Any]) = Pair(elems(0), elems(1))
  def copy(shapes: Seq[Shape[_, _, _, _]]) = new PairShape(shapes)
}
...
implicit def pairShape[Level <: ShapeLevel, M1, M2, U1, U2, P1, P2](
  implicit s1: Shape[_ <: Level, M1, U1, P1], s2: Shape[_ <: Level, M2, U2, P2]
) = new PairShape[Level, Pair[M1, M2], Pair[U1, U2], Pair[P1, P2]](Seq(s1, s2))
```

この例では、暗黙的な関数である`pairShape`が、2つの要素型を取る`Pair`のためのShapeを提供している。

<!-- The implicit method `pairShape` in this example provides a Shape for a -->
<!-- `Pair` of two element types whenever Shapes for the inidividual element -->
<!-- types are available. -->

これらの定義を用いて、タプルや`HList`を用いる事の出来るどんな場所においてでも`Pair`のレコード型を用いる事が出来る。

<!-- With these definitions in place, we can use the `Pair` record type in -->
<!-- every location in Slick where a tuple or `HList` would be acceptable: -->

```scala
// Use it in a table definition
class A(tag: Tag) extends Table[Pair[Int, String]](tag, "shape_a") {
  def id = column[Int]("id", O.PrimaryKey)
  def s = column[String]("s")
  def * = Pair(id, s)
}
val as = TableQuery[A]
as.ddl.create
...
// Insert data with the custom shape
as += Pair(1, "a")
as += Pair(2, "c")
as += Pair(3, "b")
...
// Use it for returning data from a query
val q2 = as
  .map { case a => Pair(a.id, (a.s ++ a.s)) }
  .filter { case Pair(id, _) => id =!= 1 }
  .sortBy { case Pair(_, ss) => ss }
  .map { case Pair(id, ss) => Pair(id, Pair(42 , ss)) }
```

Slick 2.0.0 documentation - 09 Plain SQL Queries

[Permalink to Plain SQL Queries — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/sql.html)

<!--Plain SQL Queries — Slick 2.0.0 documentation-->

Plain SQL Queries
=================

高度な操作について、SQL文を直接書きたくなる事があるかもしれない。Slickの *Plain SQL* クエリでは、[JDBC][1]の低レイアに触れる事無しに、よりScalaベースな記述を行う事が出来る。

<!--Sometimes you may need to write your own SQL code for an operation which is not well supported at a higher level of abstraction. Instead of falling back to the low level of [JDBC][1], you can use Slick’s *Plain SQL* queries with a much nicer Scala-based API.-->

Scaffolding
-----------

[SLick example jdbc/PlainSQL][2]では *Plain SQL* の特徴についていくつか説明している。インポートすべきパッケージが[*lifted embedding*][3]や[*direct embedding*][4]とは異なっている事に注意して欲しい。

<!--[Slick example jdbc/PlainSQL][2] demonstrates some features of the *Plain SQL* support. The imports are different from what you’re used to for the [*lifted embedding*][3] or [*direct embedding*][4]:-->

```scala
import scala.slick.session.Database
import Database.threadLocalSession
import scala.slick.jdbc.{GetResult, StaticQuery => Q}
```

まず初めに、 *Slick driver* をインポートする必要がない。SlickのJDBCに基づくAPIはJDBC自身のみに依存しているし、データベース特有の抽象化を全く実装する必要がない。データベースに接続するために必要なものは、scala.slick.session.Databaseとセッション処理を単純化したthreeadLocalSessionのみである。

<!--First of all, there is no *Slick driver* being imported. The JDBC-based APIs in Slick depend only on JDBC itself and do not implement any database-specific abstractions. All we need for the database connection is Database, plus the threadLocalSession to simplify session handling.-->

*Plain SQL* クエリを用いるために必要なクラスは、ここではQという名前でインポートしている、scala.slick.jdbc.StaticQueryである。

<!--The most important class for *Plain SQL* queries is scala.slick.jdbc.StaticQuery which gets imported as Q for more convenient use.-->

データベースの接続方法は[*in the usual way*][5]にある。例を示すために、以下のようなcase classを定義した。

<!--The database connection is opened [*in the usual way*][5]. We are also defining some case classes for our data:-->

```scala
case class Supplier(id: Int, name: String, street: String, city: String, state: String, zip: String)
case class Coffee(name: String, supID: Int, price: Double, sales: Int, total: Int)
...
Database.forURL("jdbc:h2:mem:test1", driver = "org.h2.Driver") withSession {
}
```

DDL/DML Statements
------------------

最もシンプルな `StaticQuery` のメソッドは、`updateNA` である（*NA = no args*）。`updateNA` は、結果の代わりにDDLステートメントから行数を返すStaticQuery[Unit, Int]を作成する、これは[*lifted embedding*][3]を用いるクエリと同じように実行する事が出来る。ここでは結果を得ずに、クエリを `.execute` を用いて実行させている。

<!--The simplest StaticQuery method is updateNA which creates a parameterless (*NA = no args*) StaticQuery[Unit, Int] that is supposed to return the row count from a DDL statement instead of a result set. It can be executed the same way as a query that uses the [*lifted embedding*][3]. Here we are using .execute to run the query without getting the results:-->

```scala
// 主キーと外部キーを含むテーブルを作成する
Q.updateNA("create table suppliers("+
  "id int not null primary key, "+
  "name varchar not null, "+
  "street varchar not null, "+
  "city varchar not null, "+
  "state varchar not null, "+
  "zip varchar not null)").execute
.updateNA("create table coffees("+
  "name varchar not null, "+
  "sup_id int not null, "+
  "price double not null, "+
  "sales int not null, "+
  "total int not null, "+
  "foreign key(sup_id) references suppliers(id))").execute
```

`String` を既存の `StaticQuery` オブジェクトに対し、`+` を用いて結合する事が出来る。この際、新しい `StaticQuery` が生成される。`StaticQuery.u` は、便利な関数であり、`StaticQuery.updateNA("")` で生成される空の *update* クエリを生成する。`SUPPLIERS` テーブルにいくつかのデータを挿入するためにStaticQuery.uを用いてみる。

<!--You can append a String to an existing StaticQuery object with +, yielding a new StaticQuery with the same types. The convenience method StaticQuery.u constructs an empty *update* query to start with (identical to StaticQuery.updateNA("")). We are using it to insert some data into the SUPPLIERS table:-->

```scala
// 複数のsupplierを挿入する
(Q.u + "insert into suppliers values(101, 'Acme, Inc.', '99 Market Street', 'Groundsville', 'CA', '95199')").execute
(Q.u + "insert into suppliers values(49, 'Superior Coffee', '1 Party Place', 'Mendocino', 'CA', '95460')").execute
(Q.u + "insert into suppliers values(150, 'The High Ground', '100 Coffee Lane', 'Meadows', 'CA', '93966')").execute
```

SQLコード内にリテラルを埋め込む事は、一般的にセキュリティやパフォーマンスの観点から推奨されない。特に、ユーザが提供したデータを実行時に用いるような際には危険な処理になる。変数をクエリ文字列に追加するためには、特別な連結オペレータである `+?` を用いる。これはSQL文が実行される際に、渡された値を用いてインスタンス化するものである。

<!--Embedding literals into SQL code is generally not recommended for security and performance reasons, especially if they are to be filled at run-time with user-provided data. You can use the special concatenation operator +? to add a bind variable to a query string and instantiate it with the provided value when the statement gets executed:-->

```scala
def insert(c: Coffee) = (Q.u + "insert into coffees values (" +? c.name +
  "," +? c.supID + "," +? c.price + "," +? c.sales + "," +? c.total + ")").execute
...
// Insert some coffees
Seq(
  Coffee("Colombian", 101, 7.99, , ),
  Coffee("French_Roast", 49, 8.99, , ),
  Coffee("Espresso", 150, 9.99, , ),
  Coffee("Colombian_Decaf", 101, 8.99, , ),
  Coffee("French_Roast_Decaf", 49, 9.99, , )
).foreach(insert)
```

SQL文は全ての呼び出しで同じもの（insert into coffees values (?,?,?,?,?)）となっている。

<!--The SQL statement is the same for all calls: insert into coffees values (?,?,?,?,?)-->

Query Statements
----------------

`updateNA` と似た、返り値となる行の型パラメータを取る `queryNA` というメソッドがある。このメソッドは *select* を実行し、結果をiteratorで回す事が出来る。

<!--Similar to updateNA, there is a queryNA method which takes a type parameter for the rows of the result set. You can use it to execute a *select* statement and iterate over the results:-->

```scala
Q.queryNA[Coffee]("select * from coffees") foreach { c =>
  println("  " + c.name + "t" + c.supID + "t" + c.price + "t" + c.sales + "t" + c.total)
}
```

これらを上手く機能させるためには、Slickは `PositionedResult` オブジェクトから `Coffee` の値をどのようにして読み取ればいいのかを知らせなくてはならない。これは暗黙的な `GetResult` によって行われる。`GetResult` を持つ基本的なJDBCの型や、NULLを許可するカラムを表すためのOptionや、タプルに対して、暗黙的な `GetResult` が定義されていなくてはならない。この例においては `Supplier` クラスや `Coffee` クラスのための `GetResult` を以下のように用意する必要がある。

<!--In order for this to work, Slick needs to know how to read Coffee values from a PositionedResult object. This is done with an implicit GetResult value. There are predefined GetResult implicits for the standard JDBC types, for Options of those (to represent nullable columns) and for tuples of types which have a GetResult. For the Supplier and Coffee classes in this example we have to write our own:-->

```scala
// Result set getters
implicit val getSupplierResult = GetResult(r => Supplier(r.nextInt, r.nextString, r.nextString,
      r.nextString, r.nextString, r.nextString))
implicit val getCoffeeResult = GetResult(r => Coffee(r.<<, r.<<, r.<<, r.<<, r.<<))
```

`GetResult[T]` は `PositionedResult => T` となる関数のシンプルなラッパーである。上の例において、1つ目の `GetResult` では現在の行から次の `Int` 、次の `String` といった値を読み込む `getInt` 、`getString` といった `PositionedResult` の明示的なメソッドを用いている。2つ目の `GetResult` では自動的に型を推測する簡易化されたメソッド `<<` を用いている。コンスタクタの呼び出しにおいて実際に型を判別出来る際にのみこれは用いる事ができる。

<!--GetResult[T] is simply a wrapper for a function PositionedResult => T. The first one above uses the explicit PositionedResult methods getInt and getString to read the next Int or String value in the current row. The second one uses the shortcut method << which returns a value of whatever type is expected at this place. (Of course you can only use it when the type is actually known like in this constructor call.)-->

パラメータの無いクエリのための、`queryNA` メソッドは2つの型パラメータ（1つはクエリパラメータ、もう1つは返り値となる行の型パラメータ）を取るクエリによって補完される。同様に、`updateNA` のための適切な `update` が存在する。`StaticQuery` の実行関数は型パラメータを用いて呼ばれる必要がある。以下の例では `.list` がそれにあたる。

<!--The queryNA method for parameterless queries is complemented by query which takes two type parameters, one for the query parameters and one for the result set rows. Similarly, there is a matching update for updateNA. The execution methods of the resulting StaticQuery need to be called with the query parameters, as seen here in the call to .list:-->

```scala
// 価格が$9.00より小さい全てのコーヒーに対し、coffeeのnameとsupplierのnameを取り出す
val q2 = Q.query[Double, (String, String)]("""
  select c.name, s.name
  from coffees c, suppliers s
  where c.price < ? and s.id = c.sup_id
""")
// この場合、結果はListとして読むことが出来る
val l2 = q2.list(9.0)
for (t <- l2) println("  " + t._1 + " supplied by " + t._2)
```

また、パラメータを直接的にクエリへ適用させる事も出来る。これを用いると、パラメータの無いクエリへと変換させることが出来る。これは通常の関数適用と同じように、クエリのパラメータを決めさせる事が出来る。

<!--As an alternative, you can apply the parameters directly to the query, thus reducing it to a parameterless query. This makes the syntax for parameterized queries the same as for normal function application:-->

```scala
val supplierById = Q[Int, Supplier] + "select * from suppliers where id = ?"
println("Supplier #49: " + supplierById(49).first)
```

String Interpolation
-------------------

SQL を発行する *string interpolation* 接頭辞である、`sql` や `sqlu` を用いるためには、以下のインポート文を追加する。

<!--In order to use the string interpolation prefixes sql and sqlu, you need to add one more import statement:-->

```scala
import Q.interpolation
```

再利用可能なクエリを必要としない場合には、interpolationはパラメータが付与されたクエリを生成する、最も簡単で統語的にナイスな手法である。クエリを挿入するどんな変数や式も、バインドした変数を結果を返すクエリ文字列へと変換する事が出来る（クエリへ直接挿入されるリテラル値を取得するのに `$` の代わりに `#$` を用いることも出来る）。返り値の型は呼び出しの中で、`sql` interpolatorによって作られたオブジェクトを `StaticQuery` へと変換させる `.as` によって指定される。

<!--As long as you don’t want function-like reusable queries, interpolation is the easiest and syntactically nicest way of building a parameterized query. Any variable or expression injected into a query gets turned into a bind variable in the resulting query string. (You can use #$ instead of $ to get the literal value inserted directly into the query.) The result type is specified in a call to .as which turns the object produced by the sql interpolator into a StaticQuery:-->

```scala
def coffeeByName(name: String) = sql"select * from coffees where name = $name".as[Coffee]
println("Coffee Colombian: " + coffeeByName("Colombian").firstOption)
```
*update* 文を生成するための interpolator に、`sqlu` というものもある。これは `Int` 値を返す事を強制するため、`.as` のような関数を必要としない。

<!--There is a similar interpolator sqlu for building update statements. It is hardcoded to return an Int value so it does not need the extra .as call:-->

```scala
def deleteCoffee(name: String) = sqlu"delete from coffees where name = $name".first
val rows = deleteCoffee("Colombian")
println(s"Deleted $rows rows")
```

[1]: http://en.wikipedia.org/wiki/Java_Database_Connectivity
[2]: https://github.com/slick/slick-examples/blob/2.0.0/src/main/scala/com/typesafe/slick/examples/jdbc/PlainSQL.scala
[3]: http://slick.typesafe.com/doc/2.0.0/lifted-embedding.html
[4]: http://slick.typesafe.com/doc/2.0.0/direct-embedding.html
[5]: http://slick.typesafe.com/doc/2.0.0/gettingstarted.html#gettingstarted-dbconnection

Slick 2.0.0 documentation - 10 Slick Extensions

[Permalink to Slick Extensions — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/extensions.html)

Slick Extensions
================

OracleのためのSlickドライバー（ `com.typesafe.slick.driver.oracle.OracleDriver` ）とDB2（ `com.typesafe.slick.driver.db2.DB2Driver` ）は、 Typesafe社によって商用サポートされたパッケージである。[Typesafe Subscription Agreement][1] (PDF)の諸条件の元で利用出来る。

<!--Slick drivers for Oracle (`com.typesafe.slick.driver.oracle.OracleDriver`) and DB2 (`com.typesafe.slick.driver.db2.DB2Driver`) are available in *slick-extensions*, a closed-source package package with commercial support provided by Typesafe, Inc. It is made available under the terms and conditions of the [Typesafe Subscription Agreement][1] (PDF).-->

もし[sbt][2]を用いているのならば、 Typesafeのリポジトリを用いるために次のように記述すれば良い。

<!--If you are using [sbt][2], you can add *slick-extensions* and the Typesafe repository (which contains the required artifacts) to your build definition like this:-->

    // Use the right Slick version here:
    libraryDependencies += "com.typesafe.slick" %% "slick-extensions" % "2.0.0"

    resolvers += "Typesafe Releases" at "http://repo.typesafe.com/typesafe/maven-releases/"

 [1]: http://typesafe.com/public/legal/TypesafeSubscriptionAgreement-v1.pdf
 [2]: http://www.scala-sbt.org/  

Slick 2.0.0 documentation - 11 Direct Embedding (Experimental Feature)
<!--Direct Embedding — Slick 2.0.0 documentation-->

[Permalink to Direct Embedding — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/direct-embedding.html)

Direct Embedding (Experimental Feature)
================================

direct embeddingは新しい、しかしまだ不完全で実験的なクエリAPIである。現在実験中。開発中の段階であるため、リリースに応じて非推奨な期間など無しに変更される事がある。安全に利用する事の出来る、安定したlifted embeddingクエリAPIに取って代わるような予定は無く、direct embeddingは共存させていく。lifted embeddingと違って、direct enbeddingは実装のための暗黙的な変換やオーバーロードするオペレータの代わりにマクロを用いて操作を行う。ユーザのために、コード内における違いは少なくしているが、direct enbeddingを用いるクエリは普遍的なScalaの型を用いて機能している。これは表示されるエラーメッセージの理解性を上げるためでもある。

<!--The direct embedding is a new, still incomplete, experimental Query API under development. It may change without deprecation period in any release during its experimental status. There is no plan to replace the stable lifted embedding Query API, which you can safely bet on for production use. The direct embedding co-exists. Unlike the lifted embedding, the direct embedding uses macros instead of operator overloading and implicit conversions for its implementation. For a user the difference in the code is small, but queries using the direct embedding work with ordinary Scala types, which can make error messages easier to understand.-->

以下の説明は[*lifted embedding*][1]の説明に類似した例である。

<!--The following descriptions are anolog to the description of the [*lifted embedding*][1].-->

Dependencies
------------

direct embeddingは型検査のために実行時にScalaコンパイラにアクセスする必要がある。Slickは必要性に駆られない限り、アプリケーションに対し、依存性を避けるためにScalaコンパイラへの依存性を任意としている。そのため、direct embeddingを用いる際にはプロジェクトの `build.sbt` に対し明示的にその依存性を記述しなくてはならない。

<!--The direct embedding requires access to the Scala compiler at runtime for typechecking. Slick only declares an *optional* dependency on scala-compiler in order to avoid bringing it (along with all transitive dependencies) into your application if you don’t need it. You must add it explicitly to your own project’s build.sbt file if you want to use the direct embedding:-->

```scala
libraryDependencies <+= (scalaVersion)("org.scala-lang" % "scala-compiler" % _)
```

Imports
-------

```scala
import scala.slick.driver.H2Driver
import H2Driver.simple.Database
import Database.{threadLocalSession => session}
import scala.slick.direct._
import scala.slick.direct.AnnotationMapper._
```

Row class and schema
-------------------

スキーマは現在でえは行を保持しているケースクラスに対してアノテーションを付与する事で記述する事が出来る。今後、より柔軟にスキーマの情報を拡張出来るような機能を提供する予定だ。

<!--The schema description is currently provided as annotations on a case class which is used for holding rows. We will later provide more flexible and customizable means of providing the schema information.-->

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

Queryableはテーブルデータに対しクエリの演算を行うためのものであり、注釈付けられた型引数を取る。

<!--Queryable takes an annotated case class as its type argument to formulate queries agains the corresponding table.-->

`_.price` はここではInt型である。潜在的な、マクロベースの実装においてはmapやfilterに与えられた引数はJVM上で実行されないが、その代わりにデータベースクエリへと変換される事を覚えておいて欲しい。

<!--_.price is of type Int here. The underlying, macro-based implementation takes care of that the shown arguments to map and filter are not executed on the JVM but translated to database queries instead.-->

```scala
// query database using direct embedding
val q1 = Queryable[Coffee]
val q2 = q1.filter( _.price > 3.0 ).map( _ .name )
```

Execution
---------

クエリを実行するためには、選択したデータベースのドライバーを用いるSlickBackendインスタンスを作成する必要がある。

<!--To execute the queries we need to create a SlickBackend instance passing in the chosen database backend driver.-->

```scala
val db = Database.forURL("jdbc:h2:mem:test1", driver = "org.h2.Driver")
db withSession {
    // execute query using a chosen db backend
    val backend = new SlickBackend( H2Driver, AnnotationMapper )
    println( backend.result( q2, session ) )
    println( backend.result( q2.length, session ) )
}
```

Alternative direct embedding bound to a driver and session
----------------------------------------------------------

ImplicitQueryableを用いると、queryableはバックエンドとセッションに束縛される。クエリはその上で以下のような方法で簡単に実行する事が出来る。

<!--Using ImplicitQueryable, a queryable can be bound to a backend and session. The query can be further adapted and easily executed this way.-->

```scala
//
val iq1 = ImplicitQueryable( q1, backend, session )
val iq2 = iq1.filter( c => c.price > 3.0 )
println( iq2.toSeq ) //  <- triggers execution 
println( iq2.length ) // <- triggers execution
```

Features
--------

direct embeddingは現在、 `String`, `Int`, `Double` といった値にたいしマッピングされるデータベースカラムのみサポートしている。

<!--The direct embedding currently only supports database columns, which can be mapped to either `String` , `Int` , `Double` .-->

QueryableとImplicitQueryableは現在、次のようなメソッドを用意している。

<!--Queryable and ImplicitQueryable currently support the following methods:-->

`map, flatMap, filter, length`

これらのメソッドはimmutableな演算を行うが、関数呼び出しによる変化を包含した新しいQuaryableを返す。

<!--The methods are all immutable meaning they leave the left-hand-side Queryable unmodified, but return a new Queryable incorporating the changes by the method call.-->

上記の関数におけるシンタックスとして、以下の様なオペレータを利用する事が出来る。

<!--Within the expressions passed to the above methods, the following operators may be used:-->

`Any: ==`

`Int, Double: + < >`

`String: +`

`Boolean: || &&`

他に定義された独自のオペレータについても、型検査がマッチしていれば利用する事が出来る。しかし現時点では、それらのオペレータは実行時に失敗するクエリを生成するようなSQLへ変換する事が出来ない。（例: `( coffees.map( c => c.name.repr ) )`）将来的には、コンパイル中にそのようなものもキャッチするような方法を検討している。

<!--Other operators may type check and compile ok, if they are defined for the corresponding types. They can however currently not be translated to SQL, which makes the query fail at runtime, for example: `(coffees.map( c => c.name.repr ))` . We are evaluating ways to catch those cases at compile time in the future-->

クエリは行を補完するようなオブジェクトを保持する、任意にネストされたタプルのシーケンスを結果として返す。

<!--Queries may result in sequences of arbitrarily nested tuples, which may also contain objects representing complete rows. E.g.-->

```scala
q1.map( c => (c.name, (c, c.price)) )
```

direct embeddingは現在データの挿入といった機能を持っていない。その代わりに[*lifted embedding*][2]や[*plain SQL queries*][3]などを用いる事ができる。

<!--The direct embedding currently does not feature insertion of data. Instead you can use the [*lifted embedding*][2] or [*plain SQL queries*][3].-->

 [1]: http://slick.typesafe.com/gettingstarted.html
 [2]: http://slick.typesafe.com/lifted-embedding.html
 [3]: http://slick.typesafe.com/sql.html  

Slick 2.0.0 documentation - 12 Slick TestKit
<!--Slick TestKit — Slick 2.0.0 documentation-->

[Permalink to Slick TestKit — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/testkit.html)

# Slick TestKit

Slickに対し、独自のデータベースドライバーを記述する際には、きちんと動作するのか、何が現時点で実装されていないのかなどを確認するために、ユニットテスト（もしくは加えて他の独自のカスタマイズしたテスト）をきちんと記述して欲しい。簡単にテストを記述するためのサポートとして、Slickユニットテスト用のSlick Test Kitプロジェクトを別に用意している。

<!--When you write your own database driver for Slick, you need a way to run all the standard unit tests on it (in addition to any custom tests you may want to add) to ensure that it works correctly and does not claim to support any capabilities which are not actually implemented. For this purpose the Slick unit tests have been factored out into a separate Slick TestKit project.-->

これを用いるためには、Slickの基本的なPostgreSQLドライバーと、ビルドするために必要なものを全て含んだ[Slick TestKit Example][1]をクローンして使って欲しい。

<!--To get started, you can clone the [Slick TestKit Example][1] project which contains a (slightly outdated) version of Slick’s standard PostgreSQL driver and all the infrastructure required to build and test it.-->

## Scaffolding

build.sbtは以下のように記述する。一般的な名前とバージョン設定と区別して、SlickとTestKit、junit-interface、Logback、PostgreSQL JDBC Driverへの依存性を追加する。そしてテストを行うためのオプションをいくつか記述する必要がある。

<!--Its build.sbt file is straight-forward. Apart from the usual name and version settings, it adds the dependencies for Slick, the TestKit, junit-interface, Logback and the PostgreSQL JDBC driver, and it sets some options for the test runs:-->

```scala
libraryDependencies ++= Seq(
  "com.typesafe.slick" %% "slick" % "2.0.0-RC1",
  "com.typesafe.slick" %% "slick-testkit" % "2.0.0-RC1" % "test",
  "com.novocode" % "junit-interface" % "0.10" % "test",
  "ch.qos.logback" % "logback-classic" % "0.9.28" % "test",
  "postgresql" % "postgresql" % "9.1-901.jdbc4" % "test"
)
...
testOptions += Tests.Argument(TestFrameworks.JUnit, "-q", "-v", "-s", "-a")
...
parallelExecution in Test := false
...
logBuffered := false
```

src/test/resources/logback-test.xmlに、Slickのlogbackについての設定のコピーがある。もちろん、loggingフレームワーク以外のものを使う事も出来る。

<!--There is a copy of Slick’s logback configuration in src/test/resources/logback-test.xml but you can swap out the logging framework if you prefer a different one.-->

## Driver

ドライバーの実装はsrc/main/scalaの中にある。

<!--The actual driver implementation can be found under src/main/scala.-->

## Test Harness

TestKitテストを実行するためには、DriberTestを継承したクラスを作成する必要がある。加えて、TestKitに対してどのようにtestデータベースへ接続するのか、テーブルのリストをどのように取得するのか、テスト間におけるクリーンをどのようにして行うのかなどといった事を表すTestDBの実装が必要になる。

<!--In order to run the TestKit tests, you need to add a class that extends DriverTest, plus an implementation of TestDB which tells the TestKit how to connect to a test database, get a list of tables, clean up between tests, etc.-->

PostgreSQLのテーストハーネス（src/test/scala/scala/slick/driver/test/MyPostgreTestの中にある）の場合は、大抵のデフォルトとなる実装はボックスの外で利用される。

<!--In the case of the PostgreSQL test harness (in **src/test/scala/scala/slick/driver/test/MyPostgresTest.scala**) most of the default implementations can be used out of the box:-->

```scala
@RunWith(classOf[Testkit])
class MyPostgresTest extends DriverTest(MyPostgresTest.tdb)
...
object MyPostgresTest {
  def tdb(cname: String) = new ExternalTestDB("mypostgres", MyPostgresDriver) {
    override def getLocalTables(implicit session: Session) = {
      val tables = ResultSetInvoker[(String,String,String, String)](_.conn.getMetaData()
                    .getTables("", "public", null, null))
      tables.list.filter(_._4.toUpperCase == "TABLE").map(_._3).sorted
    }
    override def getLocalSequences(implicit session: Session) = {
      val tables = ResultSetInvoker[(String,String,String, String)](_.conn.getMetaData()
                    .getTables("", "public", null, null))
      tables.list.filter(_._4.toUpperCase == "SEQUENCE").map(_._3).sorted
    }
    override lazy val capabilities = driver.capabilities + TestDB.plainSql
  }
}
```

## Database Configuration

PostgreSQLのテストハーネスは **ExternalTestDB** に基づいている一方、 **test-dbs/databases.properties** において設定が行われてなくてはならない。

<!--Since the PostgreSQL test harness is based on **ExternalTestDB**, it needs to be configured in **test-dbs/databases.properties**:-->

```scala
# PostgreSQL quick setup:
# - Install PostgreSQL server with default options
# - Change password in mypostgres.password
# - Set mypostgres.enabled = true
mypostgres.enabled = false
mypostgres.url = jdbc:postgresql:[DB]
mypostgres.user = postgres
mypostgres.password = secret
mypostgres.adminDB = postgres
mypostgres.testDB = slick-test
mypostgres.create = CREATE TABLESPACE slick_test LOCATION '[DBPATH]'; CREATE DATABASE "[DB]" TEMPLATE = template0 TABLESPACE slick_test
mypostgres.drop = DROP DATABASE IF EXISTS "[DB]"; DROP TABLESPACE IF EXISTS slick_test
mypostgres.driver = org.postgresql.Driver
```

## Testing

**sbt test** を実行すると、 **MyPostgresTest** を探索し、TestKitのJUnit runnerを用いて実行される。これはテストハーネスを通してセットアップされたデータベースを用いており、ドライバーを用いて適応可能な全てのテストが実行される事になる。

<!--Running **sbt test** discovers **MyPostgresTest** and runs it with TestKit’s JUnit runner. This in turn causes the database to be set up through the test harness and all tests which are applicable for the driver (as determined by the **capabilities** setting in the test harness) to be run.-->

 [1]: https://github.com/slick/slick-testkit-example/tree/2.0.0
