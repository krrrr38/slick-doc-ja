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

nullを許容するカラムは`T`がサポートされたプリミティブ型である際に、`Option[T]`を用いて表せば良い。ただし、このOptionに対する全ての操作は、ScalaのOption操作と異なり、データベースのnullプロパゲーションセマンティクスを用いてしまう事に注意して欲しい。特に、`None === None`という式は`None`になる。これはSLickのメジャーリリースで将来的に変更される挙動となっている。

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
