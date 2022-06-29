
[
	Activity(
        """
        In the previous sections we learned some basic functions and calcultation methods of julia. In this Section we introduce you to Agent Based modelling
        In this section we work with this package https://juliadynamics.github.io/Agents.jl/stable/performance_tips/.
        Here we learn how to create agent based simulations in julia. In Lab007 you learned about the type struct. In this section struct is an important type for your
        agent models. Now create an basic struct 

        using Agents

        mutable struct Agent <: AbstractAgent
            id::Int                    
            pos::NTuple{2,Float64}             
            phase:: Float64
        end   


        """
        ),

        Activity(
            """
            Now it is introdced how to initialize_model. Here we can set every parameter defined in struct, for every agent

            function initialize_model(;n_agents)

                
                space2d = ContinuousSpace(griddims, 1.0)
                model = ABM(Agent, space2d, scheduler = Schedulers.randomly

            end
            """    
        ),


        ]