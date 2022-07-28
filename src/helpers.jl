

function make_linkstate_table(tlist,c,L)
    for linktype in tlist
        from=linktype.from
        to=linktype.to
        if isa(from,Array)
            for x in from
                if x<1 || x>c
                    msg="One of the LinkTypes passed to LargeNet contains refers to nodes of state $x,"
                    msg*=" but $x is not a valid node state in this network." 
                    throw(ArgumentError(msg))
                end
            end            
        else
            if from<0 || from>c
                msg="One of the LinkTypes passed to LargeNet contains refers to nodes of state $from,"
                msg*=" but $from is not a valid node state in this network." 
                throw(ArgumentError(msg))
            end
        end     
        if isa(to,Array)
            for x in to
                if x<1 || x>c
                    msg="One of the LinkTypes passed to LargeNet contains refers to nodes of state $x,"
                    msg*=" but $x is not a valid node state in this network." 
                    throw(ArgumentError(msg))
                end
            end            
        else
            if to<0 || to>c
                msg="One of the LinkTypes passed to LargeNet contains refers to nodes of state $to,"
                msg*=" but $to is not a valid node state in this network." 
                throw(ArgumentError(msg))
            end
        end         
    end

    m=Array{Int,2}(undef,c,c)
    for i=1:c
        for j=1:c
            m[i,j]=L-1           
            for rule=1:L-2
                dir=tlist[rule].dir
                ft=tlist[rule].from
                tt=tlist[rule].to
                if dir!=2 
                    continue
                end
                if !((i in ft && j in tt) || (j in ft && i in tt) || (ft==0 && j in tt) || (ft==0 && i in tt) || (i in ft && tt==0) ||  (ft==j && tt==0) || (ft==0 && tt==0) )        
                    continue    
                end
                if (m[i,j]!=L-1)
                    throw(ArgumentError("LinkTyoe number $rule, passed to the FastNet constructor, seems to say that links of the form from state $i to state $j are of type $rule, but they were previously defined as LinkType $(m[i,j])."))
                end
                m[i,j]=rule
            end
        end
    end
    for i=1:c
        for j=1:c
            for rule=1:L-2
                dir=tlist[rule].dir
                ft=tlist[rule].from
                tt=tlist[rule].to
                if dir!=1 
                    continue
                end
                if !(j in tt) && tt!=0 
                    continue    
                end
                if !(i in ft) && ft!=0 
                    continue    
                end                
                if (m[i,j]!=L-1)
                    throw(ArgumentError("LinkTyoe number $rule, passed to the FastNet constructor, seems to say that links of the form from state $i to state $j are of type $rule, but they were previously defined as LinkType $(m[i,j])."))
                end
                m[i,j]=rule
            end
        end
    end
    m
end

function verify_linktype!(from,to,dir)
    if dir!=1 && dir!=2
        throw(ArgumentError("Third argument of LinkType must be 1 (unidirectional) or 2 (bidirection).")) 
    end
    if isa(from,Tuple)
        from=[from...]
    end
    if isa(to,Tuple)
        to=[to...]
    end

    if from=="*"
        from=0
    end
    if to=="*"
        to=0
    end
    
    if isa(from,Array)
        from=reshape(from,1,:)
        l=length(from)
        for i=1:l 
            try 
                from[i]=convert(Int,from[i])
            catch e
                msg="Could not process FROM argument passed to constructor of LinkType: "
                msg*="the variable passed seems to be a collection, "
                msg*="but I could not convert element $i to Int."
                throw(ArgumentError(msg))
            end
        end
    else
        try
            from=convert(Int,from)
        catch
            msg="Could not process FROM argument passed to constructor of LinkType: "
            msg*="the argument must be either an Integer, \"*\", or a Tuple or Array Integers."
            throw(ArgumentError(msg))
        end
    end

    if isa(to,Array)
        to=reshape(to,1,:)
        l=length(to)
        for i=1:l 
            try 
                to[i]=convert(Int,to[i])
            catch e
                msg="Could not process TO argument passed to constructor of LinkType: "
                msg*="the variable passed seems to be a collection, "
                msg*="but I could not convert element $i to Int."
                throw(ArgumentError(msg))
            end
        end
    else
        try
            tp=convert(Int,to)
        catch
            msg="Could not process TO argument passed to constructor of LinkType: "
            msg*="the argument must be either an Integer, \"*\", or a Tuple or Array of Integers."
            throw(ArgumentError(msg))
        end
    end
    (from,to,dir)
end
