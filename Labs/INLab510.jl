"""
Author: Stefan Hausner
"""

[	
   

	Activity(
        """
        In Lab IN510Swarm there is a suboptimization problem. The model
        populates the world with a population. And the population should
        find the nearest local minima. Every agent search in his neighbourhood
        for the lowest patchvalue. All agents have a patchvalue.
        If an agent finds an smaller patchvalue in his neighbourhood he moves to
        it.

        neighboursize = radius of the neighborhood

        try to adjust the neighboursize what do you observe
        
        Are the agents getting better in finding the local minima or
        not
        """
    ),

    Activity(
        """
        In this Lab we use the following functions to get the local
        minima use the function to find the local minima of a
        random matrix.

        ids = collect(1:5)
        mat = rand(5,1)
        patch(ids) = mat[ids]
        min_patch(patch, itr) = itr[argmin(map(patch, itr)
        id = min_patch(patch, ids)

        Also try to change mat to an rand(5,5)
        ids = collect(1:25)
        """

    ),

    Activity(
        """
        In the previous Activity we changed the neighborsize now
        we want increase the population. 

        Population is created with this formula  
        n_agent = worldsize*worldsize*pPop

        Try to change pPop.
        What can you observe?
        Try to change pPop and neighborsize.
        What can you observe?
        """
    ),
    Activity(
        """
        Now try to change the slider of deJong7 to true and reset the model.
        
        What has changed?

        Try the previous tasks in this Activity.
        What has changed?
        """      
    ),
    Activity(
        """
        Finally you can change the worldsize after
        compilation, this is only possible in this Lab.
        
        This model has an slider to adjust the worldsize.

        Try to adjust the worldsize.
        What can you observe?
        How the agents behave now?
        """
    ),
]