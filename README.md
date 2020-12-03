# Q-Learning-EDBM
The core code of the Q-Learning-based EDBM for energy-efficient train control. 
The code corresponds to the manuscript, "An eco-driving algorithm for trains through distributing energy: a Q-learning approach"<br>
The description of the five directories in this repository is shown as follows.<br>
1.DynamicProperty: The codes in this directory focus on the dynamic properties, including the discounted total reward, value function and error. This directory supports Section 4.2 of the manuscript.<br>
2.ED-state--ResultAndHypers: The codes in this directory describe the process of ED-state Q-Learning and the optimal solution can be obtained via these codes. The sensitivity analyzes of hyperparameter in ED-state Q-Learning are also discussed. This directory supports Section 4.1 and 4.4 of the manuscript.<br>
3.EnergyUnit: The codes in this directory discuss the impact of the energy unit. The relationship between the energy unit and optimal strategy and computation time is discussed via these codes. This directory supports Section 4.5 of the manuscript.<br>
4.StochasticEnvironment: The codes in this directory construt a stochastic environment to verify the effectiveness of the Q-Learning approach in stochastic environment. This directory supports Section 4.1 of the manuscript.<br>
5.TT-state--ResultAndHypers: he codes in this directory describe the process of TT-state Q-Learning and the optimal solution can be obtained via these codes. The sensitivity analyzes of hyperparameter in TT-state Q-Learning are also discussed. This directory supports Section 4.1 and 4.3 of the manuscript.<br>
