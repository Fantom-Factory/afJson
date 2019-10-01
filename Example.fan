    using afJson

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
            
            // we can event convert the other way! 
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