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
