Slick 1.0.0 documentation - 03 Lifted Embedding
<!--Lifted Embedding — Slick 1.0.0 documentation-->

[Permalink to Lifted Embedding — Slick 1.0.0 documentation](http://slick.typesafe.com/doc/1.0.0/lifted-embedding.html)

The *lifted embedding* is the standard API for type-safe queries and updates in Slick. Please see [*Getting Started*][1] for an introduction. This chapter describes the available features in more detail.

The name *Lifted Embedding* refers to the fact that you are not working with standard Scala types (as in the [*direct embedding*][2]) but with types that are *lifted* into a the scala.slick.lifted.Rep type constructor. This becomes clear when you compare the types of a simple Scala collections example

```scala
    case class Coffee(name: String, price: Double)
    val l: List[Coffee] = //...
    val l2 = l.filter(_.price > 8.0).map(_.name)
    //                  ^       ^          ^
    //                  Double  Double     String
```

... with the types of similar code using the lifted embedding:

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

All plain types are lifted into Rep. The same is true for the record type Coffees which is a subtype of Rep[(String, Int, Double, Int, Int)]. Even the literal 8.0 is automatically lifted to a Rep[Double] by an implicit conversion because that is what the > operator on Rep[Double] expects for the right-hand side.

## Tables

In order to use the lifted embedding, you need to define Table objects for your database tables:

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
    

Note that Slick clones your table objects under the covers, so you should not add any extra state to them (extra methods are fine though). Also make sure that an actual object for a table is not defined in a *static* location (i.e. at the top level or nested only inside other objects) because this can cause problems in certain situations due to an overeager optimization performed by scalac. Using a val for your table (with an anonymous structural type or a separate class definition) is fine everywhere.

All columns are defined through the column method. Note that they need to be defined with def and not val due to the cloning. Each column has a Scala type and a column name for the database (usually in upper-case). The following primitive types are supported out of the box (with certain limitations imposed by the individual database drivers):

*   *Numeric types*: Byte, Short, Int, Long, BigDecimal, Float, Double
*   *LOB types*: java.sql.Blob, java.sql.Clob, Array[Byte]
*   *Date types*: java.sql.Date, java.sql.Time, java.sql.Timestamp
*   Boolean
*   String
*   Unit
*   java.util.UUID

Nullable columns are represented by Option[T] where T is one of the supported primitive types. Note that all operations on Option values are currently using the database’s null propagation semantics which may differ from Scala’s Option semantics. In particular, None === None evaluates to false. This behaviour may change in a future major release of Slick.

After the column name, you can add optional column options to a column definition. The applicable options are available through the table’s O object. The following ones are defined for BasicProfile:

**NotNull**, **Nullable**

Explicitly mark the column a nullable or non-nullable when creating the DDL statements for the table. Nullability is otherwise determined from the type (Option or non-Option).

**PrimaryKey**

Mark the column as a (non-compound) primary key when creating the DDL statements.

**Default\[T\](defaultValue: T)**

Specify a default value for inserting data the table without this column. This information is only used for creating DDL statements so that the database can fill in the missing information.

**DBType(dbType: String)**

Use a non-standard database-specific type for the DDL statements (e.g. DBType("VARCHAR(20)") for a String column).

**AutoInc**

Mark the column as an auto-incrementing key when creating the DDL statements. Unlike the other column options, this one also has a meaning outside of DDL creation: Many databases do not allow non-AutoInc columns to be returned when inserting data (often silently ignoring other columns), so Slick will check if the return column is properly marked as AutoInc where needed.

Every table requires a * method contatining a default projection. This describes what you get back when you return rows (in the form of a table object) from a query. Slick’s * projection does not have to match the one in the database. You can add new columns (e.g. with computed values) or omit some columns as you like. The non-lifted type corresponding to the * projection is given as a type parameter to Table. For simple, non-mapped tables, this will be a single column type or a tuple of column types.

## Mapped Tables

It is possible to define a mapped table that uses a custom type for its * projection by adding a bi-directional mapping with the  operator:

```scala
    case class User(id: Option[Int], first: String, last: String)
    
    object Users extends Table[User]("users") {
      def id = column[Int]("id", O.PrimaryKey, O.AutoInc)
      def first = column[String]("first")
      def last = column[String]("last")
      def * = id.? ~ first ~ last  (User, User.unapply _)
    }
```

It is optimized for case classes (with a simple apply method and an unapply method that wraps its result in an Option) but there is also an overload that operates directly on the mapped types.

## Constraints

A foreign key constraint can be defined with a table’s foreignKey method. It takes a name for the constraint, the local column (or projection, so you can define compound foreign keys), the linked table, and a function from that table to the corresponding column(s). When creating the DDL statements for the table, the foreign key definition is added to it.

```scala
    object Suppliers extends Table[(Int, String, String, String, String, String)]("SUPPLIERS") {
      def id = column[Int]("SUP_ID", O.PrimaryKey)
      //...
    }

    object Coffees extends Table[(String, Int, Double, Int, Int)]("COFFEES") {
      def supID = column[Int]("SUP_ID")
      //...
      def supplier = foreignKey("SUP_FK", supID, Suppliers)(_.id)
    }
```    

Independent of the actual constraint defined in the database, such a foreign key can be used to navigate to the linked data with a *join*. For this purpose, it behaves the same as a manually defined utility method for finding the joined data:

```scala
    def supplier = foreignKey("SUP_FK", supID, Suppliers)(_.id)
    def supplier2 = Suppliers.where(_.id === supID)
```

A primary key constraint can be defined in a similar fashion by adding a method that calls primaryKey. This is useful for defining compound primary keys (which cannot be done with the O.PrimaryKey column option):

```scala
    object A extends Table[(Int, Int)]("a") {
      def k1 = column[Int]("k1")
      def k2 = column[Int]("k2")
      def * = k1 ~ k2
      def pk = primaryKey("pk_a", (k1, k2))
    }
```

Other indexes are defined in a similar way with the index method. They are non-unique by default unless you set the unique parameter:

```scala
    object A extends Table[(Int, Int)]("a") {
      def k1 = column[Int]("k1")
      def k2 = column[Int]("k2")
      def * = k1 ~ k2
      def idx = index("idx_a", (k1, k2), unique = true)
    }
```

All constraints are discovered reflectively by searching for methods with the appropriate return types which are defined in the table. This behavior can be customized by overriding the tableConstraints method.

## Data Definition Language

DDL statements for a table can be created with its ddl method. Multiple DDL objects can be concatenated with ++ to get a compound DDL object which can create and drop all entities in the correct order, even in the presence of cyclic dependencies between tables. The statements are executed with the create and drop methods:

```scala
    val ddl = Coffees.ddl ++ Suppliers.ddl
    db withSession {
      ddl.create
      //...
      ddl.drop
    }
```

You can use the createStatements and dropStatements methods to get the SQL code:

```scala
    ddl.createStatements.foreach(println)
    ddl.dropStatements.foreach(println)
``` 

## Expressions

Primitive (non-compound, non-collection) values are representend by type Column[T] (a sub-type of Rep[T]) where a TypeMapper[T] must exist. Only some special methods for internal use and those that deal with conversions between nullable and non-nullable columns are defined directly in the Column class.

The operators and other methods which are commonly used in the lifted embedding are added through implicit conversions defined in ExtensionMethodConversions. The actual methods can be found in the classes AnyExtensionMethods, ColumnExtensionMethods, NumericColumnExtensionMethods, BooleanColumnExtensionMethods and StringColumnExtensionMethods.

Collection values are represented by the Query class (a Rep[Seq[T]]) which contains many standard collection methods like flatMap, filter, take and groupBy. Due to the two different component types of a Query (lifted and plain), the signatures for these methods are very complex but the semantics are essentially the same as for Scala collections.

Additional methods for queries of non-compound values are added via an implicit conversion to SingleColumnQueryExtensionMethods.

## Sorting and Filtering

There are various methods with sorting/filtering semantics (i.e. they take a Query and return a new Query of the same type), for example:

```scala
    val q = Query(Coffees)
    val q1 = q.filter(_.supID === 101)
    val q2 = q.drop(10).take(5)
    val q3 = q.sortBy(_.name.desc.nullsFirst)
``` 

## Joining and Zipping

Joins are used to combine two different tables or queries into a single query.

There are two different ways of writing joins: *Explicit* joins are performed by calling a method that joins two queries into a single query of a tuple of the individual results. *Implicit* joins arise from a specific shape of a query without calling a special method.

An *implicit cross-join* is created with a flatMap operation on a Query (i.e. by introducing more than one generator in a for-comprehension):

```scala
val implicitCrossJoin = for {
  c <- Coffees
  s <- Suppliers
} yield (c.name, s.name)
```

If you add a filter expression, it becomes an implicit inner join:

```scala
val implicitInnerJoin = for {
  c <- Coffees
  s <- Suppliers if c.supID === s.id
} yield (c.name, s.name)
```

The semantics of these implicit joins are the same as when you are using flatMap on Scala collections.

Explicit joins are created by calling one of the available join methods:

```scala
val explicitCrossJoin = for {
  (c, s) <- Coffees innerJoin Suppliers
} yield (c.name, s.name)

val explicitInnerJoin = for {
  (c, s) <- Coffees innerJoin Suppliers on (_.supID === _.id)
} yield (c.name, s.name)

val explicitLeftOuterJoin = for {
  (c, s) <- Coffees leftJoin Suppliers on (_.supID === _.id)
} yield (c.name, s.name.?)

val explicitRightOuterJoin = for {
  (c, s) <- Coffees rightJoin Suppliers on (_.supID === _.id)
} yield (c.name.?, s.name)

val explicitFullOuterJoin = for {
  (c, s) <- Coffees outerJoin Suppliers on (_.supID === _.id)
} yield (c.name.?, s.name.?)
```

The explicit versions of the cross join and inner join will result in the same SQL code being generated as for the implicit versions (usually an implicit join in SQL). Note the use of .? in the outer joins. Since these joins can introduce additional NULL values (on the right-hand side for a left outer join, on the left-hand sides for a right outer join, and on both sides for a full outer join), you have to make sure to retrieve Option values from them.

In addition to the usual join operators supported by relational databases (which are based off a cross join or outer join), Slick also has zip joins which create a pairwise join of two queries. The semantics are again the same as for Scala collections, using the zip and zipWith methods:

```scala
val zipJoinQuery = for {
  (c, s) <- Coffees zip Suppliers
} yield (c.name, s.name)

val zipWithJoin = for {
  res <- Coffees.zipWith(Suppliers, (c: Coffees.type, s: Suppliers.type) => (c.name, s.name))
} yield res
```

A particular kind of zip join is provided by zipWithIndex. It zips a query result with an infinite sequence starting at 0. Such a sequence cannot be represented by an SQL database and Slick does not currently support it, either (but this is expected to change in the future). The resulting zipped query, however, can be represented in SQL with the use of a row number function, so zipWithIndex is supported as a primitive operator:

```scala
val zipWithIndexJoin = for {
  (c, idx) <- Coffees.zipWithIndex
} yield (c.name, idx)
```

## Unions
Two queries can be concatenated with the union and unionAll operators if they have compatible types:

```scala
val q1 = Query(Coffees).filter(_.price < 8.0)
val q2 = Query(Coffees).filter(_.price > 9.0)
val unionQuery = q1 union q2
val unionAllQuery = q1 unionAll q2
```

Unlike union which filters out duplicate values, unionAll simply concatenates the queries, which is usually more efficient.

## Aggregation
The simplest form of aggregation consists of computing a primitive value from a Query that returns a single column, usually with a numeric type, e.g.:

```scala
val q = Coffees.map(_.price)
val q1 = q.min
val q2 = q.max
val q3 = q.sum
val q4 = q.avg
```

Some aggregation functions are defined for arbitrary queries:

```scala
val q = Query(Coffees)
val q1 = q.length
val q2 = q.exists
```

Grouping is done with the groupBy method. It has the same semantics as for Scala collections:

```scala
val q = (for {
  c <- Coffees
  s <- c.supplier
} yield (c, s)).groupBy(_._1.supID)

val q2 = q.map { case (supID, css) =>
  (supID, css.length, css.map(_._1.price).avg)
}
```

Note that the intermediate query q contains nested values of type Query. These would turn into nested collections when executing the query, which is not supported at the moment. Therefore it is necessary to flatten the nested queries by aggregating their values (or individual columns) as done in q2.

## Querying
Queries are executed using methods defined in the [Invoker][3] trait (or [UnitInvoker][4] for the parameterless versions). There is an implicit conversion from Query, so you can execute any Query directly. The most common usage scenario is reading a complete result set into a strict collection with a specialized method such as list or the generic method to which can build any kind of collection:

```scala
val l = q.list
val v = q.to[Vector]
val invoker = q.invoker
val statement = q.selectStatement
```

This snippet also shows how you can get a reference to the invoker without having to call the implicit conversion method manually.

All methods that execute a query take an implicit Session value. Of course, you can also pass a session explicitly if you prefer:

```scala
val l = q.list(session)
```

If you only want a single result value, you can use first or firstOption. The methods foreach, foldLeft and elements can be used to iterate over the result set without first copying all data into a Scala collection.

## Deleting
Deleting works very similarly to querying. You write a query which selects the rows to delete and then call the delete method on it. There is again an implicit conversion from Query to the special [DeleteInvoker][5] which provides the delete method and a self-reference deleteInvoker:

```scala
val affectedRowsCount = q.delete
val invoker = q.deleteInvoker
val statement = q.deleteStatement
```

A query for deleting must only select from a single table. Any projection is ignored (it always deletes full rows).

## Inserting
Inserts are done based on a projection of columns from a single table. When you use the table directly, the insert is performed against its * projection. Omitting some of a table’s columns when inserting causes the database to use the default values specified in the table definition, or a type-specific default in case no explicit default was given. All methods for inserting are defined in [InsertInvoker][6] and [FullInsertInvoker][7].

```scala
Coffees.insert("Colombian", 101, 7.99, 0, 0)

Coffees.insertAll(
  ("French_Roast", 49, 8.99, 0, 0),
  ("Espresso",    150, 9.99, 0, 0)
)

// "sales" and "total" will use the default value 0:
(Coffees.name ~ Coffees.supID ~ Coffees.price).insert("Colombian_Decaf", 101, 8.99)

val statement = Coffees.insertStatement
val invoker = Coffees.insertInvoker
```
While some database systems allow inserting proper values into AutoInc columns or inserting None to get a created value, most databases forbid this behaviour, so you have to make sure to omit these columns. Slick does not yet have a feature to do this automatically but it is planned for a future release. For now, you have to use a projection which does not include the AutoInc column, like forInsert in the following example:

```scala
case class User(id: Option[Int], first: String, last: String)

object Users extends Table[User]("users") {
  def id = column[Int]("id", O.PrimaryKey, O.AutoInc)
  def first = column[String]("first")
  def last = column[String]("last")
  def * = id.? ~ first ~ last <> (User, User.unapply _)
  def forInsert = first ~ last <> ({ t => User(None, t._1, t._2)}, { (u: User) => Some((u.first, u.last))})
}

Users.forInsert insert User(None, "Christopher", "Vogt")
```

In these cases you frequently want to get back the auto-generated primary key column. By default, insert gives you a count of the number of affected rows (which will usually be 1) and insertAll gives you an accumulated count in an Option (which can be None if the database system does not provide counts for all rows). This can be changed with the returning method where you specify the columns to be returned (as a single value or tuple from insert and a Seq of such values from insertAll):

```scala
val userId =
  Users.forInsert returning Users.id insert User(None, "Stefan", "Zeiger")
```

Note that many database systems only allow a single column to be returned which must be the table’s auto-incrementing primary key. If you ask for other columns a SlickException is thrown at runtime (unless the database actually supports it).

Instead of inserting data from the client side you can also insert data created by a Query or a scalar expression that is executed in the database server:
```scala

object Users2 extends Table[(Int, String)]("users2") {
  def id = column[Int]("id", O.PrimaryKey)
  def name = column[String]("name")
  def * = id ~ name
}

Users2.ddl.create

Users2 insert (Users.map { u => (u.id, u.first ++ " " ++ u.last) })

Users2 insertExpr (Query(Users).length + 1, "admin")
```

## Updating
Updates are performed by writing a query that selects the data to update and then replacing it with new data. The query must only return raw columns (no computed values) selected from a single table. The relevant methods for updating are defined in [UpdateInvoker][8].

```scala
val q = for { c <- Coffees if c.name === "Espresso" } yield c.price
q.update(10.49)

val statement = q.updateStatement
val invoker = q.updateInvoker
```

There is currently no way to use scalar expressions or transformations of the existing data in the database for updates.

## Query Templates
Query templates are parameterized queries. A template works like a function that takes some parameters and returns a Query for them except that the template is more efficient. When you evaluate a function to create a query the function constructs a new query AST, and when you execute that query it has to be compiled anew by the query compiler every time even if that always results in the same SQL string. A query template on the other hand is limited to a single SQL string (where all parameters are turned into bind variables) by design but the query is built and compiled only once.

You can create a query template by calling flatMap on a [Parameters][9] object. In many cases this enables you to write a single for comprehension for a template.

```scala
val userNameByID = for {
  id <- Parameters[Int]
  u <- Users if u.id is id
} yield u.first

val name = userNameByID(2).first

val userNameByIDRange = for {
  (min, max) <- Parameters[(Int, Int)]
  u <- Users if u.id >= min && u.id < max
} yield u.first

val names = userNameByIDRange(2, 5).list
```

## User-Defined Functions and Types
If your database system supports a scalar function that is not available as a method in Slick you can define it as a [SimpleFunction][10]. There are predefined methods for creating unary, binary and ternary functions with fixed parameter and return types.

```scala
// H2 has a day_of_week() function which extracts the day of week from a timestamp
val dayOfWeek = SimpleFunction.unary[Date, Int]("day_of_week")

// Use the lifted function in a query to group by day of week
val q1 = for {
  (dow, q) <- SalesPerDay.map(s => (dayOfWeek(s.day), s.count)).groupBy(_._1)
} yield (dow, q.map(_._2).sum)
```

If you need more flexibility regarding the types (e.g. for varargs, polymorphic functions, or to support Option and non-Option types in a single function), you can use SimpleFunction.apply to get an untyped instance and write your own wrapper function with the proper type-checking:

```scala
def dayOfWeek2(c: Column[Date]) =
  SimpleFunction("day_of_week")(TypeMapper.IntTypeMapper)(Seq(c))
```

[SimpleBinaryOperator][11] and [SimpleLiteral][12] work in a similar way. For even more flexibility (e.g. function-like expressions with unusual syntax), you can use [SimpleExpression][13].

If you need a custom column type you can implement [TypeMapper][14] and [TypeMapperDelegate][15]. The most common scenario is mapping an application-specific type to an already supported type in the database. This can be done much simpler by using a [MappedTypeMapper][16] which takes care of all the boilerplate:

```scala
// An algebraic data type for booleans
sealed trait Bool
case object True extends Bool
case object False extends Bool

// And a TypeMapper that maps it to Int values 1 and 0
implicit val boolTypeMapper = MappedTypeMapper.base[Bool, Int](
  { b => if(b == True) 1 else 0 },    // map Bool to Int
  { i => if(i == 1) True else False } // map Int to Bool
)
```

// You can now use Bool like any built-in column type (in tables, queries, etc.)
You can also subclass MappedTypeMapper for a bit more flexibility.

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
