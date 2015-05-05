Slick 3.0.0 documentation - 13 Upgrade Guides

[Permalink to Upgrade Guides — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/upgrade.html)

アップグレードガイド
==============

Compatibility Policy
--------------------

SlickはScalaの2.10か2.11のバージョンで動作する（Scala 2.9を使ってる人は、Slickの前身である[ScalaQuery](http://scalaquery.org/)を使って欲しい）。
<!-- Slick requires Scala 2.10 or 2.11. (For Scala 2.9 please use ScalaQuery\_, the predecessor of Slick).  -->

Slickのバージョンナンバーはepoch、メジャーバージョン、マイナーバージョン、RCやSNAPSHOTといった修飾子からなる。
<!-- Slick version numbers consist of an epoch, a major and minor version, and possibly a qualifier (for milestone, RC and SNAPSHOT versions).  -->

Slickのリリースバージョン（修飾子のついてないもの）においては、同じepochとメジャーバージョンの付くものに対し、バイナリ互換性が保証されている（2.1.2に対して、2.1.0と互換性があるが、2.0.0とは互換性の保証が無い）。[Slick Extensions](http://slick.typesafe.com/doc/3.0.0/extensions.html)は少なくともSlickの同じマイナーバージョンが必要とされる（e.g. Slick Extension 2.1.2にはSlick 2.1.2を用いて、Slick 2.1.1は用いてはならない）。_slick-codegen_ はコンパイル時に用いられる事を期待しているため、互換性は保持されていない。
<!-- For release versions (i.e. versions without a qualifier), backward binary compatibility is guaranteed between releases with the same epoch and major version (e.g. you could use 2.1.2 as a drop-in relacement for 2.1.0 but not for 2.0.0). Slick Extensions \<extensions\> requires at least the same minor version of Slick (e.g. Slick Extensions 2.1.2 can be used with Slick 2.1.2 but not with Slick 2.1.1). Binary compatibility is not preserved for slick-codegen, which is generally used at compile-time.  -->

ソースコードに対する互換性は保証していないものの、同じメジャーリリースに対しては出来る限り保証しようと試みてはいる。新しいメジャーリリースにアップグレードしようとする際には、いくつかあなた側のソースを変更する必要が出てくるだろう。古い機能については非推奨にし、メジャーリリースのサイクルに対してはそのままのコードが使えるようにはしている。例として、2.1.0で非推奨になった機能は2.2.0で削除される。ただし、全ての変更に対して同じようにならない事もあるので注意して欲しい。
<!-- We do not guarantee source compatibility but we try to preserve it within the same major release. Upgrading to a new major release may require some changes to your sources. We generally deprecate old features and keep them around for a full major release cycle (i.e. features which become deprecated in 2.1.0 will not be removed before 2.2.0) but this is not possible for all kinds of changes.  -->

RC (Release candidates) は出そうと試みているバージョンと互換性が保証されるようになっている。milestonesやsnapshotは、互換性が保証されていない。
<!-- Release candidates have the same compatibility guarantees as the final versions to which they lead. There are *no compatibility guarantees* whatsoever for milestones and snapshots.  -->

Upgrade from 2.1 to 3.0
-----------------------

### Package Structure

Slickはパッケージ名を`scala.slick`から`slick`へと変更された。共通の型や値が含まれていた`scala.slick`のパッケージオブジェクトには、非推奨なエイリアスが残されている。
<!-- Slick has moved from package `scala.slick` to `slick`. A package object in `scala.slick` provides deprecated aliases for many common types and values.  -->

### Database I/O Actions

ドライバから`simple`や`Implicits`をインポートするのは非推奨となり、Slick 3.1で機能が削除される。その代わりに同様の機能を提供する`api`を使って欲しい（ただしデータベース呼び出しをブロッキングしてしまう`Invoker`や`Executor`というAPIは含まれていない）。ここに含まれていた機能は、新しいAPIであるモナディックデータベースI/Oアクションに取って替えられている。このAPIについての詳細は[Database I/O Actions](http://slick.typesafe.com/doc/3.0.0/dbio.html)を見て欲しい。
<!-- The `simple` and `Implicits` imports from drivers are deprecated and will be removed in Slick 3.1. You should use `api` instead, which will give you the same features, except for the old `Invoker` and `Executor` APIs for blocking execution of database calls. These have been replaced by a new monadic database I/O actions API. See Database I/O Actions \<dbio\> for details of the new API.  -->

### Join Operators

以前のouter joinオペレータは`null`を含む場合に、ユーザコード内で複雑にマッピングを行う必要もあったり、正しく処理していなかった。特にネストされたouter joinを用いていたり、マッピングされたエンティティを用いたouter joinを行っていた場合に、正確な処理が行えていなかった。新しいouter joinオペレータでは、left joinやright join、full outer joinの結合時に、`Option`に結果を持ち上げる事で複雑なマッピング等を行う必要がなくなった。ネストされたOptionやSlickでプリミティブ型以外に対するOptionをサポートすることにより、この機能を実現する事ができた。。
<!-- The old outer join operators did not handle `null` values correctly, requiring complicated mappings in user code, especially when using nested outer joins or outer joins over mapped entities. This is no longer necessary with the new outer join operators that lift one (left or right outer join) or both sides (full outer join) of the join into an `Option`. This is made possible by the new nested Options and non-primitive Options support in Slick.  -->

古いjoinに対応するオペレータはまだ利用可能ではあるが、非推奨となった。非推奨APIに対する警告に従い、適宜以下のように変更して欲しい。
<!-- The old operators are deprecated but still available. Deprecation warnings will point you to the right replacement:  -->

-   leftJoin -\> joinLeft
-   rightJoin -\> joinRight
-   outerJoin -\> joinFull
-   innerJoin -\> join

新しいjoinセマンティックにおいては、`join`オペレータに`JoinType`を明示的に渡しても何の意味もなさないし、その方法は非推奨になっている。今現在、`join`はinner joinのためにのみ用いられる。
<!-- Passing an explicit `JoinType` to the generic `join` operator does not make sense anymore with the new join semantics and is therefore deprecated, too. `join` is now used exclusively for inner joins.  -->

### first

昔のInvoker APIでは、`first`や`firstOption`はクエリの結果に対するコレクションの先頭の値を取得するのに使われていた。新しいAPIにおいては、同様のオペレーションは`head`と`headOption`を呼び出す事で提供される。これはScalaのコレクションAPIで用いられているものとの調和を図るためである。
<!-- The old Invoker API used the `first` and `firstOption` methods to get the first element of a collection-valued query. The same operations for streaming Actions in the new API are called `head` and `headOption` respectively, consistent with the names used by the Scala Collections API.  -->

### Column Type

`Column[T]`という型は`Rep[T]`のサブタイプへ包含された。個々のカラムのためにのみ利用可能であったオペレーションには、暗黙的な`TypedType[T]`が要求される。暗黙的な`Shape`を作成する際に、Optionカラムをより柔軟に扱うために、OptionとOptionでないカラムの双方を要求する。つまりこのケースにおいては、`OptionTypedType[T]`か`BaseTypedType[T]`が必要になる。もし双方を抽象化したいのなら、暗黙的パラメータとして要求されている`Shape`を渡し、具象型が分かる前提でそいつが呼び出し側でインスタンス化されるようにしておくと、より便利に扱えるようになる。
<!-- The type `Column[T]` has been subsumed into its supertype `Rep[T]`. For operations which are only available for individual columns, an implicit `TypedType[T]` evidence is required. The more flexible handling of Option columns requires Option and non-Option columns to be treated differently when creating an implicit `Shape`. In this case the evidence needs to be of type `OptionTypedType[T]` or `BaseTypedType[T]`, respectively. If you want to abstract over both, it may be more convenient to pass the required `Shape` as an implicit parameter and let it be instantiated at the call site where the concrete type is known.  -->

`Column[T]`は依然、`Rep[T]`のためのエイリアスとして非推奨ながら利用出来る。暗黙的な値が必要とされることがあるため、全ての場合において利用できるような完璧な後方互換になっているわけではない。
<!-- `Column[T]` is still available as a deprecated alias for `Rep[T]`. Due to the required implicit evidence, it cannot provide complete backwards compatibility in all cases.  -->

### Closing Databases

今や`Database`インスタンスは関連のあるコネクションプールやスレッドプールを持っているため、それらを使い終わった際には適切にスレッドプールなどをシャットダウンするために、`shutdown`や`close`を呼んで欲しい。新しいアクションベースなAPIへ移行する際には、この点に気をつけてほしい。非推奨な同期APIを用いている場合に限り、この処理は厳格には必要無い。
<!-- Since a `Database` instance can now have an associated connection pool and thread pool, it is important to call `shutdown` or `close` when you are done using it, so that these pools can be shut down properly. You should take care to do this when you migrate to the new action-based API. As long as you exclusively use the deprecated synchronous API, it is not strictly necessary.  -->

> **Warning**
>
> 遅延初期化に頼らないで！！Slick 3.1ではcloseする際、常に`Database`オブジェクトが必要になる。さらに、Slick 3.1ではコネクションやスレッドプールが即座に作られるかもしれない。
<!-- **warning** Do not rely on the lazy initialization! Slick 3.1 will require `Database` objects to always be closed and may create connection and thread pool immediately.  -->

### Metadata API and Code Generator

`slick.jdbc.meta`パッケージにあるJDBCメタデータAPIは、InvokerではなくActionを作成する新しいAPIに変更された。このAPIを利用しているコードジェネレータも非同期APIを利用するように完全に書き換えられた。同じ機能とコンセプトはまだサポートされてはいるものの、コードジェネレータのカスタマイズ部分にはいくつか変更を加えなくてはならないだろう。コードジェネレータのテストと[Schema Code Generation](http://slick.typesafe.com/doc/3.0.0/code-generation.html)の例を読んで欲しい。
<!-- The JDBC metadata API in package `slick.jdbc.meta` has been switched to the new API, producing Actions instead of Invokers. The code generator, which uses this API, has been completely rewritten for the asynchronous API. It still supports the same functionality and the same concepts but any customization of the code generator will have to be changed. See the code generator tests and the code-generation chapter for examples.  -->

### Inserting from Queries and Expressions

Slick 2.0から、auto incrementなカラムを無視するような挿入処理が挿入時のデフォルトの挙動となっている。他のクエリや計算された結果を用いて挿入をしたい時には、force-insertセマンティックを用いる事が出来る（auto incrementなカラムに対しても値を挿入したい時など）。新しいDBIO APIは`insert(Query)`を`forceInsertQuery(Query)`に、`insertExpr`を`forceInsertExpr`に変更することで、このような処理を実現している。
<!-- In Slick 2.0, soft inserts (where auto-incrementing columns are ignored) became the default for inserting raw values. Inserting from another query or a computed expression still uses force-insert semantics (i.e. trying to insert even into auto-incrementing columns, whether or not the database supports it). The new DBIO API properly reflects this by renaming `insert(Query)` to `forceInsertQuery(Query)` and `insertExpr` to `forceInsertExpr`.  -->

### Default String Types

JdbcProfile内に制約の無い`String`型のカラムは、デフォルトで`VARCHAR(254)`として扱われていた。既にH2Driverのようないくつかのドライバでは`String`型のカラムに対して、制約のない型が割り当てられるよう変更されている。Slick 3.0では、PostgreSQLにおいては`VARCHAR`が、MySQLにおいては`TEXT`が用いられている。以前は無害なものであったものの、MySQLの`TEXT`は`GLOB`とよく似た型になっており、いくつかの制約がかかる（デフォルト値を持たなかったり、長さの制約を与えないとインデックスが効かなかったり）。明示的に`O.Length(254)`のようなカラムのオプションを用いる事で、以前の挙動に戻す事ができるし、application.confにある`slick.driver.MySQL.defaultStringType`というキーでデフォルト値を変更することも出来る。
<!-- The default type for `String` columns of unconstrained length in JdbcProfile has traditionally been `VARCHAR(254)`. Some drivers (like H2Driver) already changed it into an unconstrained string type. Slick 3.0 now also uses `VARCHAR` on PostgreSQL and `TEXT` on MySQL. The former should be harmless but MySQL's `TEXT` type is similar to `CLOB` and has some limitations (e.g. no default values and no index without a prefix length). You can use an explicit `O.Length(254)` column option to go back to the previous behavior or change the default in the application.conf key `slick.driver.MySQL.defaultStringType`.  -->

### JdbcDriver

`JdbcDriver`オブジェクトは非推奨となった。使用しているデータベースに対応する正しいドライバを用いて欲しい。
<!-- The `JdbcDriver` object has been deprecated. You should always use the correct driver for your database system.  -->

Upgrade from 2.0 to 2.1
-----------------------

### Query type parameters

[Query](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.Query)は以前は2つの型引数を取っていたが、今は3つの型引数を取る。以前の`Query[T,E]`はSlick 2.1における`Query[T,E,Seq]`と等しい。3つ目の型引数は`.run`をクエリに対し実行した際の返り値となるべきコレクション型だ（Sli 2.0では常に`Seq`が返されていた）。将来的にはクエリをScalaのコレクション型の対応するものと同じ挙動を示すように変更する予定だ。例として、`Query[_,_,Set]`は要素のユニーク性を持っていたり、`Query[_,_,List]`には順序があるなど。コレクションの型は`.to[C]`をクエリに対し呼び出すことで`C`へ変更させる事が出来る。
<!-- Query \<slick.lifted.Query\> now takes 3 type parameters instead of two. 2.0's `Query[T,E]` is equivalent to Slick 2.1's `Query[T,E,Seq]`. The third parameter is the collection type to be returned when executing the query using `.run`, which always returned a `Seq` in Slick 2.0. This is the only place where it is used right now. In the future we will work on making queries correspond to the behavior of the corresponding Scala collection types, i.e. `Query[_,_,Set]` having the uniqueness property, `Query[_,_,List]` being order preserving, etc. The collecton type can be changed to `C` by calling `.to[C]` on a query.  -->

Slick 2.1へアップグレードするには、次のいずれかの処理を行う必要がある。1つ目の方法としては、新しいQueryの型を違う名前の _何か_ に置き換えることだ。これはつまり、importを、`import ....simple.{Query=>NewQuery,_}`と記述し、それから`type Query[T,E] = NewQuery[T,E,Seq]`というエイリアスを用意することに対応する。2つ目の方法としては、`Seq`をQueryの第三型引数に追加する事だ。次の正規表現を用いると簡単に変換出来るかもしれない。変換前: `([^a-zA-Z])Query\[([^\]]+), ?([^\]]+)\]`、変換後: `\1Query[\2, \3, Seq]`。
<!-- To upgrade your code to 2.1 you can either rename the new Query type to something else in the import, i.e. `import ....simple.{Query=>NewQuery,_}` and then write a type alias `type Query[T,E] = NewQuery[T,E,Seq]`. Or you can add `Seq` as the third type argument in your code. This regex should work for most places: replace `([^a-zA-Z])Query\[([^\]]+), ?([^\]]+)\]` with `\1Query[\2, \3, Seq]`.  -->

### `.list` and `.first`

これらのメソッドは、Slick 2.0において暗黙的な引数リストの前に空の引数を渡していた。統一性のために、これらの引数は渡さなくて良くなった。`.list()`という呼び出しは`.list`で、`.first()`は`.first`と呼び出して欲しい。
<!-- These methods had an empty argument list before the implicit argument list in 2.0. This has been dropped for uniformity. Calls like `.list()` need to be replaced with `.list` and `.first()` by `.first`.  -->

### `.where`

このメソッドはScalaのコレクションには存在しないため、非推奨となった。代わりに`.filter`を使って欲しい。
<!-- This method has been deprecated in favor of the Scala collections conformant `.filter` method.  -->

### `.isNull` and `.isNotNull`

同様に、これらのメソッドはScalaのスタンダードライブラリには無いため非推奨となった。代わりに`isEmpty`と`isDefined`を仕様して欲しい。今やこれらのメソッドはOptionのカラムにおいてのみ利用されている。Optionで無いカラムに対してこれらのメソッドを使うには、`.?`を用いてOptionなカラムになるようキャストすれば良い（e.g. `someCol.?.isDefined`）。これを行わなければならないのは、カラムに対して誤った型付を行っているためであり、nullになりえてOptionで無いカラムについては、Table定義を修正すべきである。
<!-- These methods have been deprecated in favor of new Scala standard library conformant `isEmpty` and `isDefined` methods. They can now only be used on Option columns. Otherwise you get a type error. A quick workaround for using them on non-Option columns is casting them into Option columns using `.?`, e.g. `someCol.?.isDefined`. The reason that you have to do this points to using a wrong type for your column however, i.e. non-Option for a nullable column and should really be fixed in your Table definition.  -->

### Static Plain SQL Queries

プレースホルダ構文に対するインターフェースに変更が加えられた。Slick 2.0では以下のようにかけていた。
<!-- The interface for using argument placeholders has been changed. Where in 2.0 you could write  -->

```scala
StaticQuery.query[T,…]("select ...").list(someT)
```

これは、Slick 2.1では以下のように記述しなくてはならない。
<!-- you now have to write -->

```scala
StaticQuery.query[T,…]("select ...").apply(someT).list
```

### Slick code generator / Slick model

コードジェネレータはSlick本体の開発を促進するために、異なるアーティファクトへと移動された。以前は`slick.model.codegen`というパッケージ名を利用していたが、今は`slick.codegen`に置かれている。バイナリ互換性は、コードジェネレータがコンパイル毎に利用されることを期待して、保証されていない。sbtプロジェクトでコードジェネレータを利用する際は、以下のdependencyを追加して欲しい。
<!-- The code generator has been moved into a separate artifact in order to evolve it faster than Slick core. it moved from package `slick.model.codegen` to package `slick.codegen`. Binary compatibility will not be guaranteed, as it is supposed to be used before compile time. Add  -->
<!-- to the dependencies of your code generator sbt project. -->

```scala
"com.typesafe.slick" %% "slick-codegen" % "3.0.0"
```

`SourceCodeGenerator#Table#compound`は、複合値の値と型双方に対して整形された異なるコードを生成する、`compoundValue`と`compoundType`という2つのメソッドに分離された。
<!-- Method `SourceCodeGenerator#Table#compound` has been replaced by two methods `compoundValue` and `compoundType` generating potentially differently shaped code for values and types of compound values.  -->

デフォルトとなるデータベースの全てのテーブルのリストを得るためのInvokerを返すSlickドライバの`getTables`というメソッドは、非推奨となった。代わりとなるものは、現時点で存在するメタテーブルをSlickに取り除かせるために、直接テーブル一覧を返す`defaultTables`というメソッドになる。
<!-- Method `getTables` of the Slick drivers, which returns an Invoker for listing all default database tables has been deprecated in favor of new method `defautTables`, which returns the tables directly in order to allow Slick to exclude meta tables at this point.  -->

`slick.jdbc.meta.createModel(tables)`というメソッドはドライバの中へ移動し、`H2Driver.createModel(Some(tables))`のような記述で実行される。
<!-- Method `slick.jdbc.meta.createModel(tables)` has been moved into the drivers and can now be invoked using e.g. `H2Driver.createModel(Some(tables))`  -->

Slickによって生成されたモデルはMySQLに対し、データベースのカラム型、文字列カラムの文字数、文字列のデフォルト値のような様々な情報を含んでいる。コードジェネレータは可搬的な長さのような情報を生成されたコードに埋め込み、可搬的でないデータベースのカラム型のような情報を生成されたコードに埋め込む事はオプショナルな機能とした。もしそのような設定にするのなら、`SlickCodeGenerator#Table#Column#dbType`を`true`にして欲しい。
<!-- The model generated by Slick now contains improved information like the database column type, length of string columns, default values for strings in MySQL. The code generator will embed the portable length into generated code and can optionally embed the non-portable database column type into generated code when overriding `SlickCodeGenerator#Table#Column#dbType` with `true`.  -->

jdbcのメタデータからモデルの生成をカスタマイズするために、どのようにしてコードジェネレータがカスタマイズされるのかという点において、新しい`ModelBuilder`は拡張されている。Slickにおいてモデルを生成したり失われた特徴を組み直す際、これはjdbcドライバ間の違いやバグを上手いことフォローアップしている（dbmsにある特殊な型をサポートするなど）。
<!-- The new `ModelBuilder` can be extended to customize model creation from jdbc meta data, similar to how the code generator can be customized. This allows working around differences and bugs in jdbc drivers, when creating the model or making up for missing features in Slick, e.g supporting specific types of your dbms of choice.  -->

Upgrade from 1.0 to 2.0
-----------------------

Slick2.0はSlick1.0に互換性のない拡張が含まれている。アプリケーションを1.0から2.0へ移行する際には、以下のような変更が必要になるだろう。
<!-- Slick 2.0 contains some improvements which are not source compatible with Slick 1.0. When migrating your application from 1.0 to 2.0, you will likely need to perform changes in the following areas.  -->

### Code Generation

以前は手で書いていたテーブルへのマッピングを、2.0ではデータベーススキーマを用いて自動的に生成出来るようになった。code-generaterは柔軟にカスタマイズすることも出来るため、より最適化されたものに変更する事も出来る。詳細については、[More info on code generation](http://slick.typesafe.com/doc/3.0.0/code-generation.html)を参考にして欲しい。
<!-- Instead of writing your table descriptions or plain SQL mappers by hand, in 2.0 you can now automatically generate them from your database schema. The code-generator is flexible enough to customize it's output to fit exactly what you need. More info on code generation \<code-generation\>.  -->

### Table Descriptions

Slick1.0では、テーブルは`val`や*table object*と呼ばれる`object`によって定義がなされ、射影`*`では`~`オペレータを用いてタプルを表していた。
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

Slick2.0では`Tag`を引数にテーブルクラスの定義を行い、実際のデータベーステーブルを表す`TableQuery`のインスタンスを定義する。射影`*`に対し、基本的なタプルを用いて定義を行うことも出来る。
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
以前に用いていた`~`シンタックスをそのまま使いたい場合には、[TupleMethod._](http://slick.typesafe.com/doc/3.0.0/api/#scala.slick.util.TupleMethods\$)をインポートすれば良い。`TableQuery[T]`を用いると、内部的には`new TableQuery(new T(_))`のような処理が行われ、適切なTableQueryインスタンスが作成される。Slick1.0では共通処理に関して、静的メソッドでテーブルオブジェクトに定義がなされていた。2.0においても以下のようにカスタムされた`TableQuery`オブジェクトを用いて、同様の事が出来る。
<!-- You can import TupleMethods \<slick.util.TupleMethods\$\>.\_ to get support for the old \~ syntax. The simple `TableQuery[T]` syntax is a macro which expands to a proper TableQuery instance that calls the table's constructor (`new TableQuery(new T(_))`). In Slick 1.0 it was common practice to place extra static methods associated with a table into that table's object. You can do the same in 2.0 with a custom `TableQuery` object:  -->

```scala
object suppliers extends TableQuery(new Suppliers(_)) {
  // put extra methods here, e.g.:
  val findByID = this.findBy(_.id)
}
```

`TableQuery`はデータベーステーブルのための`Query`オブジェクトのことである。予期せぬ場所で適用される`Query`への暗黙的な変換はもはや必要無い。Slick 1.0において生身の *table object* を扱っていた場所は、全て *table query* が代わりに用いられることになる。例として、以下に挙げられる挿入(inserting)や、外部キー関連などがある。
<!-- Note that a `TableQuery` is a `Query` for the table. The implicit conversion from a table row object to a `Query` that could be applied in unexpected places is no longer needed or available. All the places where you had to use the raw *table object* in Slick 1.0 have been changed to use the *table query* instead, e.g. inserting (see below) or foreign key references.  -->

<!-- The method for creating simple finders has been renamed from `createFinderBy` to `findBy`. It is defined as an *extension method* for `TableQuery`, so you have to prefix the call with `this.` (see code snippet above).  -->

### Mapped Tables


1.0において双方向マッピングを行っていた`<>`関数はオーバーロードされ、今やケースクラスの`apply`関数を直接渡す事が出来る。
<!-- In 1.0 the `<>` method for bidirectional mappings was overloaded for different arities so you could directly pass a case class's `apply` method to it:  -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
def * = id ~ name ~ street <> (Supplier _, Supplier.unapply)
```

上記のような記述はもはや3.0ではサポートされていない。その理由の1つとして、このようなオーバーロードはエラーメッセージを複雑にしすぎるためである。現在では適切なタプル型を用いて関数を定義する事が出来る。もしケースクラスをマッピングしたいのならば、コンパニオンオブジェクトの`.tupled`を単純に用いれば良いのである。
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

Slick 1.0では`BasicProfile`と`ExtendedProfile`の2つのプロファイルを提供していた。Slick 2.0ではこれら2つのプロファイルを`JdbcProfile`として統合している。今では`RelationalProfile`に挙げられるようなより抽象的なプロファイルを提供している。`RelationalProfile`は`JdbcProfile`の全ての特徴を持っているわけではないが、新しく出来た`HeapDriver`や`DistributedDriber`といった機能を支えている。Slick 1.0からコードを移植する際、`JdbcProfile`へとプロファイルを変更して欲しい。特にSlick 2.0における`BasicProfile`は1.0における`BasicProfil`と非常に異なったものになっているので注意して欲しい。
<!-- Slick 1.0 provided two *profiles*, `BasicProfile` and `ExtendedProfile`. These two have been unified in 2.0 as `JdbcProfile`. Slick now provides more abstract profiles, in particular `RelationalProfile` which does not have all the features of `JdbcProfile` but is supported by the new `HeapDriver` and `DistributedDriver`. When porting code from Slick 1.0, you generally want to switch to `JdbcProfile` when abstracting over drivers. In particular, pay attention to the fact that `BasicProfile` in 2.0 is very different from `BasicProfile` in 1.0.  -->

### Inserting

Slick1.0では挿入時に*table object*の一部を射影していた。
<!-- In Slick 1.0 you used to construct a projection for inserting from the *table object*:  -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
(Suppliers.name ~ Suppliers.street) insert ("foo", "bar")
```

2.0において*table object*は存在していないため、*table query*から射影しなくてはならない。
<!-- Since there is no raw table object any more in 2.0 you have to use a projection from the table query:  -->

```scala
suppliers.map(s => (s.name, s.street)) += ("foo", "bar")
```

`+=`オペレータはScalaコレクションとの互換性のために用いられており、`insert`という古い名前の関数はエイリアスとして依然用いる事が出来る。
<!-- Note the use of the new `+=` operator for API compatibility with Scala collections. The old name `insert` is still available as an alias.  -->

Slick 2.0ではデータを挿入する際自動的にデフォルトで`AutoInc`のついたカラムを除外する。1.0では、そのようなカラムについて手動で除外した射影関数を別に用意しなくてはならなかった。
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

2.0においてこのような冗長な記述は必要無くなる。デフォルトの射影関数を挿入時に用いる事で、自動インクリメントのついた`id`というカラムをSlickが除外してくれる。
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

逆に`AutoInc`のついたカラムに対し値を挿入したいのならば、新しく出来た`forceInsert`や`forceInsertAll`といった関数を用いれば良い。
<!-- If you really want to insert into an `AutoInc` field, you can use the new methods `forceInsert` and `forceInsertAll`.  -->

### Pre-compiled Updates

Slickはselect文において用いられるのと同じ方法で、update文における事前コンパイルもサポートしている。これについては、[Compiled Queries](http://slick.typesafe.com/doc/3.0.0/queries.html#compiled-queries)のセクションを見て欲しい。
<!-- Slick now supports pre-compilation of updates in the same manner like selects, see compiled-queries.  -->

### Database and Session Handling

Slick 1.0では`Database`のファクトリオブジェクトとして標準的なJDBCベースな`Database`と`Session`といった型が`scala.slick.session`パッケージにある。Slick 2.0からはJDBCベースなデータベースに制限せず、このパッケージは(*backend*としても知られる)[DatabaseComponent](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.backend.DatabaseComponent)階層
によって置き換えられている。もし[JdbcProfile](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcProfile)抽象レベルで動かしたいのならば、以前に`scala.slick.session`にあったものをインポートし、常に[JdbcBackend](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.JdbcBackend)を用いれば良い。ただし、`simple._`といったインポートを行うと自動的にスコープ内にこれらの型が持ち込まれてしまうので注意して欲しい。
<!-- In Slick 1.0, the common JDBC-based `Database` and `Session` types, as well as the `Database` factory object, could be found in the package `slick.session`. Since Slick 2.0 is no longer restricted to JDBC-based databases, this package has been replaced by the new slick.backend.DatabaseComponent (a.k.a. *backend*) hierarchy. If you work at the slick.driver.JdbcProfile abstraction level, you will always use a slick.jdbc.JdbcBackend from which you can import the types that were previously found in `slick.session`. Note that importing `simple._` from a driver will automatically bring these types into scope.  -->

### Dynamically and Statically Scoped Sessions

Slick 2.0では依然としてスレッドローカルな動的セッションと静的スコープセッションを提供している。しかしシンタックスが変わっており、静的スコープセッションを用いる際にはより簡潔な記述が推奨される。以前の`threadLocalSession`は`dynamicSession`という名前に変わっており、関連する`withSession`や`withTransaction`といった関数も`withDynSession`と`withDynTransaction`という名前にそれぞれ変わっている。Slick 1.0では以下のようなシンタックスで記述をしていた。
<!-- Slick 2.0 still supports both, thread-local dynamic sessions and statically scoped sessions, but the syntax has changed to make the recommended way of using statically scoped sessions more concise. The old `threadLocalSession` is now called `dynamicSession` and the overloads of the associated session handling methods `withSession` and `withTransaction` have been renamed to `withDynSession` and `withDynTransaction` respectively. If you used this pattern in Slick 1.0:  -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
import scala.slick.session.Database.threadLocalSession
myDB withSession {
  // use the implicit threadLocalSession here
}
```

Slick 2.0で以下のようなシンタックスへ変わる。
<!-- You have to change it for Slick 2.0 to: -->

```scala
import slick.jdbc.JdbcBackend.Database.dynamicSession
myDB withDynSession {
  // use the implicit dynamicSession here
}
```

Slick 1.0では静的スコープセッションにおける明示的な型宣言が必要だった。
<!-- On the other hand, due to the overloaded methods, Slick 1.0 required an explicit type annotation when using the statically scoped session:  -->

```scala
myDB withSession { implicit session: Session =>
  // use the implicit session here
}
```

これは2.0において必要なくなる。
<!-- This is no longer necessary in 2.0: -->

```scala
myDB withSession { implicit session =>
  // use the implicit session here
}
```

また、動的セッションを使うことは確かな情報を取得できるか分からない事から推奨されていない。静的セッションを用いる方がより安全である。
<!-- Again, the recommended practice is NOT to use dynamic sessions. If you are uncertain if you need them the answer is most probably no. Static sessions are safer.  -->

### Mapped Column Types

Slick 1.0の`MappedTypeMapper`は[MappedColumnType](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcTypesComponent@MappedColumnType:JdbcDriver.MappedColumnTypeFactory)へと名前が変わった。[MappedColumnType.base][MappedColumnType.base]を用いるような基本的な操作は[RelationalProfile](http://slick.typesafe.com/doc/3.0.0/api/#scala.slick.profile.RelationalProfile)レベル(高度な利用法をするのならば依然として[JdbcProfile](http://slick.typesafe.com/doc/3.0.0/api/#scala.slick.driver.JdbcProfile)が必要)において現在も利用できる。
<!-- Slick 1.0's `MappedTypeMapper` has been renamed to MappedColumnType \<slick.driver.JdbcTypesComponent@MappedColumnType:JdbcDriver.MappedColumnTypeFactory\>. Its basic form (using MappedColumnType.base \<slick.profile.RelationalTypesComponent\$MappedColumnTypeFactory@base[T,U]((T)⇒U,(U)⇒T)(ClassTag[T],RelationalDriver.BaseColumnType[U]):RelationalDriver.BaseColumnType[T]\>) is now available at the slick.profile.RelationalProfile level (with more advanced uses still requiring slick.driver.JdbcProfile). The idiomatic use in Slick 1.0 was:  -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
case class MyID(value: Int)
implicit val myIDTypeMapper =
  MappedTypeMapper.base[MyID, Int](_.value, new MyID(_))
```

この記述は、以下のように変わる。
<!-- This has changed to: -->

```scala
case class MyID(value: Int)
implicit val myIDColumnType =
  MappedColumnType.base[MyID, Int](_.value, new MyID(_))
```

もしこの例のように単純なラッパー型へマッピングするのなら、[MappedTo](http://slick.typesafe.com/doc/3.0.0/api/#scala.slick.lifted.MappedTo)を用いてもっと簡単に書くことが出来る。
<!-- If you need to map a simple wrapper type (as shown in this example), you can now do that in an easier way by extending slick.lifted.MappedTo:  -->

```scala
case class MyID(value: Int) extends MappedTo[Int]
// No extra implicit required any more
```

[MappedColumnType.base]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.profile.RelationalTypesComponent\$MappedColumnTypeFactory@base[T,U]((T)%E2%87%92U,(U)%E2%87%92T)(ClassTag[T],RelationalDriver.BaseColumnType[U]):RelationalDriver.BaseColumnType[T]
