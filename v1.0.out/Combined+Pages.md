slick-doc-ja 1.0
================

[Slick 1.0 documentation](http://slick.typesafe.com/doc/1.0.0/)の日本語訳です。

- 編集先: [GitHub - krrrr38/slick-doc-ja](https://github.com/krrrr38/slick-doc-ja)
- 連絡先: [@krrrr38](https://twitter.com/krrrr38)


他のバージョンのドキュメント
---------------------------
- Slick 1.0 翻訳
- [Slick 2.0 翻訳](http://krrrr38.github.io/slick-doc-ja/v2.0.out/slick-doc-ja+2.0.html)

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

Slick 1.0.0 documentation - 02 始めよう
<!--Getting Started — Slick 1.0.0 documentation-->

[Permalink to Getting Started — Slick 1.0.0 documentation](http://slick.typesafe.com/doc/1.0.0/gettingstarted.html)

始めよう
==========
<!--# Getting Started-->

最も簡単なSlickアプリケーションの設定方法は[Slick Examples][1]のプロジェクトを用いる事です．このプロジェクトに含まれているREADMEに従ってビルドをして，実行してみてください．

<!--The easiest way of setting up a Slick application is by starting with the [Slick Examples][1] project. You can build and run this project by following the instructions in its README file.-->

依存性
-------
<!--## Dependencies-->

プロジェクトではどのようにしてSlickを用いれば良いのか確認してみよう．まず初めに，Slickと組み込みデータベースを追加する必要がある．もし[sbt][2]を使っているのなら， **build.sbt** に対して以下のような記述を追加すれば良い．

<!--Let’s take a closer look at what’s happening in that project. First of all, you need to add Slick and the embedded databases or drivers for external databases to your project. If you are using [sbt][2], you do this in your main build.sbt file:-->

```scala:build.sbt
libraryDependencies ++= List(
  // 適切なSlickのversionをここに指定しよう
  "com.typesafe.slick" %% "slick" % "1.0.0",
  "org.slf4j" % "slf4j-nop" % "1.6.4",
  "com.h2database" % "h2" % "1.3.166"
)
```

Slickはデバッグログに[SLF4J][3]を用いている．そのためSLF4Jについても追加する必要がある．ここではロギングを無効にするために **slf4j-nop** を用いている．もしログの出力を見たいのならば[Logback][4]のようなロギング用のフレームワークに替えなくてはならない．

<!--Slick uses [SLF4J][3] for its own debug logging so you also need to add an SLF4J implementation. Here we are using slf4j-nop to disable logging. You have to replace this with a real logging framework like [Logback][4] if you want to see log output.-->

Imports
--------

[Slick example lifted/FirstExample][5]は，独立した１つのアプリケーションとなっている．このアプリケーションでは以下のようなimport文を記述している．

<!--[Slick example lifted/FirstExample][5] contains a self-contained application that you can run. It starts off with some imports:-->

```scala
// H2 databaseへ接続するためにH2Driverをimport
import scala.slick.driver.H2Driver.simple._
...
// Use the implicit threadLocalSession
import Database.threadLocalSession
```

[H2 Database][6]を用いているため，Slickの **H2Driver** をimportする必要がある．このdriverに含まれる **simple** オブジェクトには[session handling][7]といったSlickに必要な共通の機能が含まれている．それ以外にimportする必要があるのは **threadLocalSession** である．これは取り扱うスレッドにセッションを付与する事でセッションの取り扱いを単純化させるものである．これにより不必要なimplicit変数を割り当てたりといった実装を行わなくて済む．

<!--Since we are using [H2][6] as our database system, we need to import features from Slick’s H2Driver. A driver’s simple object contains all commonly needed imports from the driver and other parts of Slick such as [*session handling*][7]. The only extra import we use is the threadLocalSession. This simplifies the session handling by attaching a session to the current thread so you do not have to pass it around on your own (or at least assign it to an implicit variable).-->

Databaseへの接続
---------------

アプリケーションの中では，どのようにデータベースに接続するのかを明示する **Database** オブジェクトを初めに作る．そしてセッションを開き，続くブロック内に処理を記述する．

<!--In the body of the application we create a Database object which specifies how to connect to a database, and then immediately open a session, running all code within the following block inside that session:-->

```scala
Database.forURL("jdbc:h2:mem:test1", driver = "org.h2.Driver") withSession {
  // セッションは明示的に名付けられる事はない
  // セッションは現在のスレッドに対し，importしたthreadLocalSessionとして束縛されるのである
}
```

Java SEの環境においては，データベースセッションはJDBCドライバークラスを用いてJDBC URLへ接続する事で作られる（正しいURLの記述法はJDBCドライバーのドキュメントを見て欲しい）．もし[plain SQL queries][8]のみを用いるのであれば，それ以上何もする必要はない．しかし，もし[direct embedding][9]や[lifted embedding][10]を用いるのであれば，SlickがSQL文を作成する事になるため， **H2Driver** のようなSlickのdriverを適宜importして欲しい．

<!--In a Java SE environment, database sessions are usually created by connecting to a JDBC URL using a JDBC driver class (see the JDBC driver’s documentation for the correct URL syntax). If you are only using [*plain SQL queries*][8], nothing more is required, but when Slick is generating SQL code for you (using the [*direct embedding*][9] or the [*lifted embedding*][10]), you need to make sure to use a matching Slick driver (in our case the H2Driver import above).-->

スキーマ
--------

このアプリケーションでは[lifted embedding][10]を用いているため，データベースのテーブルに対応する **Table** オブジェクトを書かなくてはならない．

<!--We are using the [*lifted embedding*][10] in this application, so we have to write Table objects for our database tables:-->

```scala
// SUPPLIERSテーブルの定義
object Suppliers extends Table[(Int, String, String, String, String, String)]("SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey) // 主キー
  def name = column[String]("SUP_NAME")
  def street = column[String]("STREET")
  def city = column[String]("CITY")
  def state = column[String]("STATE")
  def zip = column[String]("ZIP")
  // 全てのテーブルではテーブルの型パラメタと同じタイプの射影*を定義する必要がある．
  def * = id ~ name ~ street ~ city ~ state ~ zip
}
...
// COFFEESテーブルの定義
object Coffees extends Table[(String, Int, Double, Int, Int)]("COFFEES") {
  def name = column[String]("COF_NAME", O.PrimaryKey)
  def supID = column[Int]("SUP_ID")
  def price = column[Double]("PRICE")
  def sales = column[Int]("SALES")
  def total = column[Int]("TOTAL")
  def * = name ~ supID ~ price ~ sales ~ total
  // 他のテーブルとの結合のため作成された関係を表す外部キー
  def supplier = foreignKey("SUP_FK", supID, Suppliers)(_.id)
}
```

全ての列は名前（ScalaにおけるキャメルケースやSQLにおける大文字とアンダースコアの組み合わせ）とScalaの型（SQLの型はScalaの型から自動的に推測される）を持つ．これらは **val** ではなく **def** を用いて定義しなくてはならない．テーブルオブジェクトもScalaでの名前とSQLでの名前と型を持つ必要がある．テーブルの型引数は射影*と一致してなくてはならない．全ての列をタプルで取り出すといった簡単な処理以外にも，より複雑なオブジェクトへのマッピングを行う事も出来る．

<!--All columns get a name (usually in camel case for Scala and upper case with underscores for SQL) and a Scala type (from which the SQL type can be derived automatically). Make sure to define them with def and not with val. The table object also needs a Scala name, SQL name and type. The type argument of the table must match the type of the special * projection. In simple cases this is a tuple of all columns but more complex mappings are possible.-->

**Coffees** テーブルで定義した **外部キー** は， **Coffees** テーブルの **supID** のフィールドが， **Suppliers** テーブルで存在している **id** と同じ値を持っている事を保証している．要するに，ここでは多:1の関係を作成しているのである．ある **Coffees** の列は特定の **Suppliers** の列を指すが，複数のCoffeeが同じSupplierを指していたりする．この構成はデータベースレベルで強制されている．

<!--The foreignKey definition in the Coffees table ensures that the supID field can only contain values for which a corresponding id exists in the Suppliers table, thus creating an *n to one* relationship: A Coffees row points to exactly one Suppliers row but any number of coffees can point to the same supplier. This constraint is enforced at the database level.-->

Populating the Database
-----------------------

組み込みのH2データベースエンジンへ接続すると，空のデータベースが作られる．クエリを実行する前に，データベーススキーマ（ **Coffees** テーブルと **Suppliers** テーブルから成るもの）を作成し，いくつかのテストデータを挿入してみる．

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
// coffeeをいくつか挿入する（DBがサポートしている場合には，JDBCのバッチ処理を用いる）
Coffees.insertAll(
  ("Colombian",         101, 7.99, , ),
  ("French_Roast",       49, 8.99, , ),
  ("Espresso",          150, 9.99, , ),
  ("Colombian_Decaf",   101, 8.99, , ),
  ("French_Roast_Decaf", 49, 9.99, , )
)
```

テーブルの **ddl** 関数は，テーブルやその他データベースのエンティティを作成したり削除したりするための，データベース特有のコードを用いて **DDL** （data definition language）オブジェクトを作成する．複数の **DDL** は **++** を用いる事で，お互いが依存し合っていたとしても，全てのエンティティに対し正しい順序で作成と削除を行う．

<!--The tables’ **ddl** methods create **DDL** (data definition language) objects with the database-specific code for creating and dropping tables and other database entities. Multiple **DDL** values can be combined with **++** to allow all entities to be created and dropped in the correct order, even when they have circular dependencies on each other.-->

複数のデータを挿入する際は **insert** や **insertAll** といった関数を用いる．デフォルトではデータベースの **Session** は *auto-commit* モードになっている事に注意して欲しい． **insert** や **insertAll** のようなデータベースへの呼び出しはトランザクションにおいて，原子性が保たれるよう実行される（つまり，それらの処理は完全に実行するか全く実行しないかのいずれかが保証される）．このモードにおいては， **Coffee** が対応するSupplierのIDのみを参照するため， **Supplier** テーブルに対し先にデータを挿入しなくてはならない．

<!--Inserting the tuples of data is done with the **insert** and **insertAll** methods. Note that by default a database Session is in *auto-commit* mode. Each call to the database like insert or insertAll executes atomically in its own transaction (i.e. it succeeds or fails completely but can never leave the database in an inconsistent state somewhere in between). In this mode we we have to populate the Suppliers table first because the Coffees data can only refer to valid supplier IDs.-->

これらの記述を全て包括した明示的なトランザクションのブラケットを用いることも可能である．その際，トランザクションによって処理が強制されるため，順序は重要視されない．

<!--We could also use an explicit transaction bracket encompassing all these statements. Then the order would not matter because the constraints are only enforced at the end when the transaction is committed.-->

Querying
------------

最も簡単なクエリ例として，の一つにテーブルのデータを全て順々に取り出す処理を考える．

<!--The simplest kind of query iterates over all the data in a table:-->

```scala
// coffeeのデータを全て取り出し，順に出力する
Query(Coffees) foreach { case (name, supID, price, sales, total) =>
  println("  " + name + "t" + supID + "t" + price + "t" + sales + "t" + total)
}
```

この処理はSQLに **SELECT * FROM COFFEES** を投げた結果と同じである（ただし射影関数\*を異なる形式で作成した場合には，少し違う結果となる）．ループの中で得られる値の型は当然 **Coffees** の型引数と一致する．

<!--This corresponds to a SELECT * FROM COFFEES in SQL (except that the * is the table’s * projection we defined earlier and not whatever the database sees as *). The type of the values we get in the loop is, unsurprisingly, the type parameter of Coffees.-->

上記の例に射影処理を追加してみよう．これにはScalaで **map** や *for式* を用いる事で記述することが出来る．

<!--Let’s add a *projection* to this basic query. This is written in Scala with the map method or a *for comprehension*:-->

```scala
// なぜデータベースでは文字列の変換や連結が出来ないんだろう...?
val q1 = for(c <- Coffees) // Coffeesは自動的にQueryへとなる
  yield ConstColumn("  ") ++ c.name ++ "\t" ++ c.supID.asColumnOf[String] ++
    "\t" ++ c.price.asColumnOf[String] ++ "\t" ++ c.sales.asColumnOf[String] ++
    "\t" ++ c.total.asColumnOf[String]
// 初めの文字定数はConstColumへ手動で変換する必要がある．
// その後++オペレータにより結合させる
q1 foreach println
```

全ての行がタブによって区切られた文字列として連結した結果が得られるだろう．違いはデータベースの内側で処理が行われた事であり，結果として得られる連結した文字列は同様に取得出来る．Scalaの **+** オペレータはしばしばオーバーライドされてしまうため，seqの結合で一般的に用いられている **++** の方を利用すべきだ．また，他の引数型から文字列への自動的な型変換は存在しない．この処理は型変換関数である **asColumnOf** により明示的に行うべきである．

<!--The output will be the same: For each row of the table, all columns get converted to strings and concatenated into one tab-separated string. The difference is that all of this now happens inside the database engine, and only the resulting concatenated string is shipped to the client. Note that we avoid Scala’s + operator (which is already heavily overloaded) in favor of ++ (commonly used for sequence concatenation). Also, there is no automatic conversion of other argument types to strings. This has to be done explicitly with the type conversion method asColumnOf.-->

テーブルの結合やフィルタリングはScalaのコレクションと同じように処理する事が出来る．

<!--Joining and filtering tables is done the same way as when working with Scala collections:-->

```scala
// 2つのテーブルを結合し，coffeeの値段が$9より安いもののうち，
// coffeeの名前とsupplierの名前の組みを検索
val q2 = for {
  c <- Coffees if c.price < 9.0
  s <- Suppliers if s.id === c.supID
} yield (c.name, s.name)
```

2つの値が等しいかを比較する際に， **==** の代わりに **===** を用いている事に注意して欲しい．同様に，LiftedEmbeddingでは **!=** の代わりに **=!=** を用いている．それ以外の比較に関するオペレータ（ **<** , **<=** , **>=** , **>** ）はScalaで用いているものと同じである

<!--Note the use of === instead of == for comparing two values for equality. Similarly, the lifted embedding uses =!= instead of != for inequality. (The other comparison operators are the same as in Scala: **<**, **<=**, **>=**, **>**)-->

**Suppliers if s.id === c.supID** という表現は **Coffees.supplier** という外部キーにより作成された関係に基いている．joinの条件を繰り返す代わりに，このような方法で直接的に外部キーを用いた結合が行える．

<!--The generator expression Suppliers if s.id === c.supID follows the relationship established by the foreign key Coffees.supplier. Instead of repeating the join condition here we can use the foreign key directly:-->

```scala
val q3 = for {
  c <- Coffees if c.price < 9.0
  s <- c.supplier
} yield (c.name, s.name)
```

[1]: https://github.com/slick/slick-examples/tree/1.0.0
[2]: http://www.scala-sbt.org/
[3]: http://www.slf4j.org/
[4]: http://logback.qos.ch/
[5]: https://github.com/slick/slick-examples/blob/1.0.0/src/main/scala/com/typesafe/slick/examples/lifted/FirstExample.scala
[6]: http://h2database.com/
[7]: http://slick.typesafe.com/doc/1.0.0/session.html
[8]: http://slick.typesafe.com/doc/1.0.0/sql.html
[9]: http://slick.typesafe.com/doc/1.0.0/direct-embedding.html
[10]: http://slick.typesafe.com/doc/1.0.0/lifted-embedding.html

Slick 1.0.0 documentation - 03 Lifted Embedding
<!--Lifted Embedding — Slick 1.0.0 documentation-->

[Permalink to Lifted Embedding — Slick 1.0.0 documentation](http://slick.typesafe.com/doc/1.0.0/lifted-embedding.html)

Lifted Embedding
================

*lifted embedding* はSlickにおいて型安全なクエリ操作が行える基本的なAPIである．導入には[*始めよう*][1]を読んで欲しい．この章ではSlick及び *lifted embedding* の特徴と詳細について説明する．

<!-- The *lifted embedding* is the standard API for type-safe queries and updates in Slick. Please see [*Getting Started*][1] for an introduction. This chapter describes the available features in more detail.-->

*Lifted Embedding* という名前はScalaの基本的な型を用いる[*direct embedding*][2]と異なり，scala.slick.lifted.Repの型コンストラクタへと変化するような型を用いている事に基づいている．これはScalaのシンプルなコレクションと， *lifted embedding* を用いたコードを比べると明らかである．

<!-- The name *Lifted Embedding* refers to the fact that you are not working with standard Scala types (as in the [*direct embedding*][2]) but with types that are *lifted* into a the scala.slick.lifted.Rep type constructor. This becomes clear when you compare the types of a simple Scala collections example -->

こちらがScalaのコレクションの操作，

```scala
case class Coffee(name: String, price: Double)
val l: List[Coffee] = //...
val l2 = l.filter(_.price > 8.0).map(_.name)
//                  ^       ^          ^
//                Double  Double     String
```

そしてこちらが *Lifted Embedding* を用いた操作である．

<!-- ... with the types of similar code using the lifted embedding: -->

```scala
object Coffees extends Table[(String, Int, Double, Int, Int)]("COFFEES") {
  def name = column[String]("COF_NAME", O.PrimaryKey)
  def price = column[Double]("PRICE")
  //...
}
val q = Query(Coffees)
val q2 = q.filter(_.price > 8.0).map(_.name)
//                  ^       ^          ^
//          Rep[Double]  Rep[Double]  Rep[String]
```

シンプルな型はRepへと変換させられる．レコードの型であるCoffeesは，Rep[(String, Int, Double, Int, Int)]のサブタイプへ，8.0といった数値リテラルも，自動的なimplicit conversionにより，Rep[Double]へと変化する．というのも，Rep[Double]における**>**オペレータの右辺にその型が必要になるためである．

<!-- All plain types are lifted into Rep. The same is true for the record type Coffees which is a subtype of Rep[(String, Int, Double, Int, Int)]. Even the literal 8.0 is automatically lifted to a Rep[Double] by an implicit conversion because that is what the > operator on Rep[Double] expects for the right-hand side.-->

テーブル
-----------

lifted embeddingを用いるためには，データベースのテーブル毎に，テーブルオブジェクトを定義する必要がある．

<!-- In order to use the lifted embedding, you need to define Table objects for your database tables: -->

```scala
object Coffees extends Table[(String, Int, Double, Int, Int)]("COFFEES") {
  def name = column[String]("COF_NAME", O.PrimaryKey)
  def supID = column[Int]("SUP_ID")
  def price = column[Double]("PRICE")
  def sales = column[Int]("SALES")
  def total = column[Int]("TOTAL")
  def * = name ~ supID ~ price ~ sales ~ total
}
```

Slickはテーブルオブジェクトを複製してテーブルを作成するため，不要な状態等を付与すべきではない（操作するための関数に関しては問題無い）．Tableを継承するオブジェクトは *静的な位置* （トップレベルや他のオブジェクトの中でのみネストされた場所）で定義されることは無い．これはscalacによって行われる最適化で，不要な責務まで持ってしまうという問題を防止するためである．匿名の構造型を用いたり区別されたクラス定義を用いることで，テーブル内でvalを用いる事は推奨している．

<!-- Note that Slick clones your table objects under the covers, so you should not add any extra state to them (extra methods are fine though). Also make sure that an actual object for a table is not defined in a *static* location (i.e. at the top level or nested only inside other objects) because this can cause problems in certain situations due to an overeager optimization performed by scalac. Using a val for your table (with an anonymous structural type or a separate class definition) is fine everywhere.-->


全てのカラムはカラムメソッドを通して定義される．カラムはvalではなくdefを用いて定義しなくてはならない．これはカラムは複製する必要があるためである．各々のカラムはScalaの型とデータベースにおけるカラム名（一般的には大文字）を持っている．以下のプリミティブ型については，各データベースドライバーによって課せられた特定の制限を持ちつつも，基本的にはそのまま用いる事が出来る．

<!-- All columns are defined through the column method. Note that they need to be defined with def and not val due to the cloning. Each column has a Scala type and a column name for the database (usually in upper-case). The following primitive types are supported out of the box (with certain limitations imposed by the individual database drivers): -->

*   *数値型*: Byte, Short, Int, Long, BigDecimal, Float, Double
*   *LOB型*: java.sql.Blob, java.sql.Clob, Array[Byte]
*   *Date型*: java.sql.Date, java.sql.Time, java.sql.Timestamp
*   Boolean
*   String
*   Unit
*   java.util.UUID

nullを許可するカラムについては，Tがプリミティブ型である際には，Option[T]を用いて表す事が出来る．ただし，Optionの全ての操作に関して，現在ではScalaのOptionセマンティクスとは少し異なったデータベースのnullプロパゲーションセマンティクスを用いている．（例として，None === None はfalseを返す）．このような挙動は将来的に改善される予定だ．

<!-- Nullable columns are represented by Option[T] where T is one of the supported primitive types. Note that all operations on Option values are currently using the database’s null propagation semantics which may differ from Scala’s Option semantics. In particular, None === None evaluates to false. This behaviour may change in a future major release of Slick.-->

カラム名の後には，カラムの定義に関するオプションを追記することができる．それらのオプションはテーブルのOオブジェクトを通して利用する事が出来る．例として，以下のようなオプションを用いることが出来る．

<!-- After the column name, you can add optional column options to a column definition. The applicable options are available through the table’s O object. The following ones are defined for BasicProfile:-->

**NotNull**, **Nullable**

nullを許可する，nullを許可しないといったことを，DDLの作成時に明示するもの．nullに出来るかどうかといったことは，OptionかOptionで無いかといったように，型からも決定させることが出来る．

<!-- Explicitly mark the column a nullable or non-nullable when creating the DDL statements for the table. Nullability is otherwise determined from the type (Option or non-Option).-->

**PrimaryKey**

DDLを作成する際に，主キーとしてカラムを宣言する．

<!-- Mark the column as a (non-compound) primary key when creating the DDL statements.-->

**Default\[T\](defaultValue: T)**

データをテーブルに挿入する際に用いるデフォルト値を指定する．この情報はDDLを作成する時にのみ用いられる．

<!-- Specify a default value for inserting data the table without this column. This information is only used for creating DDL statements so that the database can fill in the missing information. -->

**DBType(dbType: String)**

DDLに特定のデータベースの型を用いる際に利用する．例えばStringのカラムに対してVARCHAR(20)を指定する際には，DBType("VARCHAR(20)")と明示する．

<!-- Use a non-standard database-specific type for the DDL statements (e.g. DBType("VARCHAR(20)") for a String column).-->

**AutoInc**

DDLを作成する際に，カラムに対して自動インクリメントなキーとして指定させる．他のカラムのオプションとは異なり，このオプションはDDLを作成する時以外に意味を持つ．多くのデータベースではデータを挿入する際に，自動インクリメントでないカラムを返す事を許可していない．そこでSlickでは返されるカラムが自動インクリメントとなっているかどうかを必要に応じてチェックする．

<!-- Mark the column as an auto-incrementing key when creating the DDL statements. Unlike the other column options, this one also has a meaning outside of DDL creation: Many databases do not allow non-AutoInc columns to be returned when inserting data (often silently ignoring other columns), so Slick will check if the return column is properly marked as AutoInc where needed. -->

全てのテーブルではデフォルトの射影となる\*関数を必要とする．これはクエリから行を返すときどのような形で値を返すかを指定するものである．Slickの\*射影はデータベースから通常得られる射影と全く同じにする必要は無い．何らかの計算を行った新しいカラムを作成してもいいし．いくつかのカラムを省略してしまっても良い，\*射影で得られる型と同じ型パラメータをテーブルへ指定する．おおよそこれは単一のカラム型か，カラム型のタプルになるだろう．

<!-- Every table requires a * method contatining a default projection. This describes what you get back when you return rows (in the form of a table object) from a query. Slick’s * projection does not have to match the one in the database. You can add new columns (e.g. with computed values) or omit some columns as you like. The non-lifted type corresponding to the * projection is given as a type parameter to Table. For simple, non-mapped tables, this will be a single column type or a tuple of column types. -->

## 拡張テーブル

自分で定義したクラスに対し，テーブルをマッピングする事も出来る．オペレータを用いる事で，双方向マッピングにより*射影がその型に対応するようになる．

<!-- It is possible to define a mapped table that uses a custom type for its * projection by adding a bi-directional mapping with the  operator:-->

```scala
case class User(id: Option[Int], first: String, last: String)
...
object Users extends Table[User]("users") {
  def id = column[Int]("id", O.PrimaryKey, O.AutoInc)
  def first = column[String]("first")
  def last = column[String]("last")
  def * = id.? ~ first ~ last <> (User, User.unapply _)
}
```

Optionで結果をラップしたシンプルなapplyメソッドとunapplyメソッドを持つcase Classへと最適化されるが，マッピングされた型を直接操作するオーバーロードも存在している．

<!-- It is optimized for case classes (with a simple apply method and an unapply method that wraps its result in an Option) but there is also an overload that operates directly on the mapped types. -->

制約
-------------

外部キー制約はテーブルのforeignKeyメソッドによって定義される．制約，カラム（または行），リンクされるテーブル，そしてテーブルから一致する行への関数として，特定の名前を与える必要がある．DDLを作成する際に，外部キーはその名前を用いて追加される．

<!-- A foreign key constraint can be defined with a table’s foreignKey method. It takes a name for the constraint, the local column (or projection, so you can define compound foreign keys), the linked table, and a function from that table to the corresponding column(s). When creating the DDL statements for the table, the foreign key definition is added to it.-->

```scala
object Suppliers extends Table[(Int, String, String, String, String, String)]("SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey)
  //...
}
...
object Coffees extends Table[(String, Int, Double, Int, Int)]("COFFEES") {
  def supID = column[Int]("SUP_ID")
  //...
  def supplier = foreignKey("SUP_FK", supID, Suppliers)(_.id)
}
```    

データベースにおける実際の制約とは独立に， *join* を用いてデータを結合する際に，外部キーは利用される．この時，joinされたデータを探すための自分で定義した便利な関数のように動作させる事が出来る．

<!-- Independent of the actual constraint defined in the database, such a foreign key can be used to navigate to the linked data with a *join*. For this purpose, it behaves the same as a manually defined utility method for finding the joined data:-->

```scala
def supplier = foreignKey("SUP_FK", supID, Suppliers)(_.id)
def supplier2 = Suppliers.where(_.id === supID)
```

主キー制約はprimaryKey関数を追加する事で，同様に定義することが出来る．これは複合主キーを定義する際に役立つ．複合主キーを用いる際は，カラムのオプションにO.PrimaryKeyをつける事は出来ない．

<!-- A primary key constraint can be defined in a similar fashion by adding a method that calls primaryKey. This is useful for defining compound primary keys (which cannot be done with the O.PrimaryKey column option):-->

```scala
object A extends Table[(Int, Int)]("a") {
  def k1 = column[Int]("k1")
  def k2 = column[Int]("k2")
  def * = k1 ~ k2
  def pk = primaryKey("pk_a", (k1, k2))
}
```

他のindexについてはindex関数を用いて同様に定義することが可能だ．uniqueパラメータを設定しなければ，デフォルトでは各indexはuniqueでは無い状態になっている．

<!-- Other indexes are defined in a similar way with the index method. They are non-unique by default unless you set the unique parameter:-->

```scala
object A extends Table[(Int, Int)]("a") {
  def k1 = column[Int]("k1")
  def k2 = column[Int]("k2")
  def * = k1 ~ k2
  def idx = index("idx_a", (k1, k2), unique = true)
}
```

全ての制約はテーブルで定義された適切な返り値を持つ関数を探す際に，反射的に適応される．これはtableConstraints関数をオーバーライドすることにより自由にカスタマイズする事が出来る．

<!-- All constraints are discovered reflectively by searching for methods with the appropriate return types which are defined in the table. This behavior can be customized by overriding the tableConstraints method.-->

Data Definition Language
------------------------

DDLステートメントはddl関数を用いて作成される．複数のDDLオブジェクトは++を用いて正しい順番にcreateとdropが行われるように連結される．これはテーブルの依存関係が循環している場合にも上手く機能する．ステートメントはcreate関数やdrop関数を用いて実行される．

<!-- DDL statements for a table can be created with its ddl method. Multiple DDL objects can be concatenated with ++ to get a compound DDL object which can create and drop all entities in the correct order, even in the presence of cyclic dependencies between tables. The statements are executed with the create and drop methods:-->

```scala
val ddl = Coffees.ddl ++ Suppliers.ddl
db withSession {
  ddl.create
  //...
  ddl.drop
}
```

SQLのコードを取得するには，createStatementsやdropStatements関数を用いると良い．

<!-- You can use the createStatements and dropStatements methods to get the SQL code:-->

```scala
ddl.createStatements.foreach(println)
ddl.dropStatements.foreach(println)
``` 

Expressions
-------------

プリミティブ値（not 複合型，not コレクション）は，TypeMapper[T]が存在していれば，Rep[T]のサブタイプであるColumn[T]という型によって表される．内部的に用いられるいくつかの特別な関数と，nullを許可するかnullを許可しないカラム間の変換を行う関数のみ，Columnクラスで定義がなされている．

<!--Primitive (non-compound, non-collection) values are representend by type Column[T] (a sub-type of Rep[T]) where a TypeMapper[T] must exist. Only some special methods for internal use and those that deal with conversions between nullable and non-nullable columns are defined directly in the Column class.-->

lifted embeddingにおいて一般的に用いられているオペレータや他の関数については，ExtensionMethodConversionsで定義された暗黙的な変換を通して追加される．実際の関数は，AnyExtensionMethods，ColumnExtensionMethods，NumericColumnExtensionMethods，BooleanColumnExtensionMethods，StringColumnExtensionMethodsといったクラスの中にある．

<!-- The operators and other methods which are commonly used in the lifted embedding are added through implicit conversions defined in ExtensionMethodConversions. The actual methods can be found in the classes AnyExtensionMethods, ColumnExtensionMethods, NumericColumnExtensionMethods, BooleanColumnExtensionMethods and StringColumnExtensionMethods.-->

コレクションはflatMap，filter，take，groupByといったコレクションに本来用意されている基本的な関数を持った，Queryクラス（Rep[Seq[T]]）によって表されている．変換された型とシンプルな型といったようなQueryの異なる2つの複合型により，先のような関数はとても複雑なものになる．しかし，意味的にはScalaのコレクションと本質は同じになる．

<!--Collection values are represented by the Query class (a Rep[Seq[T]]) which contains many standard collection methods like flatMap, filter, take and groupBy. Due to the two different component types of a Query (lifted and plain), the signatures for these methods are very complex but the semantics are essentially the same as for Scala collections.-->

それ以外にも，複合でない値のクエリのための関数がSingleColumnQueryExtensionMethodsへ暗黙的な変換を通して追加されている．

<!--Additional methods for queries of non-compound values are added via an implicit conversion to SingleColumnQueryExtensionMethods.-->

ソートとフィルタリング（Sorting, Filtering）
--------------------------------------------

様々な種類のソートやフィルタリングが存在している．例えばQueryを引数に，同じ型である新しいQueryを返すものなどがある．

<!--There are various methods with sorting/filtering semantics (i.e. they take a Query and return a new Query of the same type), for example:-->

```scala
val q = Query(Coffees)
val q1 = q.filter(_.supID === 101)
val q2 = q.drop(10).take(5)
val q3 = q.sortBy(_.name.desc.nullsFirst)
``` 

結合（Join, Zipping）
--------------------

joinは1つのクエリで異なる2つの異なったテーブルやクエリを結合させるために用いられる．

<!--Joins are used to combine two different tables or queries into a single query.-->

joinを記述するには2つの方法がある． *明示的な* joinは2つのクエリを，個々の結果であるタプルの単一クエリへと結合させる関数を呼び出すことによって行う． *暗黙的な* joinは特別な関数を呼び出すこと無く，クエリを特定の形へと変形させる．

<!-- There are two different ways of writing joins: *Explicit* joins are performed by calling a method that joins two queries into a single query of a tuple of the individual results. *Implicit* joins arise from a specific shape of a query without calling a special method.-->

*暗黙的な交差結合（cross-join）* はQueryにおいてflatMapを用いることで実装出来る．for式を用いることでより簡単に表現することが可能だ．

<!--An *implicit cross-join* is created with a flatMap operation on a Query (i.e. by introducing more than one generator in a for-comprehension):-->

```scala
val implicitCrossJoin = for {
  c <- Coffees
  s <- Suppliers
} yield (c.name, s.name)
```

もしfilterのような操作を行った場合には，それは暗黙的な内部結合（inner-join）となる．

<!--If you add a filter expression, it becomes an implicit inner join:-->

```scala
val implicitInnerJoin = for {
  c <- Coffees
  s <- Suppliers if c.supID === s.id
} yield (c.name, s.name)
```

これらの暗黙的な結合はScalaコレクションにおけるflatMapを用いた時と全く同じような意味を持つ．

<!--The semantics of these implicit joins are the same as when you are using flatMap on Scala collections.-->

明示的な結合はjoin関数を呼び出す事で作成出来る．

<!--Explicit joins are created by calling one of the available join methods:-->

```scala
val explicitCrossJoin = for {
  (c, s) <- Coffees innerJoin Suppliers
} yield (c.name, s.name)
...
val explicitInnerJoin = for {
  (c, s) <- Coffees innerJoin Suppliers on (_.supID === _.id)
} yield (c.name, s.name)
...
val explicitLeftOuterJoin = for {
  (c, s) <- Coffees leftJoin Suppliers on (_.supID === _.id)
} yield (c.name, s.name.?)
...
val explicitRightOuterJoin = for {
  (c, s) <- Coffees rightJoin Suppliers on (_.supID === _.id)
} yield (c.name.?, s.name)
...
val explicitFullOuterJoin = for {
  (c, s) <- Coffees outerJoin Suppliers on (_.supID === _.id)
} yield (c.name.?, s.name.?)
```

交差結合や内部結合の明示的なversionsは，暗黙的なversions（大抵はSQLにおける暗黙的な結合）として生成されるSQLのコードへと帰着する．外部結合における.?の利用には注意して欲しい．これらの結合は付随的なNULL（左外部結合における右辺，右外部結合における左辺，完全外部結合における両辺）を生み出すが，そこからOption値を取得する事が出来る．

<!-- The explicit versions of the cross join and inner join will result in the same SQL code being generated as for the implicit versions (usually an implicit join in SQL). Note the use of .? in the outer joins. Since these joins can introduce additional NULL values (on the right-hand side for a left outer join, on the left-hand sides for a right outer join, and on both sides for a full outer join), you have to make sure to retrieve Option values from them.-->

交差結合や外部結合によらない関係データベースによってサポートされる一般的なjoinオペレータに加えて，Slickでは2つのクエリのペアワイズ結合を生成するzip joinを用意している．またそれは，ScalaのコレクションにおけるzipやzipWith関数を用いた時と全く同じような意味を持つ．

<!--In addition to the usual join operators supported by relational databases (which are based off a cross join or outer join), Slick also has zip joins which create a pairwise join of two queries. The semantics are again the same as for Scala collections, using the zip and zipWith methods:-->

```scala
val zipJoinQuery = for {
  (c, s) <- Coffees zip Suppliers
} yield (c.name, s.name)
...
val zipWithJoin = for {
  res <- Coffees.zipWith(Suppliers, (c: Coffees.type, s: Suppliers.type) => (c.name, s.name))
} yield res
```

zip joinにはzipWithIndexのような特有な結合がある．これは0から始まる無限長の数列をクエリの結果と結合させる．SQLデータベースではそのような数列を表すことが出来ないし，Slickも現在ではそれについてサポートしていない（今後変更するかもしれない）．しかし，zipされたクエリ結果というのは行番号関数を用いる事でSQLにおいても表現する事が出来る．つまりzipWithIndexはプリミティブなオペレータとしてサポートされているのである．

<!-- A particular kind of zip join is provided by zipWithIndex. It zips a query result with an infinite sequence starting at 0. Such a sequence cannot be represented by an SQL database and Slick does not currently support it, either (but this is expected to change in the future). The resulting zipped query, however, can be represented in SQL with the use of a row number function, so zipWithIndex is supported as a primitive operator:-->

```scala
val zipWithIndexJoin = for {
  (c, idx) <- Coffees.zipWithIndex
} yield (c.name, idx)
```

連結（Unions）
------------

適応可能な型については，unionやunionAllというオペレータを用いて2つのクエリを連結させる事が出来る．

<!-- Two queries can be concatenated with the union and unionAll operators if they have compatible types:-->

```scala
val q1 = Query(Coffees).filter(_.price < 8.0)
val q2 = Query(Coffees).filter(_.price > 9.0)
val unionQuery = q1 union q2
val unionAllQuery = q1 unionAll q2
```

複製された値をフィルタリングするような結合と異なり，unionAllではシンプルに，時折より効率的に，複数のクエリを結合させる．

<!--Unlike union which filters out duplicate values, unionAll simply concatenates the queries, which is usually more efficient.-->

集約（Aggregation）
------------------

集約の簡単な例として，単一のカラムを返すクエリからプリミティブ値を計算する事を考える．単一のカラムというのは基本的に数値型となる．

<!--The simplest form of aggregation consists of computing a primitive value from a Query that returns a single column, usually with a numeric type, e.g.:-->

```scala
val q = Coffees.map(_.price)
val q1 = q.min
val q2 = q.max
val q3 = q.sum
val q4 = q.avg
```

以下のような集約関数は任意のクエリにおいて実行する事が出来る．

<!--Some aggregation functions are defined for arbitrary queries:-->

```scala
val q = Query(Coffees)
val q1 = q.length
val q2 = q.exists
```

グループ化はgroupByメソッドによって実装されている．これもScalaのコレクション操作と同じ様に機能する．

<!--Grouping is done with the groupBy method. It has the same semantics as for Scala collections:-->

```scala
val q = (for {
  c <- Coffees
  s <- c.supplier
} yield (c, s)).groupBy(_._1.supID)
...
val q2 = q.map { case (supID, css) =>
  (supID, css.length, css.map(_._1.price).avg)
}
```

<!--TODO よくわからない...-->

Note that the intermediate query q contains nested values of type Query. These would turn into nested collections when executing the query, which is not supported at the moment. Therefore it is necessary to flatten the nested queries by aggregating their values (or individual columns) as done in q2.

クエリの実行（Querying）
-----------------------

Queryは[Invoker][3]トレイト（パラメータが無い場合には[UnitInvoker][4] ）において定義されたメソッドを用いて実行される．Queryからの暗黙的な変換が存在しているため，全てのQueryを直接的に実行する事が出来る．もっとも一般的な使用方法は，listといった特定の関数や，様々な種類のコレクションを生成する関数（to[Vector]など）を用いてコレクションへと結果を変換させる事である．

<!--Queries are executed using methods defined in the [Invoker][3] trait (or [UnitInvoker][4] for the parameterless versions). There is an implicit conversion from Query, so you can execute any Query directly. The most common usage scenario is reading a complete result set into a strict collection with a specialized method such as list or the generic method to which can build any kind of collection:-->

```scala
val l = q.list
val v = q.to[Vector]
val invoker = q.invoker
val statement = q.selectStatement
```

この例では，明示的に暗黙的な変換メソッドを呼び出す事無しに，invokerへの参照をどのようにして取得するのかを表している．

<!--This snippet also shows how you can get a reference to the invoker without having to call the implicit conversion method manually.-->

クエリを実行する全てのメソッドは暗黙的にSessionの値を保持している．もちろん，明示的にsessionを通しても構わない．

<!-- All methods that execute a query take an implicit Session value. Of course, you can also pass a session explicitly if you prefer:-->

```scala
val l = q.list(session)
```

もし返り値として一つだけの値を返したいなら，firstやfirstOptionといったメソッドを使う事が出来る．foreach, foldLeft, elementsといったメソッドは全てのデータをScalaのコレクションへとコピーする事なしに，得られた結果をイテレートさせて利用する事が出来る．

<!-- If you only want a single result value, you can use first or firstOption. The methods foreach, foldLeft and elements can be used to iterate over the result set without first copying all data into a Scala collection.-->

削除（Deleting）
-----------------

データの削除は先のQueryingと同じように機能する．何かデータを削除する時には，適当な行をselectした後にdeleteを呼び出すだろう．Queryからdelete関数や自己参照するdeleteInvokerを持った[DeleteInvoker][5]への暗黙的な変換が存在している．

<!--Deleting works very similarly to querying. You write a query which selects the rows to delete and then call the delete method on it. There is again an implicit conversion from Query to the special [DeleteInvoker][5] which provides the delete method and a self-reference deleteInvoker:-->

```scala
val affectedRowsCount = q.delete
val invoker = q.deleteInvoker
val statement = q.deleteStatement
```

削除を行うクエリは単一のテーブルのみを指定する．どんな射影も無視される．

<!--A query for deleting must only select from a single table. Any projection is ignored (it always deletes full rows).-->

挿入（Inserting）
----------------

データの挿入は単一のテーブルに対し，カラムの射影を用いて行われる．テーブルを直接的に利用する場合，挿入は\*射影を用いずに実行される．挿入時にテーブルのカラムを一部省くと，データベース作成時に定義されたデフォルト値か，もしくは適当に用意した，型に応じた非明示的なデフォルト値をデータベースに挿入する．データ挿入のための全てのメソッドは[InsertInvoker][6]と[FullInsertInvoker][7]において定義されている．

<!--Inserts are done based on a projection of columns from a single table. When you use the table directly, the insert is performed against its * projection. Omitting some of a table’s columns when inserting causes the database to use the default values specified in the table definition, or a type-specific default in case no explicit default was given. All methods for inserting are defined in [InsertInvoker][6] and [FullInsertInvoker][7].-->

```scala
Coffees.insert("Colombian", 101, 7.99, 0, 0)
...
Coffees.insertAll(
  ("French_Roast", 49, 8.99, 0, 0),
  ("Espresso",    150, 9.99, 0, 0)
)
...
// "sales"と"total"はデフォルト値である0を用いる
(Coffees.name ~ Coffees.supID ~ Coffees.price).insert("Colombian_Decaf", 101, 8.99)
...
val statement = Coffees.insertStatement
val invoker = Coffees.insertInvoker
```

あるデータベースシステムではAutoIncとなっているカラムへの適切な値の挿入や作成された値を取得するためにNoneという値を挿入することを許可している一方，多くのデータベースではこのような操作を禁じているため，これらのカラムについて省けるかどうかは，データベースシステムについて調べて確認をしなくてはならない．Slickはまだ自動的にこの処理を行うような機能を持ってはいないが，将来的に追加する予定である．現時点では以下の例にあるforInsertのような，AutoIncとなっているカラムを含まない射影を用いるべきである．

<!--While some database systems allow inserting proper values into AutoInc columns or inserting None to get a created value, most databases forbid this behaviour, so you have to make sure to omit these columns. Slick does not yet have a feature to do this automatically but it is planned for a future release. For now, you have to use a projection which does not include the AutoInc column, like forInsert in the following example:-->

```scala
case class User(id: Option[Int], first: String, last: String)
...
object Users extends Table[User]("users") {
  def id = column[Int]("id", O.PrimaryKey, O.AutoInc)
  def first = column[String]("first")
  def last = column[String]("last")
  def * = id.? ~ first ~ last <> (User, User.unapply _)
  def forInsert = first ~ last <> ({ t => User(None, t._1, t._2)}, { (u: User) => Some((u.first, u.last))})
}
...
Users.forInsert insert User(None, "Christopher", "Vogt")
```

このような処理を行う際，AutoIncで自動生成された主キーのカラムを取得したいと考える事があるだろう．デフォルトでは，insert関数は影響を与えた行の数（大抵1になる）を返り値として返すし，insertAll関数はOption（もしデータベースが全ての行のための数え上げ機能を提供していない場合にはNoneとなる）における計算された数を返す．insertから単一の値やタプル，insertAllからSeqのような値として，返されるカラムを指定する場合には，returning関数を用いる事で指定が可能になる．

<!--In these cases you frequently want to get back the auto-generated primary key column. By default, insert gives you a count of the number of affected rows (which will usually be 1) and insertAll gives you an accumulated count in an Option (which can be None if the database system does not provide counts for all rows). This can be changed with the returning method where you specify the columns to be returned (as a single value or tuple from insert and a Seq of such values from insertAll):-->

```scala
val userId =
  Users.forInsert returning Users.id insert User(None, "Stefan", "Zeiger")
```

多くのデータベースでは単一のカラムを返す際に，テーブルのAutoIncな主キーを返す事を許可している．もし他のカラムが叩かれたら，SlickExceptionが実行中に（データベースが実際にそれをサポートしていない限り）投げられてしまう．

<!--Note that many database systems only allow a single column to be returned which must be the table’s auto-incrementing primary key. If you ask for other columns a SlickException is thrown at runtime (unless the database actually supports it).-->

クライアント側からデータを挿入する代わりに，データベースサーバーにおいて実行されるQueryやスカラー表現によって作られたデータを挿入すること事も出来る．

<!--Instead of inserting data from the client side you can also insert data created by a Query or a scalar expression that is executed in the database server:-->

```scala
object Users2 extends Table[(Int, String)]("users2") {
  def id = column[Int]("id", O.PrimaryKey)
  def name = column[String]("name")
  def * = id ~ name
}
...
Users2.ddl.create
Users2 insert (Users.map { u => (u.id, u.first ++ " " ++ u.last) })
Users2 insertExpr (Query(Users).length + 1, "admin")
```

更新（Updating）
-----------------

データの更新は該当するデータをselectしてから，新たなデータへ更新することになるだろう．そのようなクエリは単一テーブルからselectされた生のカラム（計算された値ではない）のみを返すべきである．更新に関係する関数は[UpdateInvoker][8]において定義されている．

<!--Updates are performed by writing a query that selects the data to update and then replacing it with new data. The query must only return raw columns (no computed values) selected from a single table. The relevant methods for updating are defined in [UpdateInvoker][8].-->

```scala
val q = for { c <- Coffees if c.name === "Espresso" } yield c.price
q.update(10.49)
...
val statement = q.updateStatement
val invoker = q.updateInvoker
```

現時点では，更新のための，データベース内にあるデータのスカラー表現や変換を利用する方法は無い．

<!--There is currently no way to use scalar expressions or transformations of the existing data in the database for updates.-->

クエリテンプレート
------------------

クエリテンプレートは任意のパラメータが決められたクエリのことである．複数のパラメータを取る関数のようにテンプレートは機能し，より効率的にQueryを返す．通常，クエリを作成するために関数を評価する際，新しいクエリとなるASTをその関数は構築し，そのクエリを実行する際に，たとえ同じSQL文が結果を返したとしても，常にクエリコンパイラによって毎度クエリはコンパイルされる．一方で，クエリテンプレートは単一のSQL文（全てのパラメータが変数へバインドされるが）に制限され，たった一度しかクエリはビルド，コンパイルされない．

<!--Query templates are parameterized queries. A template works like a function that takes some parameters and returns a Query for them except that the template is more efficient. When you evaluate a function to create a query the function constructs a new query AST, and when you execute that query it has to be compiled anew by the query compiler every time even if that always results in the same SQL string. A query template on the other hand is limited to a single SQL string (where all parameters are turned into bind variables) by design but the query is built and compiled only once.-->

クエリテンプレートは[Parameters][9]オブジェクトのflatMapを呼び出すことによって作る事が出来る．大抵の場合，for式を1つ書くことで，テンプレートを作成する事が出来る．

<!--You can create a query template by calling flatMap on a [Parameters][9] object. In many cases this enables you to write a single for comprehension for a template.-->

```scala
val userNameByID = for {
  id <- Parameters[Int]
  u <- Users if u.id is id
} yield u.first
...
val name = userNameByID(2).first
...
val userNameByIDRange = for {
  (min, max) <- Parameters[(Int, Int)]
  u <- Users if u.id >= min && u.id < max
} yield u.first
...
val names = userNameByIDRange(2, 5).list
```

ユーザ定義関数とユーザ定義型
----------------------------

もしデータベースシステムがSlickにおける関数として利用出来るスカラー関数を用意していたとしたら，それを[SimpleFunction][10]として定義することが出来る．パラメータと返り値を固定した1つ，2つ，もしくは3つの関数を作成するための関数が既に定義されている．

<!--If your database system supports a scalar function that is not available as a method in Slick you can define it as a [SimpleFunction][10]. There are predefined methods for creating unary, binary and ternary functions with fixed parameter and return types.-->

```scala
// H2はタイムスタンプから曜日を抽出する関数であるday_of_week()を持っている
val dayOfWeek = SimpleFunction.unary[Date, Int]("day_of_week")
...
// 曜日によってグループ化するクエリにおいて，拡張された関数を用いる事が出来る
val q1 = for {
  (dow, q) <- SalesPerDay.map(s => (dayOfWeek(s.day), s.count)).groupBy(_._1)
} yield (dow, q.map(_._2).sum)
```

もし特定の型（varargsや，ポリモーフィックな関数，もしくはある関数におけるOptionや非Option型をサポートするため）を評価する，より柔軟な機能が欲しいのならば，型の決められていないインスタンスを得るためにSimpleFunction.applyを用いる事ができるし，適切な型検査をつけたラッパー関数を自身で書くことも出来る．

<!--If you need more flexibility regarding the types (e.g. for varargs, polymorphic functions, or to support Option and non-Option types in a single function), you can use SimpleFunction.apply to get an untyped instance and write your own wrapper function with the proper type-checking:-->

```scala
def dayOfWeek2(c: Column[Date]) =
  SimpleFunction("day_of_week")(TypeMapper.IntTypeMapper)(Seq(c))
```

[SimpleBinaryOperator][11]と[SimpleLiteral][12]はよく似た機能を持っている．さらにより柔軟な機能（普遍的でないシンタックスを持った関数に近い表現など）のために，[SimpleExpression][13]を用いる事が出来る．

<!--[SimpleBinaryOperator][11] and [SimpleLiteral][12] work in a similar way. For even more flexibility (e.g. function-like expressions with unusual syntax), you can use [SimpleExpression][13].-->

もしカスタムしたカラム型を必要とするのならば，[TypeMapper][14]と[TypeMapperDelegate][15]を実装すれば良い．大抵の場面，アプリケーション特有の型をデータベースに既にサポートされた型へとマッピングする事になる．これは全ての共通事項(boilerplate)を考慮した[MappedTypeMapper][16]を用いることによってより簡単に実装する事が出来る．

<!--If you need a custom column type you can implement [TypeMapper][14] and [TypeMapperDelegate][15]. The most common scenario is mapping an application-specific type to an already supported type in the database. This can be done much simpler by using a [MappedTypeMapper][16] which takes care of all the boilerplate:-->

```scala
// booleanの代数型
sealed trait Bool
case object True extends Bool
case object False extends Bool
...
// 上記のbooleanを1と0のIntへと変換するTypeMapper
implicit val boolTypeMapper = MappedTypeMapper.base[Bool, Int](
  { b => if(b == True) 1 else 0 },    // map Bool to Int
  { i => if(i == 1) True else False } // map Int to Bool
)
```
Bool型をテーブルやクエリなどにおいて，ビルドインされたカラム型であるかのように扱う事が出来る．
さらにより柔軟な操作にはサブクラスであるMappedTypeMapperを用いる事が出来る．

<!--// You can now use Bool like any built-in column type (in tables, queries, etc.)
You can also subclass MappedTypeMapper for a bit more flexibility.-->

[1]: http://slick.typesafe.com/doc/1.0.0/gettingstarted.html
[2]: http://slick.typesafe.com/doc/1.0.0/direct-embedding.html
[3]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.jdbc.Invoker
[4]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.jdbc.UnitInvoker
[5]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.driver.BasicInvokerComponent$DeleteInvoker
[6]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.driver.BasicInvokerComponent$InsertInvoker
[7]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.driver.BasicInvokerComponent$FullInsertInvoker
[8]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.driver.BasicInvokerComponent$UpdateInvoker
[9]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.Parameters
[10]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.SimpleFunction
[11]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.SimpleBinaryOperator
[12]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.SimpleLiteral
[13]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.SimpleExpression
[14]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.TypeMapper
[15]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.TypeMapperDelegate
[16]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.MappedTypeMapper

Slick 1.0.0 documentation - 04 Plain SQL Queries

<!--Plain SQL Queries — Slick 1.0.0 documentation-->

[Permalink to Plain SQL Queries — Slick 1.0.0 documentation](http://slick.typesafe.com/doc/1.0.0/sql.html)

Plain SQL Queries
==================

抽象的で高度な操作について，SQLコードを直接書きたくなる事があるかもしれない．Slickの *Plain SQL* クエリでは，[JDBC][1]の低レイアに触れる事無しに，よりScalaベースな記述を行う事が出来る．

<!--Sometimes you may need to write your own SQL code for an operation which is not well supported at a higher level of abstraction. Instead of falling back to the low level of [JDBC][1], you can use Slick’s *Plain SQL* queries with a much nicer Scala-based API.-->

Scaffolding
-------------

[SLick example jdbc/PlainSQL][2]では *Plain SQL* の特徴についていくつか説明している．インポートすべきパッケージが[*lifted embedding*][3]や[*direct embedding*][4]とは異なっている事に注意して欲しい．

<!--[Slick example jdbc/PlainSQL][2] demonstrates some features of the *Plain SQL* support. The imports are different from what you’re used to for the [*lifted embedding*][3] or [*direct embedding*][4]:-->

```scala
import scala.slick.session.Database
import Database.threadLocalSession
import scala.slick.jdbc.{GetResult, StaticQuery => Q}
```

まず初めに， *Slick driver* をインポートする必要がない．SlickのJDBCに基づくAPIはJDBC自身のみに依存しているし，データベース特有の抽象化を全く実装する必要がない．データベースに接続するために必要なものは，scala.slick.session.Databaseとセッション処理を単純化したthreeadLocalSessionのみである．

<!--First of all, there is no *Slick driver* being imported. The JDBC-based APIs in Slick depend only on JDBC itself and do not implement any database-specific abstractions. All we need for the database connection is Database, plus the threadLocalSession to simplify session handling.-->

*Plain SQL* クエリを用いるために必要なクラスは，ここではQという名前でインポートしている，scala.slick.jdbc.StaticQueryである．

<!--The most important class for *Plain SQL* queries is scala.slick.jdbc.StaticQuery which gets imported as Q for more convenient use.-->

データベースの接続方法は[*in the usual way*][5]にある．例を示すために，以下のようなcase classを定義した．

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

最もシンプルなStaticQueryのメソッドは，updateNAである（NA = no args）．updateNAは，結果の代わりにDDLステートメントから行数を返すStaticQuery[Unit, Int]を作成する，これは[*lifted embedding*][3]を用いるクエリと同じように実行する事が出来る．ここでは結果を得ずに，クエリを.executeを用いて実行させている．

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

文字列を既存のStaticQueryオブジェクトに対し，\+を用いて結合する事が出来る．この際，新しいStaticQueryが生成される．StaticQuery.uは，便利な関数であり，StaticQuery.updateNA("")で生成される空の *update* クエリを生成する．SUPPLIERSテーブルにいくつかのデータを挿入するためにStaticQuery.uを用いてみる．

<!--You can append a String to an existing StaticQuery object with +, yielding a new StaticQuery with the same types. The convenience method StaticQuery.u constructs an empty *update* query to start with (identical to StaticQuery.updateNA("")). We are using it to insert some data into the SUPPLIERS table:-->

```scala
// 複数のsupplierを挿入する
(Q.u + "insert into suppliers values(101, 'Acme, Inc.', '99 Market Street', 'Groundsville', 'CA', '95199')").execute
(Q.u + "insert into suppliers values(49, 'Superior Coffee', '1 Party Place', 'Mendocino', 'CA', '95460')").execute
(Q.u + "insert into suppliers values(150, 'The High Ground', '100 Coffee Lane', 'Meadows', 'CA', '93966')").execute
```

SQLコード内にリテラルを埋め込む事は，一般的にセキュリティやパフォーマンスの観点から推奨されない．特に，ユーザが提供したデータを実行時に用いるような際には危険な処理になる．変数をクエリ文字列に追加するためには，特別な連結オペレータである+?を用いる．これはSQL文が実行される際に，渡された値を用いてインスタンス化するものである．

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

SQL文は全ての呼び出しで同じもの（insert into coffees values (?,?,?,?,?)）となっている．

<!--The SQL statement is the same for all calls: insert into coffees values (?,?,?,?,?)-->

Query Statements
-----------------

updateNAと似た，返り値となる行の型パラメータを取るqueryNAというメソッドがある．このメソッドは *select文* を実行し，結果をiteratorで回す事が出来る．

<!--Similar to updateNA, there is a queryNA method which takes a type parameter for the rows of the result set. You can use it to execute a *select* statement and iterate over the results:-->

```scala
Q.queryNA[Coffee]("select * from coffees") foreach { c =>
  println("  " + c.name + "t" + c.supID + "t" + c.price + "t" + c.sales + "t" + c.total)
}
```

これらを上手く機能させるためには，SlickはPositionedResultオブジェクトからCoffeeの値をどのようにして読み取ればいいのかを知らせなくてはならない．これは暗黙的なGetResultによって行われる．GetResultを持つ基本的なJDBCの型や，NULLを許可するカラムを表すためのOptionや，タプルに対して，暗黙的なGetResultが定義されていなくてはならない．この例においてはSupplierクラスやCoffeeクラスのためのGetResultを以下のように用意する必要がある．

<!--In order for this to work, Slick needs to know how to read Coffee values from a PositionedResult object. This is done with an implicit GetResult value. There are predefined GetResult implicits for the standard JDBC types, for Options of those (to represent nullable columns) and for tuples of types which have a GetResult. For the Supplier and Coffee classes in this example we have to write our own:-->

```scala
// Result set getters
implicit val getSupplierResult = GetResult(r => Supplier(r.nextInt, r.nextString, r.nextString,
      r.nextString, r.nextString, r.nextString))
implicit val getCoffeeResult = GetResult(r => Coffee(r.<<, r.<<, r.<<, r.<<, r.<<))
```

GetResult[T]はPositionedResult => Tとなる関数のシンプルなラッパーである．上の例において，1つ目のGetResultでは現在の行から次のInt，次のStringといった値を読み込むgetInt，getStringといったPositionedResultの明示的なメソッドを用いている．2つ目のGetResultでは自動的に型を推測する簡易化されたメソッド<<を用いている．コンスタクタの呼び出しにおいて実際に型を判別出来る際にのみこれは用いる事ができる．

<!--GetResult[T] is simply a wrapper for a function PositionedResult => T. The first one above uses the explicit PositionedResult methods getInt and getString to read the next Int or String value in the current row. The second one uses the shortcut method << which returns a value of whatever type is expected at this place. (Of course you can only use it when the type is actually known like in this constructor call.)-->

パラメータの無いクエリのための，queryNAメソッドは2つの型パラメータ（1つはクエリパラメータ，もう1つは返り値となる行の型パラメータ）を取るクエリによって補完される．同様に，updateNAのための適切なupdateが存在する．StaticQueryの実行関数は型パラメータを用いて呼ばれる必要がある．以下の例では.listがそれにあたる．

<!--The queryNA method for parameterless queries is complemented by query which takes two type parameters, one for the query parameters and one for the result set rows. Similarly, there is a matching update for updateNA. The execution methods of the resulting StaticQuery need to be called with the query parameters, as seen here in the call to .list:-->

```scala
// 価格が$9.00より小さい全てのコーヒーに対し，coffeeのnameとsupplierのnameを取り出す
val q2 = Q.query[Double, (String, String)]("""
  select c.name, s.name
  from coffees c, suppliers s
  where c.price < ? and s.id = c.sup_id
""")
// この場合，結果はListとして読むことが出来る
val l2 = q2.list(9.0)
for (t <- l2) println("  " + t._1 + " supplied by " + t._2)
```

また，パラメータを直接的にクエリへ適用させる事も出来る．これを用いると，パラメータの無いクエリへと変換させることが出来る．これは通常の関数適用と同じように，クエリのパラメータを決めさせる事が出来る．

<!--As an alternative, you can apply the parameters directly to the query, thus reducing it to a parameterless query. This makes the syntax for parameterized queries the same as for normal function application:-->

```scala
val supplierById = Q[Int, Supplier] + "select * from suppliers where id = ?"
println("Supplier #49: " + supplierById(49).first)
```

String Interpolation
---------------------

文字列補完接頭辞（string interpolation prefix）であるsqlやsqluを用いるためには，以下のインポート文を追加する必要がある．

<!--In order to use the string interpolation prefixes sql and sqlu, you need to add one more import statement:-->

```scala
import Q.interpolation
```

再利用可能なクエリを必要としない場合には，interpolationはパラメータが付与されたクエリを生成する，最も簡単で統語的にナイスな手法である．クエリを挿入するどんな変数や式も，バインドした変数を結果を返すクエリ文字列へと変換する事が出来る（クエリへ直接挿入されるリテラル値を取得するのに$の代わりに#$を用いることも出来る）．返り値の型は呼び出しの中で，sql interpolatorによって作られたオブジェクトをStaticQueryへと変換させる.asによって指定される．

<!--As long as you don’t want function-like reusable queries, interpolation is the easiest and syntactically nicest way of building a parameterized query. Any variable or expression injected into a query gets turned into a bind variable in the resulting query string. (You can use #$ instead of $ to get the literal value inserted directly into the query.) The result type is specified in a call to .as which turns the object produced by the sql interpolator into a StaticQuery:-->

```scala
def coffeeByName(name: String) = sql"select * from coffees where name = $name".as[Coffee]
println("Coffee Colombian: " + coffeeByName("Colombian").firstOption)
```
update文を生成するためのよく似た補完（interpolator），sqluというものもある．これはInt値を返す事を強制するため，.asのような関数を必要としない．

<!--There is a similar interpolator sqlu for building update statements. It is hardcoded to return an Int value so it does not need the extra .as call:-->

```scala
def deleteCoffee(name: String) = sqlu"delete from coffees where name = $name".first
val rows = deleteCoffee("Colombian")
println(s"Deleted $rows rows")
```

[1]: http://en.wikipedia.org/wiki/Java_Database_Connectivity
[2]: https://github.com/slick/slick-examples/blob/1.0.0/src/main/scala/com/typesafe/slick/examples/jdbc/PlainSQL.scala
[3]: http://slick.typesafe.com/doc/1.0.0/lifted-embedding.html
[4]: http://slick.typesafe.com/doc/1.0.0/direct-embedding.html
[5]: http://slick.typesafe.com/doc/1.0.0/gettingstarted.html#gettingstarted-dbconnection

Slick 1.0.0 documentation - 05 Direct Embedding
<!--Direct Embedding — Slick 1.0.0 documentation-->

[Permalink to Direct Embedding — Slick 1.0.0 documentation](http://slick.typesafe.com/doc/1.0.0/direct-embedding.html)

Direct Embedding
=================

direct embeddingは新しい，しかしまだ不完全で実験的なクエリAPIである．現在実験中．開発中の段階であるため，リリースに応じて非推奨な期間など無しに変更される事がある．安全に利用する事の出来る，安定したlifted embeddingクエリAPIに取って代わるような予定は無く，direct embeddingは共存させていく．lifted embeddingと違って，direct enbeddingは実装のための暗黙的な変換やオーバーロードするオペレータの代わりにマクロを用いて操作を行う．ユーザのために，コード内における違いは少なくしているが，direct enbeddingを用いるクエリは普遍的なScalaの型を用いて機能している．これは表示されるエラーメッセージの理解性を上げるためでもある．

<!--The direct embedding is a new, still incomplete, experimental Query API under development. It may change without deprecation period in any release during its experimental status. There is no plan to replace the stable lifted embedding Query API, which you can safely bet on for production use. The direct embedding co-exists. Unlike the lifted embedding, the direct embedding uses macros instead of operator overloading and implicit conversions for its implementation. For a user the difference in the code is small, but queries using the direct embedding work with ordinary Scala types, which can make error messages easier to understand.-->

以下の説明は[*lifted embedding*][1]の説明に類似した例である．

<!--The following descriptions are anolog to the description of the [*lifted embedding*][1].-->

Dependencies
-------------

direct embeddingは型検査のために実行時にScalaコンパイラにアクセスする必要がある．Slickは必要性に駆られない限り，アプリケーションに対し，依存性を避けるためにScalaコンパイラへの依存性を任意としている．そのため，direct embeddingを用いる際にはプロジェクトの **build.sbt** に対し明示的にその依存性を記述しなくてはならない．

<!--The direct embedding requires access to the Scala compiler at runtime for typechecking. Slick only declares an *optional* dependency on scala-compiler in order to avoid bringing it (along with all transitive dependencies) into your application if you don’t need it. You must add it explicitly to your own project’s build.sbt file if you want to use the direct embedding:-->

```scala
libraryDependencies <+= (scalaVersion)("org.scala-lang" % "scala-compiler" % _)
```

Imports
------------

```scala
import scala.slick.driver.H2Driver
import H2Driver.simple.Database
import Database.{threadLocalSession => session}
import scala.slick.direct._
import scala.slick.direct.AnnotationMapper._
```

Row class and schema
--------------------

スキーマは現在でえは行を保持しているケースクラスに対してアノテーションを付与する事で記述する事が出来る．今後，より柔軟にスキーマの情報を拡張出来るような機能を提供する予定だ．

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
--------------

Queryableはテーブルデータに対しクエリの演算を行うためのものであり，注釈付けられた型引数を取る．

<!--Queryable takes an annotated case class as its type argument to formulate queries agains the corresponding table.-->

\_.priceはここではInt型である．潜在的な，マクロベースの実装においてはmapやfilterに与えられた引数はJVM上で実行されないが，その代わりにデータベースクエリへと変換される事を覚えておいて欲しい．

<!--_.price is of type Int here. The underlying, macro-based implementation takes care of that the shown arguments to map and filter are not executed on the JVM but translated to database queries instead.-->

```scala
// query database using direct embedding
val q1 = Queryable[Coffee]
val q2 = q1.filter( _.price > 3.0 ).map( _ .name )
```

Execution
----------

クエリを実行するためには，選択したデータベースのドライバーを用いるSlickBackendインスタンスを作成する必要がある．

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

ImplicitQueryableを用いると，queryableはバックエンドとセッションに束縛される．クエリはその上で以下のような方法で簡単に実行する事が出来る．

<!--Using ImplicitQueryable, a queryable can be bound to a backend and session. The query can be further adapted and easily executed this way.-->

```scala
//
val iq1 = ImplicitQueryable( q1, backend, session )
val iq2 = iq1.filter( c => c.price > 3.0 )
println( iq2.toSeq ) //  <- triggers execution 
println( iq2.length ) // <- triggers execution
```

Features
----------

direct embeddingは現在， **String**, **Int**, **Double** といった値にたいしマッピングされるデータベースカラムのみサポートしている．

<!--The direct embedding currently only supports database columns, which can be mapped to either **String** , **Int** , **Double** .-->

QueryableとImplicitQueryableは現在，次のようなメソッドを用意している．

<!--Queryable and ImplicitQueryable currently support the following methods:-->

**map, flatMap, filter, length**

これらのメソッドはimmutableな演算を行うが，関数呼び出しによる変化を包含した新しいQuaryableを返す．

<!--The methods are all immutable meaning they leave the left-hand-side Queryable unmodified, but return a new Queryable incorporating the changes by the method call.-->

上記の関数におけるシンタックスとして，以下の様なオペレータを利用する事が出来る．

<!--Within the expressions passed to the above methods, the following operators may be used:-->

**Any: ==**

**Int, Double: + < >**

**String: +**

**Boolean: || &&**

他に定義された独自のオペレータについても，型検査がマッチしていれば利用する事が出来る．しかし現時点では，それらのオペレータは実行時に失敗するクエリを生成するようなSQLへ変換する事が出来ない．（例: **(coffees.map( c => c.ma,e.repr ))**）将来的には，コンパイル中にそのようなものもキャッチするような方法を検討している．

<!--Other operators may type check and compile ok, if they are defined for the corresponding types. They can however currently not be translated to SQL, which makes the query fail at runtime, for example: **(coffees.map( c => c.name.repr ))** . We are evaluating ways to catch those cases at compile time in the future-->

クエリは行を補完するようなオブジェクトを保持する，任意にネストされたタプルのシーケンスを結果として返す．

<!--Queries may result in sequences of arbitrarily nested tuples, which may also contain objects representing complete rows. E.g.-->

```scala
q1.map( c => (c.name, (c, c.price)) )
```

direct embeddingは現在データの挿入といった機能を持っていない．その代わりに[*lifted embedding*][2]や[*plain SQL queries*][3]などを用いる事ができる．

<!--The direct embedding currently does not feature insertion of data. Instead you can use the [*lifted embedding*][2] or [*plain SQL queries*][3].-->

 [1]: http://slick.typesafe.com/gettingstarted.html
 [2]: http://slick.typesafe.com/lifted-embedding.html
 [3]: http://slick.typesafe.com/sql.html  

Slick 1.0.0 documentation - 06 Slick TestKit
<!--Slick TestKit — Slick 1.0.0 documentation-->

["Permalink to Slick TestKit — Slick 1.0.0 documentation](http://slick.typesafe.com/doc/1.0.0/testkit.html)

Slick TestKit
===============

Slickに対し，独自のデータベースドライバーを記述する際には，きちんと動作するのか，何が現時点で実装されていないのかなどを確認するために基本となるユニットテスト（もしくは加えて他の独自のカスタマイズしたテスト）を実行して欲しい．このためにSlickユニットテストとしてのSlick Test Kitプロジェクトを別に用意している．

<!--When you write your own database driver for Slick, you need a way to run all the standard unit tests on it (in addition to any custom tests you may want to add) to ensure that it works correctly and does not claim to support any capabilities which are not actually implemented. For this purpose the Slick unit tests have been factored out into a separate Slick TestKit project.-->

これを用いるためには，Slickの基本的なPostgreSQLドライバーと，それをビルドするために必要なものを全て含んだ[Slick TestKit Example][1]をクローンして，それをテストして欲しい．

<!--To get started, you can clone the [Slick TestKit Example][1] project which contains a (slightly outdated) version of Slick’s standard PostgreSQL driver and all the infrastructure required to build and test it.-->

Scaffolding
--------------

build.sbtは以下のように記述する．一般的な名前とバージョン設定と区別して，SlickとTestKit，junit-interface，Logback，PostgreSQL JDBC Driverへの依存性を追加する．そしてテストを行うためのオプションをいくつか記述する必要がある．

<!--Its build.sbt file is straight-forward. Apart from the usual name and version settings, it adds the dependencies for Slick, the TestKit, junit-interface, Logback and the PostgreSQL JDBC driver, and it sets some options for the test runs:-->

```scala
libraryDependencies ++= Seq(
  "com.typesafe.slick" %% "slick" % "1.0.0",
  "com.typesafe.slick" %% "slick-testkit" % "1.0.0" % "test",
  "com.novocode" % "junit-interface" % "0.10-M1" % "test",
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

src/test/resources/logback-test.xmlに，Slickのlogbackについての設定のコピーがある．しかし，もし異なるものを用いたい場合には，loggingフレームワークを取り替える事が出来る．

<!--There is a copy of Slick’s logback configuration in src/test/resources/logback-test.xml but you can swap out the logging framework if you prefer a different one.-->

Driver
-------

実際のドライバーの実装はsrc/main/scalaの中にある．

<!--The actual driver implementation can be found under src/main/scala.-->

Test Harness
------------

TestKitテストを実行するためには，DriberTestを継承したクラスを作成する必要がある．加えて，TestKitに対してどのようにtestデータベースへ接続するのか，テーブルのリストをどのように取得するのか，テスト間におけるクリーンをどのようにして行うのかなどといった事を伝えるTestDBの実装が必要になる．

<!--In order to run the TestKit tests, you need to add a class that extends DriverTest, plus an implementation of TestDB which tells the TestKit how to connect to a test database, get a list of tables, clean up between tests, etc.-->

PostgreSQLのテーストハーネス（src/test/scala/scala/slick/driver/test/MyPostgreTestの中にある）の場合は，大抵のデフォルトとなる実装はボックスの外で利用される．

<!--In the case of the PostgreSQL test harness (in **src/test/scala/scala/slick/driver/test/MyPostgresTest.scala**) most of the default implementations can be used out of the box:-->

```scala
@RunWith(classOf[Testkit])
class MyPostgresTest extends DriverTest(MyPostgresTest.tdb)
...
object MyPostgresTest {
  def tdb(cname: String) = new ExternalTestDB("mypostgres", MyPostgresDriver) {
    override def getLocalTables(implicit session: Session) = {
      val tables = ResultSetInvoker[(String,String,String, String)](_.conn.getMetaData().getTables("", "public", null, null))
      tables.list.filter(_._4.toUpperCase == "TABLE").map(_._3).sorted
    }
    override def getLocalSequences(implicit session: Session) = {
      val tables = ResultSetInvoker[(String,String,String, String)](_.conn.getMetaData().getTables("", "public", null, null))
      tables.list.filter(_._4.toUpperCase == "SEQUENCE").map(_._3).sorted
    }
    override lazy val capabilities = driver.capabilities + TestDB.plainSql
  }
}
```    

Database Configuration
-----------------------

PostgreSQLのテストハーネスは **ExternalTestDB** に基づいている一方， **test-dbs/databases.properties** において設定が行われてなくてはならない．

<!--Since the PostgreSQL test harness is based on **ExternalTestDB**, it needs to be configured in **test-dbs/databases.properties**:-->

PostgreSQL quick setup:  
- Install PostgreSQL server with default options  
- Change password in mypostgres.password  
- Set mypostgres.enabled = true  

```scala
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

**sbt test** を実行すると， **MyPostgresTest** を探索し，TestKitのJUnit runnerを用いて実行される．これはテストハーネスを通してセットアップされたデータベースを用いており，ドライバーを用いて適応可能な全てのテストが実行される事になる．

<!--Running **sbt test** discovers **MyPostgresTest** and runs it with TestKit’s JUnit runner. This in turn causes the database to be set up through the test harness and all tests which are applicable for the driver (as determined by the **capabilities** setting in the test harness) to be run.-->

 [1]: https://github.com/slick/slick-testkit-example/tree/1.0.0  

Slick 1.0.0 documentation - 07 Slick Extensions
<!--Slick Extensions — Slick 1.0.0 documentation-->

[Permalink to Slick Extensions — Slick 1.0.0 documentation](http://slick.typesafe.com/doc/1.0.0/extensions.html)

Slick Extensions
=================

OracleのためのSlickドライバー（ **com.typesafe.slick.driver.oracle.OracleDriver** ）とDB2（ **com.typesafe.slick.driver.db2.DB2Driver** ）は， Typesafe社によって商用サポートされたパッケージである，*slick-extensions* において利用する事が出来る．[Typesafe Subscription Agreement][1] (PDF)の諸条件の元，利用可能である．


<!--Slick drivers for Oracle (**com.typesafe.slick.driver.oracle.OracleDriver**) and DB2 (**com.typesafe.slick.driver.db2.DB2Driver**) are available in *slick-extensions*, a closed-source package package with commercial support provided by Typesafe, Inc. It is made available under the terms and conditions of the [Typesafe Subscription Agreement][1] (PDF).-->

もし[sbt][2]を用いているのならば， Typesafeのリポジトリを用いるために次のように記述すれば良い．

<!--If you are using [sbt][2], you can add *slick-extensions* and the Typesafe repository (which contains the required artifacts) to your build definition like this:-->

```scala
// Use the right Slick version here:
libraryDependencies += "com.typesafe.slick" %% "slick-extensions" % "1.0.0"
resolvers += "Typesafe Releases" at "http://repo.typesafe.com/typesafe/maven-releases/"
```

 [1]: http://typesafe.com/public/legal/TypesafeSubscriptionAgreement-v1.pdf
 [2]: http://www.scala-sbt.org/  
