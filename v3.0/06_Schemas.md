Slick 3.0.0 documentation - 06 Schemas

[Permalink to Schemas — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/schemas.html)

スキーマ
=======

この章では、既存のデータベースを持たない新しいアプリケーションを作る際、どのようにしてScalaのコードでデータベーススキーマを記述するのかを説明する。もしデータベーススキーマを既に持っているのなら、[code generator](http://slick.typesafe.com/doc/3.0.0/code-generation.html)を利用することで、手で書く手間は省ける。
<!-- This chapter describes how to work with database schemas in Scala code, in particular how to write them manually, which is useful when you start writing an application without a pre-existing database. If you already have a schema in the database, you can also use the code generator \<code-generation\> to take this work off your hands. -->

Table Rows
----------

型安全なクエリをScalaのAPIを通して利用するには、データベーススキーマに応じた`Table`クラスを定義する必要がある。これは、テーブルの構造を表現するものである。
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

全てのカラムは、`column`メソッドを通して定義される。どのカラムもScalaの型と、データベースで利用されるカラム名を持つ（カラム名は一般的には大文字）。以下のプリミティブな型は、`JdbcProfile`においてJDBCベースなデータベースのためのサポートがなされている（個々のデータベースドライバによっていくつかの制限が存在するが）。
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
> このOptionに対する全ての操作は、ScalaのOption操作と異なり、データベースのnullプロパゲーションセマンティクスを用いることになる点に注意して欲しい。特に、`None === None`という式は`None`になる。これはSlickのメジャーリリースで将来的に変更されるかもしれない。

<!-- **note** Currently all operations on Option values use the database's null propagation semantics which may differ from Scala's Option semantics. In particular, `None === None` evaluates to `None`. This behaviour may change in a future major release of Slick. -->

カラム名の後ろには、`column`の定義につけるオプションを付与する事ができる。適用可能なオプションは、テーブルの`O`オブジェクトを通して利用出来る。以下のオプションが、`JdbcProfile`用に定義されている。
<!-- After the column name, you can add optional column options to a `column` definition. The applicable options are available through the table's `O` object. The following ones are defined for `JdbcProfile`:  -->

- `PrimaryKey`
	- DDLステートメントを作成する際に、このカラムが主キーであることをマークする
<!-- :   Mark the column as a (non-compound) primary key when creating the     DDL statements.  -->

- `Default[T](defaultValue: T)`
	- カラムの値を設定せずにテーブルにデータを挿入する際のデフォルト値を設定する。この情報は、DDLステートメントを作成する時のみに利用される。

<!-- :   Specify a default value for inserting data into the table without     this column. This information is only used for creating DDL     statements so that the database can fill in the missing information. -->

- `DBType(dbType: String)`
	- DDBステートメントのために、データベースの型を明示する際に利用する。例として、`String`型のカラムに対して、`DBType("VARCHAR(20)")`を明示して指定したりする。
<!-- :   Use a non-standard database-specific type for the DDL statements     (e.g. `DBType("VARCHAR(20)")` for a `String` column). -->

- `AutoInc`
	- DDBステートメントを作成する際に、このカラムがauto incrementさせるカラムであることを指定する。他のカラムオプションと異なりこれはDDL作成時以外にも利用される。多くのデータベースがAutoIncなカラム以外から値を返すのを許容していないため、Slickは値を返すカラムが適切にAutoIncなカラムになっているかをチェックしている。

<!-- :   Mark the column as an auto-incrementing key when creating the DDL     statements. Unlike the other column options, this one also has a     meaning outside of DDL creation: Many databases do not allow     non-AutoInc columns to be returned when inserting data (often     silently ignoring other columns), so Slick will check if the return     column is properly marked as AutoInc where needed.  -->

- `NotNull`, `Nullable`
	- テーブルのDDLステートメントを作成する際に、nullを許容するか・しないかを明示して指定する。`Option`かそうでないかでnullを許容するかを指定出来るため、一般的にはこのオプションは用いられない。

<!-- :   Explicitly mark the column as nullable or non-nullable when creating     the DDL statements for the table. Nullability is otherwise     determined from the type (Option or non-Option). There is usually no     reason to specify these options.  -->

全てのテーブルはデフォルトの射影として`*`メソッドを定義している。これは、クエリの結果として列を返す際に、あなたがどんな情報を求めているのかを説明するためのものである。Slickの`*`射影は、データベース内のカラムと一致している必要は無い。何かしらの計算結果を追加したり、いくつかのカラムを省いて使っても良い。`*`射影の結果は、`Table`の型引数と一致する必要があり、これはマッピングされた何かしらのクラスか、カラムが用いられることになるだろう。

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

`Table`クラスに対して、実際のデータベーステーブルを表す`TableQuery`も必要になるだろう。
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

ケースクラスのコンパニオンオブジェクトを手で書いている場合には、Scalaの機能に合うように実装が行われている場合にのみ、`.tupled`は上手く動作する。他にも`(User.apply _).tupled`などを使ったりも出来るだろう。 [SI-3664](https://issues.scala-lang.org/browse/SI-3664)や[SI-4808](https://issues.scala-lang.org/browse/SI-4808)も目を通しておいて欲しい。
<!-- For case classes with hand-written companion objects, `.tupled` only works if you manually extend the correct Scala function type. Alternatively you can use `(User.apply _).tupled`. See [SI-3664](https://issues.scala-lang.org/browse/SI-3664) and [SI-4808](https://issues.scala-lang.org/browse/SI-4808).  -->

Constraints
-----------

外部キーは、Tableの[foreignKey][foreignKey]によって定義される。第一引数には、制約名、関連カラム、関連テーブルの3つを渡す。続く第二引数は、関連テーブルの紐付けるカラムに加えて、`OnUpdate`や`OnDelete`のような[ForeignKeyAction](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.model.ForeignKeyAction\$)に関するものを指定できる。`ForeignKeyAction`のデフォルト値は[NoAction](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.model.ForeignKeyAction\$\$NoAction\$)となっている。テーブルのDDLステートメントが作成された時に、宣言された外部キーが定義される。
<!-- A foreign key constraint can be defined with a Table's foreignKey \<slick.profile.RelationalTableComponent\$Table@foreignKey[P,PU,TT\<:AbstractTable[\_],U](String,P,TableQuery[TT])((TT)⇒P,ForeignKeyAction,ForeignKeyAction)(Shape[\_\<:FlatShapeLevel,TT,U,\_],Shape[\_\<:FlatShapeLevel,P,PU,\_]):ForeignKeyQuery[TT,U]\> method. It first takes a name for the constraint, the referencing column(s) and the referenced table. The second argument list takes a function from the referenced table to its referenced column(s) as well as ForeignKeyAction \<slick.model.ForeignKeyAction\$\> for `onUpdate` and `onDelete`, which are optional and default to NoAction \<slick.model.ForeignKeyAction\$\$NoAction\$\>. When creating the DDL statements for the table, the foreign key definition is added to it.  -->

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

テーブルのDDLステートメントはそのテーブルの`TableQuery`の`schema`メソッドを基に作成される。複数の`DDL`オブジェクトは`++`メソッドにより1つの`DDL`オブジェクトに結合出来る。これはcreate時もdrop時も全ての制約に対し、たとえ循環依存がテーブル間に存在したとしても、正しい挙動をするように実行されるものとなる。`create`や`drop`メソッドはDDLステートメントを実行するActionを生成する。
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

[foreignKey]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.profile.RelationalTableComponent\$Table@foreignKey[P,PU,TT<:AbstractTable[_],U](String,P,TableQuery[TT])((TT)%E2%87%92P,ForeignKeyAction,ForeignKeyAction)(Shape[_<:FlatShapeLevel,TT,U,_],Shape[_<:FlatShapeLevel,P,PU,_]):ForeignKeyQuery[TT,U]
