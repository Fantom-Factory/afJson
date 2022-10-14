# Json v2.0.14
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](https://fantom-lang.org/)
[![pod: v2.0.14](http://img.shields.io/badge/pod-v2.0.14-yellow.svg)](http://eggbox.fantomfactory.org/pods/afJson)
[![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)](https://choosealicense.com/licenses/isc/)

## <a name="overview"></a>Overview

Json is a customisable Fantom to Javascript Object Notation (JSON) mapping library.

It goes far beyond the usual `JsonInStream` and `JsonOutStream` classes by mapping and instantiating fully fledged Fantom domain objects.

Features:

* Converts all core Fantom types
* Converts nested / embedded objects
* Runs on Javascript platforms
* Simple to use
* JSON pretty printing


Just annotate fields with `@JsonProperty` then call `fromJson(...)` and `toJson(...)` - couldn't be easier!

## <a name="Install"></a>Install

Install `Json` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afJson

Or install `Json` with [fanr](https://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afJson

To use in a [Fantom](https://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afJson 2.0"]

## <a name="documentation"></a>Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afJson/) - the Fantom Pod Repository.

## <a name="quickStart"></a>Quick Start

1. Create a text file called `Example.fan`    using afJson
    
    class Example {
        Void main() {
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
            friend := (Friend) Json().fromJson(json, Friend#)
    
            echo(friend.name)     // --> Emma
            echo(friend.car.name) // --> Golf
    
            friend.score = 11
            friend.car   = null
    
            // we can even convert the other way!
            moarJson := Json().toJson(friend)
    
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


2. Run `Example.fan` as a Fantom script from the command line:    C:\> fan Example.fan
    
    Emma
    Golf
    {"name":"Emma","sex":"female","score":11,"likes":["Cakes","Adventure"]}




## <a name="terminology"></a>Terminology

**JSON** is the **string** representation of a Javascript object.

**JsonObj** is the Fantom representation of a JSON object. It *only* contains `Maps`, `Lists`, `Bools`, `Nums`, `Strs`, and `null`.

**Entity** is a Fantom object from your problem domain.

All conversion of Entities to and from JSON goes through an intermediary `JsonObj` stage:

    Entity <--> JsonObj <--> JSON

`JsonReader` and `JsonWriter` convert between JsonObjs and JSON.

`JsonConverters` has methods to convert between all.

## <a name="usage"></a>Usage

Any Fantom object may be converted to and from JSON. Just make sure that all fields to be converted are annotated with the `@JsonProperty` facet.

### <a name="supportedTypes"></a>Supported Types

The [JSON Spec](http://www.json.org/) only defines types for `Bool`, `List`, `Null`, `Number`, `Object`, and `String`. As such, this library provides the following mappings:

     Fantom                  JSON
    ------------------      --------
     afJson::JsLiteral <-->  *as is*
     sys::Bool         <-->  Bool
     sys::Decimal      <-->  Number
     sys::Date         <-->  String
     sys::DateTime     <-->  String
     sys::Depend       <-->  String
     sys::Duration     <-->  String
     sys::Enum         <-->  String
     sys::Field        <-->  String
     sys::Float        <-->  Number
     sys::Int          <-->  Number
     sys::List         <-->  List
     sys::Locale       <-->  String
     sys::Map          <-->  Object
     sys::Method       <-->  String
     sys::MimeType     <-->  String
     sys::Num          <-->  Number
          null         <-->  Null
     sys::Obj          <-->  Object
     sys::Range        <-->  String
     sys::Regex        <-->  String
     sys::Slot         <-->  String
     sys::Str          <-->  String
     sys::Time         <-->  String
     sys::TimeZone     <-->  String
     sys::Type         <-->  String
     sys::Unit         <-->  String
     sys::Uri          <-->  String
     sys::Uuid         <-->  String
     sys::Version      <-->  String
    

Plus any `Type` annotated with `@Serializable { simple = true }` is converted to and from a `Str`. Combined that accounts for all Fantom literals and core types.

### <a name="constAndNonConst"></a>Const vs Non-Const

This library can instantiate any Fantom object, both `const` and `non-const`. But if the type is `const`, or if it has `non-null` fields, then it *must* have an it-block ctor like the one below. That is the only way fields can be set during construction.

    const class User {
    
        @JsonProperty
        const Str name
    
        // the it-block ctor
        new make(|This| f) {
            f(this)
        }
    }
    

### <a name="nullAndNonNull"></a>Null vs Non-Null

Nullable fields are optional, that is, they do not require a JSON value.

    class User {
        @JsonProperty
        Str? name  // name is optional because it is nullable
    
        new make(|This| f) { f(this) }
    }
    
    json := "{}"
    user := Json().fromJson(json, User#) as User
    
    echo(user.name)  // --> null
    

Similarly, when converting an entity to JSON, `null` values are not written out:

    class User {
        @JsonProperty
        Str? name
    
        new make(|This| f) { f(this) }
    }
    
    user := User { name = null }
    json := Json().toJson(user)
    
    echo(json)  // --> {}
    

### <a name="propertyNames"></a>Property Names

Sometimes you want the JSON name to be different to the field names. To facilitate this, set the `@JsonProperty.name` attribute:

    class User {
        @JsonProperty { name = "judge" }
        Str? name
    
        new make(|This| f) { f(this) }
    }
    
    user := User { name = "Dredd" }
    json := Json().toJson(user, User#)
    
    echo(json)  // --> {"judge":"Dredd"}
    

## <a name="pickleMode"></a>Pickle Mode

Sometimes you wish to read / write objects to JSON that are outside of your control, meaning their fields won't be annotated with `@JsonProperty` facets. To facilitate this, you can turn on *Pickle Mode* whereby all non `@Transient` fields are converted, regardless of any `@JsonProperty` facets. Data from `@JsonProperty` facets, however, will still honoured if defined.

Pickle mode works by automatically writing out `_type` properties, which are them used when re-inflating objects back.

*Pickle Mode* may be turned on globally as an option in `JsonConverters`, or locally as an argument on the `@JsonProperty` facets.

    // turn on pickleMode for everything
    jsonConvs := JsonConverters(null, [
        "pickleMode" : true
    ])
    
    // ... or ...
    
    @Entity
    class User {
        @JsonProperty Str  name
        @JsonProperty Int  age
    
        ** Turn on pickleMode just for this field
        ** meta values may be *any* object
        @JsonProperty { pickleMode=true }
                  Str:Obj? meta
    
        new make(|This|in) { in(this) }
    }
    

## <a name="jsonAndDates"></a>JSON and Dates

JSON does *not* define a Date object. As such, when writing Dates, they are serialised as ISO strings. At the other end, presumably in Javascript land, something must walk your object and de-serialise all your date strings back into Date objects.

But sometimes you want a quick hack and some people advocate inserting Javascript statements directly into the JSON. It may not be the best idea, but it's a good example of custom inspectors and converters...

    using afJson
    
    class User {
        @JsonProperty Str?      name
        @JsonProperty DateTime? timestamp
    }
    
    class Example {
        Void main() {
            jsonService := Json(JsonConverters.defConvs.setAll([
                Date# : JsDateConverter()
            ]))
    
            user := User { name = "Judge Dredd"; timestamp = DateTime.now }
            json := jsonService.toJson(user)
    
            echo(json) // --> {"name":"Judge Dredd","timestamp":"new Date(1456178248297)"}
        }
    }
    
    const class JsDateConverter : JsonConverter {
        override Obj? fromJsonVal(Obj? jsonVal, JsonConverterCtx ctx)  { throw UnsupportedErr() }
    
        override Obj? toJsonVal(Obj? fantomObj, JsonConverterCtx ctx) {
            fantomObj == null ? null : JsLiteral("new Date(${((DateTime) fantomObj).toJava})")
        }
    }
    

