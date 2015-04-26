Slick 3.0.0 documentation - 12 Coming from SQL to Slick

[Permalink to Coming from SQL to Slick — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/sql-to-slick.html)

Coming from SQL to Slick
========================

<!-- Coming from JDBC/SQL to Slick is pretty straight forward in many ways. Slick can be considered as a drop-in replacement with a nicer API for handling connections, fetching results and using a query language, which is integrated more nicely into Scala than writing queries as Strings. The main obstacle for developers coming from SQL to Slick seems to be the semantic differences of seemingly similar operations between SQL and Scala's collections API which Slick's API imitates. The following sections give a quick overview over the differences. They start with conceptual differences and then list examples of many SQL operators and their Slick equivalents \<sql-to-slick-operators\>. For a more detailed explanations of Slick's API please refer to chapter queries \<queries\> and the equivalent methods in the the Scala collections API \<scala.collection.immutable.Seq\>.  -->

Schema
------

<!-- The later examples use the following database schema -->

![image](http://slick.typesafe.com/doc/3.0.0/_images/from-sql-to-slick.person-address.png)

<!-- mapped to Slick using the following code: -->

```scala
type Person = (Int,String,Int,Int)
class People(tag: Tag) extends Table[Person](tag, "PERSON") {
  def id = column[Int]("ID", O.PrimaryKey, O.AutoInc)
  def name = column[String]("NAME")
  def age = column[Int]("AGE")
  def addressId = column[Int]("ADDRESS_ID")
  def * = (id,name,age,addressId)
  def address = foreignKey("ADDRESS",addressId,addresses)(_.id)
}
lazy val people = TableQuery[People]
...
type Address = (Int,String,String)
class Addresses(tag: Tag) extends Table[Address](tag, "ADDRESS") {
  def id = column[Int]("ID", O.PrimaryKey, O.AutoInc)
  def street = column[String]("STREET")
  def city = column[String]("CITY")
  def * = (id,street,city)
}
lazy val addresses = TableQuery[Addresses]
```

<!-- Tables can alternatively be mapped to case classes. Similar code can be auto-generated \<code-generation\> or hand-written \<schemas\>.  -->

Queries in comparison
---------------------

### JDBC Query

<!-- A JDBC query with error handling could look like this: -->

```scala
import java.sql._
Class.forName("org.h2.Driver")
val conn = DriverManager.getConnection("jdbc:h2:mem:test1")
val people = new scala.collection.mutable.MutableList[(Int,String,Int)]()
try{
  val stmt = conn.createStatement()
  try{
    val rs = stmt.executeQuery("select ID, NAME, AGE from PERSON")
    try{
      while(rs.next()){
        people += ((rs.getInt(1), rs.getString(2), rs.getInt(3)))
      }
    }finally{
      rs.close()
    }
  }finally{
    stmt.close()
  }
}finally{
  conn.close()
}
```

<!-- Slick gives us two choices how to write queries. One is SQL strings just like JDBC. The other are type-safe, composable queries.  -->

### Slick Plain SQL queries

<!-- This is useful if you either want to continue writing queries in SQL or if you need a feature not (yet) supported by Slick otherwise. Executing the same query using Slick Plain SQL, which has built-in error-handling and resource management optimized for asynchronous execution, looks like this:  -->

```scala
import slick.driver.H2Driver.api._
...
val db = Database.forConfig("h2mem1")
...
val action = sql"select ID, NAME, AGE from PERSON".as[(Int,String,Int)]
db.run(action)
```

<!-- `.list` returns a list of results. `.first` a single result. `.foreach` can be used to iterate over the results without ever materializing all results at once.  -->

### Slick type-safe, composable queries

<!-- Slick's key feature are type-safe, composable queries. Slick comes with a Scala-to-SQL compiler, which allows a (purely functional) sub-set of the Scala language to be compiled to SQL queries. Also available are a subset of the standard library and some extensions, e.g. for joins. The familiarity allows Scala developers to instantly write many queries against all supported relational databases with little learning required and without knowing SQL or remembering the particular dialect. Such Slick queries are composable, which means that you can write and re-use fragments and functions to avoid repetitive code like join conditions in a much more practical way than concatenating SQL strings. The fact that such queries are type-safe not only catches many mistakes early at compile time, but also eliminates the risk of SQL injection vulnerabilities.  -->
<!-- The same query written as a type-safe Slick query looks like this: -->

```scala
import slick.driver.H2Driver.api._
...
val db = Database.forConfig("h2mem1")
...
val query = people.map(p => (p.id,p.name,p.age))
db.run(query.result)
```

<!-- `.run` automatically returns a Seq for collection-like queries and a single value for scalar queries. `.list`, `.first` and `.foreach` are also available.  -->

<!-- A key benefit compared to SQL strings is, that you can easily transform the query by calling more methods on it. E.g. `query.filter(_.age > 18)` returns transformed query which further restricts the results. This allows to build libraries of queries, which re-use each other become much more maintainable. You can abstract over join conditions, pagination, filters, etc. -->

<!-- It is important to note that Slick needs the type-information to type-check these queries. This type information closely corresponds to the database schema and is provided to Slick in the form of Table sub classes and TableQuery values shown above.  -->

Main obstacle: Semantic API differences
---------------------------------------

<!-- Some methods of the Scala collections work a bit differently than their SQL counter parts. This seems to be one of the main causes of confusion for people newly coming from SQL to Slick. Especially groupBy\_ seems to be tricky.  -->

<!-- The best approach to write queries using Slick's type-safe api is thinking in terms of Scala collections. What would the code be if you had a Seq of tuples or case classes instead of a Slick TableQuery object. Use that exact code. If needed adapt it with workarounds where a Scala library feature is currently not supported by Slick or if Slick is slightly different. Some operations are more strongly typed in Slick than in Scala for example. Arithmetic operation in different types require explicit casts using `.asColumnOf[T]`. Also Slick uses 3-valued logic for Option inference.  -->

Scala-to-SQL compilation during runtime
---------------------------------------

<!-- Slick runs a Scala-to-SQL compiler to implement its type-safe query feature. The compiler runs at Scala run-time and it does take its time which can even go up to second or longer for complex queries. It can be very useful to run the compiler only once per defined query and upfront, e.g. at app startup instead of each execution over and over. Compiled queries \<compiled-queries\> allow you to cache the generated SQL for re-use.  -->

Limitations
-----------

<!-- When you use Slick extensively you will run into cases, where Slick's type-safe query language does not support a query operator or JDBC feature you may desire to use or produces non-optimal SQL code. There are several ways to deal with that.  -->

### Missing query operators

<!-- Slick is extensible to some degree, which means you can add some kinds of missing operators yourself.  -->

#### Definition in terms of others

<!-- If the operator you desire is expressible using existing Slick operations you can simply write a Scala function or implicit class that implements the operator as a method in terms of existing operators. Here we implement `squared` using multiplication.  -->

```scala
implicit class MyStringColumnExtensions(i: Rep[Int]){
  def squared = i * i
}
...
// usage:
people.map(p => p.age.squared)
```

#### Definition using a database function

<!-- If you need a fundamental operator, which is not supported out-of-the-box you can add it yourself if it operates on scalar values. For example Slick currently does not have a `power` method out of the box. Here we are mapping it to a database function.  -->

```scala
val power = SimpleFunction.binary[Int,Int,Int]("POWER")
...
// usage:
people.map(p => power(p.age,2))
```

<!-- More information can be found in the chapter about Scalar database functions \<scalar-db-functions\>.  -->

<!-- You can however not add operators operating on queries using database functions. The Slick Scala-to-SQL compiler requires knowledge about the structure of the query in order to compile it to the most simple SQL query it can produce. It currently couldn't handle custom query operators in that context. (There are some ideas how this restriction can be somewhat lifted in the future, but it needs more investigation). An example for such operator is a MySQL index hint, which is not supported by Slick's type-safe api and it cannot be added by users. If you require such an operator you have to write your whole query using Plain SQL. If the operator does not change the return type of the query you could alternatively use the workaround described in the following section.  -->

### Non-optimal SQL code

<!-- Slick generates SQL code and tries to make it as simple as possible. The algorithm doing that is not perfect and under continuous improvement. There are cases where the generated queries are more complicated than someone would write them by hand. This can lead to bad performance for certain queries with some optimizers and DBMS. For example, Slick occasionally generates unnecessary sub-queries. In MySQL \<= 5.5 this easily leads to unnecessary table scans or indices not being used. The Slick team is working towards generating code better factored to what the query optimizers can currently optimize, but that doesn't help you now. To work around it you have to write the more optimal SQL code by hand. You can either run it as a Slick Plain SQL query or you can [use a hack](https://gist.github.com/cvogt/d9049c63fc395654c4b4), which allows you to simply swap out the SQL code Slick uses for a type-safe query.  -->

```scala
people.map(p => (p.id,p.name,p.age))
      .result
      // inject hand-written SQL, see https://gist.github.com/cvogt/d9049c63fc395654c4b4
      .overrideSql("SELECT id, name, age FROM Person")
```

SQL vs. Slick examples
----------------------

<!-- This section shows an overview over the most important types of SQL queries and a corresponding type-safe Slick query.  -->

### SELECT \*

#### SQL

```scala
sql"select * from PERSON".as[Person]
```

#### Slick

<!-- The Slick equivalent of `SELECT *` is the `result` of the plain TableQuery:  -->

```scala
people.result
```

### SELECT

#### SQL

```scala
sql"""
  select AGE, concat(concat(concat(NAME,' ('),ID),')')
  from PERSON
""".as[(Int,String)]
```

#### Slick

<!-- Scala's equivalent for `SELECT` is `map`. Columns can be referenced similarly and functions operating on columns can be accessed using their Scala eqivalents (but allowing only `++` for String concatenation, not `+`).  -->

```scala
people.map(p => (p.age, p.name ++ " (" ++ p.id.asColumnOf[String] ++ ")")).result
```

### WHERE

#### SQL

```scala
sql"select * from PERSON where AGE >= 18 AND NAME = 'C. Vogt'".as[Person]
```

#### Slick

<!-- Scala's equivalent for `WHERE` is `filter`. Make sure to use `===` instead of `==` for comparison.  -->

```scala
people.filter(p => p.age >= 18 && p.name === "C. Vogt").result
```

### ORDER BY

#### SQL

```scala
sql"select * from PERSON order by AGE asc, NAME".as[Person]
```

#### Slick

<!-- Scala's equivalent for `ORDER BY` is `sortBy`. Provide a tuple to sort by multiple columns. Slick's `.asc` and `.desc` methods allow to affect the ordering. Be aware that a single `ORDER BY` with multiple columns is not equivalent to multiple `.sortBy` calls but to a single `.sortBy` call passing a tuple.  -->

```scala
people.sortBy(p => (p.age.asc, p.name)).result
```

### Aggregations (max, etc.)

#### SQL

```scala
sql"select max(AGE) from PERSON".as[Option[Int]].head
```

#### Slick

<!-- Aggregations are collection methods in Scala. In SQL they are called on a column, but in Slick they are called on a collection-like value e.g. a complete query, which people coming from SQL easily trip over. They return a scalar value, which can be run individually. Aggregation methods such as `max` that can return `NULL` return Options in Slick.  -->

```scala
people.map(_.age).max.result
```

### GROUP BY

<!-- People coming from SQL often seem to have trouble understanding Scala's and Slick's `groupBy`, because of the different signatures involved. SQL's `GROUP BY` can be seen as an operation that turns all columns that weren't part of the grouping key into collections of all the elements in a group. SQL requires the use of it's aggregation operations like `avg` to compute single values out of these collections.  -->

#### SQL

```scala
sql"""
  select ADDRESS_ID, AVG(AGE)
  from PERSON
  group by ADDRESS_ID
""".as[(Int,Option[Int])]
```

#### Slick

<!-- Scala's groupBy returns a Map of grouping keys to Lists of the rows for each group. There is no automatic conversion of individual columns into collections. This has to be done explicitly in Scala, by mapping from the group to the desired column, which then allows SQL-like aggregation.  -->

```scala
people.groupBy(p => p.addressId)
       .map{ case (addressId, group) => (addressId, group.map(_.age).avg) }
       .result
```

<!-- SQL requires to aggregate grouped values. We require the same in Slick for now. This means a `groupBy` call must be followed by a `map` call or will fail with an Exception. This makes Slick's grouping syntax a bit more complicated than SQL's.  -->

### HAVING

#### SQL

```scala
sql"""
  select ADDRESS_ID
  from PERSON
  group by ADDRESS_ID
  having avg(AGE) > 50
""".as[Int]
```

#### Slick

<!-- Slick does not have different methods for `WHERE` and `HAVING`. For achieving semantics equivalent to `HAVING`, just use `filter` after `groupBy` and the following `map`.  -->

```scala
people.groupBy(p => p.addressId)
       .map{ case (addressId, group) => (addressId, group.map(_.age).avg) }
       .filter{ case (addressId, avgAge) => avgAge > 50 }
       .map(_._1)
       .result
```

### Implicit inner joins

#### SQL

```scala
sql"""
  select P.NAME, A.CITY
  from PERSON P, ADDRESS A
  where P.ADDRESS_ID = a.id
""".as[(String,String)]
```

#### Slick

<!-- Slick generates SQL using implicit joins for `flatMap` and `map` or the corresponding for-expression syntax.  -->

```scala
people.flatMap(p =>
  addresses.filter(a => p.addressId === a.id)
           .map(a => (p.name, a.city))
).result
...
// or equivalent for-expression:
(for(p <- people;
    a <- addresses if p.addressId === a.id
  ) yield (p.name, a.city)
).result
```

### Explicit inner joins

#### SQL

```scala
sql"""
  select P.NAME, A.CITY
  from PERSON P
  join ADDRESS A on P.ADDRESS_ID = a.id
""".as[(String,String)]
```

#### Slick

<!-- Slick offers a small DSL for explicit joins. -->

```scala
(people join addresses on (_.addressId === _.id))
  .map{ case (p, a) => (p.name, a.city) }.result
```

### Outer joins (left/right/full)

#### SQL

```scala
sql"""
  select P.NAME,A.CITY
  from ADDRESS A
  left join PERSON P on P.ADDRESS_ID = a.id
""".as[(Option[String],String)]
```

#### Slick

<!-- Outer joins are done using Slick's explicit join DSL. Be aware that in case of an outer join SQL changes the type of outer joined, non-nullable columns into nullable columns. In order to represent this in a clean way even in the presence of mapped types, Slick lifts the whole side of the join into an `Option`. This goes a bit further than the SQL semantics because it allows you to distinguish a row which was not matched in the join from a row that was matched but already contained nothign but NULL values.  -->

```scala
(addresses joinLeft people on (_.id === _.addressId))
  .map{ case (a, p) => (p.map(_.name), a.city) }.result
```

### Subquery

#### SQL

```scala
sql"""
  select *
  from PERSON P
  where P.ID in (select ID
                 from ADDRESS
                 where CITY = 'New York City')
""".as[Person]
```

#### Slick

<!-- Slick queries are composable. Subqueries can be simply composed, where the types work out, just like any other Scala code.  -->

```scala
val address_ids = addresses.filter(_.city === "New York City").map(_.id)
people.filter(_.id in address_ids).result // <- run as one query
```

<!-- The method `.in` expects a sub query. For an in-memory Scala collection, the method `.inSet` can be used instead.  -->

### Scalar value subquery / custom function

#### SQL

```scala
sql"""
  select * from PERSON P,
                     (select rand() * MAX(ID) as ID from PERSON) RAND_ID
  where P.ID >= RAND_ID.ID
  order by P.ID asc
  limit 1
""".as[Person].head
```

#### Slick

<!-- This code shows a subquery computing a single value in combination with a user-defined database function \<userdefined\>.  -->

```scala
val rand = SimpleFunction.nullary[Double]("RAND")
...
val rndId = (people.map(_.id).max.asColumnOf[Double] * rand).asColumnOf[Int]
...
people.filter(_.id >= rndId)
      .sortBy(_.id)
      .result.head
```

### insert

#### SQL

```scala
sqlu"""
insert into PERSON (NAME, AGE, ADDRESS_ID) values ('M Odersky', 12345, 1)
"""
```

#### Slick

<!-- Inserts can be a bit surprising at first, when coming from SQL, because unlike SQL, Slick re-uses the same syntax that is used for querying to select which columns should be inserted into. So basically, you first write a query and instead of creating an Action that gets the result of this query, you call `+=` on with value to be inserted, which gives you an Action that performs the insert. `++=` allows insertion of a Seq of rows at once. Columns that are auto-incremented are automatically ignored, so inserting into them has no effect. Using `forceInsert` allows actual insertion into auto-incremented columns.  -->

```scala
people.map(p => (p.name, p.age, p.addressId)) += ("M Odersky",12345,1)
```

### update

#### SQL

```scala
sqlu"""
update PERSON set NAME='M. Odersky', AGE=54321 where NAME='M Odersky'
"""
```

#### Slick

<!-- Just like inserts, updates are based on queries that select and filter what should be updated and instead of running the query and fetching the data `.update` is used to replace it.  -->

```scala
people.filter(_.name === "M Odersky")
      .map(p => (p.name,p.age))
      .update(("M. Odersky",54321))
```

### delete

#### SQL

```scala
sqlu"""
delete PERSON where NAME='M. Odersky'
"""
```

#### Slick

<!-- Just like inserts, deletes are based on queries that filter what should be deleted. Instead of getting the query result of the query, `.delete` is used to obtain an Action that deletes the selected rows.  -->

```scala
people.filter(p => p.name === "M. Odersky")
      .delete
```

### CASE

#### SQL

```scala
sql"""
  select
    case
      when ADDRESS_ID = 1 then 'A'
      when ADDRESS_ID = 2 then 'B'
    end
  from PERSON P
""".as[Option[String]]
```

#### Slick

<!-- Slick uses a small DSL \<slick.lifted.Case\$\> to allow `CASE` like case distinctions.  -->

```scala
people.map(p =>
  Case
    If(p.addressId === 1) Then "A"
    If(p.addressId === 2) Then "B"
).result
```
