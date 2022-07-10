"""
Author: Stefan Hausner
"""

[	
	Activity(
        """
        In Lab IN510Swarm there is an suboptimisation problem. The model
        populates the world with an population. And the population should
        find the nearest local minima. Every agent searches in his neighborhood
        for the lowest patchvalue. Every agents have an patchvalue.
        If an agent finds an smaller patchvalue in his neighborhood he moves to
        it.

        neighborsize = radius of the neighborhood

        try to adjust the neighborsize what do you observe
        
        Are the agents getting better in finding the local minima or
        not
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