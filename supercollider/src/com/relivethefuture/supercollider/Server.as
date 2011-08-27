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
package com.relivethefuture.supercollider
{
	import com.relivethefuture.osc.core.IMessageListener;
	import com.relivethefuture.osc.core.OscClient;
	import com.relivethefuture.osc.core.OscDispatcher;
	import com.relivethefuture.osc.core.OscMessage;
	import com.relivethefuture.supercollider.data.ServerStatus;
	import com.relivethefuture.supercollider.events.SCEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	
	import org.spicefactory.lib.logging.LogContext;
	import org.spicefactory.lib.logging.Logger;
	
	[Event(name="connected",type="SCEvent")]
	[Event(name="disconnected",type="SCEvent")]
	public class Server extends EventDispatcher implements IMessageListener
	{
		private static const log:Logger = LogContext.getLogger(Server);
		
		public var host:String = "localhost";
		public var port:uint = 57210;
		
		private var client:OscClient;
		private var dispatcher:OscDispatcher;
		
		private var getStatusMessage:OscMessage;
		
		private var status:ServerStatus;
		
		public function Server(host:String = "localhost", port:uint = 57210)
		{	
			dispatcher = new OscDispatcher();
			dispatcher.addMessageListener("/done",done);
			dispatcher.addMessageListener("/fail",fail);
		
			status = new ServerStatus();
			dispatcher.registerMessageHandler("status.reply",status);	
			getStatusMessage = new OscMessage("/status");
		}

		public function connect():void
		{
			log.debug("Connecting..");
			var c:OscClient = new OscClient(host,port);
			setOscClient(c);
		}
		
		public function disconnect():void
		{
			log.debug("Disconnecting..");
			client.close();
		}
		
		public function getStatusModel():ServerStatus
		{
			return status;
		}
		
		public function addStatusListener(listener:Function):void
		{
			status.addEventListener(SCEvent.SERVER_STATUS,listener);
		}
		
		private function setOscClient(c:OscClient):void
		{
			if(client != null)
			{
				client.removeOscListener(dispatcher);
	            client.removeEventListener(Event.CONNECT, connected);
	            client.removeEventListener(Event.CLOSE, disconnected);
	            client.removeEventListener(IOErrorEvent.IO_ERROR,ioError);
			}
			
			client = c;
			
			client.addOscListener(dispatcher);
            client.addEventListener(Event.CONNECT, connected);
            client.addEventListener(Event.CLOSE, disconnected);
            client.addEventListener(IOErrorEvent.IO_ERROR,ioError);
		}

       	private function connected(event:Event):void
        {
        	log.info("CONNECTED");
        	
        	dispatchEvent(new SCEvent(SCEvent.CONNECTED));
        	
        	// register for notifications
        	var msg:OscMessage = new OscMessage("/notify",1);
        	receiveNotifications(true);
        	client.sendPacketNow(msg);
        }
       	
       	private function disconnected(event:Event):void
       	{
        	log.info("DISCONNECTED");
        	dispatchEvent(new SCEvent(SCEvent.DISCONNECTED));
       	}
       	
        private function ioError(event:IOErrorEvent):void
        {
        	log.error("IO Error : " + event.text);
        }
        
        public function sendMessage(msg:OscMessage):void
        {
        	log.debug("Send Message : " + msg.getAddress());
        	client.sendPacketNow(msg);
        }
        	
		public function receiveNotifications(receive:Boolean):void
		{
			var msg:OscMessage = new OscMessage("/notify");
			msg.addArgument(receive);
			client.sendPacketNow(msg);
		}
		
		public function quit():void
		{
			client.sendPacketNow(new OscMessage("/quit"));
		}
		
		public function getStatus():void
		{
			client.sendPacketNow(getStatusMessage);
		}
		
		public function clearSchedule():void
		{
			client.sendPacketNow(new OscMessage("/clearSched"));
		}
		
		public function handleMessage(msg:OscMessage):void
		{
			log.debug("Handle Message : " + msg.getAddress() + " : " + msg.getTypeTags());
		}
		
		// Messages from the server
		private function done(msg:OscMessage):void
		{
			log.debug("Server says Done");
		}
		
		private function fail(msg:OscMessage):void
		{
			log.warn("Server says Fail");
		}
	}
}