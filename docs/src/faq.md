# Frequently Asked Questions

## How large can I make the network?
This depends mainly on how much memory you have. Fastnet can simulate networks with several million nodes with relative ease. At some point you will see performance drop on the number of hard disk accesses on your operating system will spike. That is the point where Julia runs out of memory and some of the data needs to get parked on the hard disk. By contrast if you have a lot of memory available Fastnet can conceivably simulate sparce networks with billions of nodes. 

## Can I use my own seed / random number generator?
Yes, you can initialize your random number generator however you want and then pass it as an argument in the FastNet constructor. 

## Should I use the fast functions or not?
Use the slow/safe version of Fastnet functions at first. Once everythign runs well switch the function calls in your *rates!* and process functions to the fast versions. 

## Is this the fastest network simulation code?
For adaptive networks it probably is, for other models maybe. It may actually depend on a number of details such as the degree distribution of the network.

## Can this also do higher order networks?
Fundamentally, no. Many of the tricks we use to speed up things would run into natural boundaries. 

## Can I mix directed and undirected links?
Yes you can. 

## How about temporal networks?
Maybe. This isn't what Fastnet was meant for, but you could try to use the FastNet structure without FastSim and instead write your own simulation code, while taking advantage of the fast bookkeeping FastNet provides. 

## I have no clue about Julia. How do I get started
Check out the [tutorial](tutorial.md), particularly the notes on running the example, which are in the final section of the tutorial.

## This crashed Julia. Who do I blame?
Yourself. Switch the fast functions for the slow version, rerun and watch for error messages. Likely your model has a logic error or passes wrong arguments to a function. 

## What do I do if I find a bug? 
Send an email to thilo2gross@gmail.com 

## Can I also contact you if I can't get my model to work
Yes I am happy to help with Fastnet problems, provided you (a) installed Fastnet, (b) read the Tutorial carefully and (c) tried to solve the problem yourself.  




