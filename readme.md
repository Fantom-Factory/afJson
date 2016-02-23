#Json v0.0.2
---
[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
[![pod: v0.0.2](http://img.shields.io/badge/pod-v0.0.2-yellow.svg)](http://www.fantomfactory.org/pods/afJson)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

## Overview

*Json is a support library that aids Alien-Factory in the development of other libraries, frameworks and applications. Though you are welcome to use it, you may find features are missing and the documentation incomplete.*

Json is a Fantom to Javascript Object Notation (JSON) mapping library.

Features:

- Converts all core Fantom types
- Converts nested / embedded objects
- Runs on Javascript platforms
- IoC enabled
- Very customisable

## Install

Install `Json` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://pods.fantomfactory.org/fanr/ afJson

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afJson 0.0"]

## Documentation

Full API & fandocs are available on the [Fantom Pod Repository](http://pods.fantomfactory.org/pods/afJson/).

## Quick Start

1. Create a text file called `Example.fan`

        using afJson
        
        class Example {
            Void main() {
                jsonService := Json()
        
                // write some JSON...
                json := """{
                               "name"  : "Emma",
                               "sex"   : "female",
                               "likes" : ["Cakes","Adventure"],
                               "car"   : {
                                   "name"  : "Golf",
                                   "brand" : "VW"
                               },
                               "score" : 9
                           }"""
        
                // ...and WHAM! A fully inflated domain object!
                friend := (Friend) jsonService.readEntity(json, Friend#)
        
                echo(friend.name)     // --> Emma
                echo(friend.car.name) // --> Golf
        
                friend.score = 11
                friend.car   = null
        
                // we can event convert the other way!
                moarJson := jsonService.writeEntity(friend)
        
                echo(moarJson)
                // --> {"name":"Emma","sex":"female","score":11,"likes":["Cakes","Adventure"]}
            }
        }
        
        
        class Friend {
            @JsonProperty Str    name
            @JsonProperty Sex    sex
            @JsonProperty Int    score
            @JsonProperty Str[]  likes
            @JsonProperty Car?   car    // embedded objects!
        
            new make(|This| f) { f(this) }
        }
        
        class Car {
            @JsonProperty Str    name
            @JsonProperty Str    brand
        
            new make(|This| f) { f(this) }
        }
        
        enum class Sex {
            male, female;
        }


2. Run `Example.fan` as a Fantom script from the command line:

        C:\> fan Example.fan
        
        Emma
        Golf
        {"name":"Emma","sex":"female","score":11,"likes":["Cakes","Adventure"]}



## Terminology

**JSON** is the **string** representation of a Javascript object.

**JsonObj** is the Fantom representation of a JSON object. It *only* contains `Maps`, `Lists`, `Bools`, `Nums`, `Strs`, and `null`.

**Entity** is a Fantom object from your problem domain.

All conversion of Entities to and from JSON goes through an intermediary `JsonObj` stage:

    Entity <--> JsonObj <--> JSON

`JsonConverters` convert between Entities and JsonObjs.

`JsonReaders` and `JsonWriters` convert between JsonObjs and JSON.

## Usage

Any Fantom object may be converted to and from JSON. Just make sure that all fields to be converted are annotated with the `@JsonProperty` facet.

### Supported Types

The [JSON Spec](http://www.json.org/) only defines types for `Bool`, `List`, `Null`, `Number`, `Object`, and `String`. As such, this library provides the following mappings:

```
 Fantom              JSON
--------------      --------
 sys::Bool     <-->  Bool
 sys::Decimal  <-->  Number
 sys::Enum     <-->  String
 sys::Field    <-->  String
 sys::Float    <-->  Number
 sys::Int      <-->  Number
 sys::List     <-->  List
 sys::Map      <-->  Object
 sys::Method   <-->  String
      null     <-->  Null
 sys::Obj      <-->  Object
 sys::Slot     <-->  String
 sys::Str      <-->  String
 sys::Type     <-->  String
```

Plus any `Type` annotated with `@Serializable { simple = true }` is converted to and from a `Str`. Combined that accounts for all Fantom literals and core types.

### Const vs Non-Const

This library can instantiate any Fantom object, both `const` and `non-const`. But if the type is `const`, or if it has `non-null` fields, then it *must* have an it-block ctor like the one below. That is the only way fields can be set during construction.

```
const class User {

    @JsonProperty
    const Str name

    // the it-block ctor
    new make(|This| f) {
        f(this)
    }
}
```

### Null vs Non-Null

Nullable fields are optional, that is, they do not require a JSON value.

```
class User {
    @JsonProperty
    Str? name  // name is optional because it is nullable

    new make(|This| f) { f(this) }
}

json := "{}"
user := Json().readEntity(json, User#) as User

echo(user.name)  // --> null
```

Similarly, when converting an entity to JSON, `null` values are not written out:

```
class User {
    @JsonProperty
    Str? name

    new make(|This| f) { f(this) }
}

user := User { name = null }
json := Json().writeEntity(user)

echo(json)  // --> {}
```

If you want `null` values to be written, then set `storeNullValues = true` on the desired field:

```
class User {
    @JsonProperty { storeNullValues = true }
    Str? name

    new make(|This| f) { f(this) }
}

user := User { name = null }
json := Json().writeEntity(user)

echo(json)  // --> {"name":null}
```

### Property Names

Sometimes you want the JSON name to be different to the field names. To facilitate this, set the `@JsonProperty.propertyName` attribute:

```
class User {
    @JsonProperty { propertyName = "judge" }
    Str? name

    new make(|This| f) { f(this) }
}

user := User { name = "Dredd" }
json := Json().writeEntity(user)

echo(json)  // --> {"judge":"Dredd"}
```

## IoC

When Json is added as a dependency to an IoC enabled application, such as [BedSheet](http://pods.fantomfactory.org/pods/afBedSheet) or [Reflux](http://pods.fantomfactory.org/pods/afReflux), then the following services are automatically made available to IoC:

- [Json](http://pods.fantomfactory.org/pods/afJson/api/Json)
- [JsonReader](http://pods.fantomfactory.org/pods/afJson/api/JsonReader)
- [JsonWriter](http://pods.fantomfactory.org/pods/afJson/api/JsonWriter)
- [JsonTypeInspectors](http://pods.fantomfactory.org/pods/afJson/api/JsonTypeInspectors) - takes contributions of `Str:JsonTypeInspector`

The above makes use of the non-invasive module feature of IoC 3.

It is useful if your converted Fantom objects are built by IoC. That way they may contain services and perform operations on themselves, such as persisting to a database. To enable this, create an `IocObjConverter` class that extends from Json's `@NoDoc ObjConverter` class:

```
using afIoc
using afJson

const class IocObjConverter : ObjConverter {
    @Inject const |->Scope| scope

    new make(|This|in) { in(this) }

    override Obj? createEntity(Type type, Field:Obj? fieldVals) {
        scope().build(type, null, fieldVals)
    }
}
```

Contribute this with the following:

```
@Contribute { serviceType=JsonTypeInspectors# }
Void contributeJsonTypeInspectors(Configuration config) {
    config.overrideValue("afJson.obj", ObjInspector { it.converter = config.build(IocObjConverter#) })
}
```

## Custom Conversion

The Json library is extremely configurable at all levels. Because of that, object conversion may not be as straight forward as you may think. This explains how the process works...

Every Fantom type to be converted, either a top level entity or an embedded object, is inspected by `JsonTypeInspectors` which produces a `JsonTypeMeta` instance. `JsonTypeMeta` describes how the Fantom type will be converted to / and from JSON. It also holds the `JsonConverter` instance that will do the converting.

Because each Fantom Type is mapped to a cached `JsonTypeMeta` instance, conversion is fast because types don't have to be re-inspected. Also, if an object is not being converted as you expect, you can inspect the nested hierarchy of `JsonTypeMeta` objects to see exactly what will happen.

`JsonTypeInspectors` holds a list of `JsonTypeInspector` instances. During inspection, each inspector is called in turn until one of them returns a `JsonTypeMeta` instance. This makes the order of the inspectors important.

To go the full hog with respect to custom conversion, you should create your own `JsonTypeInspector` and add / contribute it to `JsonTypeInspectors`. Your inspector should create `JsonTypeMeta`, complete with a custom converter, that completely describes how the type should be converted.

For example, there's no reason why fields must be annotated with `@JsonProperty`, you could easily create an inspector that returns `JsonTypeMeta` for *every* field!

If you did not want to go as far as creating an inspector, you could instead create a `JsonTypeMeta` instance. This could either be set on `JsonTypeInspectors` to be used for all given types, or passed to `Json` methods for ad hoc conversions.

Or the easiest, but most limited way, would be to set the `@JsonProperty.converterType` attribute on the affected fields.

If you are contemplating implementating custom conversion then you are encouraged to look at the Json library source for help and examples. It may be preferable to simply extend one the current Inspectors or Converters.

## JSON and Dates

JSON does *not* define a Date object. As such, when writing Dates, they are serialised as ISO strings. At the other end, presumably in Javascript land, something must walk your object and de-serialise all your date strings back into Date objects.

But sometimes you want a quick hack and some people advocate inserting Javascript statements directly into the JSON. It may not be the best idea, but it's a good example of custom inspectors and converters...

```
using afJson

class User {
    @JsonProperty Str?      name
    @JsonProperty DateTime? timestamp
}

class Example {
    Void main() {
        jsonService := Json(JsonTypeInspectors(
            JsonTypeInspectors.defaultInspectors.insert(0, JsDateInspector())
        ))

        user := User { name = "Judge Dredd"; timestamp = DateTime.now }
        json := jsonService.writeEntity(user)

        echo(json) // --> {"name":"Judge Dredd","timestamp":new Date(1456178248297)}
    }
}

const class JsDateInspector : JsonTypeInspector {
    const JsonConverter converter := JsDateConverter()

    override JsonTypeMeta? inspect(Type type, JsonTypeInspectors inspectors) {
        type.toNonNullable == DateTime# ? JsonTypeMeta { it.type = type; it.converter = this.converter } : null
    }
}

const class JsDateConverter : JsonConverter {
    override Obj? toFantom(JsonConverterCtx ctx, Obj? jsonObj) { throw UnsupportedErr() }

    override Obj? toJsonObj(JsonConverterCtx ctx, Obj? fantomObj) {
        fantomObj == null ? null : JsLiteral("new Date(${((DateTime) fantomObj).toJava})")
    }
}
```

### IoC

If using IoC then you wouldn't create a new `Json()` service, instead you would contribute `JsDateInspector` to `JsonTypeInspectors`:

```
@Contribute { serviceType=JsonTypeInspectors# }
Void contributeJsonTypeInspectors(Configuration config) {
    config.set("jsDates", JsDateInspector()).before("afJson.literal")
}
```

Putting your inspector before `afJson.literal` ensures it is first in the inspector list.

