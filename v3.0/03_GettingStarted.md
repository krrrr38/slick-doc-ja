Slick 3.0.0 documentation - 03 Getting Started

[Permalink to Getting Started — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/gettingstarted.html)

はじめよう
===============

Slickを試す最も簡単方法は、[Typesafe Activator](http://typesafe.com/activator)を使ってアプリケーションのテンプレートを作成することだ。以下のテンプレートはSlickのチームによって作られたものであり、Slickの新しいバージョンがリリースされる毎に更新されるだろう。

<!-- The easiest way to get started is with a working application in Typesafe Activator\_. The following templates are created by the Slick team, with updated versions being made for new Slick releases: -->

- Slickの基本を学びたいのなら、[Hello Slick template](https://typesafe.com/activator/template/hello-slick-3.0)から始めると良い。これはチュートリアルやこのページにあるコードを拡張したものを含んでいる。
- [Slick Plain SQL Queries template](https://typesafe.com/activator/template/slick-plainsql-3.0)はSlickを用いてどのようにしてクエリを実行させるかを知る事ができる。
- [Slick Multi-DB Patterns template](http://typesafe.com/activator/template/slick-multidb-3.0)は異なるデータベースシステムを用いたSlickのアプリケーションをどのようにして書くのか、また特別なデータベース関数に対し、Slickのクエリをどのようにして取り扱うのかを学ぶ事ができる。
- [Slick TestKit Example template](https://typesafe.com/activator/template/slick-testkit-example-3.0)はあなたが独自に作成したSlickのドライバをテストするSlick TestKitの使い方を教えてくれる。
<!-- -   To learn the basics of Slick, start with the Hello Slick template\_. It contains an extended version of the tutorial and code from this page. -->
<!-- -   The Slick Plain SQL Queries template\_ shows you how to do SQL queries with Slick. -->
<!-- -   The Slick Multi-DB Patterns template\_ shows you how to write Slick applications that can use different database systems and how to use custom database functions in Slick queries. -->
<!-- -   The Slick TestKit Example template\_ shows you how to use Slick TestKit to test your own Slick drivers. -->

これ以外にも、他のSlickのリリースバージョンにも対応した、コミュニティにより作られたSlickのテンプレートが数多く存在する。これらのテンプレートはTypesafeのウェブサイト上の、[all Slick templates](https://typesafe.com/activator/templates#filter:slick)から見つける事ができる。
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

```xml
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
> このチャプターの残り部分は、[Hello Slick template](https://typesafe.com/activator/template/hello-slick-3.0)を基にしている。[Activator](https://typesafe.com/activator)からコードを手元に用意して、編集・実行しながらチュートリアルを読むと良い。

Slickを利用するには、あなたの利用するデータベースに対応したAPIのimport文を以下のように書き加える必要がある。
<!-- To use Slick you first need to import the API for the database you will be using, like: -->

```scala
// H2データベースに接続するためのH2Driver
import slick.driver.H2Driver.api._
import scala.concurrent.ExecutionContext.Implicits.global
```

この例では[H2](http://h2database.com/)データベースを利用しているため、Slickの`H2Driver`をimportしている。ドライバの`api`オブジェクトは[database handling](http://slick.typesafe.com/doc/3.0.0/database.html)のようなSlickの一般的なAPIを含んでいる。
<!-- Since we are using H2\_ as our database system, we need to import features from Slick's `H2Driver`. A driver's `api` object contains all commonly needed imports from the driver and other parts of Slick such as database handling \<database\>. -->

SlickのAPIは、分離されたスレッドプールに置いて、全て非同期でデータベース処理を実行する。`DBIOAction`構成内のあなたのコードや`Future`の値を実行して取得するには、globalな`ExecutionContext`をインポートする必要がある。Slickを[Play](https://playframework.com/)や[Akka](http://akka.io/)を用いた大きなアプリケーションの一部として用いる場合には、そのようなフレームワークが提供しているより良い`ExecutionContext`を利用すべきだ。
<!-- Slick's API is fully asynchronous and runs database call in a separate thread pool. For running user code in composition of `DBIOAction` and `Future` values, we import the global `ExecutionContext`. When using Slick as part of a larger application (e.g. with Play\_ or Akka\_) the framework may provide a better alternative to this default `ExecutionContext`. -->

### Database Configuration

データベースに接続する方法を指定するために、アプリケーションの中で`Database`オブジェクトを作る必要がある。大抵の場合、[Typesafe Config](https://github.com/typesafehub/config)を用いて記述した`application.conf`から、データベースコネクションの設定を行うだろう。`application.conf`は[Play](https://playframework.com/)や[Akka](http://akka.io/)でも設定を記述するために用いられている。
<!-- In the body of the application we create a `Database` object which specifies how to connect to a database. In most cases you will want to configure database connections with Typesafe Config\_ in your `application.conf`, which is also used by Play\_ and Akka\_ for their configuration: -->

```json
h2mem1 = {
  url = "jdbc:h2:mem:test1"
  driver = org.h2.Driver
  connectionPool = disabled
  keepAliveConnection = true
}
```

この例ではコネクションプールは用いないで、keep-alive接続をリクエストするように設定している（インメモリデータベースにコネクションプールは必要無いし、keep-aliveはデータベース利用中に接続を切らないようにするためである）。データベースオブジェクトは以下のように利用される。
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

Slickのクエリを記述する前に、テーブル毎に`Table`と`TableQuery`を用いてデータベーススキーマを書く必要がある。直接手で書いても良いし、[スキーマコードの生成](http://slick.typesafe.com/doc/3.0.0/code-generation.html)を利用して既存のデータベーススキーマから自動生成しても良い。
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
  // は全てのテーブルで * 射影をテーブルの型パラメータに合うように定義する
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
  // joinなどを発行する際に用いられる外部キー
  def supplier = foreignKey("SUP_FK", supID, suppliers)(_.id)
}
val coffees = TableQuery[Coffees]
```

全てのカラムは名前とScalaの型が必要になる。一般的に名前はSQL側では大文字とアンダースコアで、Scala側ではcamelCaseで記述される。SQLの型はScalaの型から自動的に導出される。テーブルオブジェクトにもScalaの名前とSQLの名前とその型が必要になる。テーブルの型引数は、`*`射影の型と合っている必要がある。このような単純な例では、全てのカラムをタプルで表現出来るが、より複雑なマッピングも可能である。
<!-- All columns get a name (usually in camel case for Scala and upper case with underscores for SQL) and a Scala type (from which the SQL type can be derived automatically). The table object also needs a Scala name, SQL name and type. The type argument of the table must match the type of the special `*` projection. In simple cases this is a tuple of all columns but more complex mappings are possible. -->

`coffees`テーブルの`foreignKey`の定義は、`supID`の値が`suppliers`テーブルの`id`として存在している事を表す制約を表現するものである。ここでは`n:1`関係を作成している。1つの`Coffees`の列に対して1つの`Suppliers`の列が対応しているが、複数の`Coffees`の列が同じ`Suppliers`の列を指し示す事もある。この制約はデータベースレベルで強制されるものになる。
<!-- The `foreignKey` definition in the `coffees` table ensures that the `supID` field can only contain values for which a corresponding `id` exists in the `suppliers` table, thus creating an *n to one* relationship: A `Coffees` row points to exactly one `Suppliers` row but any number of coffees can point to the same supplier. This constraint is enforced at the database level. -->

### Populating the Database

インメモリのH2データベースエンジンへのコネクションは、空のデータベースを提供してくれる。クエリを実行する前に、データベーススキーマ（`coffees`と`suppliers`テーブルを含むもの）を作成して、テストデータを挿入してみよう。
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

`create`、`+=`、`++=`といったメソッドは、データベースへの処理の後に一定時間後に結果を生成する`Action`を返却する。複数の`Action`をシーケンスに結合し、他の`Action`を生成するためのコンビネータが、いくつか存在する。最もシンプルな方法は、`Action.seq`であり、これは返り値を破棄しながら複数の`Action`を順に結合するものである。例として、`Action`が`Unit`を返却する場合などに用いる。準備された`Action`は`db.run`により実行され、`Future[Unit]`が生成される。
<!-- The `create`, `+=` and `++=` methods return an `Action` which can be executed on a database at a later time to produce a result. There are several different combinators for combining multiple Actions into sequences, yielding another Action. Here we use the simplest one, `Action.seq`, which can concatenate any number of Actions, discarding the return values (i.e. the resulting Action produces a result of type `Unit`). We then execute the setup Action asynchronously with `db.run`, yielding a `Future[Unit]`. -->

> **Note**
>
> データベースのコネクションとトランザクションはSlickにより自動的に管理される。デフォルトでは、*auto-commit*モードの際にはコネクションは都度開放される。このモードでは、外部キーの影響により、`suppliers`テーブルのデータを`coffees`のデータより先に挿入しなくてはならない。明示的なトランザクションブラケットで内包された処理を実行することもできる（`db.run(setup.transactionally)`）。そのような記述を行う際には、トランザクションがコミットされる際にのみ制約が課せられるため、記述時の順序などを気にする必要はない。

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

出力は同じで、全てのカラムがタブで区切られて結合されたものになる。異なるのは、データベースエンジン内で行われた処理のみで、結果は全く変わらないまま得られる。注意して欲しいのは、ここでは文字列結合にScalaの`+`オペレータは使わずに、`++`を用いている。また、他の型から文字列への自動的な変換は存在しない。ここでは明示的に`asColumnOf`を用いて変換を行っている。
<!-- The output will be the same: For each row of the table, all columns get converted to strings and concatenated into one tab-separated string. The difference is that all of this now happens inside the database engine, and only the resulting concatenated string is shipped to the client. Note that we avoid Scala's `+` operator (which is already heavily overloaded) in favor of `++` (commonly used for sequence concatenation). Also, there is no automatic conversion of other argument types to strings. This has to be done explicitly with the type conversion method `asColumnOf`. -->

[Reactive Streams](http://www.reactive-streams.org/)でも、データベースから値をストリームとして取り出し、全ての結果を得る前に順に出力させるという処理を記述出来る。
<!-- This time we also use Reactive Streams\_ to get a streaming result from the database and print the elements as they come in instead of materializing the whole result set upfront. -->

テーブルの結合と結果のフィルタリング処理は、Scalaのコレクション操作と同様の記述で行える。
<!-- Joining and filtering tables is done the same way as when working with Scala collections: -->

```scala
// 9.0未満のpriceとなるcoffeeから、coffeeの名前とsupplierの名前を、joinを用いて取得する
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

`suppliers if s.id === c.supID`という表現は、`Coffees.supplier`という外部キーを用いて書き換える事ができる。joinの条件を繰り返し書く代わりに、外部キーを直接記述すれば良いのである。
<!-- The generator expression `suppliers if s.id === c.supID` follows the relationship established by the foreign key `Coffees.supplier`. Instead of repeating the join condition here we can use the foreign key directly: -->

```scala
val q3 = for {
  c <- coffees if c.price < 9.0
  s <- c.supplier
} yield (c.name, s.name)
// 以下のSQLと等価
// select c.COF_NAME, s.SUP_NAME from COFFEES c, SUPPLIERS s where c.PRICE < 9.0 and s.SUP_ID = c.SUP_ID
```
