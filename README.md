# Robot-automation-in-assembly
This is a project created for the course Computer Architecture of my university.
It uses the virtual device robot.exe and the goal of the project is for the robot to find and close all the lamps that are on.
At the start the programm creates a 2D grid and then takes as input the place of the robot, based on a grid i provide that gives a number to each cell, and its orientation and places it in said grid.
Then from the starting place, it checks all cells that can be checked with only rotation, these are the cells that are 1 space up,down,right or left of the robot.
By checking all these cells the robot updates the grid and stores in the cells value based on what it is found there(wall,lamp on)
