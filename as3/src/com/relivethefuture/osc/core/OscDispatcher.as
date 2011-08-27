/**
 * Copyright (c) 2008 Martin Wood-Mitrovski
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.relivethefuture.osc.core
{
	import flash.utils.Dictionary;
	
	/**
	 * Handles mapping of OSC Message addresses to listeners.
	 *  
	 * <p>Listeners are either objects or bound methods.</p>
	 * 
	 * <p>e.g. to register an object style listener for /foo/bar messages</p>
	 * 
	 * <code>oscDispatcher.registerHandler("/foo/bar", myOscListener);</code>
	 * 
	 * <p>Where myOscListener is an object which imlements <code>IMessageListener</code></p>
	 * 
	 * <p>For directly registering methods use something like</p>
	 * 
	 * <p><code>oscDispatcher.addMessageListener("/foo/bar", myMethod);</code></p>
	 * 
	 * <p>Where myMethod is defined like this :</p>
	 * 
	 * <p><code>public function myMethod(message:OscMessage):void</code></p>
	 * 
	 * <p>The difference between these two approaches is that the object style
	 * allows you to use one point of contact for incoming messages 
	 * whereas the bound method allows you to distribute incoming messages to
	 * different methods within your client object.</p>
	 * 
	 * <p>The method names used here probably arent the best and will no doubt
	 * change pretty soon :)</p> 
	 */
	public class OscDispatcher implements IOscListener
	{
		// In the listener dictionary keys are message addresses
		// and values are arrays of bound methods to be called
		// when a matching message is received 
		private var listeners:Dictionary;
		
		public function OscDispatcher()
		{
			listeners = new Dictionary(true);
		}

		/**
		 * Add a message handler for a particular address.
		 *  
		 * <p>The listener must implement <code>IMessageListener</code></p>
		 * 
		 * @param	address		any messages with this address will be dispatched to the listener
		 * @param	listener	the class which will handle the messages
		 */
		public function registerMessageHandler(address:String, handler:IMessageListener):void
		{
			addMessageListener(address,handler.handleMessage);
		}
		
		/**
		 * Add a message listener for a particular address.
		 * 
		 * <p>The supplied listener function must accept one
		 * parameter which is the OscMessage</p>
		 * 
		 * <p>e.g. <code>yourMethodHere(message:OscMessage):void</code></p>
		 * 
		 * @param	address		any messages with this address will be passed to the method
		 * @param	listener	the method which will handle the messages
		 */
		public function addMessageListener(address:String, listener:Function):void
		{
			if(listeners[address] == null)
			{
				listeners[address] = [listener];
			}
			else
			{
				listeners[address].push(listener);
			}			
		}
		
		/**
		 * Handle any incoming messages and dispatch them to registered
		 * listeners.
		 * 
		 * @param	message		incoming OSC message
		 */
		public function handleMessage(message:OscMessage):void
		{
			var receivers:Array = listeners[message.getAddress()];
			
			if(receivers == null) return;
			
			for(var i:uint = 0;i<receivers.length;i++)
			{
				receivers[i](message);
			}
		}
		
		/**
		 * Dispatch all messages in the bundle to any matching listeners.
		 * 
		 * <p>Nested bundles are allowed</p>
		 * 
		 * @param	bundle		the OSC bundle
		 */
		public function handleBundle(bundle:OscBundle):void
		{
			var packets:Array = bundle.getPackets();
			for(var i:uint = 0;i<packets.length;i++)
			{
				var p:OscPacket = packets[i];
				if(p.isBundle())
				{
					// Recursively handle OSC bundles
					handleBundle(p as OscBundle);
				}
				else
				{
					// pass the message on to our message handler
					handleMessage(p as OscMessage);
				}
			}
		}
	}
}