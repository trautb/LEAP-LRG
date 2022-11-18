"""
Authors: Stefan Hausner,Neil Palfreyman
"""

[	
	Activity(
    """
    In this Lab we analyse the Lab Lab513LateralActivation
    
    In this Lab we observe the function react
    
    function react(model,mat,origin)

        map(CartesianIndices(( 1:size(mat)[1], 1:size(mat)[2]))) do x
            if (x[1] == origin[1] && x[2] == origin[2])
                bBic = model.bBic
            else
                bBic = 0.0
            end
            hill(s,K) = s^3 / (s^3+K^3)
            mat[x[1],x[2]] = (mat[x[1],x[2]]+model.dt*(bBic - (model.aBic * mat[x[1],x[2]]) + 
            (model.cBic*hill(mat[x[1],x[2]], model.KBic) )))
        end
        return mat
    end 

    First, analyse the Euler line in react to see what role the different constants play. 
    Make sure you understand what I mean by an “Euler line”, and ask others, if it is not clear to you!
    Notice that in the Euler line, the time differential dt is multiplied by a bracket expression.
    Each of the three terms in this bracket expression has a specific biochemical meaning, and you need to make
    sure you understand what biochemical process is represented by each term.
    """
    "The eulerline is the line after hill.
    All of you who have studied biotechnology are familiar with every one of these three bioprocesses."   
    ),

    Activity(
    """
    Now switch off the constants cBic and DBic by setting them to zero. Now play with the values of rnaBic and aBic. Can you find
    out how these two numbers determine the final stable level of Bicoid concentration in the nucleus?

    Try to adjust these values.

    What happens?

    Is the difussion getting faster?
    """   
    ),
]