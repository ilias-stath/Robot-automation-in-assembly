# Robot-automation-in-assembly
This is a project created for the course Computer Architecture of my university. <br />
It uses the virtual device robot.exe and the goal of the project is for the robot to find and close all the lamps that are on.<br />
At the start the programm creates a 2D grid and then takes as input the place of the robot, based on a grid i provide that gives a number to each cell, and its orientation and places it in said grid.<br />
From the starting place, it checks all cells that can be checked with only rotation, these are the cells that are 1 space up,down,right or left of the robot. If it finds a lamp it checks if it is closed or not. If it is it continues, otherwise it first closes it and the continues.<br />
After checking all these cells the robot updates the grid with each cell value. Then it selects one of the 4 near cells, moves there and update it's position. <br />
By doing this the robot knows where there are walls, roads, roads that were already walked and lamps. Thus if the robot reaches a dead end, it will simply go backwards and select a path to visit in order to reach a road that is not yet walked. If it cannot find such path then the algorythm is sure that it has explored the entirety of the map and finishes.<br />
Some important things to consider: <br />
-If for some reason the map is divided in sections by walls that do not allow the robot to walk into said section, then the robot will only explore the section/sections that has access to by road.
