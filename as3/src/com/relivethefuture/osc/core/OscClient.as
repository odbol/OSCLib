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
package com.relivethefuture.osc.core {
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	
	import org.spicefactory.lib.logging.LogContext;
	import org.spicefactory.lib.logging.Logger;

	/**
	 * HTTP OSC Client.
	 *
	 * <p>Encodes and decodes OSC Packets from the socket byte stream.</p>
	 * <p>Allows both immediate transmission and queueing of outgoing packets</p>
	 */
	public class OscClient extends Socket {
		private static const log:Logger = LogContext.getLogger(OscClient);

		private var encoder:OscEncoder;
		private var decoder:OscDecoder;

		private var gotHeader:Boolean;
		private var nextMessageSize:int;

		private var queue:Array;

		private var listeners:Array;

		public var useSizeHeader:Boolean = false;
		
		/**
		 * Create a new client.
		 *
		 * <p>If the host and port parameters are supplied then the connection
		 * is made automatically.</p>
		 *
		 * @param	host	server address
		 * @param	port	server port
		 */
		public function OscClient(host:String = null, port:uint = 0) {
			super(host, port);
			encoder = new OscEncoder(false);
			decoder = new OscDecoder();
			addEventListener(ProgressEvent.SOCKET_DATA, responseHandler);

			listeners = [];
			queue = [];
		}

		/**
		 * Send a single OSC packet.
		 *
		 * <p>This method causes the packets to be queued until you
		 * call <code>flush()</code></p>
		 *
		 * @param	packet	the packet to send when the socket is flushed
		 */
		public function sendPacket(packet:OscPacket):void {
			if (log.isDebugEnabled())
				log.debug("Adding packet to queue : " + queue.length + " : " + packet.getSize());

			queue.push(packet);
		}

		/**
		 * Flush the buffer.
		 *
		 * <p>Sends all queued packets that were added via
		 * <code>sendPacket(packet:OscPacket)</code></p>
		 *
		 * <p>All the queued packets are added into a bundle before sending</p>
		 */
		override public function flush():void {
			if (!connected)
				return;

			if (queue.length > 0) {
				if (log.isDebugEnabled())
					log.debug("Flushing " + queue.length + " packets");

				var bundle:OscBundle = new OscBundle(new Date(), queue);
				encoder.encode(bundle, this);
				queue = [];
			}
			super.flush();
		}

		/**
		 * Sends the supplied packet immediately, and also anything in the queue.
		 *
		 * @param packet The OSC Packet to send immediately
		 */
		public function sendPacketNow(packet:OscPacket):void {
			if (log.isDebugEnabled())
				log.debug("Send packet : " + packet.getSize());

			if (connected) {
				// If there is data in the queue, then add this message to the queue 
				if (queue.length > 0) {
					sendPacket(packet);
				}
				else {
					// Otherwise just encode the packet straight into the buffer
					encoder.encode(packet, this);
				}

				// Send all pending data
				flush();
			}
		}

		/**
		 * Incoming data handler.
		 *
		 * @param	event	progress event which lets us know how much data is available
		 */
		private function responseHandler(event:ProgressEvent):void {
			if (log.isDebugEnabled()) {
				log.debug("Event bytesLoaded : " + event.bytesLoaded);
				log.debug("Socket Data bytesAvailable : " + bytesAvailable);
			}

			if(useSizeHeader) {
				if (bytesAvailable > 4) {
					if (!gotHeader) {
						gotHeader = true;
						nextMessageSize = readUnsignedInt();
						if (log.isDebugEnabled())
							log.debug("Next Message Size : " + nextMessageSize);
					}
	
					if (gotHeader && bytesAvailable >= nextMessageSize) {
						decodePacket();
						gotHeader = false;
					}
				}
			} else {
				log.debug("Bytes : " + bytesAvailable);
				decodePacket();
			}
		}

		private function decodePacket():void {
			if (log.isDebugEnabled())
				log.debug("Message has arrived : " + bytesAvailable);
			
			var packet:OscPacket = decoder.decode(this);
			
			if (log.isDebugEnabled())
				log.debug("IN : " + packet.getSize());
			
			for (var i:uint = 0; i < listeners.length; i++) {
				var listener:IOscListener = listeners[i];
				if (packet.isBundle()) {
					listener.handleBundle(packet as OscBundle);
				} else {
					var msg:OscMessage = packet as OscMessage;
					if (log.isDebugEnabled())
						log.debug("decoded OscMessage : " + msg.getAddress() + " : " + msg.getTypeTags());
					listener.handleMessage(msg);
				}
			}
		}
		
		/**
		 * Add a listener for incoming packets.
		 *
		 * @param listener	the object to handle incoming packets
		 */
		public function addOscListener(listener:IOscListener):void {
			if (log.isDebugEnabled())
				log.debug("Add OscListener : " + listener);
			listeners.push(listener);
		}

		/**
		 * remove a previously registered listener.
		 *
		 * @param listener	the object which is currently receiving packets
		 */
		public function removeOscListener(listener:IOscListener):void {
			for (var i:uint = 0; i < listeners.length; i++) {
				if (listeners[i] == listener) {
					listeners.splice(i, 1);
					return;
				}
			}
		}
	}
}