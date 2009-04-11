/* did i do that? i have no idea, really :D */

/* list literal: [1, "blabb", 3, 4] == list(1, "blabb", 3, 4) */
Object squareBrackets := method(
    return(call evalArgs)
)

/* index operator: list(1, 2, 3, 4)[0] == list(1, 2, 3, 4) at(0) 
   slice operator: list(1, 2, 3, 4)[1:3] == list(1, 2, 3, 4) exclusiveSlice(1, 3)
*/

SLICEOP := ":"

List squareBrackets := Sequence squareBrackets := method(
    if(call message argAt(0) next != nil
        /* slice */
        msg := call message argAt(0)
        one := msg
        two := one next
        three := two next

        one setNext(nil)
        two setNext(nil)

        begin := 0
        end := nil
        if(one name == SLICEOP) then(
            /* blubb[:1] */
            begin := 0
            end := two doInContext(call sender)
        ) elseif(two name == SLICEOP) then(
            if(three == nil) then(
                /* blubb[1:] */
                begin = one doInContext(call sender)
                end = nil
            ) else (
                /* blubb[1:3] */
                begin = one doInContext(call sender)
                end = three doInContext(call sender)
            )
        ) else(
            Exception raise("Unknown slice syntax!")
        )

        return self exSlice(begin, end)
    ,
        /* index */
        return(self at(call evalArgAt(0)))
    )
)

list(1, "blabb", 3, 4)[:3] println
