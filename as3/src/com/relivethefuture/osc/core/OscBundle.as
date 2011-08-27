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
	/**
	 * Actionscript representation of an OSC bundle.
	 * 
	 * <p>An OSC bundle is a timestamped array of OSC packets.<p>
	 * 
	 * <p>The array of packets contained within the bundle may contain other bundles, 
	 * hence a bundle is a recursive structure</p>
	 */
	public class OscBundle implements OscPacket
	{
		public static var BUNDLE_HEADER:String = "#bundle";
		public static var IMMEDIATELY:Date = new Date();
		public static var SECONDS_TO_EPOCH:Number = 2208988800;
		
		private var packets:Array;
		private var timestamp:Date;
		
		private var size:int;
		
		/**
		 * Create a new OSC Bundle.
		 * 
		 * <p>An OSC Bundle is composed of two parts</p>
		 * 
		 * <ol>
		 * <li>Timestamp</li>
		 * <li>List of packets</li>
		 * </ol>
		 * 
		 * <p>The Osc Specification 1.0 defines a time stamp as :<p>
		 *  
		 * <p>Time tags are represented by a 64 bit fixed point number. 
		 * The first 32 bits specify the number of seconds 
		 * since midnight on January 1, 1900, and the last 32 bits 
		 * specify fractional parts of a second to a precision of about 200 picoseconds. 
		 * This is the representation used by Internet NTP timestamps.
		 * The time tag value consisting of 63 zero bits 
		 * followed by a one in the least signifigant bit is a special case meaning "immediately."
		 * </p>
		 *
		 * <p>The packets may be both OSC messages and OSC bundles. Hence a bundle may contain
		 * abitrarily deep nested structures of packets.</p>
		 */ 
		public function OscBundle(timestamp:Date = null,packets:Array = null)
		{
			// Starts at 16 as we always have the #bundle header and a timestamp
			size = 16;
			
			this.packets = [];
			if(packets != null)
			{
				for(var i:int = 0;i<packets.length;i++)
				{
					addPacket(packets[i]);					
				}
			}
			
			if(timestamp == null)
			{
				timestamp = new Date();
			}
			this.timestamp = timestamp; 
		}

		/**
		 * Adds an <code>OscPacket</code> to the bundle.
		 * 
		 * <p>When the packet is added the current bundle size is updated</p>
		 * 
		 * @param	packet	the OscPacket to add to this bundle
		 */
		public function addPacket(packet:OscPacket):void
		{
			size += 4 + packet.getSize();
			packets.push(packet);
		}
		
		/**
		 * Get the array of packets.
		 * 
		 * @return	the array of packets
		 */	
		public function getPackets():Array
		{
			return packets;
		}
		
		/**
		 * Get the timestamp for this bundle.
		 * 
		 * @return	the date for this bundle
		 */ 
		public function getTimestamp():Date
		{
			return timestamp;
		}
		
		/**
		 * Set the timestamp for this bundle.
		 * 
		 * @param	time	when this bundle should be executed
		 */
		public function setTimestamp(time:Date):void
		{
			timestamp = time;
		}
		
		public function isBundle():Boolean
		{
			return true;
		}
		
		/**
		 * Can this bundle be encoded into binary.
		 * 
		 * <p>For a bundle to valid it must have a timestamp and at least 1 packet</p>
		 * 
		 * @return	true if the bundle can be encoded, false otherwise
		 */
		public function isValid():Boolean
		{
			return timestamp != null && packets.length > 0; 
		}
		
		/**
		 * The size (in bytes) of this packet when converted to binary.
		 * 
		 * @return	size in bytes
		 */
		public function getSize():int
		{
			return size;
		}
	}
}