# Robot-automation-in-assembly
This is a project created for the course Computer Architecture of my university.
It uses the virtual device robot.exe and the goal of the project is for the robot to find and close all the lamps that are on.
At the start the programm creates a 2D grid and then takes as input the place of the robot, based on a grid i provide that gives a number to each cell, and its orientation and places it in said grid.
Then from the starting place, it checks all cells that can be checked with only rotation, these are the cells that are 1 space up,down,right or left of the robot.
By checking all these cells the robot updates the grid and stores in, the cell values based on what it is found there. Then it selects one of the 4 near cells and moves there.
By doing this the robot know where there are walls, roads, roads that were already walked and lamps. Thus if the robot reaches a dead end, it will simply go backwards and select a path to visit to reach a road that is not yet walked. If it cannot find such path then the algorythm is sure that is has explored the entirety of the map and finishes.
