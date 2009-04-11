/*
    Exinterpolate is an extended `interpolate`.

    It basically does something similar to interpolate:
    Everything between !{ and } is evaluated, the return
    value is appended to the result if it's not nil.

    Additionaly, it provides two convenience functions:

        !"huhu"     The message "huhu" is evaluated and
                    its result is appended to the global result.
                    Returns nil.
                    That's an operator.
    
    Example:

        Io> exinterpolate("begin !{ for(i, 1, 10, :i) } end")
        ==> begin 12345678910 end
        Io> exinterpolate("begin !{ for(i, 1, 10, :i;!(\" \"))} end")
        ==> begin 1 2 3 4 5 6 7 8 9 10  end

    Exinterpolate is Regex-based; nested expressions are not possible at the moment.

    License: MIT license, see LICENSE
*/

Regex 

START := "!{"
END := "}"
RE := "#{START}([^#{END}]+)#{END}" interpolate asRegex

exinterpolate := method(seq, context,
    result := "" asMutable
    
    # set the convenience stuff
    if(context == nil,
        context = call sender
    )

    context = context clone
    context setSlot("!",
        block(arg,
            result appendSeq(arg)
            nil
        ) setIsActivatable(true)
    )

    matches := seq matchesOfRegex(RE)

    last_end := 0
    matches foreach(match,
        # append the stuff before the match first
        result appendSeq(seq exclusiveSlice(last_end, match start))
        # compile a message, evaluate and append the result
        res := Message fromString(match at(1)) doInContext(context)
        if(res,
            result appendSeq(res)
        )
        last_end = match end
    )
    # append the rest of the string, after the last match
    result appendSeq(seq exclusiveSlice(last_end))
    
    return(result)
)

OperatorTable addOperator("!", 0)
