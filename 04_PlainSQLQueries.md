
[Permalink](http://slick.typesafe.com/doc/1.0.0/sql.html "Permalink to Plain SQL Queries — Slick 1.0.0 documentation")

# Plain SQL Queries — Slick 1.0.0 documentation

Sometimes you may need to write your own SQL code for an operation which is not well supported at a higher level of abstraction. Instead of falling back to the low level of [JDBC][1], you can use Slick’s *Plain SQL* queries with a much nicer Scala-based API.

## Scaffolding

[Slick example jdbc/PlainSQL][2] demonstrates some features of the *Plain SQL* support. The imports are different from what you’re used to for the [*lifted embedding*][3] or [*direct embedding*][4]:

    import scala.slick.session.Database
    import Database.threadLocalSession
    import scala.slick.jdbc.{GetResult, StaticQuery =&gt; Q}
    

First of all, there is no *Slick driver* being imported. The JDBC-based APIs in Slick depend only on JDBC itself and do not implement any database-specific abstractions. All we need for the database connection is Database, plus the threadLocalSession to simplify session handling.

The most important class for *Plain SQL* queries is scala.slick.jdbc.StaticQuery which gets imported as Q for more convenient use.

The database connection is opened [*in the usual way*][5]. We are also defining some case classes for our data:

    case class Supplier(id: Int, name: String, street: String, city: String, state: String, zip: String)
    case class Coffee(name: String, supID: Int, price: Double, sales: Int, total: Int)
    
    Database.forURL("jdbc:h2:mem:test1", driver = "org.h2.Driver") withSession {
    
    }
    

## DDL/DML Statements

The simplest StaticQuery method is updateNA which creates a parameterless (*NA = no args*) StaticQuery[Unit, Int] that is supposed to return the row count from a DDL statement instead of a result set. It can be executed the same way as a query that uses the [*lifted embedding*][3]. Here we are using .execute to run the query without getting the results:

    // Create the tables, including primary and foreign keys
    Q.updateNA("create table suppliers("%2B
      "id int not null primary key, "%2B
      "name varchar not null, "%2B
      "street varchar not null, "%2B
      "city varchar not null, "%2B
      "state varchar not null, "%2B
      "zip varchar not null)").execute
    Q.updateNA("create table coffees("%2B
      "name varchar not null, "%2B
      "sup_id int not null, "%2B
      "price double not null, "%2B
      "sales int not null, "%2B
      "total int not null, "%2B
      "foreign key(sup_id) references suppliers(id))").execute
    

You can append a String to an existing StaticQuery object with %2B, yielding a new StaticQuery with the same types. The convenience method StaticQuery.u constructs an empty *update* query to start with (identical to StaticQuery.updateNA("")). We are using it to insert some data into the SUPPLIERS table:

    // Insert some suppliers
    (Q.u %2B "insert into suppliers values(101, 'Acme, Inc.', '99 Market Street', 'Groundsville', 'CA', '95199')").execute
    (Q.u %2B "insert into suppliers values(49, 'Superior Coffee', '1 Party Place', 'Mendocino', 'CA', '95460')").execute
    (Q.u %2B "insert into suppliers values(150, 'The High Ground', '100 Coffee Lane', 'Meadows', 'CA', '93966')").execute
    

Embedding literals into SQL code is generally not recommended for security and performance reasons, especially if they are to be filled at run-time with user-provided data. You can use the special concatenation operator %2B? to add a bind variable to a query string and instantiate it with the provided value when the statement gets executed:

    def insert(c: Coffee) = (Q.u %2B "insert into coffees values (" %2B? c.name %2B
      "," %2B? c.supID %2B "," %2B? c.price %2B "," %2B? c.sales %2B "," %2B? c.total %2B ")").execute
    
    // Insert some coffees
    Seq(
      Coffee("Colombian", 101, 7.99, , ),
      Coffee("French_Roast", 49, 8.99, , ),
      Coffee("Espresso", 150, 9.99, , ),
      Coffee("Colombian_Decaf", 101, 8.99, , ),
      Coffee("French_Roast_Decaf", 49, 9.99, , )
    ).foreach(insert)
    

The SQL statement is the same for all calls: insert into coffees values (?,?,?,?,?)

## Query Statements

Similar to updateNA, there is a queryNA method which takes a type parameter for the rows of the result set. You can use it to execute a *select* statement and iterate over the results:

    Q.queryNA[Coffee]("select * from coffees") foreach { c =&gt;
      println("  " %2B c.name %2B "t" %2B c.supID %2B "t" %2B c.price %2B "t" %2B c.sales %2B "t" %2B c.total)
    }
    

In order for this to work, Slick needs to know how to read Coffee values from a PositionedResult object. This is done with an implicit GetResult value. There are predefined GetResult implicits for the standard JDBC types, for Options of those (to represent nullable columns) and for tuples of types which have a GetResult. For the Supplier and Coffee classes in this example we have to write our own:

    // Result set getters
    implicit val getSupplierResult = GetResult(r =&gt; Supplier(r.nextInt, r.nextString, r.nextString,
      r.nextString, r.nextString, r.nextString))
implicit val getCoffeeResult = GetResult(r => Coffee(r.<<, r.<<, r.<<, r.<<, r.<<))
GetResult[T] is simply a wrapper for a function PositionedResult => T. The first one above uses the explicit PositionedResult methods getInt and getString to read the next Int or String value in the current row. The second one uses the shortcut method << which returns a value of whatever type is expected at this place. (Of course you can only use it when the type is actually known like in this constructor call.)

The queryNA method for parameterless queries is complemented by query which takes two type parameters, one for the query parameters and one for the result set rows. Similarly, there is a matching update for updateNA. The execution methods of the resulting StaticQuery need to be called with the query parameters, as seen here in the call to .list:

// Perform a join to retrieve coffee names and supplier names for
// all coffees costing less than $9.00
val q2 = Q.query[Double, (String, String)]("""
  select c.name, s.name
  from coffees c, suppliers s
  where c.price < ? and s.id = c.sup_id
""")
// This time we read the result set into a List
val l2 = q2.list(9.0)
for (t <- l2) println("  " + t._1 + " supplied by " + t._2)
As an alternative, you can apply the parameters directly to the query, thus reducing it to a parameterless query. This makes the syntax for parameterized queries the same as for normal function application:

val supplierById = Q[Int, Supplier] + "select * from suppliers where id = ?"
println("Supplier #49: " + supplierById(49).first)
String Interpolation
In order to use the string interpolation prefixes sql and sqlu, you need to add one more import statement:

import Q.interpolation
As long as you don’t want function-like reusable queries, interpolation is the easiest and syntactically nicest way of building a parameterized query. Any variable or expression injected into a query gets turned into a bind variable in the resulting query string. (You can use #$ instead of $ to get the literal value inserted directly into the query.) The result type is specified in a call to .as which turns the object produced by the sql interpolator into a StaticQuery:

def coffeeByName(name: String) = sql"select * from coffees where name = $name".as[Coffee]
println("Coffee Colombian: " + coffeeByName("Colombian").firstOption)
There is a similar interpolator sqlu for building update statements. It is hardcoded to return an Int value so it does not need the extra .as call:

def deleteCoffee(name: String) = sqlu"delete from coffees where name = $name".first
val rows = deleteCoffee("Colombian")
println(s"Deleted $rows rows")
