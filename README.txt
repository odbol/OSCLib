OSCLib
OSC Library for Java and others using Apache Mina
By Martin Wood-Mitrovski, 2008 http://relivethefuture.com/
Modified by Tyler Freeman, 2011-2012 http://odbol.com

Original repository at http://www.assembla.com/wiki/show/osclib

*Overview*

Open Sound Control libraries for integrating Flash / Actionscript 3 with Max/MSP, SuperCollider and any other OSC capable system (Reaktor, Plogue Bidule etc..)

Because AS3 doesnt support UDP sockets this library also contains a Java OSC client and server which can be used for providing a bridge between UDP and TCP connections. e.g.

Flash (via TCP) -> Java -> Reaktor (via UDP)

The Java client and server are based on the Apache Mina framework and can easily be used seperately for other purposes.


*Projects in SVN*

Each top level folder in SVN trunk corresponds to a single project (i.e an eclipse or flexbuilder project although you dont have to use those to work with the code)

    AS3

    Low level OSC handling for Actionscript 3.
    AS3 Tests

    Unit tests for the AS3 library
    Java

    Java client and server.
    Max

    A HTTP based OSC handler for max, built using the Java library
    OSCBox

    A set of applications which combine the AS3 OSC libraries with the GoBox project to allow the creation of OSC generating graphical control systems.
    SuperCollider

    AS3 library for working with the SuperCollider server
    SuperCollider Tests

    Unit tests for the Super Collider library

