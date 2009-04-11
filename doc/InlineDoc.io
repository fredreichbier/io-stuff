#!/usr/bin/env io
# A less command line friendly version of oleganza's InlineDoc.io
# See "Test" section below for examples.
#
# Changed: Friedrich Weber 2009
# License: WTFPL
#
# Based on the original InlineDoc.io:
# Author: Oleg Andreev (oleganza)
# License: WTFPL

/*
TODO
    * Object switchDocsOff: remove documentation from the memory and replace "doc" method with a dummy.
    * Search docs in the prototype in case current object has no docs
        (useful for inspecting "instances", not "classes").
    * Global search for a method among all the registered objects.
    * docModule definition (for specifying the name of the library)
            docModule "SGML" # for the top-level object
            docModule "SGML Element" # for the Element object inside SGML
    * Better API for docs to enable nice HTML generation.
    * Alias for the "doc" and "man" methods in case they are shadowed by other protos.
    * Complex markup (paragraphs, headers, code examples)
    * Short inline specs (both executable and readable examples of usage)
*/

Object Doc := Object clone do(
    registeredObjects := List clone

    // Container for Docs
    docsCollection := List clone do(
        Pair := List clone do(
            asString := method(
                desc := second asString split("\n") map(prependSeq("\t")) join("\n")
                "#{first}\n#{desc}" interpolate
            )
        )

        init := method(
            self methods := List clone
        )

        add := method(name, desc,
            append(list(name, desc) setProto(Pair))
            self
        )

        find := method(prefix,
            results := List clone
            if(prefix asString == "", return clone)
            foreach(lst, 
                if(lst first asString beginsWithSeq(prefix), results append(lst))
            )
            results
        )
    )

    // sets doc
    doc := method(
        docs := if(self getLocalSlot("__docs__"), 
            self getLocalSlot("__docs__")
        , 
            self __docs__ := Doc docsCollection clone
        )
        Doc registeredObjects append(self)
        docs add(call argAt(0), call evalArgAt(1))
        nil
    )

    man := method(content,
        if(self getLocalSlot("__docs__") not, 
            "No documentation for the receiver." interpolate println
            return nil
        )
        if(content == nil, 
            content = ""
        )
        __docs__ find(content asString) foreach(println)
        nil
    )
)

Object appendProto(Doc)
// Add docs for doc itself
Object do(
    doc(doc(someMethod(a,b), "Some description"), "Adds some description to a method")
    doc(man, "Show all methods descriptions for the receiver")
    doc(man("some"), "Show all docs for methods starting with 'some' prefix")
)


// Add docs for Docs API
Object Doc do(
    doc(registeredObjects, "List of all the objects containing documentation")
)

#
# Test
#

if(isLaunchScript,
    FakeLibrary := Object clone do(
        doc(hello, "Returns 'hello' string")
        hello := method(
            "hello"
        )

        doc(double(x), "Returns x*2")
        double := method(x,
            x*2
        )
    
        doc(new(name, email, age), "Creates a new object with the specified attributes")
        doc(new(mapObject), "Creates a new object with the \nattributes passed in a map object")
        doc(new(multiline), """
            line 0
            line 1
            line 2
        """)
        new := method(name, email, age,
            nil
            // TODO: do something with name, email and age
        )
    )

    Object man("doc"); FakeLibrary man("new")
    
    FakeLibrary man("new")    # emits docs for "FakeLibrary new*"
)
