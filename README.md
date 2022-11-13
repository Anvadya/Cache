# Cache Simulator

## About Our Simulator
* It is a simulator of a Set-Associative Cache written in Verilog.

## Specifications
* **Type** : Set-Associative (Modifiable to Direct-Map & Fully-Associative).
* **Number of Ways** : Modifiable in CacheController.v
* **Number of Sets** :  Modifiable in CacheController.v
* **Number of Total Blocks** : Modifiable in CacheController.v

## Algorithm used for Replacement Policy
* We have implemented the LRU(Least Recently Used) algorithm for the Replacement of the Block.
* The data of number of hits of a particular block is maintained in the 2-D Frequency Array.

## Uses
* The Simulator can be used to figure out the best design i.e the number of Sets, Ways and Blocks in the Set-Associative Cache for any particular Program.
* For Educational purposes (Eg: To experiment with and enrich the knowledge of Set-Associative Cache)

## How to Use ?

### Requirements 
* Memory trace of the program that you want to test for efficiency.
* Icarus Verilog for Running the Verilog code on your system 
* VS Code with Veriog-HDL Extension for ease of use and Simulation.

### Simulaiting the Trace
* Make a testbench for the Trace you want to test. Example given in sorting.v.
* Now run the simmilator.


# Testing the Simulator
* The following is the graph of Hit-Rate plotted for different Configurations of the Cache for Different Benchmarks from following [link](http://www.cs.toronto.edu/~reid/csc150/02f/a2/traces.html)

### Data

![](https://i.imgur.com/AgMNBMJ.jpg)

### Plot

![](https://i.imgur.com/oSSfhBY.png)
